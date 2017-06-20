//
//  ViewController.m
//  FMDB
//
//  Created by 魏延龙 on 2017/6/20.
//  Copyright © 2017年 魏延龙. All rights reserved.
//

#import "ViewController.h"

#import "courseModel.h"
#import "unitModel.h"
#import "infoModel.h"
#import "NDFMDBManager.h"

#define DBNAME @"MYDB"

#define COURSE @"course"
#define UNIT @"unit"
#define INFO @"info"

@interface ViewController ()

@property (nonatomic, strong) NDFMDBManager *manager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.manager = [NDFMDBManager shareNDSQLManger];
    
    
}
- (IBAction)creat:(id)sender {
    
    [self.manager creatQueueTableWithDBName:DBNAME tableName:COURSE withModelClass:[courseModel class] result:^(BOOL result) {
        NSLog(@"course 创建成功");
    }];
    [self.manager creatQueueTableWithDBName:DBNAME tableName:UNIT withModelClass:[unitModel class] result:^(BOOL result) {
        NSLog(@"unit 创建成功");
    }];
    [self.manager creatQueueTableWithDBName:DBNAME tableName:INFO withModelClass:[infoModel class] result:^(BOOL result) {
        NSLog(@"info 创建成功");
    }];
    
}

- (IBAction)insert:(id)sender {
    NSMutableArray *courses = [NSMutableArray array];
    NSMutableArray *units = [NSMutableArray array];
    NSMutableArray *infos = [NSMutableArray array];
    for (int i = 0; i < 10; i++) {
        courseModel *model = [[courseModel alloc] init];
        model.course_uuid = [NSString stringWithFormat:@"%d",i*100];
        [courses addObject:model];
    }
    
    for (int i = 0; i < 10; i++) {
        for (int j = 0; j < 5; j++) {
            unitModel *unit = [[unitModel alloc] init];
            unit.course_uuid = [NSString stringWithFormat:@"%d",i*100];
            unit.unit_uuid = [NSString stringWithFormat:@"%d",i * 10 + j] ;
            [units addObject:unit];
            for (int a = 0; a < 9; a ++) {
                infoModel *info = [[infoModel alloc] init];
                info.unit_uuid = [NSString stringWithFormat:@"%d",i * 10 + j] ;
                info.info_uuid = [NSString stringWithFormat:@"%d",i * 100 + j * 10 + a] ;
                info.url = [[NSUUID UUID] UUIDString];
                [infos addObject:info];
            }
            
        }
        
    }
    
    [self.manager insertLotsizeQueueTableWithDBName:DBNAME tablename:INFO withArray:infos result:^(BOOL result) {
        if (result) {
            NSLog(@"插入成功");
        }
    }];
    
    
}
- (IBAction)delete:(id)sender {
    [self.manager deleteQueueTableWithDBName:DBNAME tablename:UNIT corDic:nil result:^(BOOL result) {
        if (result) {
            NSLog(@"删除成功");
        }
    }];
}

- (IBAction)update:(id)sender {
    
}
- (IBAction)select:(id)sender {
    NSString *sql = @"select info.url from info,course,unit where course.course_uuid = 100 and unit.unit_uuid = 12 and info_uuid = 120";
    [self.manager queryDBName:DBNAME withSql:sql modelClass:[infoModel class] result:^(NSArray *res) {
        NSLog(@"res :%@",res);
    }];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
