//
//  JPCKeyValueStore.m

//
//  Created by 洋吴 on 2019/3/14.
//  Copyright © 2019 yodo1. All rights reserved.
//

#import "JPCKeyValueStore.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "FMDatabaseQueue.h"


#define PATH_OF_DOCUMENT    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]

@implementation JPCKeyValueItem

- (NSString *)description {
    return [NSString stringWithFormat:@"id=%@, value=%@, timeStamp=%@", _itemId, _itemObject, _createdTime];
}

@end

@interface JPCKeyValueStore()

@property (strong, nonatomic) FMDatabaseQueue * dbQueue;

@end

@implementation JPCKeyValueStore

static NSString *const DEFAULT_DB_NAME = @"database.sqlite";

static NSString *const CREATE_TABLE_SQL =
@"CREATE TABLE IF NOT EXISTS %@ ( \
id TEXT NOT NULL, \
json TEXT NOT NULL, \
createdTime TEXT NOT NULL, \
PRIMARY KEY(id)) \
";

static NSString *const UPDATE_ITEM_SQL = @"REPLACE INTO %@ (id, json, createdTime) values (?, ?, ?)";

static NSString *const QUERY_ITEM_SQL = @"SELECT json, createdTime from %@ where id = ? Limit 1";

static NSString *const SELECT_ALL_SQL = @"SELECT * from %@";

static NSString *const COUNT_ALL_SQL = @"SELECT count(*) as num from %@";

static NSString *const CLEAR_ALL_SQL = @"DELETE from %@";

static NSString *const DELETE_ITEM_SQL = @"DELETE from %@ where id = ?";

static NSString *const DELETE_ITEMS_SQL = @"DELETE from %@ where id in ( %@ )";

static NSString *const DELETE_ITEMS_WITH_PREFIX_SQL = @"DELETE from %@ where id like ? ";

static NSString *const DROP_TABLE_SQL = @" DROP TABLE '%@' ";

+ (BOOL)checkTableName:(NSString *)tableName {
    if (tableName == nil || tableName.length == 0 || [tableName rangeOfString:@" "].location != NSNotFound) {
        return NO;
    }
    return YES;
}

- (id)init {
    return [self initDBWithName:DEFAULT_DB_NAME];
}

- (id)initDBWithName:(NSString *)dbName {
    self = [super init];
    if (self) {
        NSString * dbPath = [PATH_OF_DOCUMENT stringByAppendingPathComponent:dbName];
        if (_dbQueue) {
            [self close];
        }
        _dbQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    }
    return self;
}

- (id)initWithDBWithPath:(NSString *)dbPath {
    self = [super init];
    if (self) {
        
        if (_dbQueue) {
            [self close];
        }
        _dbQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    }
    return self;
}

- (void)createTableWithName:(NSString *)tableName {
    if ([JPCKeyValueStore checkTableName:tableName] == NO) {
        return;
    }
    NSString * sql = [NSString stringWithFormat:CREATE_TABLE_SQL, tableName];
    __block BOOL result;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql];
    }];
    if (!result) {
    }
}

- (BOOL)isTableExists:(NSString *)tableName{
    if ([JPCKeyValueStore checkTableName:tableName] == NO) {
        return NO;
    }
    __block BOOL result;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        result = [db tableExists:tableName];
    }];
    if (!result) {

    }
    return result;
}

- (void)clearTable:(NSString *)tableName {
    if ([JPCKeyValueStore checkTableName:tableName] == NO) {
        return;
    }
    NSString * sql = [NSString stringWithFormat:CLEAR_ALL_SQL, tableName];
    __block BOOL result;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql];
    }];
    if (!result) {

    }
}

- (void)dropTable:(NSString *)tableName {
    if ([JPCKeyValueStore checkTableName:tableName] == NO) {
        return;
    }
    NSString * sql = [NSString stringWithFormat:DROP_TABLE_SQL, tableName];
    __block BOOL result;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql];
    }];
    if (!result) {

    }
}

- (void)putObject:(id)object withId:(NSString *)objectId intoTable:(NSString *)tableName {
    if ([JPCKeyValueStore checkTableName:tableName] == NO) {
        return;
    }
    NSError * error;
    if (!object) {
        return;
    }
    NSData * data = [NSJSONSerialization dataWithJSONObject:object options:0 error:&error];
    if (error) {

        return;
    }
    NSString * jsonString = [[NSString alloc] initWithData:data encoding:(NSUTF8StringEncoding)];
    NSDate * createdTime = [NSDate date];
    NSString * sql = [NSString stringWithFormat:UPDATE_ITEM_SQL, tableName];
    __block BOOL result;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql, objectId, jsonString, createdTime];
    }];
    if (!result) {

    }
}

- (id)getObjectById:(NSString *)objectId fromTable:(NSString *)tableName {
    JPCKeyValueItem * item = [self getJPCKeyValueItemById:objectId fromTable:tableName];
    if (item) {
        return item.itemObject;
    } else {
        return nil;
    }
}

- (JPCKeyValueItem *)getJPCKeyValueItemById:(NSString *)objectId fromTable:(NSString *)tableName {
    if ([JPCKeyValueStore checkTableName:tableName] == NO) {
        return nil;
    }
    NSString * sql = [NSString stringWithFormat:QUERY_ITEM_SQL, tableName];
    __block NSString * json = nil;
    __block NSDate * createdTime = nil;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet * rs = [db executeQuery:sql, objectId];
        if ([rs next]) {
            json = [rs stringForColumn:@"json"];
            createdTime = [rs dateForColumn:@"createdTime"];
        }
        [rs close];
    }];
    if (json) {
        NSError * error;
        id result = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding]
                                                    options:(NSJSONReadingAllowFragments) error:&error];
        if (error) {
            return nil;
        }
        JPCKeyValueItem * item = [[JPCKeyValueItem alloc] init];
        item.itemId = objectId;
        item.itemObject = result;
        item.createdTime = createdTime;
        return item;
    } else {
        return nil;
    }
}

- (void)putString:(NSString *)string withId:(NSString *)stringId intoTable:(NSString *)tableName {
    if (string == nil) {

        return;
    }
    [self putObject:@[string] withId:stringId intoTable:tableName];
}

- (NSString *)getStringById:(NSString *)stringId fromTable:(NSString *)tableName {
    NSArray * array = [self getObjectById:stringId fromTable:tableName];
    if (array && [array isKindOfClass:[NSArray class]]) {
        return array[0];
    }
    return nil;
}

- (void)putNumber:(NSNumber *)number withId:(NSString *)numberId intoTable:(NSString *)tableName {
    if (number == nil) {
        return;
    }
    [self putObject:@[number] withId:numberId intoTable:tableName];
}

- (NSNumber *)getNumberById:(NSString *)numberId fromTable:(NSString *)tableName {
    NSArray * array = [self getObjectById:numberId fromTable:tableName];
    if (array && [array isKindOfClass:[NSArray class]]) {
        return array[0];
    }
    return nil;
}

- (NSArray *)getAllItemsFromTable:(NSString *)tableName {
    if ([JPCKeyValueStore checkTableName:tableName] == NO) {
        return nil;
    }
    NSString * sql = [NSString stringWithFormat:SELECT_ALL_SQL, tableName];
    __block NSMutableArray * result = [NSMutableArray array];
    [_dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet * rs = [db executeQuery:sql];
        while ([rs next]) {
            JPCKeyValueItem * item = [[JPCKeyValueItem alloc] init];
            item.itemId = [rs stringForColumn:@"id"];
            item.itemObject = [rs stringForColumn:@"json"];
            item.createdTime = [rs dateForColumn:@"createdTime"];
            [result addObject:item];
        }
        [rs close];
    }];
    // parse json string to object
    NSError * error;
    for (JPCKeyValueItem * item in result) {
        error = nil;
        id object = [NSJSONSerialization JSONObjectWithData:[item.itemObject dataUsingEncoding:NSUTF8StringEncoding]
                                                    options:(NSJSONReadingAllowFragments) error:&error];
        if (error) {
        } else {
            item.itemObject = object;
        }
    }
    return result;
}

- (NSUInteger)getCountFromTable:(NSString *)tableName
{
    if ([JPCKeyValueStore checkTableName:tableName] == NO) {
        return 0;
    }
    NSString * sql = [NSString stringWithFormat:COUNT_ALL_SQL, tableName];
    __block NSInteger num = 0;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet * rs = [db executeQuery:sql];
        if ([rs next]) {
            num = [rs unsignedLongLongIntForColumn:@"num"];
        }
        [rs close];
    }];
    return num;
}

- (void)deleteObjectById:(NSString *)objectId fromTable:(NSString *)tableName {
    if ([JPCKeyValueStore checkTableName:tableName] == NO) {
        return;
    }
    NSString * sql = [NSString stringWithFormat:DELETE_ITEM_SQL, tableName];
    __block BOOL result;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql, objectId];
    }];
    if (!result) {
    }
}

- (void)deleteObjectsByIdArray:(NSArray *)objectIdArray fromTable:(NSString *)tableName {
    if ([JPCKeyValueStore checkTableName:tableName] == NO) {
        return;
    }
    NSMutableString *stringBuilder = [NSMutableString string];
    for (id objectId in objectIdArray) {
        NSString *item = [NSString stringWithFormat:@" '%@' ", objectId];
        if (stringBuilder.length == 0) {
            [stringBuilder appendString:item];
        } else {
            [stringBuilder appendString:@","];
            [stringBuilder appendString:item];
        }
    }
    NSString *sql = [NSString stringWithFormat:DELETE_ITEMS_SQL, tableName, stringBuilder];
    __block BOOL result;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql];
    }];
    if (!result) {
    }
}

- (void)deleteObjectsByIdPrefix:(NSString *)objectIdPrefix fromTable:(NSString *)tableName {
    if ([JPCKeyValueStore checkTableName:tableName] == NO) {
        return;
    }
    NSString *sql = [NSString stringWithFormat:DELETE_ITEMS_WITH_PREFIX_SQL, tableName];
    NSString *prefixArgument = [NSString stringWithFormat:@"%@%%", objectIdPrefix];
    __block BOOL result;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql, prefixArgument];
    }];
    if (!result) {
    }
}

- (void)close {
    [_dbQueue close];
    _dbQueue = nil;
}


@end
