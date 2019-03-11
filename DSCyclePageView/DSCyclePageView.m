//
//  DSCyclePageView.m
//  DSHeadLineVideoDemo
//
//  Created by cgw on 2019/3/11.
//  Copyright © 2019 bill. All rights reserved.
//

#import "DSCyclePageView.h"

@interface DSCyclePageView()<UIScrollViewDelegate>
@property (nonatomic, assign) NSInteger currIndex;    //当前展示的索引
@property (nonatomic, strong) NSMutableArray *itemViews;
@end

@implementation DSCyclePageView{
    NSString *_itemClassName;
    NSInteger _count;
}

@synthesize scrollView = _scrollView;

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if( self ){
        _needLoadNextPageData = YES;
        _currIndex = 0;
        _itemClassName = @"UIView";
        self.scrollView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    }
    return self;
}

- (void)registerItemViewClassName:(NSString *)itemClassName{
    _itemClassName = itemClassName;
}

- (void)endLoadNextPageDataWithIsHaveNewData:(BOOL)isHaveNewData{
    if( isHaveNewData ){
        _currIndex ++;
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
    CGFloat contentW = width*(_needLoadNextPageData?(count+1):count);
    [self.scrollView setContentSize:CGSizeMake(contentW, height)];
    
    NSInteger itemViewMaxCount = 3;
    //若数据数量小于最大itemView的数量，则不考虑复用
    if( count <= itemViewMaxCount ){
        itemViewMaxCount = count;
    }
    
    [self.itemViews removeAllObjects];
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    
    CGFloat startX = 0;
    if( _currIndex < count ){
        if( _currIndex ==0 ){
            startX = 0;
        }else if( _currIndex == count-1 ){
            startX = contentW - ((_needLoadNextPageData?(itemViewMaxCount+1):itemViewMaxCount)*width);
        }else{
            startX = (_currIndex-1)*width;
        }
    }
    
    for( NSInteger i=0; i<itemViewMaxCount; i++ ){
        UIView* itemView = (UIView*)[[NSClassFromString(_itemClassName) alloc] init];
        
        itemView.backgroundColor = [UIColor colorWithWhite:rand()%255/255.0 alpha:1];
        
        if( ![itemView isKindOfClass:[UIView class]] ){
            return;
        }
        
        itemView.frame = CGRectMake(startX+i*width, 0, width, height);
        [self.scrollView addSubview:itemView];
        
        [self.itemViews addObject:itemView];
    }
    
    if( _delegate && [_delegate respondsToSelector:@selector(cyclePageView:scrollToItemView:itemIndex:)] ){
        
        [_delegate cyclePageView:self scrollToItemView:[self itemViewWithCurrIndex:_currIndex] itemIndex:_currIndex];
    }
}

- (UIView*)itemViewWithCurrIndex:(NSInteger)index{
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat offx = index*width;
    for( UIView *view in self.itemViews ){
        if( view.center.x > offx && view.center.x < offx+width ){
            return view;
        }
    }
    return nil;
}

//将某个视图设置为中心，index，即将设置为中心的视图的索引
- (void)setCenterItemViewWithIndex:(NSInteger)index startX:(CGFloat)startX{
    //三个视图，只有三种情况：012、201、120
    if( self.itemViews.count <= index ) return;
    
    UIView *midView = _itemViews[index];
    midView.center =
    CGPointMake(startX+CGRectGetWidth(midView.frame)*1.5,midView.center.y);
    
    NSInteger frontIdx = (index==0)?2:(index-1);
    NSInteger nextIdx = (index==2)?0:(index+1);
    
    if( _itemViews.count > frontIdx ){
        UIView *frontView = _itemViews[frontIdx];
        frontView.center = CGPointMake(startX+CGRectGetWidth(midView.frame),midView.center.y);
    }
    
    if( _itemViews.count > nextIdx ){
        UIView *nextView = _itemViews[frontIdx];
        nextView.center = CGPointMake(startX+CGRectGetWidth(midView.frame)*2.5,midView.center.y);
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    CGFloat width = CGRectGetWidth(self.frame);
    NSInteger newIndex = (int)((scrollView.contentOffset.x+10) / width );
    
    if( newIndex == _count ){
        if([_delegate respondsToSelector:@selector(cyclePageViewLoadNextPageData:)] ){
            [_delegate cyclePageViewLoadNextPageData:self];
        }
        return;
    }

    _currIndex = newIndex;
    
    if( _delegate && [_delegate respondsToSelector:@selector(cyclePageView:scrollToItemView:itemIndex:)] ){
        UIView *showView = [self itemViewWithCurrIndex:_currIndex];
        [_delegate cyclePageView:self scrollToItemView:showView itemIndex:_currIndex];
        
        NSInteger i=0;
        CGFloat baseX = CGRectGetMinX(showView.frame);
        for( UIView *view in self.itemViews ){
            if( [view isEqual:showView] ) continue;
            
            CGFloat ix = CGRectGetMinX(view.frame);
            if( _currIndex == 0 ){
                //将其他视图 移到展示视图后面
                ix = baseX + width + (i*width);
            }else if( _currIndex == _count-1 ){
                //将其他视图 移到展示视图前面
                ix = baseX - width - width*i;
            }else{
                //将其他视图 移到展示视图的两侧
                ix = baseX -width;
                if( i>0 ){
                    ix = baseX + width;
                }
            }
            
            CGRect fr = view.frame;
            fr.origin.x = ix;
            view.frame = fr;
            
            i++;
        }
    }
}

#pragma mark - Getter
- (UIScrollView *)scrollView{
    if( !_scrollView ){
        _scrollView = [UIScrollView new];
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
