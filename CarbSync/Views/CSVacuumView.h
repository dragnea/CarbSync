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
    
    /**
     Default unit
     */
    CSVacuumViewUnit_kPa,
    
    /**
     1 kPa = 7.50061683 mmHg
     */
    CSVacuumViewUnit_mmHg,
    
    /**
     1 kPa = 10 mBar
     */
    CSVacuumViewUnit_mBar
};

IB_DESIGNABLE
@interface CSVacuumView : UIControl
@property (nonatomic) IBInspectable CSVacuumViewUnit unit;

- (void)updateValues:(CSSensorValues)values;

@end
