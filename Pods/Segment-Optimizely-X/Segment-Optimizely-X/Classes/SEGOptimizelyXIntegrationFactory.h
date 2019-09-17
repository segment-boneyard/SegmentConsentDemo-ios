//
//  SEGOptimizelyXIntegrationFactory.h
//  Pods
//
//  Created by ladan nasserian on 8/17/17.
//
//


#import <Foundation/Foundation.h>
#import <Analytics/SEGIntegrationFactory.h>
#import <OptimizelySDKiOS/OptimizelySDKiOS.h>


@interface SEGOptimizelyXIntegrationFactory : NSObject <SEGIntegrationFactory>

+ (instancetype)instanceWithOptimizely:(OPTLYManager *)optimizely;

@property OPTLYManager *manager;

@end
