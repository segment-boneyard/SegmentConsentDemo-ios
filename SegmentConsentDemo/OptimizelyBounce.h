//
//  NSObject+Optimizely.h
//  SegmentConsentDemo
//
//  Created by Brandon Sneed on 9/17/19.
//  Copyright © 2019 Brandon Sneed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Analytics/SEGAnalytics.h>
#import "SEGOptimizelyXIntegrationFactory.h"
#import <OptimizelySDKiOS/OptimizelySDKiOS.h>
#import <OptimizelySDKiOS/OPTLYManager.h>

NS_ASSUME_NONNULL_BEGIN

@interface OptimizelyBounce : NSObject
- (OPTLYManager *)setupOptimizely;
@end

NS_ASSUME_NONNULL_END
