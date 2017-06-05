//
//  AKRuleProtocol.h
//  Pods
//
//  Created by 李翔宇 on 2017/5/31.
//
//

#import <Foundation/Foundation.h>
#import "AKRuleResponderProtocol.h"

typedef NS_ENUM(NSUInteger, AKRulePriority) {
    AKRulePriorityLow = 0, //低
    AKRulePriorityDefault, //默认
    AKRulePriorityHigh, //高
    AKRulePriorityRequired, //最高
    AKRulePriorityExclusive = NSUIntegerMax,// 排他 (如果已有Exclusive优先级，则注册失败；若成功，任何其他已注册优先级失效；若成功，再注册任何优先级全部失败)
};

@protocol AKRuleProtocol <NSObject>

@property (nonatomic, assign) NSString *identifier;
@property (nonatomic, weak) id<AKRuleResponderProtocol> target;
@property (nonatomic, assign) AKRulePriority priority;

@end
