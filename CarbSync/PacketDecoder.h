//
//  PacketDecoder.h
//  CarbSync
//
//  Created by Dragnea Mihai on 10/31/16.
//  Copyright © 2016 Dragnea Mihai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PacketDecoder : NSObject
@property (nonatomic) NSArray <NSNumber *>*values;
- (void)addByte:(Byte)byte;

@end
