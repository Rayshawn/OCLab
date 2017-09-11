//
//  GCD_dispatchVC.m
//  CodeDemo
//
//  Created by shawn on 17/8/23.
//  Copyright © 2017年 wangrui. All rights reserved.
//

#import "GCD_dispatchVC.h"

@interface GCD_dispatchVC ()

@end

@implementation GCD_dispatchVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self dispatch_semaphore2];
}

- (void)dispatch_semaphore2 {
    int data = 3;
    __block int mainData = 0;
    __block dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    dispatch_queue_t queue = dispatch_queue_create("studyBlock", NULL);
    dispatch_async(queue, ^{
        int sum = 0;
        for (int i = 0; i < 5; i++) {
            sum += data;
            NSLog(@">>>> sum: %d", sum);
        }
        dispatch_semaphore_signal(sem);
    });
    
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);// 信号量为0时就一直等待，知道信号量大于0才执行
    for (int j = 0; j < 5; j++) {
        mainData++;
        NSLog(@">>> main data: %d",mainData);
    }
    
}


- (void)dispatch_semaphore {
//信号量
    dispatch_queue_t queues = dispatch_queue_create(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < 10; ++i) {
        dispatch_async(queues, ^{
            long result = dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            NSLog(@">>>   %ld",result);
            [array addObject:[NSNumber numberWithInt:i]];
            dispatch_semaphore_signal(semaphore);
        });
    }
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
