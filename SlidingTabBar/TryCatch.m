//
//  TryCatch.m
//  SlidingTabBar
//
//  Created by Mike on 6/23/15.
//  Copyright © 2015 Mike Perry. All rights reserved.
//

#import "TryCatch.h"

@implementation TryCatch

+ (void)tryIt:(void (^)())tryIt catchIt:(void (^)(NSException *))catchIt finallyIt:(void (^)())finallyIt
{
    @try {
        tryIt ? tryIt() : nil;
    }
    @catch (NSException *exception) {
        catchIt ? catchIt(exception) : nil;
    }
    @finally {
        finallyIt ? finallyIt() : nil;
    }
}

@end
