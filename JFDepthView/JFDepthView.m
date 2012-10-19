//
//  JFDepthView.m
//  JFDepthView
//
//  Created by Jeremy Fox on 10/17/12.
//  Copyright (c) 2012 Jeremy Fox. All rights reserved.
//

#import "JFDepthView.h"
#import <QuartzCore/QuartzCore.h>

#define kAnimationDuration 0.5
#define kPresentedViewWidth 600

@interface JFDepthView() {
    CGRect preTopViewWrapperFrame;
    CGRect postTopViewWrapperFrame;
    CGRect preBottomViewFrame;
    CGRect postBottomViewFrame;
}
@property (nonatomic, strong) UIView* topViewWrapper;
@property (nonatomic, strong) UIView* dimView;
@property (nonatomic, strong) UIImageView *blurredMainView;
@property (nonatomic, strong) UIGestureRecognizer* recognizer;
@property (nonatomic, strong) UIView* presentedViewContainer;
@property (nonatomic, strong) UIImage* viewImage;
@end

@implementation JFDepthView

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

- (void)presentView:(UIView*)topView inView:(UIView*)bottomView {
    
    NSParameterAssert(topView);
    NSParameterAssert(bottomView);

    self.mainView      = bottomView;
    self.presentedView = topView;
    self.presentedView.clipsToBounds = YES;
    self.presentedView.layer.cornerRadius  = 8;
    
    CGRect bottomViewFrame = self.mainView.bounds;
    CGRect topViewFrame    = self.presentedView.bounds;
    CGRect newTopViewFrame = CGRectMake(topViewFrame.origin.x,
                                        topViewFrame.origin.y,
                                        kPresentedViewWidth,
                                        topViewFrame.size.height);
    
    self.presentedView.frame = newTopViewFrame;
    
    self.view.frame = bottomViewFrame;
    self.view.backgroundColor = [UIColor blackColor];
    
    preTopViewWrapperFrame = CGRectMake((bottomViewFrame.size.width / 2) - 300,
                                     bottomViewFrame.size.height + bottomViewFrame.origin.y,
                                     kPresentedViewWidth,
                                     bottomViewFrame.size.height - 100);
    
    postTopViewWrapperFrame = CGRectMake((bottomViewFrame.size.width / 2) - 300,
                                         100,
                                         kPresentedViewWidth,
                                         bottomViewFrame.size.height - 100);
    
    preBottomViewFrame = bottomViewFrame;
    
    postBottomViewFrame = CGRectMake(50,
                                    0,
                                    bottomViewFrame.size.width - 100,
                                    bottomViewFrame.size.height - 100);
    
    self.topViewWrapper = [[UIView alloc] initWithFrame:preTopViewWrapperFrame];
    self.topViewWrapper.autoresizesSubviews = YES;
    self.topViewWrapper.layer.shadowOffset  = CGSizeMake(0, 0);
    self.topViewWrapper.layer.shadowRadius  = 20;
    self.topViewWrapper.layer.shadowOpacity = 0.7;
    self.topViewWrapper.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.topViewWrapper.bounds].CGPath;
    self.topViewWrapper.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin  |
                                           UIViewAutoresizingFlexibleRightMargin |
                                           UIViewAutoresizingFlexibleTopMargin   |
                                           UIViewAutoresizingFlexibleBottomMargin;
    
    self.presentedViewContainer = [[UIView alloc] initWithFrame:bottomViewFrame];
    self.presentedViewContainer.autoresizesSubviews = YES;
    self.presentedViewContainer.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin  |
                                                   UIViewAutoresizingFlexibleRightMargin |
                                                   UIViewAutoresizingFlexibleTopMargin   |
                                                   UIViewAutoresizingFlexibleBottomMargin;
    
    UIGraphicsBeginImageContext(self.mainView.bounds.size);
    [self.mainView.layer renderInContext:UIGraphicsGetCurrentContext()];
    self.viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.blurredMainView = [[UIImageView alloc] initWithFrame:preBottomViewFrame];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0) {
        self.blurredMainView.image = [self getBlurredImage];
    } else {
        self.blurredMainView.image = self.viewImage;
    }
    
    self.dimView = [[UIView alloc] initWithFrame:bottomViewFrame];
    self.dimView.backgroundColor = [UIColor blackColor];
    self.dimView.alpha = 0.0;
    [self.dimView addGestureRecognizer:self.recognizer];
    
    [self.topViewWrapper addSubview:self.presentedView];
    [self.presentedViewContainer addSubview:self.blurredMainView];
    [self.presentedViewContainer addSubview:self.dimView];
    [self.view addSubview:self.presentedViewContainer];
    [self.view addSubview:self.topViewWrapper];
    
    [self hideSubviews];
    
    [self.mainView addSubview:self.view];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(willPresentDepthView)]) {
        [self.delegate willPresentDepthView];
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        
        self.topViewWrapper.frame  = postTopViewWrapperFrame;
        self.blurredMainView.frame = postBottomViewFrame;
        self.dimView.alpha         = 0.4;
    }
    completion:^(BOOL finished){
        NSLog(@"Present Animation Complete");
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(didPresentDepthView)]) {
            [self.delegate didPresentDepthView];
        }
    }];
}

- (void)dismissPresentedViewInView:(UIView*)view {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(willDismissDepthView)]) {
        [self.delegate willDismissDepthView];
    }
    
    if ([self.mainView isEqual:view]) {
        [UIView animateWithDuration:0.5 animations:^{
            
            self.topViewWrapper.frame  = preTopViewWrapperFrame;
            self.blurredMainView.frame = preBottomViewFrame;
            self.dimView.alpha         = 0.0;
        }
         completion:^(BOOL finished){
             NSLog(@"Dismiss Animation Complete");
             [self showSubviews];
             [self.dimView removeFromSuperview];
             [self.blurredMainView removeFromSuperview];
             [self.presentedViewContainer removeFromSuperview];
             [self.view removeFromSuperview];
             self.presentedViewContainer = nil;
             self.mainView        = nil;
             self.dimView         = nil;
             self.blurredMainView = nil;
             
             if (self.delegate && [self.delegate respondsToSelector:@selector(didDismissDepthView)]) {
                 [self.delegate didDismissDepthView];
             }

         }];
    }
}

- (UIImage*)getBlurredImage {
    CIImage *imageToBlur = [CIImage imageWithCGImage:self.viewImage.CGImage];
    CIFilter *gaussianBlurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [gaussianBlurFilter setValue:imageToBlur forKey:@"inputImage"];
    [gaussianBlurFilter setValue:[NSNumber numberWithFloat:2.0] forKey:@"inputRadius"];
    CIImage *resultImage = [gaussianBlurFilter valueForKey:@"outputImage"];
    
    return [[UIImage alloc] initWithCIImage:resultImage];
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

@end
