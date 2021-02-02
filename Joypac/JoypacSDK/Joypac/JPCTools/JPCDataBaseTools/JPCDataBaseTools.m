//
//  JoypacDataBaseTools.m

//
//  Created by 洋吴 on 2019/3/18.
//  Copyright © 2019 yodo1. All rights reserved.
//

#import "JPCDataBaseTools.h"
#import "JPCKeyValueStore.h"
#import "JPCConst.h"

@interface JPCDataBaseTools ()

@property (nonatomic, strong) JPCKeyValueStore *store;

@end

@implementation JPCDataBaseTools

+ (instancetype)dbTools{
    
    static JPCDataBaseTools *dbTools = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dbTools = [[JPCDataBaseTools alloc]init];
    });
    return dbTools;
}

- (instancetype)init{
    if (self = [super init]) {
        [self initTable];
    }
    return self;
}
- (void)initTable{
    
    self.store = [[JPCKeyValueStore alloc]initDBWithName:kJoypacDBName];
    [self.store createTableWithName:kJoypacTableName];
    
}

- (void)putObject:(id)object withId:(NSString *)objectId{
    
    [self.store putObject:object withId:objectId intoTable:kJoypacTableName];
    
}

- (id)getObjectById:(NSString *)objectId{
    
    return [self.store getObjectById:objectId fromTable:kJoypacTableName];
}

- (void)putString:(NSString *)string withId:(NSString *)stringId{
    
    [self.store putString:string withId:stringId intoTable:kJoypacTableName];
}

- (NSString *)getStringById:(NSString *)stringId{
    
    return [self.store getStringById:stringId fromTable:kJoypacTableName];
}

- (void)putNumber:(NSNumber *)number withId:(NSString *)numberId{
    
    [self.store putNumber:number withId:numberId intoTable:kJoypacTableName];
}

- (NSNumber *)getNumberById:(NSString *)numberId{
    
    return [self.store getNumberById:numberId fromTable:numberId];
}

- (void)deleteObjectById:(NSString *)objectId{
    
    [self.store deleteObjectById:objectId fromTable:kJoypacTableName];
    
}

@end
