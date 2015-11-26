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

-(nullable instancetype) initWithPath:(NSString *) path
{
        [self setNumberOfRows: 0];
        [self setNumberOfColumns: 0];
        [self setRows: [[NSArray alloc] init]];

        if (self = [super init]) {

                BRAOfficeDocumentPackage* officeDocumentPackage = [BRAOfficeDocumentPackage open:path];
                if (officeDocumentPackage == NULL) {
                        return NULL;
                }

                BRAOfficeDocument* workbook = [officeDocumentPackage workbook];
                if (workbook == NULL) {
                        return NULL;
                }

                NSArray* worksheets = [workbook worksheets];
                if ([worksheets count] == 0) {
                        return NULL;
                }

                BRAWorksheet* worksheet = [worksheets objectAtIndex: 0];
                NSArray* rows = [worksheet rows];
                [self setNumberOfRows: [rows count]];
                [self setRows: rows];

                for (NSInteger i = 0; i < [rows count]; i++) {
                        BRARow* row = [rows objectAtIndex:i];
                        NSInteger numberOfCells = [[row cells] count];
                        if (numberOfCells > [self numberOfColumns]) {
                                [self setNumberOfColumns: numberOfCells];
                        }
                }
        }

        return self;
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

@end
