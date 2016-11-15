//
//  CSVersion.m
//  CarbSync
//
//  Created by Dragnea Mihai on 11/14/16.
//  Copyright © 2016 Dragnea Mihai. All rights reserved.
//

#import "CSVersion.h"

@implementation CSVersion

+ (CSPacketCommand)command {
    return 'v';
}

- (void)setBytes:(Byte *)bytes count:(int)count {
    if (count != 2) {
        // malformed packet
    } else {
        _stringVersion = [NSString stringWithCString:(char *)bytes encoding:NSUTF8StringEncoding];
    }
}

@end
