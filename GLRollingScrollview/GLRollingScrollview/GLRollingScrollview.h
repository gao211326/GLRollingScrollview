//
//  GLRollingScrollview.h
//  PractiseDemo
//
//  Created by 高磊 on 16/6/2.
//  Copyright © 2016年 高磊. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  点击block
 *
 *  @param atIndex 点击的index
 */
typedef void(^GLRollingScrollviewDidSelectIndexBlock)(NSInteger atIndex);

/**
 *  滚动block
 *
 *  @param toIndex 滚动到当前那个位置
 */
typedef void(^GLRollingScrollviewDidScrollToIndexBlock)(NSInteger toIndex);

@interface GLRollingScrollview : UIView

/**
 *  返回GLRollingScrollview对象
 *
 *  @param frame          大小及坐标
 *  @param imageArray     图片资源（url，image均可）
 *  @param timeinterval   自动滚动时间
 *  @param didSelectBlock 被点击block
 *  @param didScrollBlock 滚动block
 *
 *  @return 返回当前对象
 */
+(instancetype)creatGLRollingScrollviewWithFrame:(CGRect)frame
                                      imageArray:(NSArray *)imageArray
                                    timeInterval:(NSTimeInterval )timeinterval
                                       didSelect:(GLRollingScrollviewDidSelectIndexBlock)didSelectBlock
                                       didScroll:(GLRollingScrollviewDidScrollToIndexBlock)didScrollBlock;

/**
 *  启动定时器
 */
- (void)startTimer;

/**
 *  暂停定时器
 */
- (void)pauseTimer;

@end
