//
//  CSSensor.h
//  CarbSync
//
//  Created by Dragnea Mihai on 11/1/16.
//  Copyright © 2016 Dragnea Mihai. All rights reserved.
//

#import "CSPacket.h"

#define CSSensorCount 4

typedef struct {
    float value;
    float minValue;
    float nominalValue;
    float desiredValue;
    float maxValue;
} CSSensorValues;

@interface CSSensor : NSObject<CSPacketProtocol>
@property (nonatomic) NSInteger referenceSensor;

- (CSSensorValues)sensorValuesAtIndex:(NSInteger)index;

@end
