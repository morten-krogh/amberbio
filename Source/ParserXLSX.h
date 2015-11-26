#import <Foundation/Foundation.h>
#import "BRAOfficeDocumentPackage.h"

@interface ParserXLSX: NSObject {}

- (nullable instancetype)initWithPath:(nonnull NSString *)path;

@property NSInteger numberOfRows;
@property NSInteger numberOfColumns;

@property NSArray* _Nonnull rows;

-(nullable BRACell*) cellForRow:(NSInteger)row andColumn:(NSInteger)column;

@end;
