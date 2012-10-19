//
//  JFDepthView.h
//  JFDepthView
//
//  Created by Jeremy Fox on 10/17/12.
//  Copyright (c) 2012 Jeremy Fox. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JFDepthViewDelegate <NSObject>

@optional
- (void)willPresentDepthView;
- (void)didPresentDepthView;
- (void)willDismissDepthView;
- (void)didDismissDepthView;

@end

@interface JFDepthView : UIViewController <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView* mainView;
@property (nonatomic, strong) UIView* presentedView;
@property (nonatomic, weak) id<JFDepthViewDelegate> delegate;

- (JFDepthView*)initWithGestureRecognizer:(UIGestureRecognizer*)gesRec;
- (void)presentView:(UIView*)topView inView:(UIView*)bottomView;
- (void)dismissPresentedViewInView:(UIView*)view;
@end
