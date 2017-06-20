//
//  NSObject+NDUnit.m
//  NDS-iPad
//
//  Created by 魏延龙 on 2017/6/19.
//  Copyright © 2017年 魏延龙. All rights reserved.
//

#import "NSObject+NDUnit.h"
#import <objc/runtime.h>

@implementation NSObject (NDUnit)

+ (BOOL)swizzleMethod:(SEL)originalSelector withMethod:(SEL)swizzledSelector error:(NSError **)error
{
    Method originalMethod = class_getInstanceMethod(self, originalSelector);
    if (!originalMethod) {
        NSString *string = [NSString stringWithFormat:@" %@ 类没有找到 %@ 方法",NSStringFromClass([self class]),NSStringFromSelector(originalSelector)];          *error = [NSError errorWithDomain:@"NSCocoaErrorDomain" code:-1 userInfo:[NSDictionary dictionaryWithObject:string forKey:NSLocalizedDescriptionKey]];   return NO;
    }
    Method swizzledMethod = class_getInstanceMethod(self, swizzledSelector);
    
    if (!swizzledMethod) {
        NSString *string = [NSString stringWithFormat:@" %@ 类没有找到 %@ 方法",NSStringFromClass([self class]),NSStringFromSelector(swizzledSelector)];          *error = [NSError errorWithDomain:@"NSCocoaErrorDomain" code:-1 userInfo:[NSDictionary dictionaryWithObject:string forKey:NSLocalizedDescriptionKey]];   return NO;
    }
    
    if (class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod)))
    {
        class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
    return YES;
}

+ (instancetype)newsWithDict:(NSDictionary *)dict {
    id obj = [[self alloc] init];
    
    NSArray *properties = [self pri_properties];
    
    // 遍历属性数组
    for (NSString *key in properties) {
        // 判断字典中是否包含这个key
        if (dict[key] != nil) {
            // 使用 KVC 设置数值
            [obj setValue:dict[key] forKeyPath:key];
        }
    }
    
    return obj;
}
const char *propertiesKey = "propertiesKey";
+ (NSArray *)pri_properties {
    //5 判断是否处存在关联对象，如果存在直接返回
    //参数一 关联到对象
    //参数二 关联的属性key
    //在oc 中 类的本质就是一个对象
    NSArray *plist = objc_getAssociatedObject(self, propertiesKey);
    if(plist != nil)
    {
        return plist;
    }
    //1获取类的属性
    //参数是 类 和属性的计数指针  返回值是所有属性的数组
    unsigned int count = 0;//属性的计数指针
    objc_property_t *list = class_copyPropertyList([self class], &count);//返回值是所有属性的数组
    //4取得属性名数组
    NSMutableArray *arrayM = [NSMutableArray arrayWithCapacity:count];
    //3 遍历数组
    for(unsigned int i = 0; i < count; ++i)
    {
        //获取到属性
        objc_property_t pty = list[i];
        //获取属性的名称
        const char *cname = property_getName(pty);
        
        printf("%s	",cname);
        
        [arrayM addObject:[NSString stringWithUTF8String:cname]];
    }
    
    NSLog(@"%@",arrayM);
    
    free(list);//2 用了class_copyPropertyList方法一定要释放
    
    //5 设置关联对象
    //参数1>关联的对象
    //参数2>关联对象的key
    //参数3>属性数值
    //属性的持有方式 retain copy assign
    objc_setAssociatedObject(self, propertiesKey, arrayM, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    return arrayM.copy;
    
}

+ (NSDictionary *) entityToDictionary:(id)entity
{
    
    Class clazz = [entity class];
    u_int count;
    
    objc_property_t* properties = class_copyPropertyList(clazz, &count);
    NSMutableArray* propertyArray = [NSMutableArray arrayWithCapacity:count];
    NSMutableArray* valueArray = [NSMutableArray arrayWithCapacity:count];
    
    for (int i = 0; i < count ; i++)
    {
        objc_property_t prop=properties[i];
        const char* propertyName = property_getName(prop);
        
        
        //        const char* attributeName = property_getAttributes(prop);
        //        NSLog(@"%@",[NSString stringWithUTF8String:propertyName]);
        //        NSLog(@"%@",[NSString stringWithUTF8String:attributeName]);
        
        id value =  [entity valueForKey:[NSString stringWithUTF8String:propertyName]];
        if(value ==nil)
            [valueArray addObject:[NSNull null]];
        else {
            [propertyArray addObject:[NSString stringWithCString:propertyName encoding:NSUTF8StringEncoding]];
            [valueArray addObject:value];
        }
        //        NSLog(@"%@",value);
    }
    
    free(properties);
    
    NSDictionary* returnDic = [NSDictionary dictionaryWithObjects:valueArray forKeys:propertyArray];
    NSLog(@"%@", returnDic);
    
    return returnDic;
}


@end
