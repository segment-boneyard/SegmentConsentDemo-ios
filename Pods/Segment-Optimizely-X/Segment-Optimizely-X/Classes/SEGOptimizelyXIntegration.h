//
//  SEGOptimizelyXIntegration.h
//  Pods
//
//  Created by ladan nasserian on 8/17/17.
//
//

#import <Foundation/Foundation.h>
#import <Analytics/SEGIntegration.h>
#import <OptimizelySDKiOS/OptimizelySDKiOS.h>
#import <Analytics/SEGAnalytics.h>


@interface SEGOptimizelyXIntegration : NSObject <SEGIntegration>


@property (nonatomic, strong, nonnull) NSDictionary *settings;
@property (nonatomic, strong, nonnull) OPTLYManager *manager;
@property (nonatomic, strong, nonnull) SEGAnalytics *analytics;
@property (nonatomic, nullable) NSString *userId;
@property (nonatomic, nullable) NSDictionary *userTraits;


#pragma mark - Queueing
@property (nonatomic, strong) dispatch_queue_t _Nullable backgroundQueue;
@property (nonatomic, strong) NSMutableArray *_Nullable queue;
@property (nonatomic, strong) NSTimer *_Nullable flushTimer;

- (id _Nonnull)initWithSettings:(NSDictionary *_Nonnull)settings andOptimizelyManager:(OPTLYManager *_Nonnull)manager withAnalytics:(SEGAnalytics *_Nonnull)analytics;

@end
