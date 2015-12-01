//
//  Avocarrot.m
//  Amberbio
//
//  Created by Morten Krogh on 01/12/15.
//  Copyright © 2015 Morten Krogh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AvocarrotCustom.h"

BOOL avocarrot_ad_valid(AVCustomAd* ad)
{
        return  [ad getCTAText] != NULL && [ad getHeadline] != NULL && [ad getSubHeadline] != NULL && [ad getImage] != NULL;
}
