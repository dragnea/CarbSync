//
//  CSBluetoothController.m
//  CarbSync
//
//  Created by Dragnea Mihai on 11/1/16.
//  Copyright © 2016 Dragnea Mihai. All rights reserved.
//

#import "CSBluetoothController.h"
#import <CoreBluetooth/CoreBluetooth.h>

static NSString *BLE_DEVICE_UUID = @"C02C34E1-2992-4E2D-A1FE-267DF3455719";
static NSString *SERVICE_SERIAL_UUID = @"FFE0";
static NSString *CHARACTERISTIC_RXTX_UUID = @"FFE1";

@interface CSBluetoothController ()<CBCentralManagerDelegate, CBPeripheralDelegate>
@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *uartPeripheral;
@property (nonatomic, strong) CBCharacteristic *rxtxCharacteristic;
@end

@implementation CSBluetoothController

- (id)init {
    if (self = [super init]) {
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    return self;
}

- (void)scanForPeripherals {
    [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:SERVICE_SERIAL_UUID]] options:@{CBCentralManagerScanOptionAllowDuplicatesKey: @YES}];
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    _state = (CSBluetoothControllerState)central.state;
    if (_state == CBCentralManagerStatePoweredOn) {
        [self scanForPeripherals];
    }
    [self.delegate bluetoothControllerDidUpdateState:self];
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    if (![peripheral.identifier.UUIDString isEqualToString:BLE_DEVICE_UUID]) {
        // TODO: send 'unknown bluetooth hardware'
    } else if (RSSI.integerValue > -40) {
        // TODO: send 'signal too weak to connect'
    } else {
        _uartPeripheral = peripheral;
        [central connectPeripheral:peripheral options:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    // TODO: send 'connected'
    peripheral.delegate = self;
    [peripheral discoverServices:@[[CBUUID UUIDWithString:SERVICE_SERIAL_UUID]]];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    if (!error) {
        // TODO: send 'failed to connect'
    } else {
        // TODO: send 'failed to connect' with description
    }
    [self scanForPeripherals];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    if (!error) {
        // TODO: cleanup
        [self scanForPeripherals];
    } else {
        // TODO: send 'failed to disconnect' with description
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error {
    if (!error) {
        _rssi = RSSI;
    } else {
        // TODO: handle RSSI read error
    }
}

#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (!error) {
        for (CBService *service in peripheral.services) {
            [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:CHARACTERISTIC_RXTX_UUID]] forService:service];
        }
    } else {
        // TODO: send 'failed to discover uart service' with description
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (!error) {
        for (CBCharacteristic *characteristic in service.characteristics) {
            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:CHARACTERISTIC_RXTX_UUID]]) {
                _rxtxCharacteristic = characteristic;
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                _state = CSBluetoothControllerStateConnected;
                [self.centralManager stopScan];
                [self.delegate bluetoothControllerDidUpdateState:self];
            }
        }
    } else {
        // TODO: send 'failed to discover rxtx characteristic' with description
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
        // TODO: handle RX value error
    }
}

- (void)cleanup {
    if (self.uartPeripheral.state != CBPeripheralStateConnected) {
        return;
    }
    
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
