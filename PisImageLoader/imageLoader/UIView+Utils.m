//
//  UIView+Utils.m
//  NeweggUtils
//
//  Created by cheney on 13-7-16.
//  Copyright (c) 2013年 newegg. All rights reserved.
//

#import "UIView+Utils.h"
#import <objc/runtime.h>

@implementation UIView (Utils)

- (CGPoint)origin {
    return self.frame.origin;
}
- (void)setOrigin:(CGPoint)origin {
    CGRect frame = self.frame;
    
    frame.origin = origin;
    
    self.frame = frame;
}

- (CGFloat)originX {
    return self.frame.origin.x;
}
- (void)setOriginX:(CGFloat)originX {
    CGRect frame = self.frame;
    
    frame.origin.x = originX;
    
    self.frame = frame;
}

- (CGFloat)originY {
    return self.frame.origin.y;
}
- (void)setOriginY:(CGFloat)originY {
    CGRect frame = self.frame;
    
    frame.origin.y = originY;
    
    self.frame = frame;
}

- (CGSize)size {
    return self.frame.size;
}
- (void)setSize:(CGSize)size {
    CGRect frame = self.frame;
    
    frame.size = size;
    
    self.frame = frame;
}

- (CGFloat)sizeW {
    return self.frame.size.width;
}
- (void)setSizeW:(CGFloat)sizeW {
    CGRect frame = self.frame;
    
    frame.size.width = sizeW;
    
    self.frame = frame;
}

- (CGFloat)sizeH {
    return self.frame.size.height;
}
- (void)setSizeH:(CGFloat)sizeH {
    CGRect frame = self.frame;
    
    frame.size.height = sizeH;
    
    self.frame = frame;
}

- (CGFloat)right {
    return self.frame.origin.x+self.frame.size.width;
}

- (CGFloat)bottom {
    return self.frame.origin.y+self.frame.size.height;
}


- (UIImage *)screenshot {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 0);
    
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:NO];
    
	UIImage *anImage = UIGraphicsGetImageFromCurrentImageContext();
    
	UIGraphicsEndImageContext();
	
	return anImage;
}

- (UIView *)createBlurBackground
{
    return [self createBlurBackground:nil];
}

- (UIView *)createBlurBackground:(UIColor *)tintColor
{
    self.opaque = NO;
    self.backgroundColor = [UIColor clearColor];
    
    UIToolbar *toolBar = (UIToolbar *)[self viewWithTag:kBlurBgTag];
    if (!(toolBar && toolBar.superview != nil && toolBar.superview == self)) {
        toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.sizeW, self.sizeH)];
        toolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        toolBar.clipsToBounds = YES;
        toolBar.layer.masksToBounds = YES;
        toolBar.tag = kBlurBgTag;
        
        [self insertSubview:toolBar atIndex:0];
    }
    
    toolBar.barTintColor = tintColor;
    
    return toolBar;
}


- (void)bindData:(NSArray *)dataItems contentSubviews:(NSArray **)contentSubviews creation:(NECreateSubviewBlock)creation binding:(NEBindSubviewBlock)binding
{
    NSArray *viewArray = *contentSubviews;
    
    NSInteger viewCount = viewArray.count;
    NSInteger dataCount = dataItems.count;
    NSInteger maxCount = MAX(viewCount, dataCount);
    
    NSMutableArray *newSubviews = [NSMutableArray array];
    
    for (NSInteger i = 0; i < maxCount; i++) {
        UIView *subview = nil;
        
        if (i < viewCount) {
            subview = viewArray[i];
        }
        
        if (i < dataCount) {
            id dataItem = dataItems[i];
            
            if (subview == nil) {
                subview = creation(i);
                
                [self addSubview:subview];
            }
            
            [newSubviews addObject:subview];
            
            binding(subview, dataItem, i);
        } else {
            if (subview != nil) {
                [subview removeFromSuperview];
            }
        }
    }
    
    *contentSubviews = [newSubviews copy];
}


#define kUpdateSizeOffset       @"kUpdateSizeOffset"

#define kOriginalBottomSpace    @"kOriginalBottomSpace"
#define kOriginalFrame          @"kOriginalFrame"

- (void)addKeyboardObserverUpdateContainerView
{
    [self addKeyboardObserverWithOffset:0];
}
- (void)addKeyboardObserverUpdateContainerViewWithOffset:(CGFloat)offset
{
    [self addKeyboardObserverWithOffset:offset];
}
- (void)addKeyboardObserverWithOffset:(CGFloat)offset
{
    objc_setAssociatedObject(self, kUpdateSizeOffset, @(offset), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateViewWhenKeyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateViewWhenKeyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)removeKeyboardObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    objc_removeAssociatedObjects(self);
}

- (void)updateViewWhenKeyboardWillShowNotification:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    
    NSTimeInterval animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    UIViewAnimationCurve animationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    CGFloat offset = [objc_getAssociatedObject(self, kUpdateSizeOffset) floatValue];
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    UIView *superview = self.superview;
    
    CGRect keyboardBeginFrame = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect keyboardEndFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    BOOL firstShowKeyboard = (keyboardBeginFrame.origin.y == keyWindow.bounds.size.height);
    
    keyboardBeginFrame = [keyWindow convertRect:keyboardBeginFrame toView:superview];
    keyboardEndFrame = [keyWindow convertRect:keyboardEndFrame toView:superview];
    
    CGRect viewFrame = self.frame;
    CGFloat offsetY = viewFrame.origin.y + viewFrame.size.height - keyboardEndFrame.origin.y + offset;
    
    NSLayoutConstraint *bottomConstraint = [self getBottomLayoutConstraint];
    
    if (firstShowKeyboard) {
        if (bottomConstraint != nil) {
            objc_setAssociatedObject(self, kOriginalBottomSpace, @(bottomConstraint.constant), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        } else {
            objc_setAssociatedObject(self, kOriginalFrame, [NSValue valueWithCGRect:viewFrame], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    
    [UIView animateWithDuration:animationDuration delay:0 options:animationCurve << 16 animations:^{
        if (bottomConstraint != nil) {
            bottomConstraint.constant += offsetY;
            
            [self layoutIfNeeded];
        } else {
            CGRect viewEndFrame = viewFrame;
            
            viewEndFrame.size.height -= offsetY;
            
            self.frame = viewEndFrame;
        }
    } completion:^(BOOL finished){
        
    }];
}

- (void)updateViewWhenKeyboardWillHideNotification:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    
    NSTimeInterval animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    UIViewAnimationCurve animationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    [UIView animateWithDuration:animationDuration delay:0 options:animationCurve << 16 animations:^{
        NSLayoutConstraint *bottomConstraint = [self getBottomLayoutConstraint];
        
        if (bottomConstraint != nil) {
            CGFloat constant = [objc_getAssociatedObject(self, kOriginalBottomSpace) floatValue];
            
            bottomConstraint.constant = constant;
            
            [self layoutIfNeeded];
        } else {
            CGRect viewFrame = [objc_getAssociatedObject(self, kOriginalFrame) CGRectValue];
            
            self.frame = viewFrame;
        }
    } completion:^(BOOL finished){
        
    }];
}

- (NSLayoutConstraint *)getBottomLayoutConstraint {
    NSArray *constraints = self.superview.constraints;
    NSLayoutConstraint *bottomConstraint = nil;
    
    for (NSLayoutConstraint *constraint in constraints) {
        if ((constraint.firstItem == self && constraint.firstAttribute == NSLayoutAttributeBottom) || (constraint.secondItem == self && constraint.secondAttribute == NSLayoutAttributeBottom)) {
            bottomConstraint = constraint;
            break;
        }
    }
    
    return bottomConstraint;
}

@end
