//
//  CSPacket.h
//  CarbSync
//
//  Created by Dragnea Mihai on 11/7/16.
//  Copyright © 2016 Dragnea Mihai. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CSPacketProtocol <NSObject>

typedef Byte CSPacketCommand;

+ (CSPacketCommand)command;
- (void)setData:(NSArray <NSNumber *>*)data;

@end
