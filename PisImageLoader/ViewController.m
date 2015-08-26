//
//  ViewController.m
//  PisImageLoader
//
//  Created by newegg on 15/8/20.
//  Copyright (c) 2015年 newegg. All rights reserved.
//

#import "ViewController.h"
#import "UIImageView+Network.h"

@interface ViewController ()

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSString *url = @"http://c1.neweggimages.com.cn/NeweggPic2/Marketing/201508/STUDY/940x416.jpg";
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(50, 50, 220, 100)];
    
//    [imageView setImageURL:url];
//    [imageView setImageURL:url errorImage:nil];
//    [imageView setImageURL:url errorImage:nil loadingStyle:ImageViewLoadingStyleNone];
//    [imageView setImageURL:url placeHolderImage:nil errorImage:nil loadingStyle:ImageViewLoadingStyleNone];
    
    [imageView setImageURL:url loadingStyle:ImageViewLoadingStyleGray];
    
    
    [self.view addSubview:imageView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
