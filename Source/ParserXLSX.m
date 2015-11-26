//
//  ParserXLSX.m
//  Amberbio
//
//  Created by Morten Krogh on 26/11/15.
//  Copyright © 2015 Morten Krogh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ParserXLSX.h"
#include "c-functions.h"

@implementation ParserXLSX: NSObject

-(instancetype) initWithPath:(NSString *) path
{
        [self setNumberOfRows: 0];
        [self setNumberOfColumns: 0];
        [self setRows: [[NSArray alloc] init]];

        if (self = [super init]) {

                BRAOfficeDocumentPackage* officeDocumentPackage = [BRAOfficeDocumentPackage open:path];
                if (officeDocumentPackage != NULL) {
                        BRAOfficeDocument* workbook = [officeDocumentPackage workbook];
                        if (workbook != NULL) {
                                NSArray* worksheets = [workbook worksheets];
                                if ([worksheets count] != 0) {
                                        BRAWorksheet* worksheet = [worksheets objectAtIndex: 0];
                                        NSArray* rows = [worksheet rows];
                                        [self setNumberOfRows: [rows count]];
                                        [self setRows: rows];

                                        for (NSUInteger i = 0; i < [rows count]; i++) {
                                                BRARow* row = [rows objectAtIndex:i];
                                                NSUInteger numberOfCells = [[row cells] count];
                                                if (numberOfCells > [self numberOfColumns]) {
                                                        [self setNumberOfColumns: numberOfCells];
                                                }

                                                [self setValid: YES];
                                        }
                                }
                        }
                }
        }

        return self;
}

-(NSString*) cellStringForRow:(NSInteger)row andColumn:(NSInteger)column
{
        BRARow* bra_row = [[self rows] objectAtIndex: row];
        if (column < [[bra_row cells] count]) {
                BRACell* cell = [[bra_row cells] objectAtIndex: column];
                return [cell stringValue];
        } else {
                return @"";
        }
}

-(nullable BRACell*) cellForRow:(NSInteger)row andColumn:(NSInteger)column
{
        BRARow* bra_row = [[self rows] objectAtIndex: row];
        if (column < [[bra_row cells] count]) {
                BRACell* cell = [[bra_row cells] objectAtIndex: column];
                return cell;
        } else {
                return NULL;
        }
}




-(double) valueForCell:(BRACell*) cell
{
        if ([cell type] == BRACellContentTypeNumber || [cell type] == BRACellContentTypeUnknown) {
                return (double) [cell floatValue];
        } else {
                NSString* str = [cell stringValue];
                const char* const_c_string = [str cStringUsingEncoding:NSUTF8StringEncoding];
                char* c_string = malloc(strlen(const_c_string) + 1);
                strcpy(c_string, const_c_string);
                double value = parse_parse_double(c_string);
                free(c_string);
                return value;
        }
}

-(NSArray*) cellValuesRowMajor:(NSInteger)row_0 row_1:(NSInteger)row_1 col_0:(NSInteger)col_0 col_1:(NSInteger)col_1
{
        NSMutableArray* values = [NSMutableArray arrayWithCapacity: (row_1 - row_0 + 1) * (col_1 - col_0 + 1)];

        for (NSInteger i = 0; i < row_1 - row_0 + 1; i++) {
                BRARow* bra_row = [[self rows] objectAtIndex: (row_0 + i)];
                NSArray* cells_for_row = [bra_row cells];
                for (NSInteger j = 0; j < col_1 - col_0 + 1; j++) {
                        NSInteger col = col_0 + j;
                        double value = nan("");
                        if (col < [cells_for_row count]) {
                                BRACell* cell = [cells_for_row objectAtIndex: col];
                                value = [self valueForCell: cell];
                        }
                        NSInteger index = i * (col_1 - col_0 + 1) + j;
                        NSNumber* number = [[NSNumber alloc] initWithDouble: value];
                        [values insertObject: number atIndex:index];
                }

        }
        return values;
}

//func cell_values_row_major(row_0 row_0: Int, row_1: Int, col_0: Int, col_1: Int) -> [Double] {
//        var values = [Double](count: (row_1 - row_0 + 1) * (col_1 - col_0 + 1), repeatedValue: Double.NaN)
//
//        //                for i in 0 ..< row_1 - row_0 + 1 {
//        //                        for j in 0 ..< col_1 - col_0 + 1 {
//        //                                let row_of_cells = cells[row_0 + i]
//        //                                let col = col_0 + j
//        //                                if col < row_of_cells.count {
//        //                                        let cell = row_of_cells[col]
//        //                                        let index = i * (col_1 - col_0 + 1) + j
//        //                                        values[index] = cell_value(cell: cell)
//        //                                }
//        //                        }
//        //
//        //
//        //                }
//
//        return values
//}
//
//func cell_values_column_major(row_0 row_0: Int, row_1: Int, col_0: Int, col_1: Int) -> [Double] {
//        var values = [Double](count: (row_1 - row_0 + 1) * (col_1 - col_0 + 1), repeatedValue: Double.NaN)
//
//        //                for j in 0 ..< col_1 - col_0 + 1 {
//        //                        for i in 0 ..< row_1 - row_0 + 1 {
//        //                                let row_of_cells = cells[row_0 + i]
//        //                                let col = col_0 + j
//        //                                if col < row_of_cells.count {
//        //                                        let cell = row_of_cells[col]
//        //                                        let index = j * (row_1 - row_0 + 1) + i
//        //                                        values[index] = cell_value(cell: cell)
//        //                                }
//        //                        }
//        //                }
//
//        return values
//}



@end
