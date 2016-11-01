//
//  RSSIView.h
//  CarbSync
//
//  Created by Dragnea Mihai on 9/28/16.
//  Copyright © 2016 Dragnea Mihai. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface RSSIView : UIView
@property (nonatomic, strong) IBInspectable NSNumber *rssi;
@end
