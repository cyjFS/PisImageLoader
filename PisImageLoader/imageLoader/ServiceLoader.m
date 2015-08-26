//
//  ServiceLoader.m
//  NeweggLibrary
//
//  Created by Frog Tan on 14-1-23.
//  Copyright (c) 2014年 newegg. All rights reserved.
//

#import "ServiceLoader.h"
#import "Consts.h"
#import "NetworkConfiguration.h"

@implementation ServiceLoader
+ (ServiceLoader *)loaderWithRequest:(NSURLRequest *)request
						  loaderType:(ServiceLoaderType)loaderType
					   startCallBack:(ServiceLoaderStartCallBack)startCallBack
					  finishCallBack:(ServiceLoaderFinishCallBack)finishCallBack{
	ServiceLoader *loader = [[self alloc] init];
	
	loader.request = request;
	loader.type = loaderType;
	loader.startCallBack = startCallBack;  
	loader.finishCallBack = finishCallBack;
	
	return loader;
}

- (void)start{
	
}

- (void)cancel{

}

- (void)retry{
	[self start];
}

- (void)invalidate{
	
}
@end
