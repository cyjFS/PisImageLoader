//
//  ServiceLoader.h
//  NeweggLibrary
//
//  Created by Frog Tan on 14-1-23.
//  Copyright (c) 2014年 newegg. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ServiceLoaderStartCallBack)(NSURLRequest *request);
typedef void (^ServiceLoaderFinishCallBack)(NSData *data, NSURLResponse *response, NSError *error);

@protocol ServiceLoader <NSObject>
- (void)start;
- (void)cancel;
- (void)retry;
@end


typedef NS_ENUM(NSInteger, ServiceLoaderType){
	ServiceLoaderTypeGet,
	ServiceLoaderTypePost,
	ServiceLoaderTypeDelete
};

@interface ServiceLoader : NSObject<ServiceLoader>
@property	(nonatomic, strong) NSURLRequest		*request;
@property	(nonatomic, strong) NSData				*formData;
@property	(nonatomic, assign)	ServiceLoaderType	type;

@property	(nonatomic, strong) ServiceLoaderStartCallBack	startCallBack;
@property	(nonatomic, strong) ServiceLoaderFinishCallBack	finishCallBack;

+ (ServiceLoader *)loaderWithRequest:(NSURLRequest *)request
						  loaderType:(ServiceLoaderType)loaderType
					   startCallBack:(ServiceLoaderStartCallBack)startCallBack
					  finishCallBack:(ServiceLoaderFinishCallBack)finishCallBack;

- (void)invalidate;
@end
