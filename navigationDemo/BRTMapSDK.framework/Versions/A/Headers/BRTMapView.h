//
//  BRTMapView.h
//  mapbox
//
//  Created by thomasho on 2017/12/20.
//  Copyright © 2017年 thomasho. All rights reserved.
//

#import <Mapbox/Mapbox.h>
#import <BRTMapData/BRTLocalPoint.h>
#import "BRTFloorInfo.h"
#import "BRTRouteResult.h"
#import "BRTPoi.h"
#import "BRTRouteManager.h"
#import "BRTOfflineRouteManager.h"
#import "BRTMapDefine.h"
#import "BRTMapError.h"
#import "MercatorConvert.h"
#import "GeometryEngine.h"
#import "BRTPoiType.h"
#import "BRTPoiTypeRelated.h"

/**
 地图模式类型：默认模式和跟随模式
 */
typedef enum {
    BRTMapViewModeDefault = 0,
    BRTMapViewModeFollowing = 1
} BRTMapViewMode;

@class BRTMapView;


/**
    地图代理协议
 */
@protocol BRTMapViewDelegate<MGLMapViewDelegate>

@optional
/**
 *  地图加载完成事件回调
 *
 *  @param mapView 地图视图
 *  @param error 错误信息，参见BRTMapError.h
 */
- (void)mapViewDidLoad:(BRTMapView *)mapView withError:(NSError *)error;

/**
 *  地图楼层加载完成回调（含首次默认载入和地图楼层变化）
 *
 *  @param mapView 地图视图
 *  @param floorInfo 加载楼层信息
 */
- (void)mapView:(BRTMapView *)mapView didFinishLoadingFloor:(BRTFloorInfo *)floorInfo;

/**
 *  地图点选事件回调方法
 *
 *  @param mapView  地图视图
 *  @param screen   点击事件的屏幕坐标
 */
- (void)mapView:(BRTMapView *)mapView didClickAtPoint:(CGPoint)screen;

/**
 *  地图POI选中事件回调
 *
 *  @param mapView 地图视图
 *  @param array   选中的POI数组:[BRTPoi]
 */
- (void)mapView:(BRTMapView *)mapView poiSelected:(NSArray *)array;

/**
 *  设置地图POI选中颜色，if return nil use defaultHighlightColor instead.
 *
 *  @param mapView 地图视图
 *  @param poi   待高亮poi
 */
- (UIColor *)mapView:(BRTMapView *)mapView highlightColorForPoi:(BRTPoi *)poi;

/**
 *  自定义POI分类图标. {catergoryID,icon} => {NSNumber *,UIImage *}
 *
 *  @param mapView 地图视图
 */
- (NSDictionary<NSNumber *,UIImage *> *)catergoryIconsForMapView:(BRTMapView *)mapView;

@end


/**
    地图视图类
 */
@interface BRTMapView : MGLMapView

/**
 *  当前建筑信息
 */
@property (nonatomic, readonly) BRTBuilding *building;

/**
 *  当前建筑的所有楼层信息
 */
@property (nonatomic, readonly) NSArray<BRTFloorInfo *>   *floorInfos;

/**
 *  当前建筑的所有POI分类
 */
@property (nonatomic, readonly) NSArray<BRTPoiType *>   *poiTypes;

/**
 *  当前建筑的所有POI分类关联数据
 */
@property (nonatomic, readonly) NSArray<BRTPoiTypeRelated *>   *poiTypeRelated;

/**
 *  当前显示的楼层
 */
@property (nonatomic, readonly) int   currentFloor;

/**
 *  当前建筑的当前楼层信息
 */
@property (nonatomic, readonly) BRTFloorInfo  *currentFloorInfo;


/**
 *  地图轮廓层
 */
@property (nonatomic, readonly) MGLFillStyleLayer *floorLayer;

/**
 *  地图大区层
 */
@property (nonatomic, readonly) MGLFillStyleLayer *zoneLayer;

/**
*   地图房间层
*/
@property (nonatomic, readonly) MGLFillStyleLayer *roomLayer;

/**
 *  地图拉伸层
 */
@property (nonatomic, readonly) MGLFillExtrusionStyleLayer *extrusionLayer;

/**
 *  地图标签层
 */
@property (nonatomic, readonly) MGLSymbolStyleLayer *labelLayer;

/**
 *  地图设施层
 */
@property (nonatomic, readonly) MGLSymbolStyleLayer *facilityLayer;

/**
 *  是否自动高亮选中poi，默认NO
 */
@property (nonatomic, assign) BOOL highlightPOIOnSelection;

/**
 * 路径起点
 */
@property (nonatomic, strong) BRTLocalPoint *routeStart;

/**
 * 路径终点
 */
@property (nonatomic, strong) BRTLocalPoint *routeEnd;


/**
 * 地图委托
 */
@property (nonatomic, weak) id<BRTMapViewDelegate> delegate;

/**
 *  地图初始化方法
 *
 *  @param buildingID    地图显示的目标建筑
 *  @param token         SDK的用户token
 */
- (void)loadWithBuilding:(NSString *)buildingID token:(NSString *)token;

/**
 *  地图初始化方法
 *
 *  @param buildingID   地图显示的目标建筑
 *  @param appkey       SDK的用户appkey
 */
- (void)loadWithBuilding:(NSString *)buildingID appkey:(NSString *)appkey;

/**
 刷新地图
 */
- (void)reloadMapView;

/**
 *
 *  设置目标楼层，（地图初始化后即可设置，若无设置默认第一条楼层信息）
 *
 *  @param floor 楼层 -1,1
 */
- (void)setFloor:(int)floor;

/**
 * 设置地图滑动边界，（默认为currentFloorBounds）
 *
 * @param bounds 边界线
 */
- (void)setMapBounds:(MGLCoordinateBounds)bounds;

/**
 *  获取当前楼层下特定子层特定poiID的信息
 *
 *  @param pid   poiID
 *
 *  @return poi信息
 */
- (BRTPoi *)getPoiOnCurrentFloorWithPoiID:(NSString *)pid;

/**
 *  获取本层车位Poi
 *
 *  @return 车位poi数组
 */
- (NSArray <BRTPoi *> *)getParkingSpacesOnCurrentFloor;

/**
 *  获取本层设施数据
 *
 *  @return 设施数组
 */
- (NSArray <BRTPoi *> *)getAllFacilityOnCurrentFloor;

/**
 *  获取本层文本数据
 *
 *  @return 文本数组
 */
- (NSArray <BRTPoi *> *)getAllLabelOnCurrentFloor;
/**
 *  条件筛选本层poi数据
 *
 *  @param predicate 条件表达式(属性列表：KEY Attribute)
 *  @return BRTPoi数组
 */
- (NSArray <BRTPoi *> *)getPoiUsingPredicate:(NSPredicate *)predicate;

/**
 *  高亮显示POI
 *
 *  @param poi 目标poi
 *  目标poi至少包含poiID和layer信息，当前支持ROOM和FACILITY高亮
 */
- (void)highlightPoi:(BRTPoi *) poi;

/**
 *  高亮显示一组POI
 *
 *  @param poiArray 目标poi数组
 */
- (void)highlightPois:(NSArray *)poiArray;

/**
 *  高亮POI颜色
 *
 *  @param color 高亮颜色
 */
- (void)setDefaultHighlightColor:(UIColor *)color;

/**
 *  在地图显示当前楼层的规划路段
 */
- (void)showRouteResultOnCurrentFloor;

/**
 *  设置路径规划结果（同时设置为多途经点规划方案的选中部分）
 *
 *  @param result 路径结果
 */
- (void)setRouteResult:(BRTRouteResult *)result;

/*
 *  获取路径规划结果
 *
 *  @retrun result 路径结果
 */
- (BRTRouteResult *)routeResult;

/*
 *  隐藏本层导航显示
 */
- (void)hiddenRouteLayer;

/*
 *  移除导航结果，清除导航显示层
 */
- (void)removeRouteLayer;

/**
 *  根据坐标x和y提取当前楼层的ROOM POI
 *
 *  @param point 屏幕坐标
 *
 *  @return ROOM POI
 */
- (NSArray<BRTPoi *> *)extractPoiOnCurrentFloorWithPoint:(CGPoint)point;

/**
 *  设置定位图标
 *
 *  @param symbol 定位标识图标
 */
- (void)setLocationSymbol:(UIImage *)symbol;

/**
 * 显示定位图标
 *
 * @param location 定位图标位置
 */
- (void)showLocation:(BRTLocalPoint *)location;

/**
 * 显示定位图标
 *
 * @param location 定位图标位置
 * @param animate  是否平滑移动过去
 */
- (void)showLocation:(BRTLocalPoint *)location animated:(BOOL)animate;

/**
 *  在地图上移除定位结果
 */
- (void)removeLocation;

/**
 *  处理设备旋转事件
 *
 *  @param newHeading 设备方向角
 */
- (void)processDeviceRotation:(double)newHeading;

/**
 * 在线路径管理，使用在线请求
 */
@property (nonatomic) BRTRouteManager *routeManager;

/**
 * 离线路径管理，使用本地计算
 */
@property (nonatomic) BRTOfflineRouteManager *routeOfflineManager;

/**
 *  在地图当前楼层显示起点图标
 *
 *  @param sp 起点位置
 */
- (void)showRouteStartSymbolOnCurrentFloor:(BRTLocalPoint *)sp;

/**
 *  在地图当前楼层显示终点图标
 *
 *  @param ep 终点位置
 */
- (void)showRouteEndSymbolOnCurrentFloor:(BRTLocalPoint *)ep;

/**
 *  设置导航线的起点图标
 *
 *  @param symbol 起点标识图标
 */
- (void)setRouteStartSymbol:(UIImage *)symbol;

/**
 *  设置导航线的终点图标
 *
 *  @param symbol 终点标识图标
 */
- (void)setRouteEndSymbol:(UIImage *)symbol;

/**
 *  设置跨层导航切换点图标
 *
 *  @param symbol 切换点标识图标
 */
- (void)setRouteSwitchSymbol:(UIImage *)symbol;

/**
 *  设置路线规划线默认颜色
 *
 *  @param color 颜色
 */
- (void)setRouteColor:(UIColor *)color;

/**
 *  设置路线规划经过部分线颜色
 *
 *  @param color 颜色
 */
- (void) setPassedRouteColor:(UIColor *)color;

/**
 *  设置路线规划多途径线底色
 *
 *  @param color 颜色
 */
- (void)setRouteCompleteColor:(UIColor *)color;

/**
 *  在地图上显示当前楼层目标位置已经过的路径和未经过的剩余路径
 *
 *  @param lp 目标位置
 */
- (void)showPassedAndRemainingRouteResultOnCurrentFloor:(BRTLocalPoint *)lp;

/**
 *  在地图上显示当前楼层目标位置，已经过的路径和剩余路径
 *
 *  @param lp 目标位置
 */
- (void)showRemainingRouteResultOnCurrentFloor:(BRTLocalPoint *)lp;

/**
 * 本层地图边界范围
 *
 * @return 地图范围
 */
- (MGLCoordinateBounds)currentFloorBounds;

@end
