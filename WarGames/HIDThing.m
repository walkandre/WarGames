//
//  HIDThing.m
//  WarGames
//
//  Created by Andre Cardozo on 2/15/13.
//  Copyright (c) 2013 rga. All rights reserved.
//

#import "HIDThing.h"

#include <IOKit/IOKitLib.h>
#include <IOKit/hid/IOHIDLib.h>
#include <IOKit/hid/IOHIDDevice.h>
#include <IOKit/hid/IOHIDKeys.h>

@implementation HIDThing

IOHIDManagerRef         hid_manager;
CFMutableDictionaryRef  dict;
IOReturn                ret;
CFSetRef                device_set;
IOHIDDeviceRef          device_list[256];
int                     num_devices;
uint8_t                 *buf;
uint8_t                 *send_buf;
IOHIDDeviceRef          dev_ref;
boolean_t               connected = false;

- (id)init {
  self = [super init];
  if (self) {

  }
  return self;
}

- (void) check_hid
{
  // get access to the HID Manager
  hid_manager = IOHIDManagerCreate(kCFAllocatorDefault, kIOHIDOptionsTypeNone);
  if (hid_manager == NULL || CFGetTypeID(hid_manager) != IOHIDManagerGetTypeID()) {
    NSLog(@"HID: unable to access HID manager");

    return;
  }

  dict = IOServiceMatching(kIOHIDDeviceKey);
  if (dict == NULL) {
    NSLog(@"HID: unable to create iokit dictionary");

    return;
  }

  int product_id = 0x1010;
  int vendor_id  = 0x2123;

  if (product_id > 0) {
    CFDictionarySetValue(dict, CFSTR(kIOHIDProductIDKey), CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &product_id));
  }

  if (vendor_id > 0) {
    CFDictionarySetValue(dict, CFSTR(kIOHIDVendorIDKey), CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &vendor_id));
  }

  IOHIDManagerSetDeviceMatching(hid_manager, dict);

  // now open the HID manager
  ret = IOHIDManagerOpen(hid_manager, kIOHIDOptionsTypeNone);
  if (ret != kIOReturnSuccess) {
    NSLog(@"HID: Unable to open HID manager (IOHIDManagerOpen failed)");

    return;
  }

  // get a list of devices that match our requirements
  device_set = IOHIDManagerCopyDevices(hid_manager);
  if (device_set == NULL) {
    NSLog(@"HID: No Devices Found.");

    return;
  }

  num_devices = (int)CFSetGetCount(device_set);

  // NSLog(@"number of devices found = %d\n", num_devices);

  if (num_devices < 1) {
    CFRelease(device_set);
    NSLog(@"HID/macos: no devices found, even though HID manager returned a set\n");
    NSLog(@"No Devices Found though HID manager returned a set");

    return;
  }

  CFSetGetValues(device_set, (const void **)&device_list);
  CFRelease(device_set);

  // open the first device in the list
  ret = IOHIDDeviceOpen(device_list[0], kIOHIDOptionsTypeNone);
  if (ret != kIOReturnSuccess) {
    NSLog(@"HID: error opening device\n");

    return;
  }

  buf = (uint8_t *) malloc(0x1000);

  if (buf == NULL) {
    IOHIDDeviceRegisterRemovalCallback(device_list[0], NULL, NULL);
    IOHIDDeviceClose(device_list[0], kIOHIDOptionsTypeNone);

    NSLog(@"HID: Unable to allocate memory\n");

    return;
  }

  dev_ref = device_list[0];

  // register a callback to receive input
  IOHIDDeviceRegisterInputReportCallback(dev_ref, buf, 0x1000, input_callback, NULL);

  // register a callback to find out when it's unplugged
  IOHIDDeviceScheduleWithRunLoop(dev_ref, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
  IOHIDDeviceRegisterRemovalCallback(dev_ref, unplug_callback, NULL);
}

- (void) on {

  send_buf = (uint8_t *) malloc(64);
  send_buf[0] = 0x03;
  send_buf[1] = 0x01;

  IOHIDDeviceSetReport(dev_ref, kIOHIDReportTypeOutput, send_buf[0], (unsigned char*) send_buf, sizeof(send_buf) + 1);
  
}

- (void) off {

  send_buf = (uint8_t *) malloc(64);
  send_buf[0] = 0x03;
  send_buf[1] = 0x00;
  
  IOHIDDeviceSetReport(dev_ref, kIOHIDReportTypeOutput, send_buf[0], (unsigned char*) send_buf, sizeof(send_buf) + 1);
  
}

- (void) led:(BOOL) state {
  
}

- (void) move {
  /*
   
   # Protocol command bytes
   DOWN    = 0x01
   UP      = 0x02
   LEFT    = 0x04
   RIGHT   = 0x08
   FIRE    = 0x10
   STOP    = 0x20
   
   */
  send_buf = (uint8_t *) malloc(64);
  send_buf[0] = 0x02;
  send_buf[1] = 0x04;
  
  IOHIDDeviceSetReport(dev_ref, kIOHIDReportTypeOutput, send_buf[0], (unsigned char*) send_buf, sizeof(send_buf) + 1);
  
}

static void input_callback(void *context, IOReturn result, void *sender, IOHIDReportType type, uint32_t reportID, uint8_t *report, CFIndex reportLength)
{
  // NSLog(@"Connected! \n");

  connected = true;
  
}
static void unplug_callback(void *hid, IOReturn ret, void *ref)
{
  // NSLog(@"NOT Connected! \n");

  connected = false;
}


-(void) shootWithCommands:(NSArray*) commands {

  NSLog(@"Shooting with commands! \n");

  // if(!connected) return;
  
  
  [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(nextCommand) userInfo:nil repeats:NO];
  
}

-(void) nextCommand {
  
}





@end
