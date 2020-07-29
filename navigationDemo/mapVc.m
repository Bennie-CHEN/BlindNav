//
//  ViewController.m
//  navigationDemo
//
//  Created by 卜飞 on 2020/7/19.
//  Copyright © 2020 ceshi. All rights reserved.
//

typedef enum  {
    
    location = 0,
    destination,
    navigation,
} userStatus;

#import <AVFoundation/AVFoundation.h>
#import "mapVc.h"
//#import "LocationVC.h"
#import <BRTLocationEngine/BRTLocationEngine.h>
#import <BRTMapSDK/BRTMapSDK.h>
#import "IFlyMSC/IFlyMSC.h"
@interface mapVc () <BRTRouteManagerDelegate,BRTMapViewDelegate,BRTLocationManagerDelegate,BRTRouteManagerDelegate,IFlySpeechRecognizerDelegate,IFlySpeechSynthesizerDelegate>{
    BRTDirectionalHint *_lastHint;
     BRTOfflineRouteManager *offlinRouteManager;
}
@property (nonatomic ,strong) BRTLocationManager *locationManager;

@property (nonatomic,strong) NSString *buildingID,*appKey;

@property (nonatomic,strong) BRTMapView *mapView;

@property (nonatomic,strong) BRTLocalPoint * startLocalPoint;

@property (nonatomic,strong) BRTLocalPoint *  endLocalPoint;

@property (nonatomic,assign) BOOL IsFist;

@property (nonatomic,assign) userStatus userState;

@property (nonatomic,strong) AVSpeechSynthesizer *speech;

//不带界面的识别对象
@property (nonatomic, strong) IFlySpeechRecognizer *iFlySpeechRecognizer;

 @property (nonatomic, strong) IFlySpeechSynthesizer *iFlySpeechSynthesizer;

@property (nonatomic,copy) NSString * resultStr;
@end

@implementation mapVc

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView * img = [[UIImageView alloc]initWithFrame:self.view.bounds];
    img.image = [UIImage imageNamed:@"back"];
    img.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:img];
    self.view.backgroundColor = [UIColor whiteColor];
    _userState = location;
    [self setMap];
    _IsFist = YES;
    
    //创建语音识别对象
    _iFlySpeechRecognizer = [IFlySpeechRecognizer sharedInstance];
    //设置识别参数
    //设置为听写模式
    [_iFlySpeechRecognizer setParameter: @"iat" forKey: [IFlySpeechConstant IFLY_DOMAIN]];
    [_iFlySpeechRecognizer setParameter: @"en_us" forKey: [IFlySpeechConstant LANGUAGE_ENGLISH]];
    
    //asr_audio_path 是录音文件名，设置value为nil或者为空取消保存，默认保存目录在Library/cache下。
    [_iFlySpeechRecognizer setParameter:@"iat.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
    _iFlySpeechRecognizer.delegate = self;
//    _iFlySpeechRecognizer
    //启动识别服务
//    [_iFlySpeechRecognizer startListening];
    
    //获取语音合成单例
    _iFlySpeechSynthesizer = [IFlySpeechSynthesizer sharedInstance];
    //设置协议委托对象
    _iFlySpeechSynthesizer.delegate = self;
    //设置合成参数
    [_iFlySpeechSynthesizer setParameter: @"en_us" forKey: [IFlySpeechConstant LANGUAGE_ENGLISH]];
    //设置在线工作方式
    [_iFlySpeechSynthesizer setParameter:[IFlySpeechConstant TYPE_CLOUD]
     forKey:[IFlySpeechConstant ENGINE_TYPE]];
    //设置音量，取值范围 0~100
    [_iFlySpeechSynthesizer setParameter:@"50"
    forKey: [IFlySpeechConstant VOLUME]];
    //发音人，默认为”xiaoyan”，可以设置的参数列表可参考“合成发音人列表”
    [_iFlySpeechSynthesizer setParameter:@" xiaoyan "
     forKey: [IFlySpeechConstant VOICE_NAME]];
    //保存合成文件名，如不再需要，设置为nil或者为空表示取消，默认目录位于library/cache下
    [_iFlySpeechSynthesizer setParameter:@" tts.pcm"
     forKey: [IFlySpeechConstant TTS_AUDIO_PATH]];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
   self.resultStr = @"";
   
    if (_userState == location) {
        [self startAdress];
        
    }else if (_userState == destination){
    
        [self speechRecognition];
 
        
    }else if (_userState == navigation){

        _userState = location;
        
    }
}


//配置显示颜色和透明度
- (UIColor *)mapView:(BRTMapView *)mapView fillColorForPolygonAnnotation:(MGLPolygon *)annotation {
    return [UIColor cyanColor];
}
- (CGFloat)mapView:(BRTMapView *)mapView alphaForShapeAnnotation:(MGLShape *)annotation {
    return 0.5;
}

- (void)setMap{
    
    self.mapView = [[BRTMapView alloc] initWithFrame:self.view.bounds];
//    [self.view addSubview:self.mapView];
    [self.mapView setDelegate:self];
    [self.mapView loadWithBuilding:kBuildingId appkey:kAppKey];
    [self.mapView setFloor:1];
    [self.mapView setZoomLevel:22];
    [self.mapView setDirection:360];
    MGLMapCamera *camera = self.mapView.camera;
    camera.pitch = 30;
    [self.mapView setCamera:camera];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
    [self.mapView addGestureRecognizer:tap];
    
    
}


- (void)phoneticReading:(NSString *)msg{
    //启动合成会话
    [_iFlySpeechSynthesizer startSpeaking: msg];
}
- (void)speechRecognition{

//    self.mapView.userInteractionEnabled = NO;
       //asr_audio_path 是录音文件名，设置value为nil或者为空取消保存，默认保存目录在Library/cache下。
//       [_iFlySpeechRecognizer setParameter:@"iat.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
       //启动识别服务
       [_iFlySpeechRecognizer startListening];
    
}
//IFlySpeechRecognizerDelegate协议实现
//识别结果返回代理
- (void) onResults:(NSArray *) results isLast:(BOOL)isLast{
    
    if (!isLast) {
         NSMutableString *result = [NSMutableString new];

               NSDictionary *dic = [results objectAtIndex:0];

               NSLog(@"DIC:%@",dic);

               for (NSString *key in dic) {

               NSArray  * keyArr = [[self dictionaryWithJsonString:key] objectForKey:@"ws"];
               
               for (NSDictionary * dic in keyArr) {
                   
                   NSArray * cwArr = [dic objectForKey:@"cw"];
                   
                   for (NSDictionary * wDic in cwArr) {
                       self.resultStr =   [self.resultStr stringByAppendingFormat:@"%@", [wDic objectForKey:@"w"]];
                       
                   }
                   NSLog(@"%@",dic);
               }
                 
                  
                   
               }
           
           

          
           
         if (self.userState == destination) {
                [self endAdress:self.resultStr];
            }

    }
    

}
- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    
    
    if (jsonString == nil) {
        return nil;
    }

    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}
//识别会话结束返回代理
- (void)onCompleted: (IFlySpeechError *) error{
   
//    self.userState = 99;
//    self.mapView.userInteractionEnabled = YES;
   
}
//停止录音回调
- (void) onEndOfSpeech{
    
}
//开始录音回调
- (void) onBeginOfSpeech{
    
}
//音量回调函数
- (void) onVolumeChanged: (int)volume{
    
}
//会话取消回调
- (void) onCancel{
    
}

- (void)startAdress{
    
    
        BRTSearchAdapter *adapter = [[BRTSearchAdapter alloc] initWithBuildingID:kBuildingId distinct:0.1];
    
        NSArray *pois = [adapter queryPoiByCenter:self.startLocalPoint.coordinate Radius:3 Floor:self.mapView.currentFloor];
           NSMutableArray *annotations = [NSMutableArray array];
      

    if (pois.count > 0) {
        BRTPoi *pe  = pois.firstObject;
        [self phoneticReading:[NSString stringWithFormat:@"Your current location %@ Please click on the screen and say your destination",pe.name]];
        self.userState = destination;
    }else{
        self.IsFist = YES;
        [self phoneticReading:@"Positioning failed, will be repositioned"];
    }

}

- (void)endAdress:(NSString *)text{
    
    
        
        BRTSearchAdapter *adapter = [[BRTSearchAdapter alloc] initWithBuildingID:kBuildingId distinct:1.0];
         NSArray<BRTPoi *> *list = [adapter queryPoi:text andFloor:self.mapView.currentFloor];
    if (list .count > 0) {
         BRTPoi * poi = list.lastObject;
                self.endLocalPoint = poi.labelPoint;
               MGLPointAnnotation *ann = [[MGLPointAnnotation alloc] init];
               ann.coordinate = poi.labelPoint.coordinate;
               ann.title = poi.name;
               [self navigation];
    }else{
        self.userState = destination;
        [self phoneticReading:@"No destination found, please click on the screen and confirm the destination again"];
    }
       

}
- (void)navigation{
    
    BRTLocalPoint *startlp = [BRTLocalPoint pointWithCoor:self.startLocalPoint.coordinate Floor:self.mapView.currentFloor];

    BRTLocalPoint *endlp = [BRTLocalPoint pointWithCoor:self.endLocalPoint.coordinate Floor:self.mapView.currentFloor];

    if (self.mapView.routeResult) {
        //模拟定位
        [self BRTLocationManager:self.locationManager didUpdateLocation:startlp];
        return;
    }
    if (self.mapView.routeStart == nil) {
        [self.mapView setRouteStart:startlp];
        [self.mapView showRouteStartSymbolOnCurrentFloor:startlp];
    }else {
        [self.mapView setRouteEnd:endlp];
        [self requestRoute];
    }
    
}

#pragma mark - **************** methods

- (void)requestRoute
{
    //在线规划
//    [self.mapView.routeManager requestRouteWithStart:self.mapView.routeStart End:self.mapView.routeEnd];
    
    //离线规划
    [self.mapView.routeOfflineManager requestRouteWithStart:self.mapView.routeStart end:self.mapView.routeEnd];
}


- (void)dealloc {
    NSLog(@"check if '%@' recycled",NSStringFromClass(self.class));
}

#pragma mark - **************** 地图加载完成回调
- (void)mapViewDidLoad:(BRTMapView *)mapView withError:(NSError *)error {
    if (!error) {
       //可选设置请求运行时位置权限；需plist对应配置
          [BRTBLEEnvironment setRequestWhenInUseAuthorization:YES];
          
          self.mapView.routeManager.delegate = self;
          //初始化定位数据
          self.locationManager = [[BRTLocationManager alloc] initWithBuilding:self.mapView.building appKey:kAppKey];
          
          //设置定位设备信号阈值
          [self.locationManager setRssiThreshold:-80];
          self.locationManager.delegate = self;
          
          //定位超时错误回调时间（秒）
          self.locationManager.requestTimeOut =  10;
          
          //限制最大定位设备个数5个
          [self.locationManager setMaxBeaconNumberForProcessing:5];
          [self.locationManager setLimitBeaconNumber:YES];
          
          //关闭定位热力数据上传
          [self.locationManager enableHeatData:NO];
          
          //启动定位
          [self.locationManager startUpdateLocation];
    }else{
        
        [self phoneticReading:@"Map loading error"];
//        [[[UIAlertView alloc] initWithTitle:error.domain message:[NSString stringWithFormat:@"地图加载错误：%@",error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }
}

#pragma mark - **************** 定位回调方法

//返回beacon定位，固定1s/次
- (void)BRTLocationManager:(BRTLocationManager *)manager didUpdateImmediateLocation:(BRTLocalPoint *)newImmediateLocation {
//   xxxxx [self.mapView showLocation:newImmediateLocation];
       
    [self.mapView removeAnnotations:self.mapView.annotations];
    MGLPointAnnotation *ann = [[MGLPointAnnotation alloc] init];
    ann.coordinate = newImmediateLocation.coordinate;
    ann.title = @"1";
    
     if (self.IsFist == YES) {
            self.startLocalPoint = newImmediateLocation;
            self.IsFist = NO;
            [self startAdress];
           [self navigation];
   
    }

}

//返回beacon + 传感器优化定位，最快0.2s/次
- (void)BRTLocationManager:(BRTLocationManager *)manager didUpdateLocation:(BRTLocalPoint *)newLocation {
    
    
    
    //初次移到中心点
       if (manager.getLastLocation == nil) {
           [self.mapView setCenterCoordinate:newLocation.coordinate];
       }
       
       // 判断地图当前显示楼层是否与定位结果一致，若不一致则切换到定位结果所在楼层（楼层自动切换）
       if (self.mapView.currentFloor != newLocation.floor) {
           [self.mapView setFloor:newLocation.floor];
           return;
       }
       
       if (self.mapView.routeResult == nil) {
           //无路径规划显示，直接显示定位
           [self.mapView showLocation:newLocation animated:YES];
           return;
       }
       
       //有路径规划，判断是否到达终点附近，是否偏航等。进行提示。
       if ([self.mapView.routeResult isDeviatingFromRoute:newLocation withThrehold:5]) {
           //偏航5米，重新规划路径
           [self.mapView setRouteStart:newLocation];
           [self requestRoute];
           [self phoneticReading:@"You have yaw, re-plan your route."];

           return;
       }
       
       double distance2end = [self.mapView.routeResult distanceToRouteEnd:newLocation];
       if (distance2end < 5) {
           [self.mapView removeRouteLayer];
           [self phoneticReading:@"Has reached the end point, this navigation is over."];

           self.userState = location;
//           [self startAdress];
          
           return;
       }
       //导航中，未偏航，可以直接吸附到最近的路径上。注意：本层可能无路网
       BRTRoutePart *part = [self.mapView.routeResult getNearestRoutePart:newLocation];
       if (part == nil) {
           [self.mapView showLocation:newLocation];
           return;
       }
       
       //显示路过和余下线段
       [self.mapView showPassedAndRemainingRouteResultOnCurrentFloor:newLocation];
       
       //吸附到路网上
       newLocation = [self.mapView.routeResult getNearPointOnRoute:newLocation];
       [self.mapView showLocation:newLocation];
       
       //移动位置超过3米，进行导航提示(记录hint防重复播报)
       NSArray *routeGuides = [part getRouteDirectionalHintsIgnoreDistance:3 angle:15];
       BRTDirectionalHint *hint = [part getDirectionHintForLocation:newLocation FromHints:routeGuides];
       if(hint == _lastHint) return;
       _lastHint = hint;
       
       //计算当前位置点，距离本段结束点、终点距离
       float len2End = [newLocation distanceWith:[BRTLocalPoint pointWithCoor:hint.endPoint Floor:newLocation.floor]];
       if (hint.length <= 10 || len2End <= 10) {
           if(hint.nextHint)[self phoneticReading:[NSString stringWithFormat:@"Ahead%@",[hint.nextHint getDirectionString]]];
           else if(part.nextPart)[self phoneticReading:[NSString stringWithFormat:@"Take the escalator ahead to the %d building",part.nextPart.floor]];
           else [self phoneticReading:@"Navigation is about to end. To continue navigation, please tap the screen"];
           
       }else {
           //当前路段中间，或含微小弯道(依据getRouteDirectionalHintsIgnoreDistance:angle:)或直行部分
           [self phoneticReading:[NSString stringWithFormat:@"Follow the road %.0f meters",len2End]];
       }

}
/**
 *  位置更新失败事件回调
 *
 *  @param manager 定位引擎实例
 */
- (void)BRTLocationManager:(BRTLocationManager *)manager didFailUpdateLocation:(NSError *)error {
    NSLog(@"定位失败：%@",error);
    self.title = error.userInfo.allValues.description;
}

/**
 *  Beacon扫描结果事件回调，返回符合扫描参数的所有Beacon
 *
 *  @param manager 定位引擎实例
 *  @param beacons Beacon数组，[BRTBeacon]
 */
- (void)BRTLocationManager:(BRTLocationManager *)manager didRangedBeacons:(NSArray *)beacons {
    
    
//    NSLog(@"all beacons find:%@",beacons);
}

/**
 *  定位Beacon扫描结果事件回调，返回符合扫描参数的定位Beacon，定位Beacon包含坐标信息。此方法可用于辅助巡检，以及基于定位beacon的相关触发事件。
 *
 *  @param manager 定位引擎实例
 *  @param beacons 定位Beacon数组，[BRTPublicBeacon]
 */
- (void)BRTLocationManager:(BRTLocationManager *)manager didRangedLocationBeacons:(NSArray *)beacons {
    //显示扫描到的Beacon设备信息
    [self.mapView removeAnnotations:self.mapView.annotations];
    NSMutableArray *marray = [NSMutableArray array];
    NSInteger i = 0;
    for (BRTPublicBeacon *pb in beacons) {
        i++;
        if (pb.location.floor == self.mapView.currentFloor) {
            MGLPointAnnotation *ann = [[MGLPointAnnotation alloc] init];
            ann.coordinate = pb.location.coordinate;
            ann.title = [pb.minor.stringValue stringByAppendingFormat:@",%d(%ld)",pb.rssi,i];
            [marray addObject:ann];
        }
    }
    [self.mapView addAnnotations:marray];
}




- (void)routeManager:(BRTRouteManager *)routeManager didFailSolveRouteWithError:(NSError *)error {
    
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)routeManager:(BRTRouteManager *)routeManager didSolveRouteWithResult:(BRTRouteResult *)rs {
     [self.mapView setRouteResult:rs];
       [self.mapView showRouteResultOnCurrentFloor];
       
       NSArray<BRTRoutePart *> *routePartArray = [rs getRoutePartsOnFloor:self.mapView.currentFloor];
//       if (routePartArray && routePartArray.count > 0) {
//           MGLPolyline *route = routePartArray.firstObject.route;
//           [self.mapView setVisibleCoordinates:route.coordinates count:route.pointCount edgePadding:UIEdgeInsetsZero animated:YES];
//       }
//       double len = self.mapView.routeResult.length;
//       int min = ceil(len/80);
//    [self phoneticReading:[NSString stringWithFormat:@"开始导航，全程%.0f米，大约需要%d分钟",len,min]];
}


/**
 离线路网规划回调
 */
- (void)offlineRouteManager:(BRTOfflineRouteManager *)routeManager didSolveRouteWithResult:(BRTRouteResult *)rs {
    
    
    [self routeManager:nil didSolveRouteWithResult:rs];
}
- (void)offlineRouteManager:(BRTOfflineRouteManager *)routeManager didFailSolveRouteWithError:(NSError *)error {
    
    
    [self phoneticReading:@"Path planning failed"];
}



@end
