//
//  DefaultServiceLoader.m
//  NeweggLibrary
//
//  Created by Frog Tan on 14-1-23.
//  Copyright (c) 2014年 newegg. All rights reserved.
//

#import "DefaultServiceLoader.h"

#import "Consts.h"
#import "NetworkConfiguration.h"

@interface DefaultServiceLoaderHelper : NSObject<NSURLSessionDelegate>

@end

@implementation DefaultServiceLoaderHelper
//#pragma mark - NSURLSessionDelegate
//
//// TODO:: For test under PRE server
//- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler
//{
//    if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
//        if([challenge.protectionSpace.host rangeOfString:@"newegg"].location != NSNotFound) {
//            NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
//            completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
//        }
//    }
//}

- (void)dealloc{

}
@end

@interface DefaultServiceLoader () <NSURLSessionDelegate>
@property	(nonatomic, strong)	NSURLSession			*session;
@property	(nonatomic, strong) NSURLSessionDataTask	*dataTask;

@property	(nonatomic, strong) DefaultServiceLoaderHelper	*helper;
@end

@implementation DefaultServiceLoader

- (id)init{
	self = [super init];
	
	if( self ){
        self.helper = [[DefaultServiceLoaderHelper alloc] init];
	}
	
	return self;
}

- (void)start{
	[super start];
	
	NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
	
	if(!self.helper){
		self.session = [NSURLSession sessionWithConfiguration:configuration];
	}
	else{
		self.session = [NSURLSession sessionWithConfiguration:configuration
													 delegate:self.helper
												delegateQueue:nil];
	}
            
	switch (self.type) {
		case ServiceLoaderTypeGet:
		{
			self.dataTask = [self.session dataTaskWithRequest:self.request
										completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
											if(self.finishCallBack){
												self.finishCallBack(data, response, error);
											}
										}];
		}

			break;
		case ServiceLoaderTypePost:
		{
			self.dataTask = [self.session uploadTaskWithRequest:self.request
													   fromData:self.formData
											  completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
												  if(self.finishCallBack){
													  self.finishCallBack(data, response, error);
												  }
											  }];
		}
			break;
		case ServiceLoaderTypeDelete:
		{
			self.dataTask = [self.session dataTaskWithRequest:self.request
											completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
												if(self.finishCallBack){
													self.finishCallBack(data, response, error);
												}
											}];
		}
			break;
		default:
			break;
	}
	
	if(self.startCallBack){
		self.startCallBack(self.request);
	}
	
	[self.dataTask resume];
}

- (void)cancel{
	[super cancel];
	
	[self.dataTask cancel];
	self.dataTask = nil;
	
	[self.session invalidateAndCancel];
	self.session = nil;
}

- (void)retry{
	[super retry];
}

- (void)dealloc{
	
}

- (void)invalidate{
	self.startCallBack = nil;
	self.finishCallBack = nil;
	
	self.helper = nil;
	[self.session finishTasksAndInvalidate];
}


@end
