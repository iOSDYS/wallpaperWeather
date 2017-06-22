//
//  SelectAddressController.m
//  KaiYuanJieKou
//
//  Created by jiachen on 16/4/25.
//  Copyright © 2016年 jiachenmu. All rights reserved.
//

#import "SelectAddressController.h"

#import "CityModel.h"
#import "SelectAddressCell.h"
#import "CityModel.h"
#import "NSObject+Model.h"
#import "TipView.h"

@interface SelectAddressController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

/// 热门城市列表
@property (nonatomic,strong) NSArray *hotCityList;
/// 查询的城市列表
@property (nonatomic,strong) NSMutableArray *searchCityList;
@property (nonatomic,strong) NSMutableArray *cityArray;
@end

@implementation SelectAddressController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self setUpHotCityList];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"City" ofType:@"json"];
    NSData *jsonData = [[NSData alloc] initWithContentsOfFile:path];
    NSError *error;
    id jsonObj = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    _cityArray = [NSMutableArray array];
    
    for (NSDictionary *dict in jsonObj[@"result"]) {
        CityModel *model = [CityModel modelWithDict:dict];
        [_cityArray addObject:model];
    }
}

- (void)setUpHotCityList{
    _hotCityList = [[CityManager shareInstance] HotCityList];
    _searchCityList = [NSMutableArray array];
}

// -MARK: UITableViewDelegate  UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return section == 0 ? _hotCityList.count : _searchCityList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CityModel *model = indexPath.section == 0 ? _hotCityList[indexPath.row] : _searchCityList[indexPath.row];
    SelectAddressCell *cell = [SelectAddressCell cellWithUITableView:tableView CityModel:model];
    return cell;
}
    //朝阳
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = section == 0 ? @"  热门城市" : @"  搜索结果";
    titleLabel.font = DefaultFont(14);
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor colorWithHex:0x34495e];
    return titleLabel;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    CityModel *model = indexPath.section == 0 ? _hotCityList[indexPath.row] : _searchCityList[indexPath.row];
    [[CityManager shareInstance] saveCity:model];
}

// -MARK: UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self.view endEditing:YES];
    _searchCityList = [NSMutableArray array];
    NSString *text = searchBar.text;
    if (text.length == 0) {
        [TipView showTitle:@"大神，搜索内容不能为空"];
        return;
    }
    
    for (CityModel *cityModel in _cityArray) {
        if ([cityModel.city hasPrefix:text] || [cityModel.city isEqualToString:text] || [text hasPrefix:cityModel.city]) {
            [_searchCityList addObject:cityModel];
        }
    }
    
    if (_searchCityList.count == 0) {
        [TipView showTitle:@"地球上不存在该城市"];
    }
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
}

#pragma mark - 返回
- (IBAction)backToFront:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}

@end
