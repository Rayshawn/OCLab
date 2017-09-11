
//
//  CocoaController.m
//  CodeDemo
//
//  Created by shawn on 17/9/6.
//  Copyright © 2017年 wangrui. All rights reserved.
//

#import "CocoaController.h"
@import ReactiveCocoa;
#import "Person.h"

@interface CocoaController ()

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) Person *person;

@end

@implementation CocoaController

- (Person *)person {
    if (!_person) {
        _person = [[Person alloc] init];
    }
    return _person;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 200, 100, 30)];
    self.nameLabel.textColor = [UIColor redColor];
    self.nameLabel.font = [UIFont systemFontOfSize:14];
    self.nameLabel.text = [NSString stringWithFormat:@"demo"];
    self.person.name = @"demo";
    [self.view addSubview:_nameLabel];
    [self demoKvo];
}
- (void)demoKvo {
    __weak __typeof(&*self)weakSelf = self;
    [RACObserve(weakSelf.person, name) subscribeNext:^(id x) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
         strongSelf.nameLabel.text = x;
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.person.name = [NSString stringWithFormat:@"lei %d",arc4random_uniform(100)];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
