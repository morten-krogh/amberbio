//
//  geo_soft_file_parser.h
//  Amberbio
//
//  Created by Morten Krogh on 13/11/15.
//  Copyright © 2015 Morten Krogh. All rights reserved.
//

#ifndef geo_soft_file_parser_h
#define geo_soft_file_parser_h

#include <stdio.h>
#include <string.h>

void geo_soft_find_header(const void* bytes, const long length, char* cstring, const long cstring_max_length);


#endif /* geo_soft_file_parser_h */
