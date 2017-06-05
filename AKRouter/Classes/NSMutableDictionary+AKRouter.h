//
//  NSMutableDictionary+AKRouter.h
//  Pods
//
//  Created by 李翔宇 on 2017/6/2.
//
//

#import <Foundation/Foundation.h>
#import "AKRuleProtocol.h"

@interface NSMutableDictionary (AKRouter)

- (NSMutableArray<id<AKRuleProtocol>> *)responseChainsForRule:(NSString *)identifier;

@end
