//
//  CSBluetoothController.h
//  CarbSync
//
//  Created by Dragnea Mihai on 11/1/16.
//  Copyright © 2016 Dragnea Mihai. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSErrorDomain const CSBluetoothControllerErrorDomain;
extern NSInteger const CSBluetoothControllerErrorCode_weakRSSI;
extern NSInteger const CSBluetoothControllerErrorCode_wrongDevice;
extern NSInteger const CSBluetoothControllerErrorCode_connectionFailure;

typedef NS_ENUM(NSInteger, CSBluetoothControllerState) {
    CSBluetoothControllerStateUnknown = 0,
    CSBluetoothControllerStateResetting,
    CSBluetoothControllerStateUnsupported,
    CSBluetoothControllerStateUnauthorized,
    CSBluetoothControllerStatePoweredOff,
    CSBluetoothControllerStatePoweredOn,
    CSBluetoothControllerStateScaning,
    CSBluetoothControllerStateConnecting,
    CSBluetoothControllerStateConnected
};

@class CSBluetoothController;

@protocol CSBluetoothControllerDelegate <NSObject>
- (void)bluetoothControllerDidUpdateState:(CSBluetoothController *)controller;
- (void)bluetoothController:(CSBluetoothController *)controller error:(NSError *)error;
- (void)bluetoothController:(CSBluetoothController *)controller didReceivedByte:(Byte)byte;
- (void)bluetoothControllerDidUpdateRSSI:(CSBluetoothController *)controller;
@end

@interface CSBluetoothController : NSObject
@property (nonatomic, strong, readonly) NSNumber *rssi;
@property (nonatomic, assign, readonly) CSBluetoothControllerState state;
@property (nonatomic, weak) id<CSBluetoothControllerDelegate>delegate;

- (void)sendByte:(Byte)byte;

@end
