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
@end

@implementation MainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _bluetoothControler = [[CSBluetoothController alloc] init];
    _bluetoothControler.delegate = self;
    
    _sensors = [[CSSensor alloc] initWithUnit:CSSensorUnit_kPa];
    
    _packetDecoder = [[CSPacketDecoder alloc] init];
    _packetDecoder.delegate = self;
    
    for (CSVacuumView *vacuumGauge in self.vacuumGauges) {
        vacuumGauge.indexLabel.text = [NSString stringWithFormat:@"%d", (int)vacuumGauge.tag];
        vacuumGauge.valueLabel.text = [NSString stringWithFormat:@"%dkPa", (int)arc4random_uniform(115)];
    }
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
    } else {
        return nil;
    }
}

- (void)packetDecoder:(CSPacketDecoder *)packetDecoder packetUpdated:(id<CSPacketProtocol>)packet command:(CSPacketCommand)command {
    if (command == [CSSensor command]) {
        // sensors updated
    }
}

- (void)packetDecoder:(CSPacketDecoder *)packetDecoder error:(NSError *)error {
    
}

@end
