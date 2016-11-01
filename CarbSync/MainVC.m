//
//  MainVC.m
//  CarbSync
//
//  Created by Dragnea Mihai on 9/27/16.
//  Copyright © 2016 Dragnea Mihai. All rights reserved.
//

#import "MainVC.h"
#import "RSSIView.h"
#import "VacuumGaugeView.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "PacketDecoder.h"

static NSString *BLE__DEVICE_UUID = @"C02C34E1-2992-4E2D-A1FE-267DF3455719";
static NSString *SERVICE_SERIAL_UUID = @"FFE0";
static NSString *CHARACTERISTIC_RXTX_UUID = @"FFE1";


@interface MainVC ()<CBCentralManagerDelegate, CBPeripheralDelegate>
@property (nonatomic, weak) IBOutlet VacuumGaugeView *bar1;
@property (nonatomic, weak) IBOutlet VacuumGaugeView *bar2;
@property (nonatomic, weak) IBOutlet VacuumGaugeView *bar3;
@property (nonatomic, weak) IBOutlet VacuumGaugeView *bar4;
@property (nonatomic, weak) IBOutlet RSSIView *rssiView;
@property (nonatomic, weak) IBOutlet UILabel *statusLabel;

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) CBCharacteristic *txCharacteristic;
@property (nonatomic, strong) NSTimer *rssiTimer;
@property (nonatomic, strong) NSTimer *displayTimer;
@property (nonatomic, strong) PacketDecoder *packetDecoder;
@end

@implementation MainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _packetDecoder = [[PacketDecoder alloc] init];
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    self.statusLabel.text = @"Searching bluetooth module";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendAt:(id)sender {
    //[_peripheral writeValue:[@"A" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:_txCharacteristic type:CBCharacteristicWriteWithoutResponse];
    
}

- (void)scan {
    [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:SERVICE_SERIAL_UUID]] options:nil];//@{CBCentralManagerScanOptionAllowDuplicatesKey: @YES}];
}

- (void)timerUpdateRSSI:(NSTimer *)timer {
    [self.peripheral readRSSI];
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBManagerStatePoweredOn:
            self.statusLabel.text = @"Scaning for device";
            [self scan];
            break;
        case CBManagerStatePoweredOff:
            self.statusLabel.text = @"Bluetooth inactive";
            break;
        case CBManagerStateResetting:
            self.statusLabel.text = @"Resetting bluetooth";
            break;
        case CBManagerStateUnsupported:
            self.statusLabel.text = @"Bluetooth unsupported";
            break;
        case CBManagerStateUnauthorized:
            self.statusLabel.text = @"Bluetooth unauthorized";
            break;
            
        case CBManagerStateUnknown:
        default:
            
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    if ([peripheral.identifier.UUIDString.uppercaseString isEqualToString:BLE__DEVICE_UUID] && self.peripheral != peripheral) {
        self.peripheral = peripheral;
        self.statusLabel.text = [NSString stringWithFormat:@"Connecting..."];
        NSLog(@"BluetoothController: Connecting to peripheral: %@ (%@)", peripheral.name, peripheral.identifier);
        [central connectPeripheral:peripheral options:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    self.statusLabel.text = [NSString stringWithFormat:@"Connected"];
    NSLog(@"BluetoothController: Connected to peripheral %@ (%@)", peripheral.name, peripheral.identifier);
    [central stopScan];
    peripheral.delegate = self;
    [peripheral discoverServices:@[[CBUUID UUIDWithString:SERVICE_SERIAL_UUID]]];
    self.rssiTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(timerUpdateRSSI:) userInfo:nil repeats:YES];
    self.displayTimer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(refreshDisplay:) userInfo:nil repeats:YES];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"BluetoothController: Disconnected %@ (%@). With error: %@", peripheral.name, peripheral.identifier, error.localizedDescription);
    self.statusLabel.text = @"Disconnected";
    self.peripheral = nil;
    [self.rssiTimer invalidate];
    self.rssiTimer = nil;
    self.rssiView.rssi = nil;
    [self.displayTimer invalidate];
    self.displayTimer = nil;
    [self scan];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"BluetoothController: Failed to connect to peripheral. %@", error.localizedDescription);
    [self cleanup];
}

#pragma mark - CBPeripheralDelegate

- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray<CBService *> *)invalidatedServices {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error {
    if (!error) {
        self.rssiView.rssi = RSSI;
    } else {
        NSLog(@"BluetoothController: Error reading RSSI. %@", error.localizedDescription);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    for (CBService *service in peripheral.services) {
        if ([service.UUID.UUIDString.uppercaseString isEqualToString:SERVICE_SERIAL_UUID]) {
            [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:CHARACTERISTIC_RXTX_UUID]] forService:service];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    NSLog(@"descriptor (%@) = %@", descriptor.UUID.UUIDString, descriptor.value);
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"write (%@) = %@", characteristic.UUID.UUIDString, [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding]);
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (!error) {
        if ([characteristic.UUID.UUIDString.uppercaseString isEqualToString:CHARACTERISTIC_RXTX_UUID]) {
            Byte byte;
            for (NSInteger bytePos = 0; bytePos < characteristic.value.length; bytePos++) {
                [characteristic.value getBytes:&byte range:NSMakeRange(bytePos, 1)];
                [self.packetDecoder addByte:byte];
            }
        }
    } else {
        NSLog(@"BlutoothController: UpdateValueForCharacteristic error. %@", error.localizedDescription);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (!error) {
        if (characteristic.isNotifying) {
            //NSLog(@"notify (%@) = %@", characteristic.UUID.UUIDString, characteristic.value);
            
            
            
        } else {
            NSLog(@"BlutoothController: Notification stopped. Disconnecting");
            [self.centralManager cancelPeripheralConnection:peripheral];
        }
    } else {
        NSLog(@"BlutoothController: Notification error. %@", error.localizedDescription);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (!error) {
        if ([service.UUID.UUIDString.uppercaseString isEqualToString:SERVICE_SERIAL_UUID]) {
            for (CBCharacteristic *characteristic in service.characteristics) {
                if ([characteristic.UUID.UUIDString isEqualToString:CHARACTERISTIC_RXTX_UUID] && (characteristic.properties & CBCharacteristicPropertyWriteWithoutResponse)) {
                    _txCharacteristic = characteristic;
                    [self.peripheral setNotifyValue:YES forCharacteristic:characteristic];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self readSensors];
                    });
                }
            }
        }
    } else {
        NSLog(@"BlutoothController: Error discovering characteristics. %@", error.localizedDescription);
        [self cleanup];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    for (CBDescriptor *descriptor in characteristic.descriptors) {
        [peripheral readValueForDescriptor:descriptor];
    }
}

- (void)cleanup {
    if (self.peripheral.state != CBPeripheralStateConnected) {
        return;
    }
    
    if (self.peripheral.services != nil) {
        for (CBService *service in self.peripheral.services) {
            if (service.characteristics != nil) {
                for (CBCharacteristic *characteristic in service.characteristics) {
                    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:CHARACTERISTIC_RXTX_UUID]]) {
                        if (characteristic.isNotifying) {
                            [self.peripheral setNotifyValue:NO forCharacteristic:characteristic];
                        }
                    }
                }
            }
        }
    }
    
    // If we've got this far, we're connected, but we're not subscribed, so we just disconnect
    [self.centralManager cancelPeripheralConnection:self.peripheral];
}

#pragma mark - Start

- (void)readSensors {
    [self.peripheral writeValue:[@"s" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.txCharacteristic type:CBCharacteristicWriteWithoutResponse];
}

- (void)refreshDisplay:(NSTimer *)timer {
    self.bar1.value = self.packetDecoder.values[0].integerValue;
    self.bar2.value = self.packetDecoder.values[1].integerValue;
    self.bar3.value = self.packetDecoder.values[2].integerValue;
    self.bar4.value = self.packetDecoder.values[3].integerValue;
}

@end
