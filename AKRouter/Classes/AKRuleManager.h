//
//  AKRuleManager.h
//  Pods
//
//  Created by 李翔宇 on 2017/5/31.
//
//

#import <Foundation/Foundation.h>
#import "AKRuleProtocol.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, AKRuleMode) {
    AKRuleModeExact = 0, //精确
    AKRuleModeBroadcast //广播
};

extern NSString * const AKRuleManagerErrorDomain;
extern NSString * const AKRuleManagerErrorMessageKey;

//用于支持URL通配信息
extern NSString * const AKRuleManagerHostWildcardKey;
extern NSString * const AKRuleManagerPathWildcardKey;

@interface AKRuleManager : NSObject

@property (class, nonatomic, strong) NSString *scheme;
@property (class, nonatomic, strong) NSString *host;

/**
 注册规则

 @param rule AKRuleProtocol规则对象
 @param error 错误
 @return 标识注册结果的BOOL值
 */
+ (BOOL)registerRule:(id<AKRuleProtocol>)rule error:(NSError **)error;

/**
 取消规则
 当调用方和target不是同一对象的时候，属于规则被意外取消
 
 @param identifier AKRuleProtocol规则标识
 @param target 对象
 */
+ (void)cancelRule:(NSString *)identifier
            target:(id<AKRuleResponderProtocol>)target;


/**
 请求schemeURL

 @param schemeURL 自定义的SchemeURL，autohome://\<App\>/\/path[?key=value...]
 @param success 可能同步或者异步，由实现方控制
 @param failure 可能同步或者异步，由实现方控制
 */
+ (void)requestSchemeURL:(NSString *)schemeURL
                 success:(AKRuleResponseSuccess)success
                 failure:(AKRuleResponseFailure)failure;

/**
 请求schemeURL
 
 @param identifier 规则标识符
 @param param 参数
 @param mode 模式
 @param success 可能同步或者异步，由实现方控制
 @param failure 可能同步或者异步，由实现方控制
 */
+ (void)requestRule:(NSString *)identifier
              param:(NSDictionary *)param
               mode:(AKRuleMode)mode
            success:(AKRuleResponseSuccess)success
            failure:(AKRuleResponseFailure)failure;

@end

NS_ASSUME_NONNULL_END
