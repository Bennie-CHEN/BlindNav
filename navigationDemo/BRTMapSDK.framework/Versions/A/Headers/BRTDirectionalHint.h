//
//  BRTDirectionalHint.h
//  BRTMapProject
//
//  Created by thomasho on 2018/4/18.
//  Copyright © 2018年 thomasho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <Mapbox/Mapbox.h>
#import "IPVector.h"

#define INITIAL_EMPTY_ANGLE 1000

/**
 相对方向类型，用于导航提示
 */
typedef NS_ENUM(NSUInteger, BRTRelativeDirection) {
    BRTStraight,
    BRTTurnRight,
    BRTRightForward,
    BRTLeftForward,
    BRTRightBackward,
    BRTLeftBackward,
    BRTTurnLeft,
    BRTBackward
};

/**
 导航方向提示，用于导航结果的展示，表示其中的一段
 */
@interface BRTDirectionalHint : NSObject

/**
 *  导航方向提示的初始化方法，一般不需要直接调用，由导航管理类调用生成
 *
 *  @param start 当前导航段的起点
 *  @param end   当前导航段的终点
 *  @param angle 前一导航段的方向角
 *
 *  @return 导航方向类实例
 */
- (id)initWithStartPoint:(IPVector *)start EndPoint:(IPVector *)end PreviousAngle:(double)angle;

/**
 *  当前段起点
 */
@property (nonatomic, assign, readonly) CLLocationCoordinate2D startPoint;

/**
 *  当前段终点
 */
@property (nonatomic, assign, readonly) CLLocationCoordinate2D endPoint;

/**
 * 当前提示段路线
 */
@property (nonatomic, strong) MGLPolyline *line;

/**
 *  当前段的相对方向
 */
@property (nonatomic, readonly) BRTRelativeDirection relativeDirection;

/**
 *  前一段的方向角
 */
@property (nonatomic, readonly) double previousAngle;

/**
 *  当前段的方向角
 */
@property (nonatomic, readonly) double currentAngle;

/**
 *  当前段的长度
 */
@property (nonatomic, readonly) double length;


/**
 *  生成当前段的方向提示
 *
 *  @return 当前的方向提示字符串
 */
- (NSString *)getDirectionString;

/**
 下一段提示
 
 @return 下一段提示
 */
@property (nonatomic,strong) BRTDirectionalHint *nextHint;


/**
 *  当前段是否路过（自定义）
 */
@property (nonatomic, assign) int passed;


/**
 * 获取方向提示
 *
 * @param direction 方向枚举
 * @return 方向提示字符串
 */
+ (NSString *)getDirection:(BRTRelativeDirection)direction;


/**
 获取两个角度方向

 @param angle 当前角度
 @param preAngle 上一角度
 @return 方向
 */
+ (BRTRelativeDirection)calculateRelativeDirection:(double)angle previousAngle:(double)preAngle;

@end
