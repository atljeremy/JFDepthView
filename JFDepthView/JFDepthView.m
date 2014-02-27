/*
 * JFDepthView
 *
 * Created by Jeremy Fox on 10/19/12.
 * Copyright (c) 2012 Jeremy Fox. All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#import "JFDepthView.h"
#import <Accelerate/Accelerate.h>
#import "UIImage+ImageEffects.h"

#define isiPad() [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad

#define kAnimationDuration  0.5
#define kiPadPresentedViewWidth 600
#define kiPadPresentedViewOriginY 30
#define kiPhonePresentedViewOriginY 50
#define kLightBlurAmount  (isiPad()) ? 2.0f : 1.0f
#define kMediumBlurAmount (isiPad()) ? 4.0f : 3.0f
#define kHardBlurAmount   (isiPad()) ? 6.0f : 5.0f

@interface UIView (JFDepthView)
- (UIImage*)getScreenShotOfRect:(CGRect)rect;
- (void)openPerspectiveTransformWithCompletionHandler:(void(^)(BOOL finished))completion;
- (void)closePerspectiveTransformWithCompletionHandler:(void(^)(BOOL finished))completion;
- (void)animateToSize:(CGSize)toSize fromSize:(CGSize)fromSize duration:(CGFloat)duration completion:(void(^)(BOOL finished))completion;
@end

@interface JFDepthView() {
    CGRect originalPresentedViewFrame;
    CGRect preTopViewWrapperFrame;
    CGRect postTopViewWrapperFrame;
    CGRect preBottomViewFrame;
    CGRect postBottomViewFrame;
    CGRect bottomViewFrame;
}
@property (nonatomic, strong) UIView* topViewWrapper;
@property (nonatomic, strong) UIView* dimView;
@property (nonatomic, strong) UIImageView* blurredMainView;
@property (nonatomic, strong) UIView* presentedViewContainer;
@property (nonatomic, strong) UIImage* viewImage;
@end

@implementation JFDepthView
@synthesize presentedViewController = _presentedViewController;

- (id)init
{
    if (self = [super init]) {
        NSLog(@"JFDepthView Initialized!");
        
        _recognizer   = nil;
        _isPresenting = NO;
        _blurAmount   = JFDepthViewBlurAmountMedium;
        _hideStatusBarDuringPresentation = NO;
        _animationOption = JFDepthViewAnimationOptionPerspectiveTransform;
    }
    return self;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self deallocate];
    [self setRecognizer:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if (self.presentedViewController) {
        [self.presentedViewController didReceiveMemoryWarning];
    }
}

#pragma mark - iOS 5 Rotation Support
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - iOS 6 Rotation Support

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationMaskAll;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (!self.presentedViewController) return;
    
    // Notify presented view of rotation event so it can handle updating things as needed.
    [self.presentedViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (!self.presentedViewController) return;
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsLandscape(fromInterfaceOrientation)
        && UIInterfaceOrientationIsLandscape(orientation)) {
        return;
    }
    
    if (UIInterfaceOrientationIsPortrait(fromInterfaceOrientation)
        && UIInterfaceOrientationIsPortrait(orientation)) {
        return;
    }
    
    // Notify presented view of rotation event so it can handle updating things as needed.
    [self.presentedViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    float presentedViewWidth = [self getPresentedViewWidth];
    float presentedViewOriginY = [self getPresentedViewOriginY];
    
    if (UIInterfaceOrientationIsLandscape(fromInterfaceOrientation)) {
        // Rotated to a portrait orientation
        
        CGRect portraitBounds = screenBounds;
        
        preTopViewWrapperFrame = CGRectMake((portraitBounds.size.width / 2) - (preTopViewWrapperFrame.size.width / 2),
                                            portraitBounds.size.height,
                                            preTopViewWrapperFrame.size.width,
                                            preTopViewWrapperFrame.size.height);
        
        preBottomViewFrame = portraitBounds;
        
        postTopViewWrapperFrame = CGRectMake((portraitBounds.size.width / 2) - (self.topViewWrapper.frame.size.width / 2),
                                             presentedViewOriginY,
                                             presentedViewWidth,
                                             portraitBounds.size.height - presentedViewOriginY);
        
        [UIView animateWithDuration:0.2 animations:^{
            self.topViewWrapper.frame = postTopViewWrapperFrame;
        } completion:^(BOOL finished){
            NSLog(@"JFDepthView: Did Rotate Animation Complete");
        }];
        
    } else {
        // Rotated to a landscape orientation
        
        CGRect landscapeBounds = CGRectMake(screenBounds.origin.x,
                                            screenBounds.origin.y,
                                            screenBounds.size.height,
                                            screenBounds.size.width);
        
        preTopViewWrapperFrame = CGRectMake((landscapeBounds.size.width / 2) - (preTopViewWrapperFrame.size.width / 2),
                                            landscapeBounds.size.height,
                                            preTopViewWrapperFrame.size.width,
                                            preTopViewWrapperFrame.size.height);
        
        preBottomViewFrame = landscapeBounds;
        
        postTopViewWrapperFrame = CGRectMake((landscapeBounds.size.width / 2) - (self.topViewWrapper.frame.size.width / 2),
                                             presentedViewOriginY,
                                             presentedViewWidth,
                                             landscapeBounds.size.height - presentedViewOriginY);
        
        [UIView animateWithDuration:0.2 animations:^{
            self.topViewWrapper.frame = postTopViewWrapperFrame;
        } completion:^(BOOL finished){
            NSLog(@"JFDepthView: Did Rotate Animation Complete");
        }];
    }
    
}

- (void)presentViewController:(UIViewController*)topViewController inView:(UIView*)bottomView animated:(BOOL)animated
{
    NSParameterAssert(topViewController);
    NSParameterAssert(bottomView);
    
    if (self.presentedViewController) {
        self.presentedViewController = nil;
    }
    self.presentedViewController = topViewController;
    [self presentView:self.presentedViewController.view inView:bottomView animated:animated];
}

- (void)presentView:(UIView*)topView inView:(UIView*)bottomView animated:(BOOL)animated
{
    NSParameterAssert(topView);
    NSParameterAssert(bottomView);
    
    self.view.userInteractionEnabled = NO;
    
    /**
     * Save the original view frame so it can be reset after being presented.
     * This eliminates an issue of continually reducing the size of a persistant 
     * view that is presented multiple times.
     */
    originalPresentedViewFrame = topView.frame;
    
    BOOL isiPad        = isiPad();
    self.mainView      = bottomView;
    self.presentedView = topView;
    self.presentedView.clipsToBounds       = YES;
    self.presentedView.autoresizesSubviews = YES;
    self.presentedView.layer.cornerRadius  = 8;
    self.presentedView.autoresizingMask    = UIViewAutoresizingFlexibleWidth |
    UIViewAutoresizingFlexibleHeight;
    
    CGFloat presentedViewWidth = [self getPresentedViewWidth];
    CGFloat presentedViewOriginY = [self getPresentedViewOriginY];
    
    bottomViewFrame        = self.mainView.bounds;
    CGRect topViewFrame    = self.presentedView.bounds;
    CGRect newTopViewFrame = CGRectMake(CGRectGetMinX(topViewFrame),
                                        CGRectGetMinY(topViewFrame),
                                        presentedViewWidth,
                                        topViewFrame.size.height);
    
    self.presentedView.frame = newTopViewFrame;
    
    self.view.frame = bottomViewFrame;
    self.view.backgroundColor = [UIColor blackColor];
    
    preTopViewWrapperFrame = CGRectMake((bottomViewFrame.size.width / 2) - (presentedViewWidth / 2),
                                        bottomViewFrame.size.height + bottomViewFrame.origin.y,
                                        presentedViewWidth,
                                        bottomViewFrame.size.height - presentedViewOriginY);
    
    postTopViewWrapperFrame = CGRectMake((bottomViewFrame.size.width / 2) - (presentedViewWidth / 2),
                                         presentedViewOriginY,
                                         presentedViewWidth,
                                         bottomViewFrame.size.height - presentedViewOriginY);
    
    preBottomViewFrame = bottomViewFrame;
    
    CGFloat postX      = (isiPad) ? 30 : 0;
    CGFloat postWidth  = (isiPad) ? bottomViewFrame.size.width - 60  : bottomViewFrame.size.width;
    CGFloat postHeight = (isiPad) ? bottomViewFrame.size.height - 60 : bottomViewFrame.size.height;
    postBottomViewFrame = CGRectMake(postX,
                                     0,
                                     postWidth,
                                     postHeight);
    
    CGFloat shadowRadius  = (isiPad) ? 20 : 10;
    CGFloat shadowOpacity = (isiPad) ? 1.0 : 0.5;
    self.topViewWrapper = [[UIView alloc] initWithFrame:preTopViewWrapperFrame];
    self.topViewWrapper.autoresizesSubviews = YES;
    self.topViewWrapper.layer.shadowOffset  = CGSizeZero;
    self.topViewWrapper.layer.shadowRadius  = shadowRadius;
    self.topViewWrapper.layer.shadowOpacity = shadowOpacity;
    self.topViewWrapper.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.topViewWrapper.bounds].CGPath;
    self.topViewWrapper.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin  |
    UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleTopMargin   |
    UIViewAutoresizingFlexibleBottomMargin|
    UIViewAutoresizingFlexibleHeight;
    
    self.presentedViewContainer = [[UIView alloc] initWithFrame:bottomViewFrame];
    self.presentedViewContainer.autoresizesSubviews = YES;
    self.presentedViewContainer.backgroundColor = [UIColor blackColor];
    self.presentedViewContainer.alpha = 0.0;
    self.presentedViewContainer.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin  |
    UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleTopMargin   |
    UIViewAutoresizingFlexibleBottomMargin|
    UIViewAutoresizingFlexibleHeight      |
    UIViewAutoresizingFlexibleWidth;
    
    self.viewImage = [self.mainView getScreenShotOfRect:self.mainView.bounds];
    
    self.blurredMainView = [[UIImageView alloc] initWithFrame:preBottomViewFrame];
    self.blurredMainView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin  |
    UIViewAutoresizingFlexibleRightMargin;
    
    self.blurredMainView.image = [self.viewImage applyLightEffect];
    
    self.dimView = [[UIView alloc] initWithFrame:bottomViewFrame];
    self.dimView.backgroundColor = [UIColor clearColor];
    self.dimView.alpha = 0.0;
    if (self.recognizer) {
        [self.dimView addGestureRecognizer:self.recognizer];
    }
    self.dimView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
    UIViewAutoresizingFlexibleHeight;
    
    [self.topViewWrapper addSubview:self.presentedView];
    [self.presentedViewContainer addSubview:self.blurredMainView];
    [self.presentedViewContainer addSubview:self.dimView];
    [self.view addSubview:self.presentedViewContainer];
    [self.view addSubview:self.topViewWrapper];
    
    self.view.backgroundColor = [UIColor clearColor];
    [self.mainView addSubview:self.view];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(willPresentDepthView:)]) {
        [self.delegate willPresentDepthView:self];
    }
    
    if (self.hideStatusBarDuringPresentation) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }
    
    switch (self.animationOption) {
        case JFDepthViewAnimationOptionPushBack:
            [self presentWithPushBackAnimationWithBlur:NO animated:animated];
            break;
            
        case JFDepthViewAnimationOptionPushBackAndBlur:
            [self presentWithPushBackAnimationWithBlur:YES animated:animated];
            break;
            
        case JFDepthViewAnimationOptionPerspectiveTransformAndBlur:
            [self presentWithPerspectiveTransformWithBlur:YES animated:animated];
            break;
            
        case JFDepthViewAnimationOptionPerspectiveTransform:
        default:
            [self presentWithPerspectiveTransformWithBlur:NO animated:animated];
            break;
    }
}

#pragma mark ----------------------
#pragma mark Presentation Helpers
#pragma mark ----------------------

- (void)presentWithPushBackAnimationWithBlur:(BOOL)blur animated:(BOOL)animated
{
    if (!blur) self.blurredMainView.image = self.viewImage;
    NSTimeInterval duration = (animated) ? 0.5 : 0.0;
    [UIView animateWithDuration:duration animations:^{
        self.topViewWrapper.frame = postTopViewWrapperFrame;
        self.blurredMainView.frame = postBottomViewFrame;
        self.presentedViewContainer.alpha = 1.0;
        self.dimView.alpha = 1.0;
        [self hideSubviews];
    } completion:^(BOOL finished){
        NSLog(@"JFDepthView: Present Animation Complete");
        
        self.view.userInteractionEnabled = YES;
        self.isPresenting = YES;
        [self removeAllAnimations];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(didPresentDepthView:)]) {
            [self.delegate didPresentDepthView:self];
        }
    }];
}

- (void)presentWithPerspectiveTransformWithBlur:(BOOL)blur animated:(BOOL)animated
{
    if (!blur) self.blurredMainView.image = self.viewImage;
    NSTimeInterval duration = (animated) ? 1.0 : 0.0;
    self.presentedViewContainer.alpha = 1.0f;
    [self.blurredMainView openPerspectiveTransformWithCompletionHandler:^(BOOL done) {
        [UIView animateWithDuration:duration delay:0.0f usingSpringWithDamping:0.8f initialSpringVelocity:0.5f options:UIViewAnimationOptionAllowAnimatedContent animations:^{
            self.topViewWrapper.frame = postTopViewWrapperFrame;
            self.dimView.alpha = 1.0;
        } completion:^(BOOL finished) {
            NSLog(@"JFDepthView: Present Animation Complete");
            
            [self hideSubviews];
            self.view.userInteractionEnabled = YES;
            self.isPresenting = YES;
            [self removeAllAnimations];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(didPresentDepthView:)]) {
                [self.delegate didPresentDepthView:self];
            }
        }];
    }];
}

#pragma mark ----------------------
#pragma mark Dismissal Helpers
#pragma mark ----------------------

- (void)dismissPresentedViewInView:(UIView*)view animated:(BOOL)animated
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(willDismissDepthView:)]) {
        [self.delegate willDismissDepthView:self];
    }
    
    if ([self.mainView isEqual:view]) {
        
        if (self.hideStatusBarDuringPresentation) {
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
        }
        
        switch (self.animationOption) {
            case JFDepthViewAnimationOptionPushBack:
                [self dismissWithPullForwardAnimationWithBlur:NO animated:animated];
                break;
                
            case JFDepthViewAnimationOptionPushBackAndBlur:
                [self dismissWithPullForwardAnimationWithBlur:YES animated:animated];
                break;
                
            case JFDepthViewAnimationOptionPerspectiveTransformAndBlur:
                [self dismissWithPerspectiveTransformWithBlur:YES animated:animated];
                break;
                
            case JFDepthViewAnimationOptionPerspectiveTransform:
            default:
                [self dismissWithPerspectiveTransformWithBlur:NO animated:animated];
                break;
        }
    }
}

- (void)dismissWithPullForwardAnimationWithBlur:(BOOL)blur animated:(BOOL)animated
{
    NSTimeInterval duration = (animated) ? 0.5 : 0.0;
    [UIView animateWithDuration:duration animations:^{
        self.topViewWrapper.frame = preTopViewWrapperFrame;
        self.blurredMainView.frame = preBottomViewFrame;
        self.presentedViewContainer.alpha = 0.0;
        self.dimView.alpha = 0.0;
        [self showSubviews];
    } completion:^(BOOL finished){
        NSLog(@"JFDepthView: Dismiss Animation Complete");
        
        self.presentedView.frame = originalPresentedViewFrame;
        [self removeAllViewsFromSuperView];
        [self removeAllAnimations];
        [self deallocate];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(didDismissDepthView:)]) {
            [self.delegate didDismissDepthView:self];
        }
        
        self.isPresenting = NO;
        
    }];
}

- (void)dismissWithPerspectiveTransformWithBlur:(BOOL)blur animated:(BOOL)animated
{
    NSTimeInterval duration = (animated) ? 0.5 : 0.0;
    [UIView animateWithDuration:duration animations:^{
        self.topViewWrapper.frame = preTopViewWrapperFrame;
        self.dimView.alpha = 0.0;
    } completion:^(BOOL finished){
        self.presentedView.frame = originalPresentedViewFrame;
        [self.blurredMainView closePerspectiveTransformWithCompletionHandler:^(BOOL done) {
            NSLog(@"JFDepthView: Dismiss Animation Complete");
            self.presentedViewContainer.alpha = 0.0;
            [self showSubviews];
            [self removeAllViewsFromSuperView];
            [self removeAllAnimations];
            [self deallocate];
            if (self.delegate && [self.delegate respondsToSelector:@selector(didDismissDepthView:)]) {
                [self.delegate didDismissDepthView:self];
            }
            self.isPresenting = NO;
        }];
    }];
}

#pragma mark ----------------------
#pragma mark Utils & Additional Helpers
#pragma mark ----------------------

- (CGFloat)getPresentedViewWidth
{
    
    static CGFloat width = 0;
    
    // User defined
    if (!isnan(self.presentedViewWidth) && self.presentedViewWidth > 0.0) {
        width = self.presentedViewWidth;
    }
    
    if (width != 0) {
        return width;
    }
    
    if (isiPad()) {
        width = kiPadPresentedViewWidth;
    } else {
        width = self.presentedViewController.view.frame.size.width - 30;
    }
    
    return width;
}

- (CGFloat)getPresentedViewOriginY
{
    CGFloat y;
    if (isiPad()) {
        y = kiPadPresentedViewOriginY;;
    } else {
        y = kiPhonePresentedViewOriginY;
    }
    
    // User defined
    if (!isnan(self.presentedViewOriginY) && self.presentedViewOriginY > 0.0) {
        y = self.presentedViewOriginY;
    }
    
    return y;
}

- (float)getBlurAmount
{
    float amount;
    switch (self.blurAmount) {
        case JFDepthViewBlurAmountLight:
            amount = kLightBlurAmount;
            break;
            
        case JFDepthViewBlurAmountHard:
            amount = kHardBlurAmount;
            break;
            
        case JFDepthViewBlurAmountMedium:
        default:
            amount = kMediumBlurAmount;
            break;
    }
    
    return amount;
}

- (void)hideSubviews {
    for (UIView* subview in self.mainView.subviews) {
        if (subview && ![subview isEqual:self.view]) {
            subview.alpha = 0.0;
        }
    }
}

- (void)showSubviews {
    for (UIView* subview in self.mainView.subviews) {
        if (subview && ![subview isEqual:self.view]) {
            subview.alpha = 1.0;
        }
    }
}

#pragma mark ----------------------
#pragma mark Memory Management
#pragma mark ----------------------

- (void)removeAllViewsFromSuperView
{
    [self.dimView                removeFromSuperview];
    [self.blurredMainView        removeFromSuperview];
    [self.presentedViewContainer removeFromSuperview];
    [self.presentedView          removeFromSuperview];
    [self.topViewWrapper         removeFromSuperview];
    [self.view                   removeFromSuperview];
}

- (void)removeAllAnimations
{
    [self.view.layer                   removeAllAnimations];
    [self.presentedView.layer          removeAllAnimations];
    [self.presentedViewContainer.layer removeAllAnimations];
    [self.topViewWrapper.layer         removeAllAnimations];
    [self.blurredMainView.layer        removeAllAnimations];
    [self.dimView.layer                removeAllAnimations];
}

- (void)deallocate
{
    [self setPresentedViewContainer:nil];
    [self setMainView:nil];
    [self setDimView:nil];
    [self setBlurredMainView:nil];
    [self setTopViewWrapper:nil];
    [self setViewImage:nil];
    [self setPresentedView:nil];
    [self setPresentedViewController:nil];
}

@end

#pragma mark ----------------------
#pragma mark UIView ScreenCapture Category
#pragma mark ----------------------

@implementation UIView (JFDepthView)

- (UIImage*)getScreenShotOfRect:(CGRect)rect
{
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(c, CGRectGetMinX(rect), CGRectGetMinY(rect));
    [self.layer renderInContext:c];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)animateToSize:(CGSize)toSize fromSize:(CGSize)fromSize duration:(CGFloat)duration completion:(void(^)(BOOL finished))completion
{
    self.transform = CGAffineTransformMakeScale(fromSize.width, fromSize.height);
    [UIView animateWithDuration:1.0f delay:0.0f usingSpringWithDamping:0.7f initialSpringVelocity:0.3f options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        self.transform = CGAffineTransformMakeScale(toSize.width, toSize.height);
    } completion:completion];
}

- (void)openPerspectiveTransformWithCompletionHandler:(void(^)(BOOL finished))completion {
    CGRect f = self.frame;
    f.origin.y = -(CGRectGetHeight(f) / 2);
    self.frame = f;
    self.layer.anchorPoint = CGPointMake(0.5, 0);
    CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
    rotationAndPerspectiveTransform.m34 = 1.0 / -1000.0;
    rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, -.1, 1.0f, 0.0f, 0.0f);
    [UIView animateWithDuration:0.5f delay:0.0f usingSpringWithDamping:0.7f initialSpringVelocity:0.5f options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        self.layer.transform = rotationAndPerspectiveTransform;
    } completion:completion];
}

- (void)closePerspectiveTransformWithCompletionHandler:(void(^)(BOOL finished))completion {
    self.layer.anchorPoint = CGPointMake(0.5, 0);
    CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
    rotationAndPerspectiveTransform.m34 = 0;
    rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, 0, 1.0f, 0.0f, 0.0f);
    [UIView animateWithDuration:0.5f delay:0.0f usingSpringWithDamping:0.7f initialSpringVelocity:0.5f options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        self.layer.transform = rotationAndPerspectiveTransform;
    } completion:completion];
}

@end
