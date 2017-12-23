//
//  ViewController.m
//  TestRefresh
//
//  Created by FQL on 2017/12/23.
//  Copyright © 2017年 FQL. All rights reserved.
//

#import "ViewController.h"
#import "MJRefresh.h"
#import "Masonry.h"


@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIImageView *topView;

@property (nonatomic, assign) NSInteger count;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"Title";
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.topView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.equalTo(self.view);
        make.height.mas_equalTo(200);
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1), dispatch_get_main_queue(), ^{
        self.count = 15;
        [self.tableView reloadData];
    });
    
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (![self.tableView isEqual:scrollView]) {
        return;
    }
    
    CGFloat offsetY = scrollView.contentOffset.y;
    if (offsetY < 0 && offsetY > -200) { //往上推的过程 但是还没有完全推出头部高
        [self.topView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(-offsetY -200 );
        }];
    }else if(offsetY > 0) { //头部隐藏 固定
        [self.topView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo( -200 );
        }];
    } else { //下拉刷新
        [self.topView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0 );
        }];
    }
    
}

#pragma mark Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.text = [NSString stringWithFormat:@"cell %ld",indexPath.row];
    return cell;
}


#pragma mark setter and getter
- (UIImageView *)topView {
    if (!_topView) {
        _topView = [[UIImageView alloc] init];
        _topView.contentMode = UIViewContentModeScaleToFill;
        _topView.image = [UIImage imageNamed:@"Head"];
    }
    return _topView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        //顶部高度虽然是200 但是要减去状态栏的20高，，所以offset高为180
        _tableView.contentInset = UIEdgeInsetsMake(180, 0, 0, 0);
        _tableView.scrollIndicatorInsets = UIEdgeInsetsMake(180, 0, 0, 0);
        MJWeakSelf;
        _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            weakSelf.count = 15;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1), dispatch_get_main_queue(), ^{
                [_tableView.mj_header endRefreshing];
            });
            [weakSelf.tableView reloadData];
        }];
        
        
        _tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            weakSelf.count += 15;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1), dispatch_get_main_queue(), ^{
                [_tableView.mj_footer endRefreshing];
            });
            [weakSelf.tableView reloadData];
        }];
    }
    return _tableView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
