//
//  DSCyclePageView.m
//  DSHeadLineVideoDemo
//
//  Created by cgw on 2019/3/11.
//  Copyright © 2019 bill. All rights reserved.
//

#import "DSCyclePageView.h"

@interface DSCyclePageViewScrollView : UIScrollView
@end

@interface DSCyclePageView()<UIScrollViewDelegate>
@property (nonatomic, strong) NSMutableArray *itemViews;
@property (nonatomic, assign) NSInteger currIndex;
@property (nonatomic, assign) NSInteger count;
@end

@implementation DSCyclePageView{
    
    NSInteger _willShowItemIndex;  //将要展示的item的索引
    NSInteger _maxItemViewCount;   //最大的itemView的数量。规定5个
}

@synthesize scrollView = _scrollView;

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if( self ){
        _currIndex = 0;
        _maxItemViewCount = 3;
        self.scrollView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    }
    return self;
}

- (UIView*)dequeueReusableItemView{
    if( self.itemViews.count < _maxItemViewCount){
        return nil;
    }
    else{
        BOOL isSlideToRight = ((_willShowItemIndex) < _currIndex);
        NSInteger index = isSlideToRight?(_itemViews.count-1):0;
        if( _itemViews.count > index ){
            UIView *willShowItemView = _itemViews[index];
            [_itemViews removeObjectAtIndex:index];
            if( isSlideToRight ){
                [_itemViews insertObject:willShowItemView atIndex:0];
            }else{
                [_itemViews addObject:willShowItemView];
            }
            return willShowItemView;
        }
        return nil;
    }
}

- (void)reloadData{
    
    if( _delegate == nil ) return;
    
    NSInteger count = 0;
    if( [_delegate respondsToSelector:@selector(cyclePageViewItemCount:)] ){
        count = [_delegate cyclePageViewItemCount:self];
        _count = count;
    }
    
    if( count <= 0 ){
        [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        return;
    }
    
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);
    CGFloat contentW = width*count;
    [self.scrollView setContentSize:CGSizeMake(contentW, height)];
    
    [self.itemViews removeAllObjects];
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    if( [_delegate respondsToSelector:@selector(cyclePageView:itemViewAtIndex:)] ){
        
        //重加载数据时，最多加载3个数据。
        NSInteger itemCount = 3;
        if( count < itemCount ){
            itemCount = count;
        }
        NSInteger startIndex = 0;
        if( _currIndex <=1){
            startIndex = 0;
        }else if( _currIndex >= count-2 ){
            startIndex = count-3;
        }
        else{
            startIndex = _currIndex-1;
        }
        
        for( NSInteger i=0; i<itemCount; i++ ){
            
            UIView *item = [_delegate cyclePageView:self itemViewAtIndex:i+startIndex];
            if( item && (self.itemViews.count <= _maxItemViewCount) && ( [self.itemViews containsObject:item]==NO )){
                [self.itemViews addObject:item];
                [self.scrollView addSubview:item];
            }
            item.frame = CGRectMake((startIndex+i)*width, 0, width, height);
        }
        
        [self.scrollView setContentOffset:CGPointMake(_currIndex*width, 0)];
    }
}

- (void)reloadCurrIndexPageData{
    
    if( _delegate == nil ) return;
    
    //若当前页面停留在上次加载数据的最后一个页面，则重新加载一次本页数据。
    if( _currIndex == _count-1 ){
        [_delegate cyclePageView:self itemViewAtIndex:_currIndex];
    }
    
    NSInteger count = 0;
    if( [_delegate respondsToSelector:@selector(cyclePageViewItemCount:)] ){
        count = [_delegate cyclePageViewItemCount:self];
        _count = count;
    }
    
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);
    CGFloat contentW = width*count;
    [self.scrollView setContentSize:CGSizeMake(contentW, height)];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if( _count <= _maxItemViewCount ) return;
    
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat nextItemViewCenterX = _currIndex *width + width/2;
    CGFloat frontItemViewCenterX = _currIndex *width - width/2;
    CGFloat offsetX = scrollView.contentOffset.x;
    NSInteger willShowIndex = _currIndex;
    
    NSInteger addIndex = 1;
    if( offsetX > nextItemViewCenterX ){
        if( willShowIndex < _count-1){
            willShowIndex ++;
        }
    }
    else if( offsetX < frontItemViewCenterX ){
        if( willShowIndex > 0 ){
            willShowIndex --;
            
            addIndex = -addIndex;
        }
    }
    
    //滚动超过一半的宽度，则加载下一个或上一个item
    if( willShowIndex != _currIndex ){
        
        //不加载新的视图的情况
        if( _currIndex < 2 || _currIndex > _count-3 ){
            if( _currIndex == 0 || _currIndex == _count-1 ){
                _currIndex = willShowIndex;
                return;
            }
            else if( _currIndex == 1 && willShowIndex < _currIndex ){
                _currIndex = willShowIndex;
                return;
            }
            else if( _currIndex == _count-2 && willShowIndex > _currIndex ){
                _currIndex = willShowIndex;
                return;
            }
        }
        
        if( _delegate && [_delegate respondsToSelector:@selector(cyclePageView:itemViewAtIndex:)] ){
            
            _willShowItemIndex = willShowIndex;
            
            NSLog(@"加载item");
            UIView *item = [_delegate cyclePageView:self itemViewAtIndex:willShowIndex+addIndex];
            
            if( item && (self.itemViews.count <= _maxItemViewCount) && ( [self.itemViews containsObject:item]==NO )){
                [self.itemViews addObject:item];
                [self.scrollView addSubview:item];
            }
            
            CGFloat width = CGRectGetWidth(self.frame);
            CGFloat height = CGRectGetHeight(self.frame);
            item.frame = CGRectMake((willShowIndex+addIndex)*width, 0, width, height);
            
            _currIndex = willShowIndex;
        }
    }
}

#pragma mark - Getter
- (UIScrollView *)scrollView{
    if( !_scrollView ){
        _scrollView = [DSCyclePageViewScrollView new];
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        _scrollView.scrollEnabled = YES;
        
        [self addSubview:_scrollView];
        
        if (@available(iOS 11.0, *)) {
            _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }else{
            _scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        }
    }
    return _scrollView;
}

- (NSMutableArray *)itemViews {
    if( !_itemViews ){
        _itemViews = [NSMutableArray new];
    }
    return _itemViews;
}

@end

/*
 若数据不多于3个。则加载全部数据。
 若数据多于3个，则：
 每次加载 都要加载3页的数据
 
 滚动过程：
 当滑动至当前页时，下载下一页或上一页的数据。
 */


@implementation DSCyclePageViewScrollView

- (id)init{
    self = [super init];
    if( self )
    {
        [self initSelf];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self initSelf];
    }
    return self;
}

- (void)initSelf{
    //为了防止，uibutton 加在tableview上后，没有效果的问题
    self.canCancelContentTouches = YES;
    self.delaysContentTouches = NO;
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view{
    return YES;
}

@end
