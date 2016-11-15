//
//  CSVacuumView.m
//  CarbSync
//
//  Created by Dragnea Mihai on 11/1/16.
//  Copyright © 2016 Dragnea Mihai. All rights reserved.
//

#import "CSVacuumView.h"
#import "CSAnimatableShapeLayer.h"

@interface CSVacuumView ()
@property (nonatomic, strong) CSAnimatableShapeLayer *intervalLayer;
@property (nonatomic, strong) CSAnimatableShapeLayer *indicatorLayer;
@property (nonatomic, strong) CSAnimatableShapeLayer *desiredIndicatorLayer;
@property (nonatomic, strong) UILabel *indexLabel;
@property (nonatomic, strong) UILabel *valueLabel;
@property (nonatomic) CGRect contentRect;
@end

@implementation CSVacuumView

- (id)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    _contentRect = CGRectInset(self.bounds, 3.0, 32.0);
    
    _intervalLayer = [CSAnimatableShapeLayer layer];
    _intervalLayer.fillColor = [UIColor colorWithWhite:0.1 alpha:0.1].CGColor;
    [self.layer addSublayer:_intervalLayer];
    
    _indicatorLayer = [CSAnimatableShapeLayer layer];
    _indicatorLayer.fillColor = [UIColor colorWithRed:0.8 green:0.0 blue:0.0 alpha:0.5].CGColor;
    CGPathRef indicatorPath = CGPathCreateWithRect(CGRectMake(_contentRect.origin.x, _contentRect.origin.y - 2.0, _contentRect.size.width, 4.0), NULL);
    _indicatorLayer.path = indicatorPath;
    CGPathRelease(indicatorPath);
    [self.layer addSublayer:_indicatorLayer];
    
    _desiredIndicatorLayer = [CSAnimatableShapeLayer layer];
    _desiredIndicatorLayer.fillColor = [UIColor colorWithRed:0.0 green:0.5 blue:0.0 alpha:0.5].CGColor;
    CGPathRef desiredIndicatorPath = CGPathCreateWithRect(CGRectMake(_contentRect.origin.x + 2.0, _contentRect.origin.y - 1.0, _contentRect.size.width - 4.0, 2.0), NULL);
    _desiredIndicatorLayer.path = desiredIndicatorPath;
    CGPathRelease(desiredIndicatorPath);
    [self.layer addSublayer:_desiredIndicatorLayer];
    
    _indexLabel = [[UILabel alloc] init];
    _indexLabel.textAlignment = NSTextAlignmentCenter;
    _indexLabel.textColor = [UIColor darkGrayColor];
    _indexLabel.font = [UIFont boldSystemFontOfSize:20.0];
    _indexLabel.backgroundColor = [UIColor clearColor];
    _indexLabel.text = [NSNumber numberWithInteger:self.tag + 1].stringValue;
    [self addSubview:_indexLabel];
    
    _valueLabel = [[UILabel alloc] init];
    _valueLabel.textAlignment = NSTextAlignmentCenter;
    _valueLabel.textColor = [UIColor blackColor];
    _valueLabel.font = [UIFont systemFontOfSize:15.0];
    _valueLabel.backgroundColor = [UIColor clearColor];
    _valueLabel.minimumScaleFactor = 0.5;
    _valueLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:_valueLabel];
    
    [self updateMinValue:0.38 value:0.4 desiredValue:0.52 maxValue:0.74];
}

- (void)updateMinValue:(CGFloat)minValue value:(CGFloat)value desiredValue:(CGFloat)desiredValue maxValue:(CGFloat)maxValue {
    // update interval layer
    CGFloat minPosY = _contentRect.size.height * MIN(minValue, 1.0);
    CGPathRef intervalPath = CGPathCreateWithRect(CGRectMake(_contentRect.origin.x,
                                                             _contentRect.origin.y + minPosY,
                                                             _contentRect.size.width,
                                                             _contentRect.size.height * MIN(maxValue, 1.0) - minPosY),
                                                  NULL);
    _intervalLayer.path = intervalPath;
    CGPathRelease(intervalPath);
    
    // update indicator
    _indicatorLayer.position = CGPointMake(0.0, _contentRect.size.height * MIN(value, 1.0));
    
    // update desired indicator
    _desiredIndicatorLayer.position = CGPointMake(0.0, _contentRect.size.height * MIN(desiredValue, 1.0));
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _contentRect = CGRectInset(self.bounds, 3.0, 32.0);
    _indexLabel.frame = CGRectMake(3.0, 3.0, self.bounds.size.width - 6.0, 26.0);
    _valueLabel.frame = CGRectMake(3.0, self.bounds.size.height - 29.0, self.bounds.size.width - 6.0, 26.0);
}


- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 2.0);
    CGContextSetStrokeColorWithColor(context, [UIColor darkGrayColor].CGColor);
    
    // upper border
    CGContextMoveToPoint(context, 0.0, 16.0);
    CGContextAddLineToPoint(context, 0.0, 0.0);
    CGContextAddLineToPoint(context, rect.size.width, 0.0);
    CGContextAddLineToPoint(context, rect.size.width, 16.0);
    
    // lower border
    CGContextMoveToPoint(context, 0.0, rect.size.height - 16.0);
    CGContextAddLineToPoint(context, 0.0, rect.size.height);
    CGContextAddLineToPoint(context, rect.size.width, rect.size.height);
    CGContextAddLineToPoint(context, rect.size.width, rect.size.height - 16.0);
    
    CGContextStrokePath(context);
    
    // add side border
    CGContextSetLineWidth(context, 1.0 / [UIScreen mainScreen].scale);
    CGContextSetStrokeColorWithColor(context, [UIColor lightGrayColor].CGColor);
    CGContextMoveToPoint(context, 1.0, 16.0);
    CGContextAddLineToPoint(context, 1.0, rect.size.height - 16.0);
    CGContextMoveToPoint(context, rect.size.width - 1.0, 16.0);
    CGContextAddLineToPoint(context, rect.size.width - 1.0, rect.size.height - 16.0);
    CGContextStrokePath(context);
    
    // draw gradation
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, 1.0 / [UIScreen mainScreen].scale);
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:0.8 alpha:1.0].CGColor);
    for (NSInteger y = 0; y <= 10; y++) {
        CGContextMoveToPoint(context, _contentRect.origin.x + 16.0, _contentRect.origin.y + (_contentRect.size.height / 10.0) * y);
        CGContextAddLineToPoint(context, _contentRect.size.width - 16.0, _contentRect.origin.y + (_contentRect.size.height / 10.0) * y);
    }
    CGContextStrokePath(context);
}

@end
