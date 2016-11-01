//
//  CSRSSIView.m
//  CarbSync
//
//  Created by Dragnea Mihai on 11/1/16.
//  Copyright © 2016 Dragnea Mihai. All rights reserved.
//

#import "CSRSSIView.h"

@implementation CSRSSIView

- (void)setRssi:(NSNumber *)rssi {
    _rssi = rssi;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    NSInteger rssi = [self.rssi integerValue];
    NSInteger bars;
    
    if (!self.rssi || rssi == 0) {
        bars = 0; // > 16m or no signal
    } else if (rssi < -64) {
        bars = 1; // 16m
    } else if (rssi < -58) {
        bars = 2; // 8m
    } else if (rssi < -52) {
        bars = 3; // 4m
    } else if (rssi < -46) {
        bars = 4; // 2m
    } else {
        bars = 5; // < 1m
    }
    
    CGContextSetLineWidth(context, 2.0);
    
    CGFloat barWidth = rect.size.width / 5.0;
    CGFloat barHeightHalf = rect.size.height / 2.0;
    CGFloat barHeightInterval = barHeightHalf / 5.0;
    for (NSInteger bar = 0; bar < 5; bar++) {
        if (bar < bars) {
            CGContextSetFillColorWithColor(context, self.tintColor.CGColor);
        } else {
            CGContextSetFillColorWithColor(context, [UIColor lightGrayColor].CGColor);
        }
        CGContextFillRect(context, CGRectMake(bar * barWidth, barHeightHalf - bar * barHeightInterval, barWidth - [UIScreen mainScreen].scale, barHeightHalf + bar * barHeightInterval));
    }
    
}

@end
