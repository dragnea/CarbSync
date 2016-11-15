//
//  MainVC.m
//  CarbSync
//
//  Created by Dragnea Mihai on 9/27/16.
//  Copyright © 2016 Dragnea Mihai. All rights reserved.
//

#import "MainVC.h"
#import "CSBluetoothController.h"
#import "CSPacketDecoder.h"
#import "CSSensor.h"
#import "CSVersion.h"
#import "CSVacuumView.h"
#import "CSRSSIView.h"

@interface MainVC ()<CSBluetoothControllerDelegate, CSPacketDecoderDelegate>
@property (nonatomic, strong) IBOutletCollection(CSVacuumView) NSArray <CSVacuumView *>*vacuumGauges;
@property (nonatomic, weak) IBOutlet CSRSSIView *rssiView;
@property (nonatomic, strong) NSTimer *rssiTimer;
@property (nonatomic, strong) NSTimer *displayTimer;
@property (nonatomic, strong) CSBluetoothController *bluetoothControler;
@property (nonatomic, strong) CSPacketDecoder *packetDecoder;
@property (nonatomic, strong) CSSensor *sensors;
@property (nonatomic, strong) CSVersion *version;
@property (nonatomic, strong) CADisplayLink *displayLink;
@end

@implementation MainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _bluetoothControler = [[CSBluetoothController alloc] init];
    _bluetoothControler.delegate = self;
    
    _sensors = [[CSSensor alloc] initWithUnit:CSSensorUnit_kPa];
    _version = [[CSVersion alloc] init];
    
    _packetDecoder = [[CSPacketDecoder alloc] init];
    _packetDecoder.delegate = self;
    
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkTick:)];
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}


#pragma mark - CSBluetoothControllerDelegate

- (void)bluetoothControllerDidUpdateState:(CSBluetoothController *)controller {
    switch (controller.state) {
        case CSBluetoothControllerStatePoweredOn:
            self.rssiView.status = CSRSSIStatus_active;
            break;
        case CSBluetoothControllerStatePoweredOff:
            self.rssiView.status = CSRSSIStatus_inactive;
            break;
        case CSBluetoothControllerStateResetting:
            self.rssiView.status = CSRSSIStatus_inactive;
            break;
        case CSBluetoothControllerStateUnsupported:
            self.rssiView.status = CSRSSIStatus_inactive;
            break;
        case CSBluetoothControllerStateUnauthorized:
            self.rssiView.status = CSRSSIStatus_inactive;
            break;
        case CSBluetoothControllerStateConnected:
            [controller sendByte:'v'];
            break;
            
        case CSBluetoothControllerStateUnknown:
        default:
            
            break;
    }
}

- (void)bluetoothController:(CSBluetoothController *)controller status:(NSString *)status {
    
}

- (void)bluetoothController:(CSBluetoothController *)controller didReceivedByte:(Byte)byte {
    [self.packetDecoder addByte:byte];
}

#pragma mark - CSPacketDecoderDelegate

- (id<CSPacketProtocol>)packetDecoder:(CSPacketDecoder *)packetDecoder packetWithCommand:(CSPacketCommand)command {
    if (command == [CSSensor command]) {
        return _sensors;
    } else if (command == [CSVersion command]) {
        return _version;
    } else {
        return nil;
    }
}

- (void)packetDecoder:(CSPacketDecoder *)packetDecoder packetUpdated:(id<CSPacketProtocol>)packet command:(CSPacketCommand)command {
    if (command == [CSSensor command]) {
        
    } else if (command == [CSVersion command]) {
        [self.bluetoothControler sendByte:'s'];
    } else {
        
    }
}

- (void)packetDecoder:(CSPacketDecoder *)packetDecoder error:(NSError *)error {
    
}

- (void)displayLinkTick:(CADisplayLink *)displayLink {
    for (CSVacuumView *vacuumGauge in self.vacuumGauges) {
        CSSensorValues values = [self.sensors sensorValuesAtIndex:vacuumGauge.tag];
        [vacuumGauge updateMinValue:values.minValue value:values.nominalValue desiredValue:values.desiredValue maxValue:values.maxValue];
    }
}

@end
