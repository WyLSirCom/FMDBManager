//
//  NDFMDBModel.h
//  NDS-iPad
//
//  Created by 魏延龙 on 2017/6/19.
//  Copyright © 2017年 魏延龙. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NDFMDBModel : NSObject

@property (nonatomic, copy) NSString *course_uuid;
@property (nonatomic, assign) NSInteger unit_uuid;
@property (nonatomic, copy) NSString *resource_uuid;
@property (nonatomic, assign) float name;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *type;

@end
