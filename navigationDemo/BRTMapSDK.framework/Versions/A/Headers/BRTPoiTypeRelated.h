//
//  BRTPoiTypeRelated.h
//  BRTMapProject
//
//  Created by thomasho on 2019/7/26.
//  Copyright © 2019 o2o. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BRTPoiTypeRelated : NSObject

@property (nonatomic, strong) NSString *TITLE;
@property (nonatomic, strong) NSString *CONTENT;
@property (nonatomic, strong) NSString *ID;

+ (instancetype)parse:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
