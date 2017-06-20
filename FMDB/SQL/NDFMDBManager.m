//
//  NDFMDBManager.m
//  NDS-iPad
//
//  Created by 魏延龙 on 2017/6/19.
//  Copyright © 2017年 魏延龙. All rights reserved.
//

#import "NDFMDBManager.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "NSObject+NDUnit.h"
#import <FMDB.h>



@interface NDFMDBManager ()

@property (nonatomic ,strong) FMDatabaseQueue *queue;

@end

@implementation NDFMDBManager


static NDFMDBManager *manage = nil;

+ (instancetype)shareNDSQLManger {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manage = [[NDFMDBManager alloc] init];
    });
    return manage;
}

-(void)openQueueWithDBName:(NSString *)DBName{
    NSString *path = [self sqlpathWithDbName:DBName];
    NSLog(@"queuepath:%@", path);
    _queue = [FMDatabaseQueue databaseQueueWithPath:path];
}

/*
 * sql数据库的路径
 */
-(NSString *)sqlpathWithDbName:(NSString *)DBName{
    NSString *theName = [DBName stringByAppendingString:@".sqlite"];
    NSString *directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] ;
    NSString *fileMan = [directory stringByAppendingPathComponent:@"NDS"];
    [[NSFileManager defaultManager] createDirectoryAtPath:fileMan withIntermediateDirectories:0 attributes:nil error:nil];
    NSString *path = [fileMan stringByAppendingPathComponent:theName];
    NSLog(@"path : %@",path);
    return path;
}

/*
 * 拼接创建表的sql
 */
-(NSString *)creatSqlWithTableName:(NSString *)tableName withModelClass:(id)Model{
    unsigned int count ;
    
    objc_property_t *properties = class_copyPropertyList(Model, &count);
    NSMutableString *mString = [NSMutableString string];
    for (int i = 0; i < count; i++) {
        objc_property_t property = properties[i];
        const char *cName = property_getName(property);
        if (cName) {
            const char *ctype = getPropertyType(property);
            NSString *name = [NSString stringWithCString:cName encoding:NSUTF8StringEncoding];
            NSString *type = [self getSqltype:[NSString stringWithUTF8String:ctype]];
            NSString *unitStr = [NSString stringWithFormat:@",%@ %@",name,type];
            [mString appendString:unitStr];
        }
    }
    NSString *sqlStr = [NSString stringWithFormat:@"create table if not exists %@(id integer primary key autoincrement %@)", tableName, mString];
    //sqlstr = create table if not exists nihao(id integer primary key autoincrement ,course_uuid TEXT,unit_uuid INTEGER,resource_uuid TEXT,name REAL,url TEXT,type TEXT)
    free(properties);
    return sqlStr;
    
}

/*
 * 插入数据的sql
 */
-(NSString *)insertSqlWithtableName:(NSString *)tableName withModel:(id)model{
    u_int count ;
    objc_property_t *properties = class_copyPropertyList([model class], &count);
    NSMutableArray *keys = [NSMutableArray array];
    NSMutableArray *objs = [NSMutableArray array];
    for (int i = 0; i < count; i ++) {
        objc_property_t property = properties[i];
        const char *cName = property_getName(property);
        if (cName) {
            NSString *name = [NSString stringWithUTF8String:cName];
            NSString *value = [model valueForKey:name];
            [keys addObject:[NSString stringWithFormat:@"'%@'",name]];
            [objs addObject:[NSString stringWithFormat:@"'%@'",value]];
        }
    }
    NSString *keystring = [keys componentsJoinedByString:@","];
    NSString *objstring = [objs componentsJoinedByString:@","];
    NSString *sqlStr = [NSString stringWithFormat:@"insert into %@ (%@) values (%@)", tableName, keystring, objstring];
    //insert into test ('course_uuid','unit_uuid','resource_uuid','name','url','type') values ('course_uuid','12','resource_uuid','0','(null)','(null)');
    return sqlStr;
}

/*
 * 拼接删除sql
 */
-(NSString *)deleteSqlWithTableName:(NSString *)tableName withDic:(NSDictionary *)DicInfo{
    
    NSString *mosaic = [self mosaic:DicInfo type:@"and"];
    if (mosaic == nil) {
        NSString *sqlStr = [NSString stringWithFormat:@"delete from %@" , tableName];
        return sqlStr;
    }
    NSString *sqlStr = [NSString stringWithFormat:@"delete from %@ where %@" , tableName,mosaic];
    NSLog(@"删除sql：%@",sqlStr);
    
    return sqlStr;
}

/*
 * 拼接更新sql
 **/
-(NSString *)updateSqlWithTablename:(NSString *)tableName withDic:(NSDictionary *)DicInfo corDic:(NSDictionary *)corDic{
    NSString *resmosaic = [self mosaic:DicInfo type:@","];
    NSString *cormosaic = [self mosaic:corDic type:@"and"];
    
    if (cormosaic == nil) {
        NSString *sqlStr = [NSString stringWithFormat:@"update %@ set %@", tableName, resmosaic];
        return sqlStr;
    }
    NSString *sqlStr = [NSString stringWithFormat:@"update %@ set %@ where %@", tableName, resmosaic, cormosaic];
    NSLog(@"更新sql：%@",sqlStr);
    return sqlStr;
}

/*
 * 查询的sql
 */
-(NSString *)querySqlWithtableName:(NSString *)tableName withArr:(NSArray *)ArrInfo corDic:(NSDictionary *)corDic{
    //@"SELECT Id, name,screenName,profileImageUrl,mbtype,city FROM User WHERE name='%@'", name];
    NSMutableString *mutableStr = [NSMutableString string];
    if (ArrInfo.count == 0) {
        [mutableStr appendString:@"*"];
    } else {
        for (int i = 0; i < ArrInfo.count; i++) {
            [mutableStr appendString:ArrInfo[i]];
            if (i != ArrInfo.count - 1) {
                [mutableStr appendString:@","];
            }
        }
    }
    NSString *mosaic = [self mosaic:corDic type:@"and"];
    if (!mosaic) {
        NSString *sqlStr = [NSString stringWithFormat:@"select %@ from %@", mutableStr, tableName];
        return sqlStr;
    }
    NSString *sqlStr = [NSString stringWithFormat:@"select %@ from %@ where %@", mutableStr, tableName,mosaic];
    NSLog(@"查询sql：%@",sqlStr);
    
    return sqlStr;
}
//拼接  coutry = 'dd' ，city = 'RR' ／ name = 'smith' and gender = '2'
-(NSString *)mosaic:(NSDictionary *)dic type:(NSString *)str{
    if (!dic) {
        return nil;
    }
    NSMutableString *mutableStr = [NSMutableString string];
    NSArray *allkeys = [dic allKeys];
    for (int i = 0; i < allkeys.count; i++) {
        NSString *key = [allkeys objectAtIndex:i];
        NSString *objStr = [dic objectForKey:key];
        [mutableStr appendString:key];
        [mutableStr appendString:@" "];
        [mutableStr appendString:@"="];
        [mutableStr appendString:@" "];
        [mutableStr appendString:[NSString stringWithFormat:@"'%@'",objStr]];
        if (i != allkeys.count - 1) {
            [mutableStr appendString:@" "];
            [mutableStr appendString:str];
            [mutableStr appendString:@" "];
        }
    }
    return mutableStr;
}

- (NSDictionary *) entityToDictionary:(id)entity
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
        
        id value =  [entity valueForKey:[NSString stringWithUTF8String:propertyName]];
        if(value != nil){
            [propertyArray addObject:[NSString stringWithCString:propertyName encoding:NSUTF8StringEncoding]];
            [valueArray addObject:value];
        }
    }
    
    free(properties);
    
    NSDictionary* returnDic = [NSDictionary dictionaryWithObjects:valueArray forKeys:propertyArray];
    NSLog(@"%@", returnDic);
    
    return returnDic;
}

static const char *getPropertyType(objc_property_t property) {
    const char *attributes = property_getAttributes(property);
    //printf("attributes=%s\n", attributes);
    char buffer[1 + strlen(attributes)];
    strcpy(buffer, attributes);
    char *state = buffer, *attribute;
    while ((attribute = strsep(&state, ",")) != NULL) {
        if (attribute[0] == 'T' && attribute[1] != '@') {
            // it's a C primitive type:
            
            // if you want a list of what will be returned for these primitives, search online for
            // "objective-c" "Property Attribute Description Examples"
            // apple docs list plenty of examples of what you get for int "i", long "l", unsigned "I", struct, etc.
            
            NSString *name = [[NSString alloc] initWithBytes:attribute + 1 length:strlen(attribute) - 1 encoding:NSASCIIStringEncoding];
            return (const char *)[name cStringUsingEncoding:NSASCIIStringEncoding];
        }
        else if (attribute[0] == 'T' && attribute[1] == '@' && strlen(attribute) == 2) {
            // it's an ObjC id type:
            return "id";
        }
        else if (attribute[0] == 'T' && attribute[1] == '@') {
            // it's another ObjC object type:
            NSString *name = [[NSString alloc] initWithBytes:attribute + 3 length:strlen(attribute) - 4 encoding:NSASCIIStringEncoding];
            return (const char *)[name cStringUsingEncoding:NSASCIIStringEncoding];
        }
    }
    return "";
}

-(NSString *)getSqltype:(NSString *)type{
    NSString *string;
    if ([[type lowercaseString] isEqualToString:@"nsstring"]) {
        string = @"TEXT";
    } else if ([[type lowercaseString] isEqualToString:@"i"] || [[type lowercaseString] isEqualToString:@"q"]) {
        string = @"INTEGER";
    } else if ([[type lowercaseString] isEqualToString:@"f"]) {
        string = @"REAL";
    } else {
        string = @"BLOB";
    }
    return string;
}

#pragma mark 对外接口

//创建表
-(void)creatQueueTableWithDBName:(NSString *)dbname tableName:(NSString *)tableName withModelClass:(id)modelClass result:(DBResult)block{
    [self openQueueWithDBName:dbname];
    [_queue inDatabase:^(FMDatabase *db) {
        NSString *sqlStr = [self creatSqlWithTableName:tableName withModelClass:modelClass];
        NSLog(@"建表 －－－－ %@", sqlStr);
        BOOL create = [db executeUpdate:sqlStr];
        block(create);
    }];
}
//插入单条数据
-(void)insertQueueTableWithDBName:(NSString *)dbname tableName:(NSString *)tableName withModel:(id)model result:(DBResult)block{
    [self openQueueWithDBName:dbname];
    
    NSString *insertSql = [self insertSqlWithtableName:tableName withModel:model];
    
    [_queue inDatabase:^(FMDatabase *db) {
        BOOL res = [db executeUpdate:insertSql];
        if (block) {
            block(res);
        }
    }];
}
//批量插入数据 传入模型数组
-(void)insertLotsizeQueueTableWithDBName:(NSString *)dbname tablename:(NSString *)tablename withArray:(NSArray *)models result:(DBResult)block{
    [self openQueueWithDBName:dbname];
    [_queue inDatabase:^(FMDatabase *db) {
        [db beginTransaction];
        BOOL isRollBack = NO;
        @try {
            for (id model in models) {
                NSString *insertSql = [self insertSqlWithtableName:tablename withModel:model];
                [db executeUpdate:insertSql];
            }
        } @catch (NSException *exception) {
            isRollBack = YES;
            [db rollback];
        } @finally {
            if (!isRollBack) {
                [db commit];
                block(YES);
            } else {
                block(NO);
            }
        }
    }];
}

//查询数据 //@"SELECT Id, name,screenName,profileImageUrl,mbtype,city FROM User WHERE name='%@'", name];
-(void)queryQueueTableWithDBName:(NSString *)dbname tablename:(NSString *)tablename withArr:(NSArray *)ArrInfo corDic:(NSDictionary *)corDic modelClass:(Class)modelClass result:(void (^)(NSArray *res))block{
    [self openQueueWithDBName:dbname];
    NSString *sqlStr = [self querySqlWithtableName:tablename withArr:ArrInfo corDic:corDic];
    [_queue inDatabase:^(FMDatabase *db) {
        FMResultSet *result= [db executeQuery:sqlStr];
        NSMutableArray *array=[NSMutableArray array];
        while (result.next) {
            NSDictionary *dic = result.resultDictionary;
            if (modelClass != nil) {
                id model = [modelClass newsWithDict:dic];
                [array addObject:model];
            } else {
                [array addObject:dic];
            }
        }
        block(array);
    }];
}

//删除数据
-(void)deleteQueueTableWithDBName:(NSString *)dbname tablename:(NSString *)tablename corDic:(NSDictionary *)corDic result:(DBResult)block{
    [self openQueueWithDBName:dbname];
    NSString *sqlStr = [self deleteSqlWithTableName:tablename withDic:corDic];
    [_queue inDatabase:^(FMDatabase *db) {
        BOOL result = [db executeUpdate:sqlStr];
        block(result);
    }];
}

//删除数据
-(void)deleteQueueTableWithDBName:(NSString *)dbname tablename:(NSString *)tablename corModel:(id)cormodel result:(DBResult)block{
    NSDictionary *corDic = [self entityToDictionary:cormodel];
    [self deleteQueueTableWithDBName:dbname tablename:tablename corDic:corDic result:^(BOOL result) {
        block(result);
    }];
}

//更新数据
-(void)updateQueueTableWithDBName:(NSString *)dbname tablename:(NSString *)tableName withDicInfo:(NSDictionary *)dicInfo withCorDic:(NSDictionary *)corDic result:(void (^)(_Bool res))block{
    [self openQueueWithDBName:dbname];
    [_queue inDatabase:^(FMDatabase *db) {
        NSString *updateSql = [self updateSqlWithTablename:tableName withDic:dicInfo corDic:corDic];
        BOOL result = [db executeUpdate:updateSql];
        block(result);
    }];
}

//更新数据
-(void)updateQueueTableWithDBName:(NSString *)dbname tablename:(NSString *)tableName withModelInfo:(id)modelInfo withCorModel:(id)cormodel result:(DBResult)block{
    NSDictionary *infoDic = [self entityToDictionary:modelInfo];
    NSDictionary *corDic = [self entityToDictionary:cormodel];
//    NDLog(@"infodic %@ corinfo %@",infoDic,corDic);
    [self updateQueueTableWithDBName:dbname tablename:tableName withDicInfo:infoDic withCorDic:corDic result:^(bool res) {
        block(res);
    }];
}

#pragma mark sql语句直接操作
//用sql查询
-(void)queryDBName:(NSString *)dbname withSql:(NSString *)sql modelClass:(Class)modelClass result:(void (^)(NSArray *res))block{
    [self openQueueWithDBName:dbname];
    [_queue inDatabase:^(FMDatabase *db) {
        FMResultSet *result= [db executeQuery:sql];
        NSMutableArray *array=[NSMutableArray array];
        while (result.next) {
            NSDictionary *dic = result.resultDictionary;
            if (modelClass != nil) {
                id model = [modelClass newsWithDict:dic];
                [array addObject:model];
            } else {
                [array addObject:dic];
            }
        }
        block(array);
    }];
}
@end
