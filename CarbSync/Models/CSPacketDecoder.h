//
//  CSPacketDecoder.h
//  CarbSync
//
//  Created by Dragnea Mihai on 11/5/16.
//  Copyright © 2016 Dragnea Mihai. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSErrorDomain const CSPacketDecodedErrorDomain;
extern NSInteger const CSPacketDecoderErrorCode_bufferOverflow;

@class CSPacketDecoder;

@protocol CSPacketDecoderDelegate <NSObject>
- (void)packetDecoderAvailableData:(CSPacketDecoder *)packetDecoder;
- (void)packetDecoder:(CSPacketDecoder *)packetDecoder error:(NSError *)error;
@end

@interface CSPacketDecoder : NSObject
@property (nonatomic, weak) id<CSPacketDecoderDelegate>delegate;
@property (nonatomic, readonly) Byte command;
@property (nonatomic, strong, readonly) NSArray <NSNumber *>*data;
- (void)addByte:(Byte)byte;
@end
