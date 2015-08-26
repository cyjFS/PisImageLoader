//
//  UIView+Utils.h
//  NeweggUtils
//
//  Created by cheney on 13-7-16.
//  Copyright (c) 2013年 newegg. All rights reserved.
//
#import <UIKit/UIKit.h>
typedef UIView * (^NECreateSubviewBlock) (NSInteger index);
typedef void (^NEBindSubviewBlock) (id subview, id dataItem, NSInteger index);

#define kBlurBgTag 288628

@interface UIView (Utils)

@property(nonatomic,assign) CGPoint origin;
@property(nonatomic,assign) CGFloat originX;
@property(nonatomic,assign) CGFloat originY;
@property(nonatomic,assign) CGSize size;
@property(nonatomic,assign) CGFloat sizeW;
@property(nonatomic,assign) CGFloat sizeH;
@property(nonatomic,assign) CGFloat right;
@property(nonatomic,assign) CGFloat bottom;

- (UIImage *)screenshot;

- (UIView *)createBlurBackground;
- (UIView *)createBlurBackground:(UIColor *)tintColor;

- (void)bindData:(NSArray *)dataItems contentSubviews:(NSArray **)contentSubviews creation:(NECreateSubviewBlock)creation binding:(NEBindSubviewBlock)binding;


- (void)addKeyboardObserverUpdateContainerView;
- (void)addKeyboardObserverUpdateContainerViewWithOffset:(CGFloat)offset;
- (void)removeKeyboardObserver;

@end
