//
//  UIImageView+Network.m
//  PisImageLoader
//
//  Created by newegg on 15/8/20.
//  Copyright (c) 2015年 newegg. All rights reserved.
//

#import "UIImageView+Network.h"
#import "NSString+Utils.h"
#import "UIView+Utils.h"

#import "ServiceLoader.h"
#import "ServiceLoaderUtil.h"

#import <objc/runtime.h>

#define kLoaderKey	"Loader"
#define kRelatedIndicatorViewKey	"RelatedIndicatorView"
#define kImageURLKey "RemoteImageURL"

#define kActivityIndicatorViewTag 99999

@interface ImageCacheManager ()
@property (nonatomic, strong) NSMutableArray        *fileIndexInMemory;
@property (nonatomic, strong) NSCache               *imageMemoryCache;
@property (nonatomic, strong) NSCache               *filePathMemoryCache;
@property (nonatomic, strong) dispatch_queue_t      writeDataQueue;
@property (nonatomic, strong) dispatch_queue_t      loadDataQueue;

@property (nonatomic, strong) NSString              *indexFilePath;

- (void)cacheImageData:(NSData *)imageData
                forURL:(NSString *)url;

- (void)loadCachedImageForURL:(NSString *)url
                        start:(void (^)(void))start
                       finish:(void (^)(UIImage *image))finish;
@end

@interface UIImageView (Loader)
@property (nonatomic, strong) ImageLoader                *loader;
@property (nonatomic, strong) UIActivityIndicatorView    *relatedIndicatorView;
@property (nonatomic, strong) NSString                   *remoteImageURL;
@end

@implementation UIImageView (Loader)
- (void) setLoader:(ImageLoader *)loader{
    objc_setAssociatedObject(self, kLoaderKey, loader, OBJC_ASSOCIATION_RETAIN);
}

- (ImageLoader *)loader{
    return objc_getAssociatedObject(self, kLoaderKey);
}

- (UIActivityIndicatorView *)relatedIndicatorView{
    return objc_getAssociatedObject(self, kRelatedIndicatorViewKey);
}

- (void)setRelatedIndicatorView:(UIActivityIndicatorView *)relatedIndicatorView{
    objc_setAssociatedObject(self, kRelatedIndicatorViewKey, relatedIndicatorView, OBJC_ASSOCIATION_RETAIN);
}

- (NSString *)remoteImageURL{
    return objc_getAssociatedObject(self, kImageURLKey);
}

- (void)setRemoteImageURL:(NSString *)imageURL{
    objc_setAssociatedObject(self, kImageURLKey, imageURL, OBJC_ASSOCIATION_RETAIN);
}

@end

static const ImageViewLoadingStyle DefaultLoadingStyle = ImageViewLoadingStyleNone;

@implementation UIImageView (Network)
- (void)setImageURL:(NSString *)url
   placeHolderImage:(UIImage *)placeHolderImage
         errorImage:(UIImage *)errorImage
       loadingStyle:(ImageViewLoadingStyle)loadingStyle{
    self.remoteImageURL = url;
    
    self.image = nil;
    
    if ([url hasNonWhitespaceText]) {
        if (self.loader) {
            [self.loader cancel];
        }
        self.loader = [[ImageLoader alloc] init];
        
        [self.loader loadImageWithURL:url
                                start:^{
                                    self.image = placeHolderImage;
                                    
                                    if (loadingStyle != ImageViewLoadingStyleNone) {
                                        if (!self.relatedIndicatorView) {
                                            self.relatedIndicatorView = [[UIActivityIndicatorView alloc] init];
                                            
                                            [self addSubview:self.relatedIndicatorView];
                                        }
                                        
                                        UIActivityIndicatorViewStyle style = loadingStyle == ImageViewLoadingStyleGray ? UIActivityIndicatorViewStyleGray : UIActivityIndicatorViewStyleWhite;
                                        self.relatedIndicatorView.activityIndicatorViewStyle = style;
                                        self.relatedIndicatorView.center = CGPointMake(self.sizeW / 2, self.sizeH / 2);
                                        [self.relatedIndicatorView startAnimating];
                                    }
                                }
                               finish:^(UIImage *image) {
                                   if (!image) {
                                       self.image = errorImage;
                                   }
                                   else{
                                       self.image = image;
                                   }
                                   
                                   [self.relatedIndicatorView stopAnimating];
                               }];
    }
}

- (void)setImageURL:(NSString *)url
   placeHolderImage:(UIImage *)placeHolderImage
       loadingStyle:(ImageViewLoadingStyle)loadingStyle{
    [self setImageURL:url
     placeHolderImage:placeHolderImage
           errorImage:nil
         loadingStyle:loadingStyle];
}

- (void)setImageURL:(NSString *)url
   placeHolderImage:(UIImage *)placeHolderImage{
    [self setImageURL:url
     placeHolderImage:placeHolderImage
         loadingStyle:DefaultLoadingStyle];
}

- (void)setImageURL:(NSString *)url
         errorImage:(UIImage *)errorImage
       loadingStyle:(ImageViewLoadingStyle)loadingStyle{
    [self setImageURL:url
     placeHolderImage:nil
           errorImage:errorImage
         loadingStyle:loadingStyle];
}

- (void)setImageURL:(NSString *)url
         errorImage:(UIImage *)errorImage{
    [self setImageURL:url
           errorImage:errorImage
         loadingStyle:DefaultLoadingStyle];
}

- (void)setImageURL:(NSString *)url
       loadingStyle:(ImageViewLoadingStyle)loadingStyle{
    [self setImageURL:url
           errorImage:nil
         loadingStyle:loadingStyle];
}

- (void)setImageURL:(NSString *)url{
    [self setImageURL:url
         loadingStyle:DefaultLoadingStyle];
}

- (void)setLocalImage:(UIImage *)image{
    [self.loader cancel];
    
    self.remoteImageURL = nil;
    self.image = image;
}

- (UIImage *)localImage{
    return self.image;
}
@end

#define ImageCacheDirectory ([NSTemporaryDirectory() stringByAppendingPathComponent:@"pis.cache"])
#define ImageCacheIndexFileName @"PisImageCache.index"

@interface ImageIndex : NSObject<NSCoding>
@property (nonatomic, strong) NSString  *imageURL;
@property (nonatomic, strong) NSString  *fileNameOnDisk;
@property (nonatomic, strong) NSDate    *createDate;
@property (nonatomic, strong) NSDate    *lastAccessDate;

+ (id)newIndexWithFileName:(NSString *)fileName url:(NSString *)url;
@end

@implementation ImageIndex
- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.imageURL forKey:@"url"];
    [aCoder encodeObject:self.fileNameOnDisk forKey:@"name"];
    [aCoder encodeObject:self.createDate forKey:@"cDate"];
    [aCoder encodeObject:self.lastAccessDate forKey:@"aDate"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [self init];
    
    if (self) {
        self.imageURL = [aDecoder decodeObjectForKey:@"url"];
        self.fileNameOnDisk = [aDecoder decodeObjectForKey:@"name"];
        self.createDate = [aDecoder decodeObjectForKey:@"cDate"];
        self.lastAccessDate = [aDecoder decodeObjectForKey:@"aDate"];
    }
    
    return self;
}

+ (id)newIndexWithFileName:(NSString *)fileName
                       url:(NSString *)url{
    ImageIndex *result = [[ImageIndex alloc] init];
    
    result.fileNameOnDisk = fileName;
    result.imageURL = url;
    result.createDate = [NSDate date];
    result.lastAccessDate = [NSDate date];
    
    return result;
}
@end

@interface ImageLoader ()
@property (nonatomic, strong) ServiceLoader *loader;
@end

@implementation ImageLoader
- (void)loadImageWithURL:(NSString *)url
                   start:(void (^)(void))start
                  finish:(void (^)(UIImage *))finish{
    url = [[url stringByTrimming] urlEncodedUsingUTF8Encoding];
    
    self.loader = [ServiceLoaderUtil loaderForGetWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]
                                                       start:^(NSURLRequest *request) {
                                                           
                                                       }
                                                      finish:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                          if (error.code == NSURLErrorCancelled) {
                                                              return;
                                                          }
                                                          
                                                          UIImage *image = [[UIImage alloc] initWithData:data];
                                                          if (image) {
                                                              [[ImageCacheManager sharedManager] cacheImageData:data
                                                                                                        forURL:url];
                                                          }
                                                          
                                                          if (finish) {
                                                              dispatch_sync(dispatch_get_main_queue(), ^{
                                                                  finish(image);
                                                              });
                                                          }
                                                      }];
    
    [[ImageCacheManager sharedManager] loadCachedImageForURL:url
                                                       start:^{
                                                           if (start) {
                                                               start();
                                                           }
                                                       }
                                                      finish:^(UIImage *image) {
                                                          if (image) {
                                                              if (finish) {
                                                                  finish(image);
                                                              }
                                                          }
                                                          else{
                                                              [self.loader start];
                                                          }
                                                      }];
}

- (void)cancel{
    [self.loader cancel];
    self.loader = nil;
}

- (void)dealloc{
    [self cancel];
}
@end

@implementation ImageCacheManager

- (id)init{
    self = [super init];
    
    if (self) {
        self.filePathMemoryCache = [[NSCache alloc] init];
        self.imageMemoryCache = [[NSCache alloc] init];
        [self.imageMemoryCache setCountLimit:50];
        
        self.writeDataQueue = dispatch_queue_create("pis.writeData", NULL);
        self.loadDataQueue = dispatch_queue_create("pis.loadData", DISPATCH_QUEUE_CONCURRENT);
        
        self.indexFilePath = [ImageCacheDirectory stringByAppendingPathComponent:ImageCacheIndexFileName];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self createIndexFile];
        });
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleMemoryWarningNotification)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
        
        self.fileIndexInMemory = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithFile:self.indexFilePath]];
        if (!self.fileIndexInMemory) {
            self.fileIndexInMemory = [NSMutableArray array];
        }
    }
    
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidReceiveMemoryWarningNotification
                                                  object:nil];
}

+ (id)sharedManager{
    static ImageCacheManager *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ImageCacheManager alloc] init];
    });
    
    return manager;
}

- (void)cacheImageData:(NSData *)imageData
                forURL:(NSString *)url{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [[UIImage alloc] initWithData:imageData];
        if (image) {
            [self.imageMemoryCache setObject:image
                                      forKey:url];
        }
    });
    
    NSString *cachedFilePath = [self.filePathMemoryCache objectForKey:url];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (cachedFilePath && [fileManager fileExistsAtPath:cachedFilePath]) {
        return;
    }
    
    NSString *fileName = [NSString UUIDString];
    
    cachedFilePath = [ImageCacheDirectory stringByAppendingPathComponent:fileName];
    
    dispatch_async(self.writeDataQueue, ^{
        BOOL success = [self createIndexFile];
        
        if (success) {
            ImageIndex *newIndex = [ImageIndex newIndexWithFileName:fileName
                                                                url:url];
            [self.fileIndexInMemory addObject:newIndex];
            
            //1.存储图片内容
            BOOL saveImageSuccess = [fileManager createFileAtPath:cachedFilePath
                                                         contents:imageData
                                                    attributes:nil];
            
            //2.存储索引文件
            if (saveImageSuccess) {
                BOOL saveIndexFileSuccess = [NSKeyedArchiver archiveRootObject:self.fileIndexInMemory
                                                                        toFile:self.indexFilePath];
                
                if (!saveIndexFileSuccess) {
                    [fileManager removeItemAtPath:cachedFilePath
                                            error:nil];
                }
            }
            
            [self.filePathMemoryCache setObject:cachedFilePath forKey:url];
        }
    });
}

- (void)loadCachedImageForURL:(NSString *)url
                        start:(void (^)(void))start
                       finish:(void (^)(UIImage *))finish{
    if (start) {
        start();
    }
    
    UIImage *cachedImage = [self.imageMemoryCache objectForKey:url];
    
    if (cachedImage) {
        finish(cachedImage);
    }
    else{
        dispatch_async(self.loadDataQueue, ^{
            NSString *cachedFilePath = [self.filePathMemoryCache objectForKey:url];
            
            if (!cachedFilePath) {
                for (ImageIndex *index in self.fileIndexInMemory) {
                    if ([index.imageURL isEqualToString:url]) {
                        cachedFilePath = [ImageCacheDirectory stringByAppendingPathComponent:index.fileNameOnDisk];
                        
                        break;
                    }
                }
            }
            
            NSData *imageData = [NSData dataWithContentsOfFile:cachedFilePath];
            if (finish) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    UIImage *image = [[UIImage alloc] initWithData:imageData];
                    
                    if (image) {
                        [self.imageMemoryCache setObject:image forKey:url];
                    }
                    
                    finish(image);
                });
            }
        });
    }
}

+ (void)calculateCacheSizeStart:(void (^)(void))start
                       finished:(void (^)(NSUInteger))finish{
    if (start) {
        start();
    }
    
    dispatch_async([[self sharedManager] loadDataQueue], ^{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSString *directory = ImageCacheDirectory;
        NSEnumerator *enumerator = [fileManager enumeratorAtPath:directory];
        
        NSString *itemName;
        NSUInteger size = 0;
        
        while ((itemName = enumerator.nextObject)) {
            NSDictionary *attributes = [fileManager attributesOfItemAtPath:[directory stringByAppendingPathComponent:itemName] error:nil];
            
            size += [[attributes valueForKey:NSFileSize] longLongValue];
        }
        
        if (finish) {
            finish(size);
        }
    });
}

+ (void)clearCacheStart:(void (^)(void))start
               finished:(void (^)(void))finish{
    if (start) {
        start();
    }
    
    dispatch_async([[self sharedManager] writeDataQueue], ^{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSString *directory = ImageCacheDirectory;
        NSEnumerator *enumerator = [fileManager enumeratorAtPath:directory];
        NSString *itemName ;
        
        while ((itemName = enumerator.nextObject)) {
            [fileManager removeItemAtPath:[directory stringByAppendingPathComponent:itemName] error:nil];
        }
        
        [[[self sharedManager] fileIndexInMemory] removeAllObjects];
        
        if (finish) {
            finish();
        }
    });
}

+(void)clearCacheBeforeDate:(NSDate *)date
                      start:(void (^)(void))start
                   finished:(void (^)(void))finish{
    if (start) {
        start();
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *fileIndecies = [[self sharedManager] fileIndexInMemory];
        fileIndecies = [fileIndecies sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            ImageIndex *index1 = obj1;
            ImageIndex *index2 = obj2;
            
            return [index1.lastAccessDate compare:index2.lastAccessDate];
        }];
        
        NSMutableArray *mutableFileIndecies = [NSMutableArray arrayWithArray:fileIndecies];
        
        for (ImageIndex *index in fileIndecies) {
            if ([index.lastAccessDate compare:date] != NSOrderedDescending) {
                NSString *filePath = [ImageCacheDirectory stringByAppendingPathComponent:index.fileNameOnDisk];
                
                BOOL removeSuccess = [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
                
                if (removeSuccess) {
                    [mutableFileIndecies removeObject:index];
                }
            }
            else{
                break;
            }
        }
        
        [[self sharedManager] setFileIndexInMemory:[NSMutableArray arrayWithArray:mutableFileIndecies]];
        
        [NSKeyedArchiver archiveRootObject:mutableFileIndecies toFile:[[self sharedManager] indexFilePath]];
    });
}

#pragma mark - 
#pragma mark - handle notification
- (void)handleMemoryWarningNotification{
    [self.filePathMemoryCache removeAllObjects];
    [self.imageMemoryCache removeAllObjects];
}

#pragma mark - 
#pragma mark - utility mothods
- (BOOL)createIndexFile{
    NSString *directory = ImageCacheDirectory;
    NSString *indexFileName = self.indexFilePath;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSError *error;
    if (![fileManager fileExistsAtPath:directory]) {
        [fileManager createDirectoryAtPath:directory
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:&error];
    }
    
    if(error){
        return NO;
    }
    
    if (![fileManager fileExistsAtPath:indexFileName]) {
        return [fileManager
                createFileAtPath:indexFileName
                contents:nil
                attributes:nil];
    }
    
    return YES;
}

- (void)updateLastAccessDateForURL:(NSString *)url{
    for (ImageIndex *index in self.fileIndexInMemory) {
        if ([index.imageURL isEqualToString:url]) {
            index.lastAccessDate = [NSDate date];
            
            break;
        }
    }
    
    [NSKeyedArchiver archiveRootObject:self.fileIndexInMemory
                                toFile:self.indexFilePath];
}
@end
