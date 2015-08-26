//
//  HTTPMethods.h
//  NeweggLibrary
//
//  Created by Frog Tan on 14-1-23.
//  Copyright (c) 2014年 newegg. All rights reserved.
//

#ifndef NeweggLibrary_Consts_h
#define NeweggLibrary_Consts_h

#define	KFormBoundary				@"0194784892923"

//http method
#define	kHTTPMethodGET				@"GET"
#define	kHTTPMethodPOST				@"POST"
#define	kHTTPMethodDelete			@"DELETE"
#define	kHTTPMethodPUT				@"PUT"

//content type
#define kContentTypeKey				@"Content-Type"

#define kContentTypeJSON			@"application/json"
#define kContentTypeFormURLEncoded	@"application/x-www-form-urlencoded"
#define kContentTypeFile			[NSString stringWithFormat:@"multipart/fLorm-data; boundary=%@", KFormBoundary]

////content length
#define kContentLengthKey			@"Content-Length"

#endif
