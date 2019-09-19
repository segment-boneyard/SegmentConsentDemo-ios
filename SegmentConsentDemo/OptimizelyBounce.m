//
//  OptimizelyBounce.m
//  SegmentConsentDemo
//
//  Created by Brandon Sneed on 9/17/19.
//  Copyright © 2019 Brandon Sneed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OptimizelyBounce.h"

@implementation OptimizelyBounce

- (OPTLYManager *)setupOptimizely {
    OPTLYLoggerDefault *optlyLogger = [[OPTLYLoggerDefault alloc] initWithLogLevel:OptimizelyLogLevelError];
    // Initialize an Optimizely manager
    OPTLYManagerBuilder *builder = [OPTLYManagerBuilder builderWithBlock:^(OPTLYManagerBuilder *builder) {
        builder.projectId = @"8724802167";//@"8135581546";
        builder.logger = optlyLogger;
        
    }];
    OPTLYManager *manager = [[OPTLYManager alloc] initWithBuilder:builder];

    // Test delayed initialization
    double delayInSeconds = 5.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        // Initialize an Optimizely client by asynchronously downloading the datafile
        [manager initializeWithCallback:^(NSError *_Nullable error, OPTLYClient *_Nullable client) {
            NSLog(@"Optimizely is up.");
        }];
    });

    return manager;
}

@end
