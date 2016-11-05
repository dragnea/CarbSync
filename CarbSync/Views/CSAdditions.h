//
//  CSAdditions.h
//  CarbSync
//
//  Created by Dragnea Mihai on 11/3/16.
//  Copyright © 2016 Dragnea Mihai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CATransaction (CATransactionAdditions)

+ (void)animateWithDuration:(NSTimeInterval)duration
                 animations:(nullable void (^)(void))animations
                 completion:(nullable void (^)(void))completion;

@end
