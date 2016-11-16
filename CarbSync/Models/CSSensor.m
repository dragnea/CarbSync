//
//  CSSensor.m
//  CarbSync
//
//  Created by Dragnea Mihai on 11/1/16.
//  Copyright © 2016 Dragnea Mihai. All rights reserved.
//

#import "CSSensor.h"

#define MED(A, B) (A + B) / 2

const int16_t kMinSensorValue = 22;
const int16_t kMaxSensorValue = 946 - kMinSensorValue;

@implementation CSSensor {
    CSSensorValues sensorValues[CSSensorCount];
}

+ (CSPacketCommand)command {
    return 's';
}

float smooth(float oldValue, float newValue, int samples) {
    return newValue / samples + oldValue * (1.0f - 1.0f / samples);
}

- (void)setBytes:(Byte *)bytes count:(int)count {
    if (count != 8) {
        // malformed packet
    } else {
        // load values
        float averageValue = 0.0f;
        for (int s = 0; s < CSSensorCount; s++) {
            int16_t value = (bytes[s * 2] << 8 | bytes[s * 2 + 1]);
            value = kMaxSensorValue - MIN(kMaxSensorValue, value - kMinSensorValue);
            sensorValues[s].value = (float)value / kMaxSensorValue;
            averageValue += sensorValues[s].value;
        }
        
        // process values
        if (_referenceSensor < 0) {
            averageValue = averageValue / CSSensorCount;
        } else {
            averageValue = sensorValues[_referenceSensor].value;
        }
        for (int s = 0; s < CSSensorCount; s++) {
            float nominalValue = sensorValues[s].desiredValue + sensorValues[s].value - averageValue;
            sensorValues[s].minValue = MIN(nominalValue, smooth(sensorValues[s].minValue, nominalValue, 25));
            sensorValues[s].nominalValue = nominalValue;
            sensorValues[s].maxValue = MAX(nominalValue, smooth(sensorValues[s].maxValue, nominalValue, 25));
        }
    }
}



- (id)init {
    if (self = [super init]) {
        for (int i = 0; i < CSSensorCount; i++) {
            sensorValues[i] = (CSSensorValues){0.0f, 0.5f, 0.5f, 0.5f, 0.5f};
            _referenceSensor = -1;
        }
    }
    return self;
}

- (CSSensorValues)sensorValuesAtIndex:(NSInteger)index {
    return sensorValues[index];
}

@end
