//
//  CSVersion.h
//  CarbSync
//
//  Created by Dragnea Mihai on 11/14/16.
//  Copyright © 2016 Dragnea Mihai. All rights reserved.
//

#import "CSPacket.h"

@interface CSVersion : NSObject<CSPacketProtocol>
@property (nonatomic, strong, readonly) NSString *stringVersion;
@end
