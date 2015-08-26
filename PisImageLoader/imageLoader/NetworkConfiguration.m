//
//  NetworkConfiguration.m
//  NeweggLibrary
//
//  Created by Frog Tan on 14-1-24.
//  Copyright (c) 2014年 newegg. All rights reserved.
//

#import "NetworkConfiguration.h"

@implementation NetworkConfiguration
+ (NetworkConfiguration *)sharedConfiguration{
	static NetworkConfiguration *configuration = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		configuration = [[self alloc] init];
	});
	
	return configuration;
}
@end
