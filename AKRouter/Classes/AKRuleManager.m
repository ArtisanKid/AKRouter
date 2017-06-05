//
//  AKRuleManager.m
//  Pods
//
//  Created by 李翔宇 on 2017/5/31.
//
//

#import "AKRuleManager.h"
#import "NSMutableDictionary+AKRouter.h"

NSString * const AKRuleManagerRuleModeKey = @"AKRuleManagerRuleModeKey";
NSString * const AKRuleManagerErrorDomain = @"AKRuleManagerErrorDomain";
NSString * const AKRuleManagerErrorMessageKey = @"AKRuleManagerErrorMessageKey";

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

+ (BOOL)registerRule:(id<AKRuleProtocol>)rule error:(NSError **)error {
    dispatch_semaphore_wait(self.manager.semaphore, DISPATCH_TIME_FOREVER);
    NSMutableArray<id<AKRuleProtocol>> *rulesM = [self.manager.responseChainDicM responseChainsForRule:rule.identifier];
    
    //如果已经注册排他，那么不能再次注册
    if(rule.priority == AKRulePriorityExclusive) {
        if(rulesM.lastObject.priority == AKRulePriorityExclusive) {
            *error = [NSError errorWithDomain:AKRuleManagerErrorDomain
                                                 code:0
                                             userInfo:@{AKRuleManagerErrorMessageKey : @"已有Exclusive权限规则"}];
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
    NSMutableArray<id<AKRuleProtocol>> *rulesM = [self.manager.responseChainDicM responseChainsForRule:identifier];
    
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
        failure(nil);
        return;
    }
    
    NSURL *url = [NSURL URLWithString:schemeURL];
    if(!url) {
        failure(nil);
        return;
    }
    
    NSString *identifier = url.path;
    NSString *query = url.query;
    NSArray<NSString *> *queryItems = [query componentsSeparatedByString:@"&"];
    
    __block AKRuleMode mode = AKRuleModeExact;
    NSMutableDictionary *paramsM = [NSMutableDictionary dictionary];
    [queryItems enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray<NSString *> *pairs = [obj componentsSeparatedByString:@"="];
        if([pairs.firstObject isEqualToString:AKRuleManagerRuleModeKey]) {
            mode = [pairs.lastObject integerValue];
        } else {
            paramsM[pairs.firstObject] = pairs.lastObject;
        }
    }];
    
    [self requestRule:identifier
                param:[paramsM copy]
                 mode:mode
              success:success
              failure:failure];
}

+ (void)requestRule:(NSString *)identifier
              param:(NSDictionary *)param
               mode:(AKRuleMode)mode
            success:(AKRuleResponseSuccess)success
            failure:(AKRuleResponseFailure)failure {
    BOOL someoneCanHandle = NO;
    
    NSArray<id<AKRuleProtocol>> *rules = [[self.manager.responseChainDicM responseChainsForRule:identifier] copy];
    for(NSInteger i = rules.count - 1; i >= 0; i--) {
        id<AKRuleResponderProtocol> target = rules[i].target;
        if(!target) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self cancelRule:identifier target:nil];
            });
            continue;
        }
        
        if(![target canHandleRule:identifier param:param]) {
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
                                 userInfo:@{AKRuleManagerErrorMessageKey : @"未找到可处理对象"}];
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
