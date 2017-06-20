//
//  NSMutableArray+NDUnit.m
//  NDS-iPad
//
//  Created by 魏延龙 on 2017/6/19.
//  Copyright © 2017年 魏延龙. All rights reserved.
//

#import "NSMutableArray+NDUnit.h"
#import "NSObject+NDUnit.h"
#import <objc/runtime.h>

@implementation NSMutableArray (NDUnit)


+(void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @autoreleasepool {
//            [objc_getClass("__NSArrayM") swizzleMethod:
//             @selector(objectAtIndex:) withMethod:@selector(lqq_objectAtIndex:) error:nil];
            [objc_getClass("__NSArrayM") swizzleMethod:
             @selector(addObject:) withMethod:@selector(lqq_addObject:) error:nil];
        };
    });
}

-(void)lqq_addObject:(id)object {
    if (!object || [object isKindOfClass:[NSNull class]]) {
        [self lqq_addObject:[NSNull null]];
    } else {
        [self lqq_addObject:object];
    }
}

@end
