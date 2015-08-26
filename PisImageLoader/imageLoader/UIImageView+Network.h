//
//  UIImageView+Network.h
//  PisImageLoader
//
//  Created by newegg on 15/8/20.
//  Copyright (c) 2015年 newegg. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(char, ImageViewLoadingStyle){
    ImageViewLoadingStyleNone, //不显示loading
    ImageViewLoadingStyleWhite,//显示白色的loading
    ImageViewLoadingStyleGray  //显示灰色的loading
};
@interface UIImageView (Network)

@property (nonatomic, strong) UIImage    *localImage;
/*
 * url : 图片地址
 * placeHolderImage : 图片资源请求回来之前显示的占位图
 * errorImage : 图片请求失败时显示的占位图
 * loadingStype : 请求图片时的loading样式
 */
- (void)setImageURL:(NSString *)url
   placeHolderImage:(UIImage *)placeHolderImage
         errorImage:(UIImage *)errorImage
       loadingStyle:(ImageViewLoadingStyle)loadingStyle;

- (void)setImageURL:(NSString *)url
   placeHolderImage:(UIImage *)placeHolderImage
       loadingStyle:(ImageViewLoadingStyle)loadingStyle;

- (void)setImageURL:(NSString *)url
   placeHolderImage:(UIImage *)placeHolderImage;

- (void)setImageURL:(NSString *)url
         errorImage:(UIImage *)errorImage
       loadingStyle:(ImageViewLoadingStyle)loadingStyle;

- (void)setImageURL:(NSString *)url
         errorImage:(UIImage *)errorImage;

- (void)setImageURL:(NSString *)url
       loadingStyle:(ImageViewLoadingStyle)loadingStyle;

- (void)setImageURL:(NSString *)url;

- (void)setLocalImage:(UIImage *)localImage;
@end


@interface ImageLoader : NSObject
- (void)loadImageWithURL:(NSString *)url
                   start:(void (^)(void))start
                  finish:(void (^)(UIImage *image))finish;

- (void)cancel;
@end

@interface ImageCacheManager : NSObject
+ (id)sharedManager;

+ (void)clearCacheBeforeDate:(NSDate *)date
                       start:(void (^)(void))start
                    finished:(void (^)(void))finish;

+ (void)clearCacheStart:(void (^)(void))start
               finished:(void (^)(void))finish;

+ (void)calculateCacheSizeStart:(void (^)(void))start
                       finished:(void (^)(NSUInteger size))finish;

@end

