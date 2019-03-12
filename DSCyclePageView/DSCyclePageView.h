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

- (UIView*)dequeueReusableItemView;

//加载数据
- (void)reloadData;

- (void)reloadCurrIndexPageData;

@end

@protocol DSCyclePageViewDelegate <NSObject>

@optional
- (NSInteger)cyclePageViewItemCount:(DSCyclePageView*)pageView;
- (UIView*)cyclePageView:(DSCyclePageView*)pageView itemViewAtIndex:(NSInteger)Index;
@end

NS_ASSUME_NONNULL_END
