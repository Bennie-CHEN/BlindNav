//
//  GeometryEngine.h
//  BRTMapProject
//
//  Created by thomasho on 2018/4/18.
//  Copyright © 2018年 thomasho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mapbox/Mapbox.h>
#import "GeometryResult.h"

@interface GeometryEngine : NSObject

+ (GeometryEngine *)defaultEngine;

- (CLLocationDistance)lengthOfGeometry:(MGLPolyline *)line;

- (double)areaOfGeometry:(MGLPolygon *)polygon;

- (CLLocationDistance)distanceBetweenCoordinates:(CLLocationCoordinate2D)from to:(CLLocationCoordinate2D)to;

- (CLLocationDistance)distanceToGeometry:(MGLPolyline *)line toPoint:(CLLocationCoordinate2D)coordinate;

- (GeometryResult *)nearestCoordinateInGeometry:(MGLPolyline *)line toPoint:(CLLocationCoordinate2D)coordinate;

- (BOOL)geometry:(MGLPolygon *)polygon contains:(CLLocationCoordinate2D )coordinate;


/**
 获得线上距离为distance的坐标点

 @param line 线
 @param distance 距离
 @return 点
 */
- (CLLocationCoordinate2D)pointOnLine:(MGLPolyline *)line atDistance:(double)distance;

@end
