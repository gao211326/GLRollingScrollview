//
//  ViewController.m
//  GLRollingScrollview
//
//  Created by 高磊 on 2017/3/7.
//  Copyright © 2017年 高磊. All rights reserved.
//

#import "ViewController.h"
#import "GLRollingScrollview.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSMutableArray *images = [[NSMutableArray alloc] init];
    
    for (int i =0; i < 6; i ++)
    {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg",i+1]];
        [images addObject:image];
    }
    
    NSArray *array = @[@"http://tupian.enterdesk.com/2012/1214/dqd/02/_30.jpg",@"http://image.tianjimedia.com/uploadImages/2014/139/05/BP14777AHBYY_1000x500.jpg",@"http://tupian.enterdesk.com/2013/lxy/06/22/4.jpg"];
    
    [images addObjectsFromArray:array];
    
    GLRollingScrollview *rollingScrollView = [GLRollingScrollview creatGLRollingScrollviewWithFrame:CGRectMake(0, 60, self.view.frame.size.width, 200) imageArray:images timeInterval:2 didSelect:^(NSInteger atIndex)
    {
            NSLog(@" 打印信息:%ld",(long)atIndex);
    } didScroll:^(NSInteger toIndex) {
        
    }];
    
    [self.view addSubview:rollingScrollView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
