//
//  ViewController.m
//  DSHeadLineVideoDemo
//
//  Created by cgw on 2019/3/11.
//  Copyright © 2019 bill. All rights reserved.
//

#import "ViewController.h"
#import "DSCyclePageView.h"

@interface ViewController ()<DSCyclePageViewDelegate>

@end

@implementation ViewController{
    DSCyclePageView *_pageView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    CGSize size = [UIScreen mainScreen].bounds.size;
    _pageView = [[DSCyclePageView alloc] initWithFrame:CGRectMake(0, 60, size.width, size.height-2*60)];
    _pageView.delegate = self;
    [_pageView registerItemViewClassName:@"UILabel"];
    
    [_pageView reloadData];
    
    [self.view addSubview:_pageView];
}


#pragma mark - Delegate
- (void)cyclePageViewLoadNextPageData:(DSCyclePageView *)pageView{
    
    [pageView endLoadNextPageDataWithIsHaveNewData:NO];
}

- (NSInteger)cyclePageViewItemCount:(DSCyclePageView *)pageView{
    return 10;
}

- (void)cyclePageView:(DSCyclePageView *)pageView scrollToItemView:(UIView *)itemView itemIndex:(NSInteger)Index{
    UILabel *lbl = (UILabel*)itemView;
    lbl.textColor = [UIColor redColor];
    lbl.font = [UIFont systemFontOfSize:36];
    lbl.text = @(Index).stringValue;
    lbl.textAlignment = NSTextAlignmentCenter;
}

@end
