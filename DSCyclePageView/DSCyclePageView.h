//
//  DSCyclePageView.h
//  DSHeadLineVideoDemo
//
//  Created by cgw on 2019/3/11.
//  Copyright © 2019 bill. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DSCyclePageViewDelegate;
/**
 横向滑动页面，左滑下一页面，右滑上一页。
 */
@interface DSCyclePageView : UIView

@property (nonatomic, weak) id<DSCyclePageViewDelegate> delegate ;

@property (nonatomic, strong, readonly) UIScrollView *scrollView;

/**
 当在最后一页，继续滚动时，是否需要加载下一页数据的页面。默认为YES
 */
@property (nonatomic, assign) BOOL needLoadNextPageData;

//设置页面上展示的itemView的类。默认为UIView
- (void)registerItemViewClassName:(NSString*)itemClassName;

- (void)endLoadNextPageDataWithIsHaveNewData:(BOOL)isHaveNewData;

//刷新当前展示的页面的数据
- (void)reloadData;

@end

@protocol DSCyclePageViewDelegate <NSObject>

@optional
- (NSInteger)cyclePageViewItemCount:(DSCyclePageView*)pageView;
- (void)cyclePageView:(DSCyclePageView*)pageView scrollToItemView:(UIView*)itemView itemIndex:(NSInteger)Index;
- (void)cyclePageViewLoadNextPageData:(DSCyclePageView *)pageView;
@end

NS_ASSUME_NONNULL_END
