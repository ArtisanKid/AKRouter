//
//  NSMutableDictionary+AKRouter.m
//  Pods
//
//  Created by 李翔宇 on 2017/6/2.
//
//

#import "NSMutableDictionary+AKRouter.h"

@implementation NSMutableDictionary (AKRouter)

- (NSMutableArray<id<AKRuleProtocol>> *)responseChainsForRule:(NSString *)identifier {
    if(!identifier.length) {
        return nil;
    }
    
    NSMutableArray *responseChains = self[identifier];
    if(!responseChains) {
        responseChains = [NSMutableArray array];
        self[identifier] = responseChains;
    }
    return responseChains;
}

@end
