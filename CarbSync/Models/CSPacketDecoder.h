//
//  CSPacketDecoder.h
//  CarbSync
//
//  Created by Dragnea Mihai on 11/5/16.
//  Copyright © 2016 Dragnea Mihai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSPacket.h"

extern NSErrorDomain const CSPacketDecodedErrorDomain;
extern NSInteger const CSPacketDecoderErrorCode_bufferOverflow;

@class CSPacketDecoder;

@protocol CSPacketDecoderDelegate <NSObject>
- (void)packetDecoder:(CSPacketDecoder *)packetDecoder packetUpdated:(id<CSPacketProtocol>)packet command:(CSPacketCommand)command;
- (void)packetDecoder:(CSPacketDecoder *)packetDecoder error:(NSError *)error;
@end

@interface CSPacketDecoder : NSObject
@property (nonatomic, weak) id<CSPacketDecoderDelegate>delegate;
- (void)addByte:(Byte)byte;
- (void)registerPacketClass:(Class<CSPacketProtocol>)packet;
@end
