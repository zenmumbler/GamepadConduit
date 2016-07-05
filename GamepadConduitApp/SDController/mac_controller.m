// ------------------------------------------------------------------
// io::mac_controller - stardazed
// (c) 2016 by Arthur Langereis
// ------------------------------------------------------------------

#include "mac_controller.h"
#include "mac_360driver.h"

#import <IOKit/hid/IOHIDLib.h>
#import <Foundation/Foundation.h>


static void hidDeviceRemoved(void* context, IOReturn ior, void* userRef) {
	ControllerDriverContext *controllerCtx = (__bridge ControllerDriverContext*)(context);
	struct ControllerState* cs = controllerCtx.controller;
	cs->isConnected = false;
}


static void hidDeviceAdded(void* context, IOReturn ior, void* userRef, IOHIDDeviceRef device) {
	Controller *devCtx = (__bridge Controller*)(context);
	
	// -- get the vendor and product ID for quick identification
	CFNumberRef vendorIDRef = (CFNumberRef)IOHIDDeviceGetProperty(device, CFSTR(kIOHIDVendorIDKey));
	CFNumberRef productIDRef = (CFNumberRef)IOHIDDeviceGetProperty(device, CFSTR(kIOHIDProductIDKey));
	
	int vendorID, productID;
	CFNumberGetValue(vendorIDRef, kCFNumberIntType, &vendorID);
	CFNumberGetValue(productIDRef, kCFNumberIntType, &productID);
	
	// -- find if we have a registered driver that knows this controller
	NSArray<id<ControllerDriver>>* drivers = [devCtx drivers];
	NSUInteger foundIndex = [drivers indexOfObjectPassingTest:^BOOL(id<ControllerDriver> _Nonnull driver, NSUInteger idx, BOOL * _Nonnull stop) {
		BOOL supported = [driver supportsDevice:device vendor:vendorID product:productID];
		*stop = supported;
		return supported;
	}];

	// -- open device for comms and register callbacks
	if (foundIndex != NSNotFound) {
		if (IOHIDDeviceOpen(device, kIOHIDOptionsTypeNone) == kIOReturnSuccess) {
			id<ControllerDriver> driver = [drivers objectAtIndex:foundIndex];
			ControllerDriverContext *controllerCtx = [devCtx createController];
			IOHIDValueCallback callback = [driver callbackForDevice:device vendor: vendorID product: productID];
			
			IOHIDDeviceRegisterInputValueCallback(device, callback, (__bridge void * _Nullable)(controllerCtx));
			IOHIDDeviceRegisterRemovalCallback(device, hidDeviceRemoved, (__bridge void * _Nullable)(controllerCtx));
			
			NSLog(@"Detected Usable Controller/Gamepad, vendorID: %d; productID: %d", vendorID, productID);
		}
		else {
			// FIXME: can't open device communications, log
			NSLog(@"Could not communicate with Controller/Gamepad, vendorID: %d; productID: %d", vendorID, productID);
		}
	}
	else {
		// FIXME: no suitable driver found, report or log
		NSLog(@"Unknown Controller/Gamepad, vendorID: %d; productID: %d", vendorID, productID);
	}
}


@implementation ControllerDriverContext
struct ControllerState state_ = {};

-(instancetype)initWithController: (Controller*)controller {
	self.context = controller;
	return self;
}

-(struct ControllerState*)controller {
	return &state_;
}

@end


@implementation Controller

NSMutableArray<id<ControllerDriver>> *controllerDrivers_;
NSMutableArray<ControllerDriverContext*> *controllers_;
IOHIDManagerRef hidManager_;

- (instancetype)init {
	// -- register the controller drivers
	controllerDrivers_ = [[NSMutableArray alloc] init];
	[controllerDrivers_ addObject:[[X360ControllerDriver alloc] init]];

	controllers_ = [[NSMutableArray alloc] init];

	// -- setup the HID manager and callbacks
	hidManager_ = IOHIDManagerCreate(kCFAllocatorDefault, kIOHIDOptionsTypeNone);
	
	NSArray* criteria = @[
		  @{	(NSString*)CFSTR(kIOHIDDeviceUsagePageKey):
					[NSNumber numberWithInt:kHIDPage_GenericDesktop],
				(NSString*)CFSTR(kIOHIDDeviceUsageKey):
					[NSNumber numberWithInt:kHIDUsage_GD_Joystick]
			},
		  @{	(NSString*)CFSTR(kIOHIDDeviceUsagePageKey):
					[NSNumber numberWithInt:kHIDPage_GenericDesktop],
				(NSString*)CFSTR(kIOHIDDeviceUsageKey):
					[NSNumber numberWithInt:kHIDUsage_GD_GamePad]
			},
		  @{	(NSString*)CFSTR(kIOHIDDeviceUsagePageKey):
					[NSNumber numberWithInt:kHIDPage_GenericDesktop],
				(NSString*)CFSTR(kIOHIDDeviceUsageKey):
					[NSNumber numberWithInt:kHIDUsage_GD_MultiAxisController]
			}
	  ];
	
	IOHIDManagerSetDeviceMatchingMultiple(hidManager_, (__bridge CFArrayRef)criteria);
	IOHIDManagerRegisterDeviceMatchingCallback(hidManager_, hidDeviceAdded, (__bridge void * _Nullable)(self));
	IOHIDManagerScheduleWithRunLoop(hidManager_, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);

	return self;
}

- (unsigned)count {
	return (unsigned)controllers_.count;
}

- (bool)enabled:(unsigned)index {
	return index < controllers_.count;
}

- (struct ControllerState*) state:(unsigned)index {
	if (index >= controllers_.count)
		return NULL;
	return [controllers_ objectAtIndex:(index)].controller;
}

- (ControllerDriverContext*)createController {
	ControllerDriverContext* cdc = [[ControllerDriverContext alloc] initWithController:self];
	[controllers_ addObject:cdc];
	return cdc;
}

- (NSArray<id<ControllerDriver>>*)drivers {
	return controllerDrivers_;
}

@end