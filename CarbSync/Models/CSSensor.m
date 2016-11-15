//
//  CSSensor.m
//  CarbSync
//
//  Created by Dragnea Mihai on 11/1/16.
//  Copyright © 2016 Dragnea Mihai. All rights reserved.
//

#import "CSSensor.h"

const int16_t kMinSensorValue = 22;
const int16_t kMaxSensorValue = 946 - kMinSensorValue;

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
        // load values
        float values[4];
        float mediumValue = 0.0f;
        for (int s = 0; s < 4; s++) {
            int16_t value = (bytes[s * 2] << 8 | bytes[s * 2 + 1]);
            value = kMaxSensorValue - MIN(kMaxSensorValue, value - kMinSensorValue);
            values[s] = (float)value / kMaxSensorValue;
            mediumValue += values[s];
        }
        
        // process values
        mediumValue = mediumValue / 4.0f;
        for (int s = 0; s < 4; s++) {
            
            float value = sensorValues[s].desiredValue + values[s] - mediumValue;
            sensorValues[s].minValue = MIN(value, sensorValues[s].minValue);
            sensorValues[s].nominalValue = value;
            sensorValues[s].maxValue = MAX(value, sensorValues[s].maxValue);
            
        }
    }
}

- (id)initWithUnit:(CSSensorUnit)unit {
    if (self = [super init]) {
        _unit = unit;
        for (int i = 0; i < 4; i++) {
            sensorValues[i] = (CSSensorValues){0.5f, 0.5f, 0.5f, 0.5f};
        }
    }
    return self;
}

- (CSSensorValues)sensorValuesAtIndex:(NSInteger)index {
    return sensorValues[index];
}

@end
