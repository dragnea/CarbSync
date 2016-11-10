//
//  CSVacuumView.h
//  CarbSync
//
//  Created by Dragnea Mihai on 11/1/16.
//  Copyright © 2016 Dragnea Mihai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSVacuumView : UIView
@property (nonatomic, strong, readonly) UILabel *indexLabel;
@property (nonatomic, strong, readonly) UILabel *valueLabel;

- (void)updateMinValue:(CGFloat)minValue value:(CGFloat)value desiredValue:(CGFloat)desiredValue maxValue:(CGFloat)maxValue;

@end
