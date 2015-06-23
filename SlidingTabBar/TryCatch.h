//
//  TryCatch.h
//  SlidingTabBar
//
//  Created by Mike on 6/23/15.
//  Copyright © 2015 Mike Perry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TryCatch : NSObject

+ (void)tryIt:(void(^)())tryIt catchIt:(void(^)(NSException *exception))catchIt finallyIt:(void(^)())finallyIt;

@end
