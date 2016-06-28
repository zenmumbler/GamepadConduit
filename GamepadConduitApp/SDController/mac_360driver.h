// ------------------------------------------------------------------
// io::mac_360driver - stardazed
// (c) 2016 by Arthur Langereis
// ------------------------------------------------------------------

#ifndef SD_IO_MAC_360DRIVER_H
#define SD_IO_MAC_360DRIVER_H

#include "mac_controller.h"

@interface X360ControllerDriver : NSObject<ControllerDriver>
	- (bool) supportsDevice: (IOHIDDeviceRef)ref vendor: (int)vendorID product: (int)productID;
	- (IOHIDValueCallback) callbackForDevice: (IOHIDDeviceRef)device vendor: (int)vendorID product: (int)productID;
@end

#endif
