// ------------------------------------------------------------------
// io::mac_MFIdriver - stardazed
// (c) 2016 by Arthur Langereis
// ------------------------------------------------------------------

#ifndef SD_IO_MAC_MFIDRIVER_H
#define SD_IO_MAC_MFIDRIVER_H

#include "mac_controller.h"

@interface MFIControllerDriver : NSObject<ControllerDriver>
- (bool) supportsDevice: (IOHIDDeviceRef)ref vendor: (int)vendorID product: (int)productID;
- (IOHIDValueCallback) callbackForDevice: (IOHIDDeviceRef)device vendor: (int)vendorID product: (int)productID;
@end

#endif
