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
#import <QuartzCore/QuartzCore.h>

#define isiPad() [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad

#define kAnimationDuration  0.5
#define kiPadPresentedViewWidth 600
#define kiPadPresentedViewOriginY 30
#define kiPhonePresentedViewOriginY 50
#define kLightBlurAmount  0.1f
#define kMediumBlurAmount 0.2f
#define kHardBlurAmount   0.3f

@interface UIImage (Blur)
-(UIImage *)boxblurImageWithBlur:(CGFloat)blur;
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
@property (nonatomic, strong) UIGestureRecognizer* recognizer;
@property (nonatomic, strong) UIView* presentedViewContainer;
@property (nonatomic, strong) UIImage* viewImage;
@end

@implementation JFDepthView
@synthesize mainView                = _mainView;
@synthesize presentedView           = _presentedView;
@synthesize presentedViewController = _presentedViewController;
@synthesize presentedViewContainer  = _presentedViewContainer;
@synthesize isPresenting            = _isPresenting;
@synthesize topViewWrapper          = _topViewWrapper;
@synthesize dimView                 = _dimView;
@synthesize blurredMainView         = _blurredMainView;
@synthesize recognizer              = _recognizer;
@synthesize viewImage               = _viewImage;
@synthesize presentedViewWidth      = _presentedViewWidth;
@synthesize blurAmount              = _blurAmount;
@synthesize presentedViewOriginY    = _presentedViewOriginY;
@synthesize hideStatusBarDuringPresentation = _hideStatusBarDuringPresentation;

- (JFDepthView*)init {
    
    @throw [NSException exceptionWithName:@"JFDepthView Invalid Initialization"
                                   reason:@"JFDepthView must be initialized using initWithGestureRecognizer:"
                                 userInfo:nil];
    return nil;
}

- (JFDepthView*)initWithGestureRecognizer:(UIGestureRecognizer*)gesRec {
    if (self = [super init]) {
        NSLog(@"JFDepthView Initialized!");
        
        self.recognizer = gesRec;
        self.isPresenting = NO;
        self.blurAmount = JFDepthViewBlurAmountMedium;
        self.hideStatusBarDuringPresentation = NO;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    // Dispose of any resources that can be recreated.
}

#pragma mark - iOS 5 Rotation Support
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - iOS 6 Rotation Support

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationMaskAll;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    if (!self.presentedViewController) return;
    
    // Notify presented view of rotation event so it can handle updating things as needed.
    [self.presentedViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        // Rotating to a landscape orientation
        
    } else {
        // Rotated to a portrait orientation
        
    }
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
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

- (void)presentViewController:(UIViewController*)topViewController inView:(UIView*)bottomView animated:(BOOL)animated {
    
    NSParameterAssert(topViewController);
    NSParameterAssert(bottomView);
    
    if (self.presentedViewController) {
        self.presentedViewController = nil;
    }
    self.presentedViewController = topViewController;
    [self presentView:self.presentedViewController.view inView:bottomView animated:animated];
}

- (void)presentView:(UIView*)topView inView:(UIView*)bottomView animated:(BOOL)animated {
    
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
    
    float presentedViewWidth = [self getPresentedViewWidth];
    float presentedViewOriginY = [self getPresentedViewOriginY];
    
    bottomViewFrame        = self.mainView.bounds;
    CGRect topViewFrame    = self.presentedView.bounds;
    CGRect newTopViewFrame = CGRectMake(topViewFrame.origin.x,
                                        topViewFrame.origin.y,
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
    
    CGFloat postX      = (isiPad) ? 50 : 0;
    CGFloat postWidth  = (isiPad) ? bottomViewFrame.size.width - 100  : bottomViewFrame.size.width;
    CGFloat postHeight = (isiPad) ? bottomViewFrame.size.height - 100 : bottomViewFrame.size.height;
    postBottomViewFrame = CGRectMake(postX,
                                     0,
                                     postWidth,
                                     postHeight);
    
    CGFloat shadowRadius  = (isiPad) ? 20 : 10;
    CGFloat shadowOpacity = (isiPad) ? 1.0 : 0.5;
    self.topViewWrapper = [[UIView alloc] initWithFrame:preTopViewWrapperFrame];
    self.topViewWrapper.autoresizesSubviews = YES;
    self.topViewWrapper.layer.shadowOffset  = CGSizeMake(0, 0);
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
    self.presentedViewContainer.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin  |
    UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleTopMargin   |
    UIViewAutoresizingFlexibleBottomMargin|
    UIViewAutoresizingFlexibleHeight      |
    UIViewAutoresizingFlexibleWidth;
    
    UIGraphicsBeginImageContext(self.mainView.bounds.size);
    [self.mainView.layer renderInContext:UIGraphicsGetCurrentContext()];
    self.viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.blurredMainView = [[UIImageView alloc] initWithFrame:preBottomViewFrame];
    self.blurredMainView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin  |
    UIViewAutoresizingFlexibleRightMargin ;
    
    self.blurredMainView.image = [self getBlurredImage];
    
    self.dimView = [[UIView alloc] initWithFrame:bottomViewFrame];
    self.dimView.backgroundColor = [UIColor blackColor];
    self.dimView.alpha = 0.0;
    [self.dimView addGestureRecognizer:self.recognizer];
    self.dimView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
    UIViewAutoresizingFlexibleHeight;
    
    [self.topViewWrapper addSubview:self.presentedView];
    [self.presentedViewContainer addSubview:self.blurredMainView];
    [self.presentedViewContainer addSubview:self.dimView];
    [self.view addSubview:self.presentedViewContainer];
    [self.view addSubview:self.topViewWrapper];
    
    [self hideSubviews];
    
    [self.mainView addSubview:self.view];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(willPresentDepthView:)]) {
        [self.delegate willPresentDepthView:self];
    }
    
    if (self.hideStatusBarDuringPresentation) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }
    
    float duration = (animated) ? 0.5 : 0.0;
    [UIView animateWithDuration:duration animations:^{
        
        self.topViewWrapper.frame  = postTopViewWrapperFrame;
        self.blurredMainView.frame = postBottomViewFrame;
        self.dimView.alpha         = 0.4;
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

- (void)dismissPresentedViewInView:(UIView*)view animated:(BOOL)animated {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(willDismissDepthView:)]) {
        [self.delegate willDismissDepthView:self];
    }
    
    if ([self.mainView isEqual:view]) {
        
        if (self.hideStatusBarDuringPresentation) {
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
        }
        
        float duration = (animated) ? 0.5 : 0.0;
        [UIView animateWithDuration:duration animations:^{
            
            self.topViewWrapper.frame  = preTopViewWrapperFrame;
            self.blurredMainView.frame = preBottomViewFrame;
            self.dimView.alpha         = 0.0;
        } completion:^(BOOL finished){
            NSLog(@"JFDepthView: Dismiss Animation Complete");
            
            self.presentedView.frame = originalPresentedViewFrame;
            [self showSubviews];
            [self removeAllViewsFromSuperView];
            [self removeAllAnimations];
            [self deallocate];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(didDismissDepthView:)]) {
                [self.delegate didDismissDepthView:self];
            }
            
            self.isPresenting = NO;
            
        }];
    }
}

- (CGFloat)getPresentedViewWidth {
    
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

- (CGFloat)getPresentedViewOriginY {
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

- (float)getBlurAmount {
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

- (UIImage*)getBlurredImage {
    NSData *imageData = UIImageJPEGRepresentation(self.viewImage, 1); // convert to jpeg
    UIImage* image = [UIImage imageWithData:imageData];
    return [image boxblurImageWithBlur:self.getBlurAmount];
}

- (void)hideSubviews {
    for (UIView* subview in self.mainView.subviews) {
        if (subview) {
            subview.hidden = YES;
        }
    }
}

- (void)showSubviews {
    for (UIView* subview in self.mainView.subviews) {
        if (subview) {
            subview.hidden = NO;
        }
    }
}

#pragma mark - Memory Management

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

@implementation UIImage (Blur)

-(UIImage *)boxblurImageWithBlur:(CGFloat)blur {
    if (blur < 0.f || blur > 1.f) {
        blur = 0.5f;
    }
    int boxSize = (int)(blur * 50);
    boxSize = boxSize - (boxSize % 2) + 1;
    
    CGImageRef img = self.CGImage;
    
    vImage_Buffer inBuffer, outBuffer;
    
    vImage_Error error;
    
    void *pixelBuffer;
    
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    
    if(pixelBuffer == NULL)
        NSLog(@"No pixelbuffer");
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    
    if (error) {
        NSLog(@"JFDepthView: error from convolution %ld", error);
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             kCGImageAlphaNoneSkipLast);
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    
    free(pixelBuffer);
    CFRelease(inBitmapData);
    
    CGImageRelease(imageRef);
    
    return returnImage;
}

@end
