//
//  CSRSSIView.h
//  CarbSync
//
//  Created by Dragnea Mihai on 11/1/16.
//  Copyright © 2016 Dragnea Mihai. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CSRSSIStatus) {
    CSRSSIStatus_inactive,
    CSRSSIStatus_active,
    CSRSSIStatus_scaning,
    CSRSSIStatus_connecting,
    CSRSSIStatus_connected
};

IB_DESIGNABLE
@interface CSRSSIView : UIView
@property (nonatomic) CSRSSIStatus status;
@property (nonatomic, strong) IBInspectable NSNumber *rssi;
@end
