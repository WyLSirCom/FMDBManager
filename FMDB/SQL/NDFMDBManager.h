//
//  NDFMDBManager.h
//  NDS-iPad
//
//  Created by 魏延龙 on 2017/6/19.
//  Copyright © 2017年 魏延龙. All rights reserved.
//  线程安全

#import <Foundation/Foundation.h>

typedef void(^DBResult)(BOOL result);

@interface NDFMDBManager : NSObject

+ (instancetype)shareNDSQLManger;

/**
 创建表

 @param dbname 数据库的名字
 @param tableName 表的名字
 @param modelClass [model class]
 @param block 结果
 */
-(void)creatQueueTableWithDBName:(NSString *)dbname tableName:(NSString *)tableName withModelClass:(id)modelClass result:(DBResult)block;

/**
 插入单条数据

 @param dbname 数据库的名字
 @param tableName 表的名字
 @param model 数据模型
 @param block 结果
 */
-(void)insertQueueTableWithDBName:(NSString *)dbname tableName:(NSString *)tableName withModel:(id)model result:(DBResult)block;


/**
 批量插入数据

 @param dbname 数据库的名字
 @param tablename 表的名字
 @param models 数据模型数组
 @param block 结果
 */
-(void)insertLotsizeQueueTableWithDBName:(NSString *)dbname tablename:(NSString *)tablename withArray:(NSArray *)models result:(DBResult)block;

/**
 查询数据

 @param dbname 数据库的名字
 @param tablename 表的名字
 @param ArrInfo 要查询的字段 传nil 获得所有字段
 @param corDic 查询的条件 key是字段 value是值  传nil 获得所有数据
 @param modelClass 传入模型的class 可以为空，为空返回的是数组字典
 @param block 结果 模型数组
 */
-(void)queryQueueTableWithDBName:(NSString *)dbname tablename:(NSString *)tablename withArr:(NSArray *)ArrInfo corDic:(NSDictionary *)corDic modelClass:(id)modelClass result:(void (^)(NSArray *res))block;

/**
 删除数据

 @param dbname 数据库的名字
 @param tablename 表的名字
 @param corDic 删除的条件 key是字段 value是值
 @param block 结果
 */
-(void)deleteQueueTableWithDBName:(NSString *)dbname tablename:(NSString *)tablename corDic:(NSDictionary *)corDic result:(DBResult)block;

/**
 按条件更新

 @param dbname 数据库名字
 @param tableName 表的名字
 @param dicInfo 更新的数据 key是字段 value是值
 @param corDic 更新的条件 key是字段 value是值 为nil全部更新
 @param block 结果
 */
-(void)updateQueueTableWithDBName:(NSString *)dbname tablename:(NSString *)tableName withDicInfo:(NSDictionary *)dicInfo withCorDic:(NSDictionary *)corDic result:(void (^)(_Bool res))block;

/**
 用sql语句查询

 @param dbname 数据库的名字
 @param sql 表的名字
 @param modelClass 传入模型的class 可以为空，为空返回的是数组字典
 @param block 返回结果 数组字典或模型字典
 */
-(void)queryDBName:(NSString *)dbname withSql:(NSString *)sql modelClass:(Class)modelClass result:(void (^)(NSArray *res))block;

/**
 按条件更新

 @param dbname 数据库的名字
 @param tableName 表的名字
 @param modelInfo 更新字段的模型
 @param cormodel 条件模型
 @param block 结果
 */
-(void)updateQueueTableWithDBName:(NSString *)dbname tablename:(NSString *)tableName withModelInfo:(id)modelInfo withCorModel:(id)cormodel result:(DBResult)block;

/**
 删除数据

 @param dbname 数据库的名字
 @param tablename 表的名字
 @param cormodel 条件模型
 @param block 结果
 */
-(void)deleteQueueTableWithDBName:(NSString *)dbname tablename:(NSString *)tablename corModel:(id)cormodel result:(DBResult)block;

@end
