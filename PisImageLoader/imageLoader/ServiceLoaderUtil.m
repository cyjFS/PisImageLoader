//
//  ServiceLoaderFactory.m
//  NeweggLibrary
//
//  Created by Frog Tan on 14-1-23.
//  Copyright (c) 2014年 newegg. All rights reserved.
//

#import "ServiceLoaderUtil.h"
#import "DefaultServiceLoader.h"
#import "Consts.h"

@implementation ServiceLoaderUtil

//GET
+ (ServiceLoader *)loaderForGetWithRequest:(NSURLRequest *)request
									 start:(ServiceLoaderStartCallBack)start
									finish:(ServiceLoaderFinishCallBack)finish{
	NSMutableURLRequest *mutableRequest = [request mutableCopy];
	[mutableRequest setHTTPMethod:kHTTPMethodGET];

	return [DefaultServiceLoader loaderWithRequest:mutableRequest
										loaderType:ServiceLoaderTypeGet
									 startCallBack:start
									finishCallBack:finish];
}

//POST
+ (ServiceLoader *)loaderForPostWithRequest:(NSURLRequest *)request
								   formData:(NSData *)formData
									  start:(ServiceLoaderStartCallBack)start
									 finish:(ServiceLoaderFinishCallBack)finish{
	NSMutableURLRequest *mutableRequest = [request mutableCopy];
	[mutableRequest setHTTPMethod:kHTTPMethodPOST];
	[mutableRequest setValue:[NSString stringWithFormat:@"%llu", (unsigned long long)(formData.length)]
		  forHTTPHeaderField:kContentLengthKey];
	
	ServiceLoader *loader = [DefaultServiceLoader loaderWithRequest:mutableRequest
														 loaderType:ServiceLoaderTypePost
													  startCallBack:start
													 finishCallBack:finish];
	loader.formData = formData;
	
	
	return loader;
}


//DELETE
+ (ServiceLoader *)loaderForDeleteWithRequest:(NSURLRequest *)request
										start:(ServiceLoaderStartCallBack)start
									   finish:(ServiceLoaderFinishCallBack)finish{
	NSMutableURLRequest *mutableRequest = [request mutableCopy];
	[mutableRequest setHTTPMethod:kHTTPMethodDelete];
	
	return [DefaultServiceLoader loaderWithRequest:mutableRequest
										loaderType:ServiceLoaderTypeDelete
									 startCallBack:start
									finishCallBack:finish];

}
@end
