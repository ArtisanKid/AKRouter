//
//  NSMutableDictionary+AKRouter.m
//  Pods
//
//  Created by 李翔宇 on 2017/6/2.
//
//

#import "NSMutableDictionary+AKRouter.h"

@implementation NSMutableDictionary (AKRouter)

- (NSMutableArray *)ak_routerArrayForKey:(id)key {
    if(!key) {
        return nil;
    }
    
    NSMutableArray *array = self[key];
    if(!array) {
        array = [NSMutableArray array];
        self[key] = array;
    }
    return array;
}

@end
