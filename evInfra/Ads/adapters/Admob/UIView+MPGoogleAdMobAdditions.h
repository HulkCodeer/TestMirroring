//
//  UIView+MPGoogleAdMobAdditions.h
//  evInfra
//
//  Created by Michael Lee on 2020/08/20.
//  Copyright © 2020 soft-berry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (MPGoogleAdMobAdditions)

/// Adds constraints to the receiver's superview that keep the receiver the same size and position
/// as the superview.
- (void)gad_fillSuperview;

@end
