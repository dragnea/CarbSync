//
//  CSSensor.m
//  CarbSync
//
//  Created by Dragnea Mihai on 11/1/16.
//  Copyright © 2016 Dragnea Mihai. All rights reserved.
//

#import "CSSensor.h"

@implementation CSSensor {
    CSSensorValues sensorValues[4];
}

+ (CSPacketCommand)command {
    return 's';
}

- (void)setBytes:(Byte *)bytes count:(int)count {
    if (count != 8) {
        // malformed packet
    } else {
        CSSensorValues sensor;
        int16_t value;
        for (int s = 0; s < 4; s++) {
            
            value = bytes[s * 2] << 8 | bytes[s * 2 + 1];
            sensor = sensorValues[s];
            
            sensor.nominalValue = value;
            
        }
    }
}

- (id)initWithUnit:(CSSensorUnit)unit {
    if (self = [super init]) {
        _unit = unit;
    }
    return self;
}

- (CSSensorValues)sensorValuesAtIndex:(NSInteger)index {
    return sensorValues[index];
}

@end
