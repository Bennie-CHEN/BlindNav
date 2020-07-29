//
//  AppDelegate.m
//  navigationDemo
//
//  Created by 卜飞 on 2020/7/19.
//  Copyright © 2020 ceshi. All rights reserved.
//

#import "AppDelegate.h"
#import "mapVc.h"
#import "IFlyMSC/IFlyMSC.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
 
    NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@",APPID_VALUE];
      
      //Configure and initialize iflytek services.(This interface must been invoked in application:didFinishLaunchingWithOptions:)
      [IFlySpeechUtility createUtility:initString];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    mapVc * vc = [[mapVc alloc]init];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:vc];
       [self.window makeKeyAndVisible];
    return YES;
}





@end
