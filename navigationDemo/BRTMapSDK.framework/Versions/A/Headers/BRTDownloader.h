//
//  BRTDownloader.h
//  TYMapSDK
//
//  Created by thomasho on 2017/9/13.
//  Copyright © 2017年 thomasho. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BRTMapUpdate : NSObject
@property (nonatomic,strong) NSString *map_v_old;
@property (nonatomic,strong) NSString *map_v_new;
@property (nonatomic,strong) NSString *tile_host;
@property (nonatomic,strong) NSString *tile_path;
@property (nonatomic,assign) BOOL tile_succ;
@property (nonatomic,assign) BOOL fromLocal;
@end

@interface BRTDownloader : NSObject

typedef void(^OnMapDataCompletion)(BRTMapUpdate *update, NSError* error);

+ (void)get:(NSString *)url callBack:(void (^)(id , NSError *))callback;
+ (void)updateMap:(NSString *)buildingID AppKey:(NSString *)appKey OnCompletion:(OnMapDataCompletion)completion;

@end
