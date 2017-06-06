//
//  AKRuleManager.m
//  Pods
//
//  Created by 李翔宇 on 2017/5/31.
//
//

#import "AKRuleManager.h"
#import "NSMutableDictionary+AKRouter.h"
#import "AKRuleLimitManager.h"

NSString * const AKRuleManagerErrorDomain = @"AKRuleManagerErrorDomain";
NSString * const AKRuleManagerErrorMessageKey = @"AKRuleManagerErrorMessageKey";

NSString * const AKRuleManagerHostWildcardKey = @"*";
NSString * const AKRuleManagerPathWildcardKey = @"/*";

@interface AKRuleManager()

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray<id<AKRuleProtocol>> *> *responseChainDicM;
@property (nonatomic, strong) dispatch_semaphore_t semaphore;

@end

@implementation AKRuleManager

#pragma mark - 标准单例

+ (AKRuleManager *)manager {
    static AKRuleManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[super allocWithZone:NULL] init];
        sharedInstance.semaphore = dispatch_semaphore_create(1);
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

static NSString *AKRuleManagerScheme = nil;
+ (void)setScheme:(NSString *)scheme {
    AKRuleManagerScheme = scheme;
}

+ (NSString *)scheme {
    return AKRuleManagerScheme;
}

static NSString *AKRuleManagerHost = nil;
+ (void)setHost:(NSString *)host {
    AKRuleManagerHost = host;
}

+ (NSString *)host {
    return AKRuleManagerHost;
}

+ (BOOL)registerRule:(id<AKRuleProtocol>)rule error:(NSError **)error {
    dispatch_semaphore_wait(self.manager.semaphore, DISPATCH_TIME_FOREVER);
    if(![rule.identifier isKindOfClass:[NSString class]]
       || !rule.identifier.length) {
        *error = [NSError errorWithDomain:AKRuleManagerErrorDomain
                                     code:0
                                 userInfo:@{AKRuleManagerErrorMessageKey : @"identifier类型错误"}];
        dispatch_semaphore_signal(self.manager.semaphore);
        return NO;
    }
    
    if(!rule.target) {
        *error = [NSError errorWithDomain:AKRuleManagerErrorDomain
                                     code:0
                                 userInfo:@{AKRuleManagerErrorMessageKey : @"target为空"}];
        dispatch_semaphore_signal(self.manager.semaphore);
        return NO;
    }
    
    if(![AKRuleLimitManager checkClass:[rule.target class] rule:rule.identifier]) {
        *error = [NSError errorWithDomain:AKRuleManagerErrorDomain
                                     code:0
                                 userInfo:@{AKRuleManagerErrorMessageKey : @"没有注册权限"}];
        dispatch_semaphore_signal(self.manager.semaphore);
        return NO;
    }
    
    NSMutableArray<id<AKRuleProtocol>> *rulesM = [self.manager.responseChainDicM ak_routerArrayForKey:rule.identifier];
    
    //如果已经注册排他，那么不能再次注册
    if(rule.priority == AKRulePriorityExclusive) {
        id<AKRuleProtocol> lastRule = rulesM.lastObject;
        if(lastRule.priority == AKRulePriorityExclusive) {
            if(lastRule.target) {
                
            }
            
            *error = [NSError errorWithDomain:AKRuleManagerErrorDomain
                                         code:0
                                     userInfo:@{AKRuleManagerErrorMessageKey : @"已有Exclusive优先级对象"}];
            dispatch_semaphore_signal(self.manager.semaphore);
            return NO;
        }
    }
    
    if(rulesM.count) {
        for(NSInteger i = rulesM.count - 1; i >= 0; i--) {
            id<AKRuleProtocol> _rule = rulesM[i];
            if(rule.priority < _rule.priority) {
                if(i == 0) {
                    [rulesM insertObject:rule atIndex:i];
                    break;
                }
                continue;
            }
            [rulesM insertObject:rule atIndex:i + 1];
        }
    } else {
        [rulesM addObject:rule];
    }
    dispatch_semaphore_signal(self.manager.semaphore);
    return YES;
}

+ (void)cancelRule:(NSString *)identifier
            target:(id<AKRuleResponderProtocol>)target {
    dispatch_semaphore_wait(self.manager.semaphore, DISPATCH_TIME_FOREVER);
    NSMutableArray<id<AKRuleProtocol>> *rulesM = [self.manager.responseChainDicM ak_routerArrayForKey:identifier];
    for(NSInteger i = rulesM.count - 1; i >= 0; i--) {
        id<AKRuleProtocol> rule = rulesM[i];
        if(rule.target != target) {
            continue;
        }
        [rulesM removeObject:rule];
    }
    dispatch_semaphore_signal(self.manager.semaphore);
}

+ (void)requestSchemeURL:(NSString *)schemeURL
                 success:(AKRuleResponseSuccess)success
                 failure:(AKRuleResponseFailure)failure {
    if(![schemeURL isKindOfClass:[NSString class]]
       || !schemeURL.length) {
        NSError *error = [NSError errorWithDomain:AKRuleManagerErrorDomain
                                             code:0
                                         userInfo:@{AKRuleManagerErrorMessageKey : @"schemeURL类型错误"}];
        failure(error);
        return;
    }
    
    NSURL *url = [NSURL URLWithString:schemeURL];
    if(!url) {
        NSError *error = [NSError errorWithDomain:AKRuleManagerErrorDomain
                                             code:0
                                         userInfo:@{AKRuleManagerErrorMessageKey : @"schemeURL格式错误"}];
        failure(error);
        return;
    }
    
    NSString *scheme = url.scheme;
    if([self.scheme isKindOfClass:[NSString class]]
       && self.scheme.length) {
        //不是指定Scheme，尝试三方应用打开
        if(![scheme isEqualToString:self.scheme]) {
            NSError *error = [NSError errorWithDomain:AKRuleManagerErrorDomain
                                                 code:0
                                             userInfo:@{AKRuleManagerErrorMessageKey : @"不能处理当前schemeURL"}];
            failure(error);
            
            if([UIApplication.sharedApplication canOpenURL:url]) {
                [UIApplication.sharedApplication openURL:url];
            }
        }
    }
    
    NSString *identifier = nil;
    AKRuleMode mode = AKRuleModeExact;
    NSString *path = url.path;
    if([path hasPrefix:AKRuleManagerPathWildcardKey]) {
        identifier = [path stringByReplacingOccurrencesOfString:AKRuleManagerPathWildcardKey withString:@""];
        mode = AKRuleModeBroadcast;
    }
    
    NSString *query = url.query;
    NSArray<NSString *> *queryItems = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *paramsM = [NSMutableDictionary dictionary];
    [queryItems enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray<NSString *> *pairs = [obj componentsSeparatedByString:@"="];
        paramsM[pairs.firstObject] = pairs.lastObject;
    }];
    
    [self requestRule:identifier
                param:[paramsM copy]
                 mode:mode
              success:success
              failure:^(NSError *error) {
                  failure(error);
                  
                  if([url.host isEqualToString:AKRuleManagerHostWildcardKey]) {
                      if([UIApplication.sharedApplication canOpenURL:url]) {
                          [UIApplication.sharedApplication openURL:url];
                      }
                  }
              }];
}

+ (void)requestRule:(NSString *)identifier
              param:(NSDictionary *)param
               mode:(AKRuleMode)mode
            success:(AKRuleResponseSuccess)success
            failure:(AKRuleResponseFailure)failure {
    BOOL someoneCanHandle = NO;
    
    NSMutableArray<id<AKRuleProtocol>> *rulesM = [self.manager.responseChainDicM ak_routerArrayForKey:identifier];
    NSArray<id<AKRuleProtocol>> *rules = [rulesM copy];
    if(!rules.count) {
        NSError *error = [NSError errorWithDomain:AKRuleManagerErrorDomain
                                             code:0
                                         userInfo:@{AKRuleManagerErrorMessageKey : @"未找到能够处理当前规则的对象"}];
        failure(error);
        return;
    }
    
    for(NSInteger i = rules.count - 1; i >= 0; i--) {
        id<AKRuleResponderProtocol> target = rules[i].target;
        if(!target) {
            [rulesM removeObject:rules[i]];
            continue;
        }
        
        if(![target canHandleRule:identifier param:param]) {
            if(rules[i].priority == AKRulePriorityExclusive) {
                NSError *error = [NSError errorWithDomain:AKRuleManagerErrorDomain
                                                     code:0
                                                 userInfo:@{AKRuleManagerErrorMessageKey : @"已有Exclusive优先级对象，未能处理当前规则"}];
                failure(error);
                return;
            }
            
            continue;
        }
        
        someoneCanHandle = YES;
        
        [target handleRule:identifier param:param success:success failure:failure];
        if(mode == AKRuleModeExact) {
            break;
        }
    }
    
    if(!someoneCanHandle) {
        NSError *error = [NSError errorWithDomain:AKRuleManagerErrorDomain
                                             code:0
                                         userInfo:@{AKRuleManagerErrorMessageKey : @"未找到能够处理当前规则的对象"}];
        failure(error);
    }
}

#pragma mark - Property Method
- (NSMutableDictionary<NSString *, NSMutableArray<id<AKRuleProtocol>> *> *)responseChainDicM {
    if(_responseChainDicM) {
        return _responseChainDicM;
    }
    
    _responseChainDicM = [NSMutableDictionary dictionary];
    return _responseChainDicM;
}

@end
