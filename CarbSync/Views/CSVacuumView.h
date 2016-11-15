//
//  CSVacuumView.h
//  CarbSync
//
//  Created by Dragnea Mihai on 11/1/16.
//  Copyright © 2016 Dragnea Mihai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSSensor.h"

typedef NS_ENUM(NSInteger, CSVacuumViewUnit) {
    CSVacuumViewUnit_kPa
};

IB_DESIGNABLE
@interface CSVacuumView : UIControl
@property (nonatomic) IBInspectable CSVacuumViewUnit unit;

- (void)updateValues:(CSSensorValues)values;

@end
