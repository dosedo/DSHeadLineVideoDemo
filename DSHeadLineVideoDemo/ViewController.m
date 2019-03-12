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
@property (nonatomic, strong) NSArray *datas;
@end

@implementation ViewController{
    DSCyclePageView *_pageView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _datas = @[@"",@"",@"",@"",@"",@"",@"",@"",@"",@""];
    
    CGSize size = [UIScreen mainScreen].bounds.size;
    _pageView = [[DSCyclePageView alloc] initWithFrame:CGRectMake(0, 60, size.width, size.height-2*60)];
    _pageView.delegate = self;
    [_pageView reloadData];
    
    [self.view addSubview:_pageView];
    
    UIButton *btn = [UIButton new];
    [btn setTitle:[self getTitle] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    btn.frame = CGRectMake((size.width-150)/2, 100, 150, 40);
    btn.layer.masksToBounds = YES;
    btn.layer.borderWidth = 1;
    btn.layer.borderColor = [UIColor orangeColor].CGColor;
    btn.layer.cornerRadius = 20;
    [self.view addSubview:btn];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    [btn addTarget:self action:@selector(handleFresh:) forControlEvents:UIControlEventTouchUpInside];
}

- (NSString*)getTitle{
//    NSString *titles = [@"刷新_index_" stringByAppendingString:@(_pageView.currIndex).stringValue];
    return @"刷新";
}

- (void)handleFresh:(UIButton*)btn{
    
//    _pageView.currIndex = (rand()%10);
    
    [_pageView reloadData];
    
    [btn setTitle:[self getTitle] forState:UIControlStateNormal];
}

#pragma mark - Delegate

- (NSInteger)cyclePageViewItemCount:(DSCyclePageView *)pageView{
    return _datas.count;
}

- (UIView *)cyclePageView:(DSCyclePageView *)pageView itemViewAtIndex:(NSInteger)Index{
    UILabel *lbl = (UILabel*)[pageView dequeueReusableItemView];
    if( lbl == nil ){
        lbl = [UILabel new];
        lbl.backgroundColor = [UIColor colorWithRed:rand()%255/255.0 green:rand()%255/255.0 blue:rand()%255/255.0 alpha:1];
    }
    lbl.textColor = [UIColor redColor];
    lbl.font = [UIFont systemFontOfSize:36];
    lbl.text = @(Index).stringValue;
    lbl.textAlignment = NSTextAlignmentCenter;
    
    if( Index == _datas.count - 2 ){
        //加载数据
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:30];
        [arr addObjectsFromArray:_datas];
        [arr addObjectsFromArray:@[@"",@"",@"",@"",@"",@"",@"",@""]];
        _datas = arr;
        
        [pageView reloadCurrIndexPageData];
    }
    
    return lbl;
}


@end
