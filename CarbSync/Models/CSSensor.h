//
//  CSSensor.h
//  CarbSync
//
//  Created by Dragnea Mihai on 11/1/16.
//  Copyright © 2016 Dragnea Mihai. All rights reserved.
//

#import "CSPacket.h"

typedef NS_ENUM(NSInteger, CSSensorUnit) {
    CSSensorUnit_kPa
};

typedef struct CSSensorValues {
    float minValue;
    float nominalValue;
    float desiredValue;
    float maxValue;
} CSSensorValues;

@interface CSSensor : NSObject<CSPacketProtocol>
@property (nonatomic) CSSensorUnit unit;

- (id)initWithUnit:(CSSensorUnit)unit;
- (CSSensorValues)sensorValuesAtIndex:(NSInteger)index;

@end
