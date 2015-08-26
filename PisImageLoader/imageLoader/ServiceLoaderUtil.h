//
//  ServiceLoaderFactory.h
//  NeweggLibrary
//
//  Created by Frog Tan on 14-1-23.
//  Copyright (c) 2014年 newegg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServiceLoader.h"

@interface ServiceLoaderUtil : NSObject
//GET
+ (ServiceLoader *)loaderForGetWithRequest:(NSURLRequest *)request
								 start:(ServiceLoaderStartCallBack)start
								finish:(ServiceLoaderFinishCallBack)finish;

//POST
+ (ServiceLoader *)loaderForPostWithRequest:(NSURLRequest *)request
								   formData:(NSData *)formData
								  start:(ServiceLoaderStartCallBack)start
								 finish:(ServiceLoaderFinishCallBack)finish;

//DELETE
+ (ServiceLoader *)loaderForDeleteWithRequest:(NSURLRequest *)request
									start:(ServiceLoaderStartCallBack)start
								   finish:(ServiceLoaderFinishCallBack)finish;
@end
