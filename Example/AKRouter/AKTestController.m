//
//  AKTestController.m
//  AKRouter
//
//  Created by 李翔宇 on 2017/6/5.
//  Copyright © 2017年 Freud. All rights reserved.
//

#import "AKTestController.h"

@interface AKTestController ()

@end

@implementation AKTestController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Test";
    
    self.view.backgroundColor = UIColor.whiteColor;
    
    UIButton *alertButton = [UIButton buttonWithType:UIButtonTypeCustom];
    alertButton.backgroundColor = UIColor.grayColor;
    [alertButton setTitle:@"弹框消息" forState:UIControlStateNormal];
    [alertButton addTarget:self action:@selector(alertButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:alertButton];
    
    UIButton *schemeAlertButton = [UIButton buttonWithType:UIButtonTypeCustom];
    schemeAlertButton.backgroundColor = UIColor.grayColor;
    [schemeAlertButton setTitle:@"scheme弹框消息" forState:UIControlStateNormal];
    [schemeAlertButton addTarget:self action:@selector(schemeAlertButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:schemeAlertButton];
    
    UIButton *colorButton = [UIButton buttonWithType:UIButtonTypeCustom];
    colorButton.backgroundColor = UIColor.grayColor;
    [colorButton setTitle:@"颜色消息" forState:UIControlStateNormal];
    [colorButton addTarget:self action:@selector(colorButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:colorButton];
    
    UIButton *sumButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sumButton.backgroundColor = UIColor.grayColor;
    [sumButton setTitle:@"计算消息" forState:UIControlStateNormal];
    [sumButton addTarget:self action:@selector(sumButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sumButton];
    
    [alertButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(64. + 50.);
        make.height.mas_equalTo(50.);
        make.centerX.mas_equalTo(0.);
    }];
    
    [schemeAlertButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(alertButton.mas_bottom).mas_offset(20.);
        make.height.mas_equalTo(alertButton);
        make.centerX.mas_equalTo(alertButton);
    }];
    
    [colorButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(schemeAlertButton.mas_bottom).mas_offset(20.);
        make.height.mas_equalTo(schemeAlertButton);
        make.centerX.mas_equalTo(schemeAlertButton);
    }];
    
    [sumButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(colorButton.mas_bottom).mas_offset(20.);
        make.height.mas_equalTo(colorButton);
        make.centerX.mas_equalTo(colorButton);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

static NSUInteger AKTestControllerAlertTimes = 0;

- (void)alertButtonTouchUpInside:(UIButton *)button {
    AKTestControllerAlertTimes++;
    
    [AKRuleManager requestRule:AKRuleAlert
                         param:@{AKRuleAlertParamTimesKey : @(AKTestControllerAlertTimes)}
                          mode:AKRuleModeExact
                       success:^(id result) {
                           
                       }
                       failure:^(NSError *error) {
                           
                       }];
}

- (void)schemeAlertButtonTouchUpInside:(UIButton *)button {
    AKTestControllerAlertTimes++;
    
    NSString *url = [NSString stringWithFormat:@"autohome://main/ui/alert?times=%@", @(AKTestControllerAlertTimes)];
    [AKRuleManager requestSchemeURL:url success:^(id result) {
        
    } failure:^(NSError *error) {
        
    }];
}

- (void)colorButtonTouchUpInside:(UIButton *)button {
    [AKRuleManager requestRule:AKRuleChangeColor
                         param:@{AKRuleChangeColorParamColorKey : UIColor.blueColor}
                          mode:AKRuleModeBroadcast
                       success:^(id result) {
                           
                       }
                       failure:^(NSError *error) {
                           
                       }];
}

- (void)sumButtonTouchUpInside:(UIButton *)button {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [AKRuleManager requestRule:AKRuleSum
                         param:@{@(1) : @(3), @(1) : @(4)}
                          mode:AKRuleModeExact
                       success:^(id result) {
                           NSLog(@"计算结果为 ：%@", result);
                           dispatch_semaphore_signal(semaphore);
                       }
                       failure:^(NSError *error) {
                           NSLog(@"计算失败");
                           dispatch_semaphore_signal(semaphore);
                       }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    NSLog(@"计算消息结束");
}

@end
