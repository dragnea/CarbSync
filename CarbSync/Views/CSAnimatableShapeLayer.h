//
//  CSAnimatableShapeLayer.h
//  CarbSync
//
//  Created by Dragnea Mihai on 11/3/16.
//  Copyright © 2016 Dragnea Mihai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSAdditions.h"

@interface CSAnimatableShapeLayer : CAShapeLayer
@property (nonatomic, strong, readonly) NSMutableSet *animatableKeys;
@end
