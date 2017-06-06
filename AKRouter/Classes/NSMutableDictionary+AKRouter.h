//
//  NSMutableDictionary+AKRouter.h
//  Pods
//
//  Created by 李翔宇 on 2017/6/2.
//
//

#import <Foundation/Foundation.h>
#import "AKRuleProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableDictionary (AKRouter)

- (NSMutableArray *)ak_routerArrayForKey:(id)key;

@end

NS_ASSUME_NONNULL_END
