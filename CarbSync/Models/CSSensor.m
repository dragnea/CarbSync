//
//  CSSensor.m
//  CarbSync
//
//  Created by Dragnea Mihai on 11/1/16.
//  Copyright © 2016 Dragnea Mihai. All rights reserved.
//

#import "CSSensor.h"

@implementation CSSensor

+ (CSPacketCommand)command {
    return 's';
}

- (void)setData:(NSArray<NSNumber *> *)data {
    
}

- (id)initWithUnit:(CSSensorUnit)unit {
    if (self = [super init]) {
        _unit = unit;
    }
    return self;
}

@end
