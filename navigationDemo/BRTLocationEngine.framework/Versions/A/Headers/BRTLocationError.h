//
//  BRTLocationError.h
//  BRTLocationEngine
//
//  Created by thomasho on 17/5/4.
//  Copyright © 2017年 brightbeacon. All rights reserved.
//

#ifndef BRTLocationError_h
#define BRTLocationError_h

#define BRTLocationErrorDomain @"BRTLocationErrorDomain"
/**
 定位数据、定位超时错误对照
 */
typedef NS_ENUM(NSUInteger, BRTLocationError) {
    /** 100 权限更新失败*/
    kBRTLocationErrorLicenseUpdateFailed = 100,
    /** 101 权限更新接口验证失败*/
    kBRTLocationErrorLicenseUpdateDenied,
    /** 102 定位数据版本检查失败*/
    kBRTLocationErrorVersionUpdateFailed,
    /** 103 定位数据版本检查接口：验证失败，无定位数据*/
    kBRTLocationErrorVersionUpdateDenied,
    /** 104 定位数据更新失败*/
    kBRTLocationErrorDataUpdateFailed,
    /** 105 定位数据更新接口验证失败*/
    kBRTLocationErrorDataUpdateDenied,
    /** 106 定位数据文件有误*/
    kBRTLocationErrorDataZipFailed,
    /** 107 定位数据校验失败*/
    kBRTLocationErrorInvalidCode,
    /** 108 定位超时，持续返回*/
    kBRTLocationErrorTimeOut
};

#endif /* BRTLocationError_h */
