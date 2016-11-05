//
//  CSAdditions.m
//  CarbSync
//
//  Created by Dragnea Mihai on 11/3/16.
//  Copyright © 2016 Dragnea Mihai. All rights reserved.
//

#import "CSAdditions.h"

@implementation CATransaction (CATransactionAdditions)

+ (void)animateWithDuration:(NSTimeInterval)duration
                 animations:(nullable void (^)(void))animations
                 completion:(nullable void (^)(void))completion {
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:duration];
    
    if (completion) {
        [CATransaction setCompletionBlock:completion];
    }
    
    if (animations) {
        animations();
    }
    
    [CATransaction commit];
}

@end
