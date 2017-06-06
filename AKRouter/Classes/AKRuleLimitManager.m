//
//  AKRuleLimitManager.m
//  Pods
//
//  Created by 李翔宇 on 2017/6/6.
//
//

#import "AKRuleLimitManager.h"
#import "NSMutableDictionary+AKRouter.h"

@interface AKRuleLimitManager()

@property (nonatomic, strong) NSMutableDictionary<Class, NSMutableArray<NSString *> *> *whiteListDicM;
@property (nonatomic, strong) NSMutableDictionary<Class, NSMutableArray<NSString *> *> *blackListDicM;

@end

@implementation AKRuleLimitManager

+ (AKRuleLimitManager *)manager {
    static AKRuleLimitManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[super allocWithZone:NULL] init];
    });
    return sharedInstance;
}

+ (id)alloc {
    return [self manager];
}

+ (id)allocWithZone:(NSZone * _Nullable)zone {
    return [self manager];
}

- (id)copy {
    return self;
}

- (id)copyWithZone:(NSZone * _Nullable)zone {
    return self;
}

#pragma mark - Public Method
+ (void)registerClass:(Class)cls whiteList:(NSString *)firstLimit, ... {
    if(!cls) { return; }
    
    NSString *limit = firstLimit;
    va_list argList;
    va_start(argList, firstLimit);
    
    NSMutableArray<NSString *> *limitsM = [self.manager.whiteListDicM ak_routerArrayForKey:cls];
    do {
        [limitsM addObject:limit];
    } while (limit == va_arg(argList, id));
    va_end(argList);
}

+ (void)registerClass:(Class)cls blackList:(NSString *)firstLimit, ... {
    if(!cls) { return; }
    
    NSString *limit = firstLimit;
    va_list argList;
    va_start(argList, firstLimit);
    
    NSMutableArray<NSString *> *limitsM = [self.manager.blackListDicM ak_routerArrayForKey:cls];
    do {
        [limitsM addObject:limit];
    } while (limit == va_arg(argList, id));
    va_end(argList);
}

+ (BOOL)checkClass:(Class)cls rule:(NSString *)identifier {
    if(!cls) {
        return NO;
    }
    
    if(![identifier isKindOfClass:[NSString class]]
       || !identifier.length) {
        return NO;
    }
    
    NSArray<NSString *> *blackList = [self.manager.blackListDicM ak_routerArrayForKey:cls];
    if([blackList containsObject:identifier]) {
        return NO;
    }
    
    NSArray<NSString *> *whiteList = [self.manager.whiteListDicM ak_routerArrayForKey:cls];
    if(![whiteList containsObject:identifier]) {
        return NO;
    }
    
    return YES;
}

#pragma mark - Property Method
- (NSMutableDictionary<Class, NSMutableArray<NSString *> *>  *)whiteListDicM {
    if(_whiteListDicM) {
        return _whiteListDicM;
    }
    
    _whiteListDicM = [NSMutableDictionary dictionary];
    return _whiteListDicM;
}

- (NSMutableDictionary<Class, NSMutableArray<NSString *> *>  *)blackListDicM {
    if(_blackListDicM) {
        return _blackListDicM;
    }
    
    _blackListDicM = [NSMutableDictionary dictionary];
    return _blackListDicM;
}

@end
