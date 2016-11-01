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
@property (nonatomic, weak) CBPeripheral *uartPeripheral;
@property (nonatomic, weak) CBCharacteristic *rxtxCharacteristic;
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
    if ([self.delegate respondsToSelector:@selector(bluetoothControllerDidUpdateState:)]) {
        [self.delegate bluetoothControllerDidUpdateState:self];
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    if (![peripheral.identifier isEqual:[CBUUID UUIDWithString:BLE_DEVICE_UUID]]) {
        // TODO: send 'unknown bluetoot hardware'
    } else if (RSSI.integerValue > 40) {
        // TODO: send 'signal too weak to connect'
    } else {
        [central connectPeripheral:peripheral options:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    // TODO: send 'connected'
    _uartPeripheral = peripheral;
    peripheral.delegate = self;
    [peripheral discoverServices:@[[CBUUID UUIDWithString:SERVICE_SERIAL_UUID]]];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    if (!error) {
        // TODO: send 'failed to connect'
    } else {
        // TODO: send 'failed to connect' with description
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    if (!error) {
        // TODO: cleanup
    } else {
        // TODO: send 'failed to disconnect' with description
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
            }
        }
    } else {
        // TODO: send 'failed to discover rxtx characteristic' with description
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (!error) {
        
    } else {
        // TODO: handle RX value error
    }
}

#pragma mark - Public methods

- (void)sendByte:(Byte)byte {
    [self.uartPeripheral writeValue:[NSData dataWithBytes:&byte length:1] forCharacteristic:self.rxtxCharacteristic type:CBCharacteristicWriteWithoutResponse];
}

@end
