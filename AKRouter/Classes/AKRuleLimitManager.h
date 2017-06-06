//
//  AKRuleLimitManager.h
//  Pods
//
//  Created by 李翔宇 on 2017/6/6.
//
//

#import <Foundation/Foundation.h>

@interface AKRuleLimitManager : NSObject

+ (void)registerClass:(Class)cls whiteList:(NSString *)identifier, ... NS_REQUIRES_NIL_TERMINATION;
+ (void)registerClass:(Class)cls blackList:(NSString *)identifier, ... NS_REQUIRES_NIL_TERMINATION;

+ (BOOL)checkClass:(Class)cls rule:(NSString *)identifier;

@end
