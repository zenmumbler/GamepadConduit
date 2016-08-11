// ------------------------------------------------------------------
// io::mac_MFIdriver - stardazed
// (c) 2016 by Arthur Langereis
// ------------------------------------------------------------------

#include "mac_MFIdriver.h"
#include <math.h>

static void MFIValueCallback(void* context, IOReturn ior, void* userData, IOHIDValueRef value) {
	// -- acquire runtime context
	ControllerDriverContext *controllerCtx = (__bridge ControllerDriverContext*)(context);
	struct ControllerState *controller = controllerCtx.controller;
	
	IOHIDElementRef element = IOHIDValueGetElement(value);
	if (CFGetTypeID(element) != IOHIDElementGetTypeID()) {
		return;
	}
	
	int usage = IOHIDElementGetUsage(element);
	CFIndex elementValue = IOHIDValueGetIntegerValue(value);
	
	// any input exposes the controller
	controller->isExposed = true;
	
	if (usage == 7) {
		// Left Trigger
		float normValue = (float)elementValue / 255.f;
		controller->leftTrigger = normValue;
	}
	else if (usage == 8) {
		// Right Trigger
		float normValue = (float)elementValue / 255.f;
		controller->rightTrigger = normValue;
	}
	else if (usage == 547) {
		// Menu button
		controller->menu.pressed = elementValue == 1;
	}
	else if (usage > 47 && usage < 54) {
		// Thumb Sticks
		float normValue = (float)elementValue / 127.f;
		
		switch (usage) {
			case 48: controller->leftStick.posX  = normValue; break;
			case 49: controller->leftStick.posY  = -normValue; break;
			case 50: controller->rightStick.posX = normValue; break;
			case 53: controller->rightStick.posY = -normValue; break;
		}
	}
	else {
		// Buttons
		struct ButtonState* button = NULL;
		
		switch (usage) {
			case   1: button = &controller->A; break;
			case   2: button = &controller->B; break;
			case   3: button = &controller->X; break;
			case   4: button = &controller->Y; break;
			case   5: button = &controller->leftShoulder; break;
			case   6: button = &controller->rightShoulder; break;
			
			// none of these are present on MFI gamepads
//			case  XX: button = &controller->leftThumb; break;
//			case  XX: button = &controller->rightThumb; break;
//			case  XX: button = &controller->start; break;
//			case  XX: button = &controller->select; break;

			case 144: button = &controller->dPad.up; break;
			case 145: button = &controller->dPad.down; break;
			case 147: button = &controller->dPad.left; break;
			case 146: button = &controller->dPad.right; break;
			default: break;
		}
		
		if (button) {
			button->pressed = elementValue > 5;
		}
	}
}


// A list of Mac-compatible MFI devices (I only have the Nimbus to test)
static uint32_t supportedVendorProductKeys[] = {
	0x01111420, // SteelSeries Nimbus
};


@implementation MFIControllerDriver
- (bool) supportsDevice: (IOHIDDeviceRef)ref vendor: (int)vendorID product: (int)productID {
	uint32_t venPro = (vendorID << 16) | productID;
	
	uint32_t count = sizeof(supportedVendorProductKeys) / sizeof(uint32_t);
	for (unsigned x = 0; x < count; ++x) {
		if (supportedVendorProductKeys[x] == venPro) {
			return true;
		}
	}
	return false;
}

- (IOHIDValueCallback) callbackForDevice: (IOHIDDeviceRef)device vendor: (int)vendorID product: (int)productID {
	return MFIValueCallback;
}
@end
