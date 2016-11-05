//
//  CSAnimatableShapeLayer.m
//  CarbSync
//
//  Created by Dragnea Mihai on 11/3/16.
//  Copyright © 2016 Dragnea Mihai. All rights reserved.
//

#import "CSAnimatableShapeLayer.h"

@implementation CSAnimatableShapeLayer
@synthesize animatableKeys = _animatableKeys;

- (NSMutableSet *)animatableKeys {
    if (!_animatableKeys) {
        _animatableKeys = [NSMutableSet set];
    }
    return _animatableKeys;
}

- (id<CAAction>)actionForKey:(NSString *)event {
    if ([self.animatableKeys containsObject:event]) {
        return [self animationForKey:event];
    } else {
        return [super actionForKey:event];
    }
}

- (CABasicAnimation *)animationForKey:(NSString *)key {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:key];
    animation.fromValue = [self.presentationLayer valueForKey:key];
    animation.duration = [CATransaction animationDuration];
    return animation;
}
@end
