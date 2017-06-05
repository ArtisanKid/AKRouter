//
//  AKHighPriorityController.m
//  AKRouter
//
//  Created by 李翔宇 on 2017/6/5.
//  Copyright © 2017年 Freud. All rights reserved.
//

#import "AKHighPriorityController.h"
#import "AKRule.h"
#import "AKTestController.h"
#import "AKHighPriorityController.h"
#import "AKLowPriorityController.h"

@interface AKHighPriorityController ()<AKRuleResponderProtocol>

@end

@implementation AKHighPriorityController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"High Priority";
    
    self.view.backgroundColor = UIColor.whiteColor;
    
    UIButton *pushTestButton = [UIButton buttonWithType:UIButtonTypeCustom];
    pushTestButton.backgroundColor = UIColor.grayColor;
    [pushTestButton setTitle:@"打开测试页面" forState:UIControlStateNormal];
    [pushTestButton addTarget:self action:@selector(pushTestButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pushTestButton];
    
    UIButton *pushHighPriorityButton = [UIButton buttonWithType:UIButtonTypeCustom];
    pushHighPriorityButton.backgroundColor = UIColor.grayColor;
    [pushHighPriorityButton setTitle:@"打开HighPriority页面" forState:UIControlStateNormal];
    [pushHighPriorityButton addTarget:self action:@selector(pushHighPriorityButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pushHighPriorityButton];
    
    UIButton *pushLowPriorityButton = [UIButton buttonWithType:UIButtonTypeCustom];
    pushLowPriorityButton.backgroundColor = UIColor.grayColor;
    [pushLowPriorityButton setTitle:@"打开LowPriority页面" forState:UIControlStateNormal];
    [pushLowPriorityButton addTarget:self action:@selector(pushLowPriorityButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pushLowPriorityButton];
    
    UIButton *alertButton = [UIButton buttonWithType:UIButtonTypeCustom];
    alertButton.backgroundColor = UIColor.grayColor;
    [alertButton setTitle:@"注册弹框" forState:UIControlStateNormal];
    [alertButton addTarget:self action:@selector(alertButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:alertButton];
    
    UIButton *colorButton = [UIButton buttonWithType:UIButtonTypeCustom];
    colorButton.backgroundColor = UIColor.grayColor;
    [colorButton setTitle:@"注册颜色" forState:UIControlStateNormal];
    [colorButton addTarget:self action:@selector(colorButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:colorButton];
    
    UIButton *sumButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sumButton.backgroundColor = UIColor.grayColor;
    [sumButton setTitle:@"注册计算" forState:UIControlStateNormal];
    [sumButton addTarget:self action:@selector(sumButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sumButton];
    
    [pushTestButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(64. + 50.);
        make.height.mas_equalTo(50.);
        make.centerX.mas_equalTo(0.);
    }];
    
    [pushHighPriorityButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(pushTestButton.mas_bottom).offset(20.);
        make.height.mas_equalTo(50.);
        make.leading.mas_equalTo(0.);
    }];
    
    [pushLowPriorityButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.height.width.mas_equalTo(pushHighPriorityButton);
        make.leading.mas_equalTo(pushHighPriorityButton.mas_trailing).mas_offset(20.);
        make.trailing.mas_equalTo(0.);
    }];
    
    [alertButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(pushLowPriorityButton.mas_bottom).mas_offset(20.);
        make.leading.mas_equalTo(0.);
        make.height.mas_equalTo(50.);
    }];
    
    [colorButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.width.height.mas_equalTo(alertButton);
        make.leading.mas_equalTo(alertButton.mas_trailing).mas_offset(20.);
    }];
    
    [sumButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.width.height.mas_equalTo(colorButton);
        make.leading.mas_equalTo(colorButton.mas_trailing).mas_offset(20.);
        make.trailing.mas_equalTo(0.);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pushTestButtonTouchUpInside:(UIButton *)button {
    AKTestController *testController = [[AKTestController alloc] init];
    [self.navigationController pushViewController:testController animated:YES];
}

- (void)pushHighPriorityButtonTouchUpInside:(UIButton *)button {
    AKHighPriorityController *highPriorityController = [[AKHighPriorityController alloc] init];
    [self.navigationController pushViewController:highPriorityController animated:YES];
}

- (void)pushLowPriorityButtonTouchUpInside:(UIButton *)button {
    AKLowPriorityController *lowPriorityController = [[AKLowPriorityController alloc] init];
    [self.navigationController pushViewController:lowPriorityController animated:YES];
}

- (void)alertButtonTouchUpInside:(UIButton *)button {
    button.selected = !button.isSelected;
    if(button.isSelected) {
        [button setTitle:@"取消弹框" forState:UIControlStateNormal];
        
        AKRule *rule = [[AKRule alloc] init];
        rule.identifier = AKRuleAlert;
        rule.target = self;
        rule.priority = AKRulePriorityHigh;
        
        [AKRuleManager registerRule:rule error:nil];
    } else {
        [button setTitle:@"注册弹框" forState:UIControlStateNormal];
        
        [AKRuleManager cancelRule:AKRuleAlert target:self];
    }
}

- (void)colorButtonTouchUpInside:(UIButton *)button {
    button.selected = !button.isSelected;
    if(button.isSelected) {
        [button setTitle:@"取消颜色" forState:UIControlStateNormal];
        
        AKRule *rule = [[AKRule alloc] init];
        rule.identifier = AKRuleChangeColor;
        rule.target = self;
        rule.priority = AKRulePriorityHigh;
        
        [AKRuleManager registerRule:rule error:nil];
    } else {
        [button setTitle:@"注册颜色" forState:UIControlStateNormal];
        
        [AKRuleManager cancelRule:AKRuleAlert target:self];
    }
}

- (void)sumButtonTouchUpInside:(UIButton *)button {
    button.selected = !button.isSelected;
    if(button.isSelected) {
        [button setTitle:@"取消计算" forState:UIControlStateNormal];
        
        AKRule *rule = [[AKRule alloc] init];
        rule.identifier = AKRuleSum;
        rule.target = self;
        rule.priority = AKRulePriorityHigh;
        
        [AKRuleManager registerRule:rule error:nil];
    } else {
        [button setTitle:@"注册计算" forState:UIControlStateNormal];
        
        [AKRuleManager cancelRule:AKRuleAlert target:self];
    }
}

/**
 是否可以处理指定规则
 
 @param identifier 规则标识符
 @param param 规则对应参数
 @return 标识是否可以处理的BOOL值
 */
- (BOOL)canHandleRule:(NSString *)identifier param:(NSDictionary *)param {
    if([identifier isEqualToString:AKRuleAlert]) {
        return YES;
    } else if([identifier isEqualToString:AKRuleChangeColor]) {
        UIColor *color = param[AKRuleChangeColorParamColorKey];
        return [color isKindOfClass:[UIColor class]];
    } else if([identifier isEqualToString:AKRuleSum]) {
        for(NSNumber *number in param.allValues) {
            if(![number respondsToSelector:@selector(floatValue)]) {
                return NO;
            }
        }
        return YES;
    } else {
        return NO;
    }
}

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
           failure:(AKRuleResponseFailure)failure {
    if([identifier isEqualToString:AKRuleAlert]) {
        NSUInteger level = [self.navigationController.viewControllers indexOfObject:self];
        NSString *message = [NSString stringWithFormat:@"%@ : %@ : times->%@", self.title, @(level), param[AKRuleAlertParamTimesKey]];
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [controller addAction:action];
        [UIApplication.sharedApplication.delegate.window.rootViewController presentViewController:controller animated:YES completion:^{
            
        }];
        success(nil);
    } else if([identifier isEqualToString:AKRuleChangeColor]) {
        UIColor *color = param[AKRuleChangeColorParamColorKey];
        self.view.backgroundColor = color;
        success(nil);
    } else if([identifier isEqualToString:AKRuleSum]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            CGFloat sum = 0.;
            for(NSNumber *number in param.allValues) {
                sum += [number floatValue];
            }
            success(@(sum));
        });
    } else {
        failure(nil);
    }
}

/**
 规则被意外取消
 
 @param identifier 规则标识符
 @param error NSError错误
 */
- (void)unexpectedCancelRule:(NSString *)identifier error:(NSError *)error {
    
}

@end
