// ------------------------------------------------------------------
// controller - adapted stardazed
// (c) 2016 by Arthur Langereis
// ------------------------------------------------------------------

#ifndef CONTROLLER_H
#define CONTROLLER_H

#import <IOKit/hid/IOHIDLib.h>
#import <Foundation/Foundation.h>


struct ButtonState {
	uint8_t pressed;
};


struct DirectionalPad {
	struct ButtonState left, right, up, down;
};


struct Stick {
	float posX, posY;
};


struct ControllerState {
	BOOL isConnected, isExposed;
	struct Stick leftStick, rightStick;
	struct DirectionalPad dPad;
	struct ButtonState A, B, X, Y, leftShoulder, rightShoulder;
	struct ButtonState leftThumb, rightThumb;
	struct ButtonState select, start, menu;
	float leftTrigger, rightTrigger;
};


uint32_t packedButtonsState(struct ControllerState* const cs);


// ------


@protocol ControllerDriver <NSObject>
- (bool) supportsDevice: (IOHIDDeviceRef)ref vendor: (int)vendorID product: (int)productID;
- (IOHIDValueCallback) callbackForDevice: (IOHIDDeviceRef)device vendor: (int)vendorID product: (int)productID;
@end


@class ControllerDriverContext;


@interface Controller : NSObject
- (instancetype)init;
- (bool)enabled: (unsigned)index;
- (struct ControllerState*) state: (unsigned)index NS_RETURNS_INNER_POINTER;
@property (NS_NONATOMIC_IOSONLY, readonly) unsigned int count;
@property (NS_NONATOMIC_IOSONLY, readonly, strong) ControllerDriverContext *createController;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray<id<ControllerDriver>> *drivers;
@end


@interface ControllerDriverContext : NSObject 
-(instancetype)initWithController: (Controller*)controller;
@property (NS_NONATOMIC_IOSONLY, readonly) struct ControllerState *controller;
@property Controller *context;
@end


#endif
