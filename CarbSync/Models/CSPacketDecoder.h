//
//  CSPacketDecoder.h
//  CarbSync
//
//  Created by Dragnea Mihai on 11/5/16.
//  Copyright © 2016 Dragnea Mihai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSPacketDecoder : NSObject
@property (nonatomic, readonly) BOOL isDataAvailable;
@property (nonatomic, readonly) Byte command;
@property (nonatomic, strong, readonly) NSArray <NSNumber *>*data;
- (void)addByte:(Byte)byte;
@end
