//
//  AKRuleResponderProtocol.h
//  Pods
//
//  Created by 李翔宇 on 2017/5/31.
//
//

#import <Foundation/Foundation.h>

typedef void(^AKRuleResponseSuccess)(id result);
typedef void(^AKRuleResponseFailure)(NSError *error);

@protocol AKRuleResponderProtocol <NSObject>

/**
 是否可以处理指定规则

 @param identifier 规则标识符
 @param param 规则对应参数
 @return 标识是否可以处理的BOOL值
 */
- (BOOL)canHandleRule:(NSString *)identifier param:(NSDictionary *)param;

/**
 处理指定规则

 @param identifier 规则标识符
 @param param 规则对应参数
 @param success 可以同步或者异步，由实现方控制
 @param failure 可以同步或者异步，由实现方控制
 */
- (void)handleRule:(NSString *)identifier
             param:(NSDictionary *)param
           success:(AKRuleResponseSuccess)success
           failure:(AKRuleResponseFailure)failure;

/**
 规则被意外取消

 @param identifier 规则标识符
 @param error NSError错误
 */
- (void)unexpectedCancelRule:(NSString *)identifier error:(NSError *)error;

@end
