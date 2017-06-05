//
//  AKRule.h
//  Pods
//
//  Created by 李翔宇 on 2017/5/31.
//
//

#import <Foundation/Foundation.h>
#import "AKRuleProtocol.h"

@interface AKRule : NSObject <AKRuleProtocol>

@property (nonatomic, assign) NSString *identifier;
@property (nonatomic, weak) id<AKRuleResponderProtocol> target;
@property (nonatomic, assign) AKRulePriority priority;

@end
