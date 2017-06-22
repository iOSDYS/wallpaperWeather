//
//  CS_Location.m
//  CarServant
//
//  Created by Hero on 16/3/3.
//  Copyright © 2016年. All rights reserved.
//

#import "CS_Location.h"
#import <MapKit/MapKit.h>

@interface CS_Location()<CLLocationManagerDelegate>
@property (nonatomic,strong) CLLocationManager *locationManager;
@end

@implementation CS_Location
+ (instancetype)shareInstance{
    static CS_Location *shareInstance = nil;
    if (shareInstance == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            shareInstance = [[CS_Location alloc] init];
        });
    }
    return shareInstance;
}

- (void)startLocate{
    if([CLLocationManager locationServicesEnabled]) {
        self.locationManager = [[CLLocationManager alloc] init] ;
        self.locationManager.delegate = self;
        if ([[UIDevice currentDevice] systemVersion].floatValue >= 8.0) {
            [self.locationManager requestWhenInUseAuthorization];
        }
        [self.locationManager startUpdatingLocation];
    }else {
        if (self.block) {
            self.block(@"北京市");
        }
    }
}

#pragma mark - CoreLocation Delegate
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *currentLocation = [locations lastObject];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    //根据经纬度反向地理编译出地址信息
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *array, NSError *error)
     {
         if (array.count > 0)
         {
             CLPlacemark *placemark = [array objectAtIndex:0];
             NSString *city = placemark.locality;
             if (!city) {
                 city = placemark.administrativeArea;
             }
             NSString *subCity = [city substringToIndex:city.length];
             
             if (self.block) {
                 self.block(subCity);
             }
         }
         else if (error == nil && [array count] == 0)
         {
             NSLog(@"No results were returned.");
         }
         else if (error != nil)
         {
             NSLog(@"An error occurred = %@", error);
         }
     }];
    [manager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    if (error.code == kCLErrorDenied) {
        // 提示用户出错原因，可按住Option键点击 KCLErrorDenied的查看更多出错信息，可打印error.code值查找原因所在
    }
}

@end
