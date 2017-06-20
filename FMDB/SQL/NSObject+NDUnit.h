//
//  NSObject+NDUnit.h
//  NDS-iPad
//
//  Created by 魏延龙 on 2017/6/19.
//  Copyright © 2017年 魏延龙. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (NDUnit)

/*! @method swizzleMethod:withMethod:error:
 @abstract 对系统方法进行替换
 @param originalSelector 想要替换的方法
 @param swizzledSelector 实际替换为的方法
 @param error 替换过程中出现的错误，如果没有错误为nil
 */
+ (BOOL)swizzleMethod:(SEL)originalSelector withMethod:(SEL)swizzledSelector error:(NSError **)error;


+ (instancetype)newsWithDict:(NSDictionary *)dict;

+ (NSDictionary *) entityToDictionary:(id)entity;
@end
