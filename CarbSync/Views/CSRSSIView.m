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

- (void)setStatus:(CSRSSIStatus)status {
    _status = status;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    NSInteger rssi = [self.rssi integerValue];
    NSInteger bars;
    
    if (rssi == 0 || self.status != CSRSSIStatus_connected) {
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
    
    CGContextSetLineWidth(context, 1.0);
    
    CGFloat barWidth = rect.size.width / 5.0;
    CGFloat barHeightInterval = rect.size.height / 6.0;
    CGContextSetFillColorWithColor(context, self.tintColor.CGColor);
    for (NSInteger bar = 0; bar < 5; bar++) {
        
        switch (self.status) {
            case CSRSSIStatus_inactive:
            case CSRSSIStatus_scaning:
                CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:0.0 alpha:0.3].CGColor);
                break;
            case CSRSSIStatus_active:
                CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:0.0 alpha:0.5].CGColor);
                break;
            case CSRSSIStatus_connecting:
                CGContextSetStrokeColorWithColor(context, [self.tintColor colorWithAlphaComponent:0.5].CGColor);
                break;
            case CSRSSIStatus_connected:
                CGContextSetStrokeColorWithColor(context, self.tintColor.CGColor);
                break;
                
            default:
                break;
        }
        
        CGContextAddRect(context, CGRectMake(bar * barWidth + 1.0,
                                             rect.size.height - (bar + 1) * barHeightInterval - 1.0,
                                             barWidth - [UIScreen mainScreen].scale,
                                             (bar + 1)* barHeightInterval - 1.0));
        
        if (bar < bars) {
            CGContextDrawPath(context, kCGPathFillStroke);
        } else {
            CGContextStrokePath(context);
        }
    }
    
    switch (self.status) {
        case CSRSSIStatus_active:
            
            break;
        case CSRSSIStatus_scaning:
            CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.3 green:0.3 blue:1.0 alpha:0.8].CGColor);
            CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:1.0 alpha:0.4].CGColor);
            CGContextAddEllipseInRect(context, CGRectMake(4.0, 4.0, rect.size.height / 2.0, rect.size.height / 2.0));
            CGContextDrawPath(context, kCGPathFillStroke);
            CGContextSetLineWidth(context, 4.0);
            CGContextMoveToPoint(context, rect.size.height / 2.0 + 3.0, rect.size.height / 2.0 + 2.0);
            CGContextAddLineToPoint(context, rect.size.width - 4.0, rect.size.height - 4.0);
            CGContextStrokePath(context);
            break;
        case CSRSSIStatus_connecting:
            
            break;
        case CSRSSIStatus_connected:
            
            break;
            
        case CSRSSIStatus_inactive:
        default:
            CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:1.0 green:0.3 blue:0.3 alpha:0.8].CGColor);
            CGContextSetLineWidth(context, 4.0);
            CGContextMoveToPoint(context, 0.0, 0.0);
            CGContextAddLineToPoint(context, rect.size.width, rect.size.height);
            CGContextMoveToPoint(context, rect.size.width, 0.0);
            CGContextAddLineToPoint(context, 0.0, rect.size.height);
            CGContextStrokePath(context);
            break;
    }
    
}

@end
