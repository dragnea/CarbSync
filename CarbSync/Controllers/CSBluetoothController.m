//
//  CSBluetoothController.m
//  CarbSync
//
//  Created by Dragnea Mihai on 11/1/16.
//  Copyright © 2016 Dragnea Mihai. All rights reserved.
//

#import "CSBluetoothController.h"
#import <CoreBluetooth/CoreBluetooth.h>

NSErrorDomain const CSBluetoothControllerErrorDomain = @"CSBluetoothControllerErrorDomain";
NSInteger const CSBluetoothControllerErrorCode_weakRSSI = -1111;
NSInteger const CSBluetoothControllerErrorCode_wrongDevice = -1112;
NSInteger const CSBluetoothControllerErrorCode_connectionFailure = -1113;

static NSString *BLE_DEVICE_UUID = @"C02C34E1-2992-4E2D-A1FE-267DF3455719";
static NSString *SERVICE_SERIAL_UUID = @"FFE0";
static NSString *CHARACTERISTIC_RXTX_UUID = @"FFE1";

@interface CSBluetoothController ()<CBCentralManagerDelegate, CBPeripheralDelegate>
@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *uartPeripheral;
@property (nonatomic, strong) CBCharacteristic *rxtxCharacteristic;
@property (nonatomic, strong) NSTimer *rssiTimer;
@end

@implementation CSBluetoothController

- (id)init {
    if (self = [super init]) {
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    return self;
}

- (void)setState:(CSBluetoothControllerState)state {
    _state = state;
    [self.delegate bluetoothControllerDidUpdateState:self];
    if (state == CBCentralManagerStatePoweredOn) {
        [self scanForPeripherals];
    }
}

- (void)sendError:(NSError *)error {
    [self.delegate bluetoothController:self error:error];
}

- (void)scanForPeripherals {
    [self cleanup];
    [self setState:CSBluetoothControllerStateScaning];
    [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:SERVICE_SERIAL_UUID]] options:@{CBCentralManagerScanOptionAllowDuplicatesKey: @YES}];
}

- (void)rssiTick:(NSTimer *)timer {
    [self.uartPeripheral readRSSI];
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    [self setState:(CSBluetoothControllerState)central.state];
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    if (![peripheral.identifier.UUIDString isEqualToString:BLE_DEVICE_UUID]) {
        [self sendError:[NSError errorWithDomain:CSBluetoothControllerErrorDomain
                                            code:CSBluetoothControllerErrorCode_wrongDevice
                                        userInfo:@{NSLocalizedDescriptionKey: @"Wrong device"}]];
    } else if (RSSI.integerValue > -40) {
        [self sendError:[NSError errorWithDomain:CSBluetoothControllerErrorDomain
                                            code:CSBluetoothControllerErrorCode_weakRSSI
                                        userInfo:@{NSLocalizedDescriptionKey: @"RSSI too weak"}]];
    } else {
        _uartPeripheral = peripheral;
        [self setState:CSBluetoothControllerStateConnecting];
        [central connectPeripheral:peripheral options:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    peripheral.delegate = self;
    [peripheral discoverServices:@[[CBUUID UUIDWithString:SERVICE_SERIAL_UUID]]];
    _rssiTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(rssiTick:) userInfo:nil repeats:YES];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    if (!error) {
        [self sendError:[NSError errorWithDomain:CSBluetoothControllerErrorDomain
                                            code:CSBluetoothControllerErrorCode_connectionFailure
                                        userInfo:@{NSLocalizedDescriptionKey: @"Failed to connect"}]];
    } else {
        [self sendError:error];
    }
    [self scanForPeripherals];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    if (!error) {
        
    } else {
        [self sendError:error];
    }
    [self scanForPeripherals];
}

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error {
    if (!error) {
        if (![_rssi isEqualToNumber:RSSI]) {
            _rssi = RSSI;
            [self.delegate bluetoothControllerDidUpdateRSSI:self];
        }
    } else {
        [self sendError:error];
    }
}

#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (!error) {
        for (CBService *service in peripheral.services) {
            [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:CHARACTERISTIC_RXTX_UUID]] forService:service];
        }
    } else {
        [self sendError:error];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (!error) {
        for (CBCharacteristic *characteristic in service.characteristics) {
            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:CHARACTERISTIC_RXTX_UUID]]) {
                _rxtxCharacteristic = characteristic;
                [self.centralManager stopScan];
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                [self setState:CSBluetoothControllerStateConnected];
            }
        }
    } else {
        [self sendError:error];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (!error) {
        if ([characteristic.UUID.UUIDString.uppercaseString isEqualToString:CHARACTERISTIC_RXTX_UUID]) {
            Byte *bytes = (Byte*)characteristic.value.bytes;
            NSUInteger bytesCount = characteristic.value.length;
            for (NSInteger bytePos = 0; bytePos < bytesCount; bytePos++) {
                [self.delegate bluetoothController:self didReceivedByte:bytes[bytePos]];
            }
        }
    } else {
        [self sendError:error];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
}

- (void)cleanup {
    if (self.uartPeripheral.state != CBPeripheralStateConnected) {
        return;
    }
    [self.rssiTimer invalidate];
    self.rssiTimer = nil;
    _rssi = nil;
    if (self.uartPeripheral.services != nil) {
        for (CBService *service in self.uartPeripheral.services) {
            if (service.characteristics != nil) {
                for (CBCharacteristic *characteristic in service.characteristics) {
                    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:CHARACTERISTIC_RXTX_UUID]]) {
                        if (characteristic.isNotifying) {
                            [self.uartPeripheral setNotifyValue:NO forCharacteristic:characteristic];
                        }
                    }
                }
            }
        }
    }
    
    // If we've got this far, we're connected, but we're not subscribed, so we just disconnect
    [self.centralManager cancelPeripheralConnection:self.uartPeripheral];
}

#pragma mark - Public methods

- (void)sendByte:(Byte)byte {
    [self.uartPeripheral writeValue:[NSData dataWithBytes:&byte length:1] forCharacteristic:self.rxtxCharacteristic type:CBCharacteristicWriteWithoutResponse];
}

@end
