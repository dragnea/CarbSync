//
//  CSBluetoothController.h
//  CarbSync
//
//  Created by Dragnea Mihai on 11/1/16.
//  Copyright © 2016 Dragnea Mihai. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CSBluetoothControllerState) {
    CSBluetoothControllerStateUnknown = 0,
    CSBluetoothControllerStateResetting,
    CSBluetoothControllerStateUnsupported,
    CSBluetoothControllerStateUnauthorized,
    CSBluetoothControllerStatePoweredOff,
    CSBluetoothControllerStatePoweredOn,
};

@class CSBluetoothController;

@protocol CSBluetoothControllerDelegate <NSObject>
- (void)bluetoothControllerDidUpdateState:(CSBluetoothController *)controller;
- (void)bluetoothController:(CSBluetoothController *)controller status:(NSString *)status;
- (void)bluetoothController:(CSBluetoothController *)controller didReceivedByte:(Byte)byte;
@end

@interface CSBluetoothController : NSObject
@property (nonatomic, assign, readonly) CSBluetoothControllerState state;
@property (nonatomic, weak) id<CSBluetoothControllerDelegate>delegate;

- (void)sendByte:(Byte)byte;

@end
