#import <Foundation/Foundation.h>
#import "BRAOfficeDocumentPackage.h"

@interface ParserXLSX: NSObject {

//        NSInteger* number_of_rows;


}

- (instancetype)initWithPath:(NSString *)path;

@property BOOL valid;
@property NSInteger numberOfRows;
@property NSInteger numberOfColumns;

@property NSArray* rows;

-(NSString*) cellStringForRow: (NSInteger) row andColumn: (NSInteger) column;
-(NSArray*) cellValuesRowMajor:(NSInteger)row_0 row_1:(NSInteger)row_1 col_0:(NSInteger)col_0 col_1:(NSInteger)col_1;

@end;
