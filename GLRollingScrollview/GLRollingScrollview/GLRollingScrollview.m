//
//  GLRollingScrollview.m
//  PractiseDemo
//
//  Created by 高磊 on 16/6/2.
//  Copyright © 2016年 高磊. All rights reserved.
//

#import "GLRollingScrollview.h"
#import "UIImageView+WebCache.h"

static NSString *const GLRollingScrollviewCellId = @"GLRollingScrollviewCellId";

//当到100个的时候，会自动滚到第一个
static NSInteger const kMaxRollingScrollViewNumber = 100;

@interface GLRollingScrollviewCell : UICollectionViewCell

@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) UILabel *titleLable;

@end

@implementation GLRollingScrollviewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        

        
        self.imageView = [[UIImageView alloc] init];
        [self addSubview:self.imageView];
        
        self.titleLable = [[UILabel alloc] init];
        self.titleLable.textColor = [UIColor redColor];
        self.titleLable.font = [UIFont systemFontOfSize:15];
        self.titleLable.textAlignment = NSTextAlignmentLeft;
        self.titleLable.hidden = YES;
        [self addSubview:self.titleLable];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.frame = self.bounds;
    self.titleLable.frame = CGRectMake(0, self.frame.size.height - 30, self.frame.size.width, 30);
    self.titleLable.hidden = self.titleLable.text.length > 0 ? NO : YES;
}

@end


@interface GLRollingScrollview ()<UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate>

@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) UICollectionViewFlowLayout *collectionFlowLayout;

@property (nonatomic,assign) NSTimeInterval intervalTimer;

@property (nonatomic,copy) GLRollingScrollviewDidSelectIndexBlock rollingDidSelectBlock;
@property (nonatomic,copy) GLRollingScrollviewDidScrollToIndexBlock rollingDidScrollBlock;

@property (nonatomic, assign) CFRunLoopTimerRef timer;

@property (nonatomic,assign) NSInteger totalNumber;

@end

@implementation GLRollingScrollview


+(instancetype)creatGLRollingScrollviewWithFrame:(CGRect)frame
                                      imageArray:(NSArray *)imageArray
                                    timeInterval:(NSTimeInterval )timeinterval
                                       didSelect:(GLRollingScrollviewDidSelectIndexBlock)didSelectBlock
                                       didScroll:(GLRollingScrollviewDidScrollToIndexBlock)didScrollBlock
{
    GLRollingScrollview *rollingScrollView = [[GLRollingScrollview alloc] initWithFrame:frame];
    rollingScrollView.rollingDidSelectBlock = didSelectBlock;
    rollingScrollView.rollingDidScrollBlock = didScrollBlock;
    rollingScrollView.imageUrlArray = imageArray;
    rollingScrollView.intervalTimer = timeinterval;
    [rollingScrollView initGLRollingScroll];
    return rollingScrollView;
}

- (void)dealloc
{
    
}

- (void)removeFromSuperview
{
    [self pauseTimer];
    
    [super removeFromSuperview];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self addCollectionView];
        
    }
    return self;
}


#pragma mark == setter

- (void)setIntervalTimer:(NSTimeInterval)intervalTimer
{
    _intervalTimer = intervalTimer;
    
    [self startTimer];
}


- (void)setImageUrlArray:(NSArray *)imageUrlArray
{
    if (![imageUrlArray isKindOfClass:[NSArray class]])
    {
        return;
    }
    
    if (imageUrlArray == nil || imageUrlArray.count == 0)
    {
        self.totalNumber = 0;
        [self pauseTimer];
        self.collectionView.scrollEnabled = NO;
        [self.collectionView reloadData];
    }
    
    if (_imageUrlArray != imageUrlArray)
    {
        _imageUrlArray = imageUrlArray;
        
        if (imageUrlArray.count > 1)
        {
            self.totalNumber = imageUrlArray.count * kMaxRollingScrollViewNumber;
            [self startTimer];
            self.collectionView.scrollEnabled = YES;
        }
        else
        {
            [self pauseTimer];
            self.totalNumber = 1;
            self.collectionView.scrollEnabled = NO;
        }
        [self.collectionView reloadData];
    }
}


#pragma mark == private method

- (void)addCollectionView
{
    self.collectionFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    self.collectionFlowLayout.minimumLineSpacing = 0;
    self.collectionFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.collectionFlowLayout.itemSize = self.bounds.size;
    
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:self.collectionFlowLayout];
    self.collectionView.dataSource = (id)self;
    self.collectionView.delegate = (id)self;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.showsVerticalScrollIndicator = self.collectionView.showsHorizontalScrollIndicator = NO;
    [self.collectionView registerClass:[GLRollingScrollviewCell class] forCellWithReuseIdentifier:GLRollingScrollviewCellId];
    [self addSubview:self.collectionView];
}

//滚动到中间位置
- (void)initGLRollingScroll
{
    if (self.totalNumber == 0)
    {
        return;
    }
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.totalNumber * 0.5 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
}

//开启定时器
- (void)startTimer
{
    [self cofigTimer];
}

//关闭定时器
- (void)pauseTimer
{
    if (self.timer)
    {
        CFRunLoopTimerInvalidate(self.timer);
        CFRunLoopRemoveTimer(CFRunLoopGetCurrent(), self.timer, kCFRunLoopCommonModes);
    }
}

//配置定时器
- (void)cofigTimer
{
    if (self.imageUrlArray.count <= 1)
    {
        return;
    }
    
    if (self.timer)
    {
        CFRunLoopTimerInvalidate(self.timer);
        CFRunLoopRemoveTimer(CFRunLoopGetCurrent(), self.timer, kCFRunLoopCommonModes);
    }
    
    __weak typeof(self)weakSelf = self;
    
    CFRunLoopTimerRef time = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, CFAbsoluteTimeGetCurrent()+ _intervalTimer, _intervalTimer, 0, 0, ^(CFRunLoopTimerRef timer) {
        [weakSelf autoScroll];
    });
    self.timer  = time;
    CFRunLoopAddTimer(CFRunLoopGetCurrent(), time, kCFRunLoopCommonModes);
}

//自动滚动
- (void)autoScroll
{
    NSInteger currentIndex = (self.collectionView.contentOffset.x + self.collectionFlowLayout.itemSize.width * 0.5) / self.collectionFlowLayout.itemSize.width;
    NSInteger toIndex = currentIndex + 1;
    
    NSIndexPath *indexPath = nil;
    if (toIndex == self.totalNumber)
    {
        toIndex = self.totalNumber * 0.5;
        indexPath = [NSIndexPath indexPathForRow:toIndex inSection:0];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
    else
    {
        indexPath = [NSIndexPath indexPathForItem:toIndex inSection:0];
        
        [self.collectionView scrollToItemAtIndexPath:indexPath
                                    atScrollPosition:UICollectionViewScrollPositionNone
                                            animated:YES];
    }
}

#pragma mark == UICollectionViewDelegate


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.totalNumber;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GLRollingScrollviewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:GLRollingScrollviewCellId forIndexPath:indexPath];
    NSInteger itemIndex = indexPath.row % self.imageUrlArray.count;

    if (itemIndex < self.imageUrlArray.count)
    {
        NSString *urlString = self.imageUrlArray[itemIndex];
        if ([urlString isKindOfClass:[UIImage class]])
        {
            cell.imageView.image = (UIImage *)urlString;
        }
        else if ([urlString hasPrefix:@"http://"] ||
                 [urlString hasPrefix:@"https://"] ||
                 [urlString rangeOfString:@"/"].location != NSNotFound)
        {
            [cell.imageView sd_setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:[UIImage imageNamed:@"图片加载失败"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (!image)
                {
                    [cell.imageView setImage:[UIImage imageNamed:@"图片加载失败"]];
                }
            }];
        }
        else
        {
            cell.imageView.image = [UIImage imageNamed:urlString];
        }
    }
    
    if (itemIndex < self.titleArray.count)
    {
        cell.titleLable.text = self.titleArray[itemIndex];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.totalNumber == 0)
    {
        return;
    }
    if (self.rollingDidSelectBlock)
    {
        self.rollingDidSelectBlock(indexPath.row % self.imageUrlArray.count);
    }
}


#pragma mark == UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self pauseTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self startTimer];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.totalNumber == 0)
    {
        return;
    }
    
    NSInteger currentIndex = (scrollView.contentOffset.x + self.collectionView.frame.size.width * 0.5) / self.collectionView.frame.size.width;;
    
    currentIndex = currentIndex % self.imageUrlArray.count;
    
    
    CGFloat x = scrollView.contentOffset.x - self.collectionView.frame.size.width;
    NSUInteger index = fabs(x) / self.collectionView.frame.size.width;
    CGFloat fIndex = fabs(x) / self.collectionView.frame.size.width;
    

    //下面的第二个条件 可以确保 尽量一次去执行block 而不多次
    if (self.rollingDidScrollBlock && fabs(fIndex - (CGFloat)index) <= 0.00001)
    {        
//            NSLog(@" 打印信息:%ld",(long)currentIndex);
        
        self.rollingDidScrollBlock(currentIndex);
    }
    
}

@end
