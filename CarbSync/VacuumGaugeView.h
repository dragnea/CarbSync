//
//  VacuumGaugeView.h
//  CarbSync
//
//  Created by Dragnea Mihai on 9/29/16.
//  Copyright © 2016 Dragnea Mihai. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface VacuumGaugeView : UIView
@property (nonatomic) IBInspectable NSInteger minValueSensor;
@property (nonatomic) IBInspectable NSInteger maxValueSensor;
@property (nonatomic) IBInspectable NSInteger value;
@property (nonatomic) IBInspectable NSInteger latency;
@property (nonatomic, strong) IBInspectable NSString *unit;
@property (nonatomic) IBInspectable NSInteger index;
@end
