//
//  CMNetworkManager.m
//  KaiYuanJieKou

//  Created by jiachen on 16/4/18.
//  Copyright © 2016年 jiachenmu. All rights reserved.
//

#import "CMNetworkManager.h"
#import "CityModel.h"
#import "TipModel.h"



#define AppCode      @"1147c52179084170a21295696bb77068"
#define WeatherHttp @"http://apistore.baidu.com/microservice/weather"
#define WeatherCityListHttp @"http://jisutqybmf.market.alicloudapi.com/weather/city"


@implementation CMNetworkManager


+ (void)requestDataWithCityID:(NSString *)cityID cityName:(NSString *)cityName Complete:(CompleteBlock)completeBlock{
    NSString *appcode = @"1147c52179084170a21295696bb77068";
    NSString *host = @"http://jisutqybmf.market.alicloudapi.com";
    NSString *path = @"/weather/query";
    NSString *method = @"GET";
    NSString *querys = @"citycode=101010100";
    if (cityID) {
        querys = [NSString stringWithFormat:@"citycode=%@",cityID];
    }
    if (cityName) {
        querys = [NSString stringWithFormat:@"city=%@",cityName];
    }
    NSString *url = [NSString stringWithFormat:@"%@%@?%@",  host,  path , querys];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: url]  cachePolicy:1  timeoutInterval:20];
    request.HTTPMethod  =  method;
    [request addValue:  [NSString  stringWithFormat:@"APPCODE %@" ,  appcode]  forHTTPHeaderField:  @"Authorization"];
    NSURLSession *requestSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask *task = [requestSession dataTaskWithRequest:request
                                                   completionHandler:^(NSData * _Nullable body , NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                       if (!error) {
                                                           NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:body options:NSJSONReadingMutableContainers
                                                                                                                 error:nil];
                                                           completeBlock(dic);
                                                       } else{
                                                           [SVProgressHUD showErrorWithStatus:@"加载失败"];
                                                        
                                                       }
                                                   }];
    
    [task resume];
}

//根据城市名称 查询 cityID
+ (void)requestDataWithCityName:(NSString *)cityName Complete:(CompleteBlock)completeBlock{
    NSString *appcode = @"1147c52179084170a21295696bb77068";
    NSString *host = @"http://jisutqybmf.market.alicloudapi.com";
    NSString *path = @"/weather/city";
    NSString *method = @"GET";
    NSString *querys = @"";
    NSString *url = [NSString stringWithFormat:@"%@%@%@",  host,  path , querys];
    NSString *bodys = @"";
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: url]  cachePolicy:1  timeoutInterval:20];
    request.HTTPMethod  =  method;
    [request addValue:  [NSString  stringWithFormat:@"APPCODE %@" ,  appcode]  forHTTPHeaderField:  @"Authorization"];
    NSURLSession *requestSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask *task = [requestSession dataTaskWithRequest:request
                                                   completionHandler:^(NSData * _Nullable body , NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                       NSLog(@"Response object: %@" , response);
                                                       NSString *bodyString = [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding];
                                                       
                                                       //打印应答中的body
                                                       NSLog(@"Response body: %@" , bodyString);
                                                   }];
    
    [task resume];
}


@end
