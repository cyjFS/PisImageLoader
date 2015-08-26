//
//  NetworkConfiguration.h
//  NeweggLibrary
//
//  Created by Frog Tan on 14-1-24.
//  Copyright (c) 2014年 newegg. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^RequestHandler)(NSURLRequest *urlRequest, NSData *data);
typedef void (^ResponseHandler)(NSURLResponse *urlResponse, NSData *data);

@interface NetworkConfiguration : NSObject

+ (NetworkConfiguration *)sharedConfiguration;

@end
