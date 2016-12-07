//
//  ViewController.m
//  Runtime
//
//  Created by CC on 2016/11/28.
//  Copyright © 2016年 CC. All rights reserved.
//

#import "ViewController.h"
#import "ExchangeMethodController.h"
#import "AddMethodController.h"
#import "TransmitController.h"

static NSString *const cellID = @"runtimeCell";

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view addSubview:self.tableView];
}

#pragma mark -- UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
        case 0:
        {
            ExchangeMethodController *exchangeMethodVC = [[ExchangeMethodController alloc]init];
            [self.navigationController pushViewController:exchangeMethodVC animated:YES];
        }
            break;
            
        case 1:
        {
            AddMethodController *addMethodVC = [[AddMethodController alloc]init];
            [self.navigationController pushViewController:addMethodVC animated:YES];
        }
            break;
            
        case 2:
        {
            TransmitController *transmitVC = [[TransmitController alloc]init];
            [self.navigationController pushViewController:transmitVC animated:YES];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark -- UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault
                                     reuseIdentifier:cellID];
    }
    cell.textLabel.text = _dataSource[indexPath.row];
    return cell;
}

#pragma mark -- getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:self.view.bounds
                                                 style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (NSArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [[NSArray alloc]initWithObjects:@"交换方法",
                                                      @"添加方法",
                                                      @"消息转发", nil];
    }
    return _dataSource;
}

@end
