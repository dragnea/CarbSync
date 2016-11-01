//
//  VacuumGaugeView.m
//  CarbSync
//
//  Created by Dragnea Mihai on 9/29/16.
//  Copyright © 2016 Dragnea Mihai. All rights reserved.
//

#import "VacuumGaugeView.h"

const int kPa1000PerAdcUnit = 124; // 0.12 per ADC unit;
const int adcValueFor0Kpa = 942; // 4.6v

@interface VacuumGaugeView ()
@property (nonatomic, strong) UILabel *indexLabel;
@property (nonatomic, strong) UILabel *valueLabel;
@property (nonatomic) NSInteger intervalMin;
@property (nonatomic) NSInteger intervalMax;
@property (nonatomic, strong) NSMutableArray *intervalValues;
@property (nonatomic, strong) NSMutableArray *samplesLatency;
@end

@implementation VacuumGaugeView {
    
}

- (instancetype)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.intervalValues = [NSMutableArray array];
    self.samplesLatency = [NSMutableArray array];
    self.indexLabel = [[UILabel alloc] init];
    self.indexLabel.textAlignment = NSTextAlignmentCenter;
    self.indexLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.indexLabel];
    [self.indexLabel addConstraint:[NSLayoutConstraint constraintWithItem:self.indexLabel
                                                                attribute:NSLayoutAttributeHeight
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:nil
                                                                attribute:NSLayoutAttributeHeight
                                                               multiplier:1.0
                                                                 constant:30.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.indexLabel
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1.0
                                                      constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.indexLabel
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1.0
                                                      constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.indexLabel
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0
                                                      constant:0.0]];
    
    self.valueLabel = [[UILabel alloc] init];
    self.valueLabel.textAlignment = NSTextAlignmentCenter;
    self.valueLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.valueLabel];
    [self.valueLabel addConstraint:[NSLayoutConstraint constraintWithItem:self.valueLabel
                                                                attribute:NSLayoutAttributeHeight
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:nil
                                                                attribute:NSLayoutAttributeHeight
                                                               multiplier:1.0
                                                                 constant:30.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.valueLabel
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1.0
                                                      constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.valueLabel
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1.0
                                                      constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.valueLabel
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0
                                                      constant:0.0]];
    self.index = 0;
    self.unit = @"kPa";
    self.minValueSensor = 20;
    self.maxValueSensor = 942;
    self.value = 0;
    self.latency = 0;
}

- (void)setIndex:(NSInteger)index {
    _index = index;
    self.indexLabel.text = [NSString stringWithFormat:@"%ld", _index];
}

- (void)setValue:(NSInteger)value {
    if (value < self.minValueSensor) {
        _value = self.minValueSensor;
    } else if (value > self.maxValueSensor) {
        _value = self.maxValueSensor;
    } else {
        _value = value;
    }
    
    [self.intervalValues addObject:@(value)];
    if (self.intervalValues.count > 10) {
        [self.intervalValues removeObjectAtIndex:0];
    }
    
    // determine min/max interval
    NSInteger intervalMin = _value;
    NSInteger intervalMax = _value;
    for(NSNumber *intervalValue in self.intervalValues) {
        if (intervalValue.integerValue < intervalMin) {
            intervalMin = intervalValue.integerValue;
        }
        if (intervalValue.integerValue > intervalMax) {
            intervalMax = intervalValue.integerValue;
        }
    }
    self.intervalMin = intervalMin;
    self.intervalMax = intervalMax;
    
    self.valueLabel.text = [NSString stringWithFormat:@"%0.2f %@", (adcValueFor0Kpa - _value) * kPa1000PerAdcUnit / 1000.0, self.unit];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect contentRect = CGRectMake(0.0, CGRectGetMaxY(self.indexLabel.frame), rect.size.width, CGRectGetMinY(self.valueLabel.frame) - CGRectGetMaxY(self.indexLabel.frame));
    
    int minY = contentRect.size.height - self.intervalMax * contentRect.size.height / self.maxValueSensor + contentRect.origin.y;
    int maxY = contentRect.size.height - self.intervalMin * contentRect.size.height / self.maxValueSensor + contentRect.origin.y;
    int valueY = contentRect.size.height - self.value * contentRect.size.height / self.maxValueSensor + contentRect.origin.y;

    if (self.latency > 0) {
        int values[3] = {minY, maxY, valueY};
        [self.samplesLatency addObject:[NSValue valueWithPointer:values]];
        if (self.samplesLatency.count > self.latency) {
            [self.samplesLatency removeObjectsInRange:NSMakeRange(0, self.samplesLatency.count - self.latency)];
        }
        for (int latencyIndex = 0; latencyIndex < self.samplesLatency.count; latencyIndex++) {
            int *valuesToAdd = [self.samplesLatency[latencyIndex] pointerValue];
            minY += valuesToAdd[0];
            maxY += valuesToAdd[1];
            valueY += valuesToAdd[2];
        }
        minY /= self.samplesLatency.count;
    }
    
    // round value
    minY = ceil(minY);
    maxY = ceil(maxY);
    valueY = ceil(valueY);
    
    // draw interval
    CGContextSetFillColorWithColor(context, [UIColor purpleColor].CGColor);
    CGContextFillRect(context, CGRectMake(0.0, minY, rect.size.width, maxY - minY));
    
    // draw indicator
    CGContextFillRect(context, CGRectMake(0.0, valueY - 1.0, rect.size.width, 3.0));
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillRect(context, CGRectMake(1.0, valueY, rect.size.width - 2.0, 1.0));
}

@end
