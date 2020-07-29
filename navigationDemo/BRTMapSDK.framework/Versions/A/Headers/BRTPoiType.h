//
//  BRTPoiType.h
//  BRTMapProject
//
//  Created by thomasho on 2019/7/26.
//  Copyright © 2019 o2o. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BRTPoiType : NSObject

@property (nonatomic, strong) NSString *TYPE_KEY;
@property (nonatomic, strong) NSString *TYPE_VALUE;
@property (nonatomic, strong) NSString *PARENT_ID;
@property (nonatomic, assign) NSInteger IS_LAST;
@property (nonatomic, assign) NSInteger STATUS;
@property (nonatomic, strong) NSArray <BRTPoiType *>* children;

+ (instancetype)parse:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
