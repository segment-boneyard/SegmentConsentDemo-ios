//
//  SEGOptimizelyXIntegrationFactory.m
//  Pods
//
//  Created by ladan nasserian on 8/17/17.
//
//

#import "SEGOptimizelyXIntegrationFactory.h"
#import "SEGOptimizelyXIntegration.h"
#import <OptimizelySDKiOS/OptimizelySDKiOS.h>


@implementation SEGOptimizelyXIntegrationFactory

+ (instancetype)instanceWithOptimizely:(OPTLYManager *)manager
{
    static dispatch_once_t once;
    static SEGOptimizelyXIntegrationFactory *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] initWithOptimizely:manager];
    });
    return sharedInstance;
}

- (id)initWithOptimizely:(OPTLYManager *)manager
{
    if (self = [super init]) {
        self.manager = manager;
    }

    return self;
}

+ (instancetype)createWithOptimizelyManager:(NSString *)token optimizelyManager:(OPTLYManager *)manager
{
    return [[self alloc] initWithOptimizely:manager];
}

- (id<SEGIntegration>)createWithSettings:(NSDictionary *)settings forAnalytics:(SEGAnalytics *)analytics
{
    return [[SEGOptimizelyXIntegration alloc] initWithSettings:settings andOptimizelyManager:self.manager withAnalytics:analytics];
}

- (NSString *)key
{
    return @"Optimizely X";
}


@end
