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
@property (nonatomic, weak) IBOutlet UIButton *unitButton;
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
    
    _sensors = [[CSSensor alloc] init];
    _version = [[CSVersion alloc] init];
    
    _packetDecoder = [[CSPacketDecoder alloc] init];
    _packetDecoder.delegate = self;
    
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkTick:)];
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
    [self setUnit:[[NSUserDefaults standardUserDefaults] integerForKey:@"display_unit"]];
}

- (void)setUnit:(CSVacuumViewUnit)unit {
    for (CSVacuumView *vacuumGauge in self.vacuumGauges) {
        vacuumGauge.unit = unit;
    }
    [self.unitButton setTitle:[CSVacuumView stringForUnit:unit] forState:UIControlStateNormal];
    [[NSUserDefaults standardUserDefaults] setInteger:unit forKey:@"display_unit"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)vacuumViewTouched:(CSVacuumView *)sender {
    sender.selected = !sender.selected;
    for (CSVacuumView *vacuumView in self.vacuumGauges) {
        if (vacuumView != sender) {
            vacuumView.selected = NO;
        }
    }
    if (sender.selected) {
        self.sensors.referenceSensor = sender.tag;
    } else {
        self.sensors.referenceSensor = -1;
    }
}

- (IBAction)unitButtonTouched:(id)sender {
    UIAlertController *unitActionSheet = [UIAlertController alertControllerWithTitle:@"Select unit" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [unitActionSheet addAction:[UIAlertAction actionWithTitle:[CSVacuumView stringForUnit:CSVacuumViewUnit_kPa]
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
                                                          [self setUnit:CSVacuumViewUnit_kPa];
                                                      }]];
    [unitActionSheet addAction:[UIAlertAction actionWithTitle:[CSVacuumView stringForUnit:CSVacuumViewUnit_mmHg]
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
                                                          [self setUnit:CSVacuumViewUnit_mmHg];
                                                      }]];
    [unitActionSheet addAction:[UIAlertAction actionWithTitle:[CSVacuumView stringForUnit:CSVacuumViewUnit_mBar]
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
                                                          [self setUnit:CSVacuumViewUnit_mBar];
                                                      }]];
    [unitActionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:unitActionSheet animated:YES completion:nil];
    
}

- (void)start {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.bluetoothControler sendByte:'v'];
    });
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
        case CSBluetoothControllerStateScaning:
            self.rssiView.status = CSRSSIStatus_scaning;
            break;
        case CSBluetoothControllerStateConnecting:
            self.rssiView.status = CSRSSIStatus_connecting;
            break;
        case CSBluetoothControllerStateConnected:
            self.rssiView.status = CSRSSIStatus_connected;
            [self start];
            break;
            
        case CSBluetoothControllerStateUnknown:
        default:
            
            break;
    }
}

- (void)bluetoothControllerDidUpdateRSSI:(CSBluetoothController *)controller {
    self.rssiView.rssi = controller.rssi;
}

- (void)bluetoothController:(CSBluetoothController *)controller error:(NSError *)error {
    NSLog(@"CSBluetoothController: %@", error);
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
    NSLog(@"CSPacketDecoder: %@", error);
}

- (void)displayLinkTick:(CADisplayLink *)displayLink {
    for (CSVacuumView *vacuumGauge in self.vacuumGauges) {
        [vacuumGauge updateValues:[self.sensors sensorValuesAtIndex:vacuumGauge.tag]];
    }
}

@end
