//
//  JFDepthView.h
//  JFDepthView
//
//  Created by Jeremy Fox on 10/17/12.
//  Copyright (c) 2012 Jeremy Fox. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JFDepthViewDelegate;

/**
 * JFDepthView
 *
 * This is a class extending from UIViewControll that can be
 * used to add a cool 3D "Depth" effect to presented views.
 */
@interface JFDepthView : UIViewController <UIGestureRecognizerDelegate>

/**
 * JFDepthView - mainView
 *
 * This is the view in which everything will appear within.
 * This property will be set automatically when you call
 * the presentView:inView: method.
 */
@property (nonatomic, weak) UIView* mainView;

/**
 * JFDepthView - presentedView
 *
 * This is the view that is being presented.
 * This property will be set automatically when you call
 * the presentView:inView: method.
 */
@property (nonatomic, weak) UIView* presentedView;

/**
 * JFDepthView - delegate
 *
 * Set this in your view controller that creates the JFDepthView
 * object and set it to "self". Then imaplement the delegate
 * methods above.
 */
@property (nonatomic, weak) id<JFDepthViewDelegate> delegate;

/**
 * JFDepthView - initWithGestureRecognizer:
 *
 * This is the required initialization method of JFDepthView. Do not use init.
 *
 * @param UIGestureRecognizer gesRec
 * This is the desired UIGestureRecognizer you wish to place on
 * the surrounding area of your presented view to allow users to
 * dismiss the view by simply tapping this area or maybe swiping
 * downward, it's up to you.
 */
- (JFDepthView*)initWithGestureRecognizer:(UIGestureRecognizer*)gesRec;

/**
 * JFDepthView - presentView:inView:
 *
 * Use this method to present a view with a cool 3D "depth" effect.
 *
 * @param UIView topView
 * This is the view to be presented.
 *
 * @param UIView bottomView
 * This is the view in which everything will be presented in.
 */
- (void)presentView:(UIView*)topView inView:(UIView*)bottomView;

/**
 * JFDepthView - dismissPresentedViewInView
 *
 * Use this method to dismiss the presented view.
 *
 * @param UIView view
 * This must be a reference to the view that contains the presented view.
 */
- (void)dismissPresentedViewInView:(UIView*)view;

/**
 * JFDepthView - presentViewController:inView:
 *
 * Use this method to present a view controller with a cool 3D "depth" effect.
 * NOTE: Use this method is you are concerned about rotation support.
 *
 * @param UIViewController topView
 * This is the view controller to be presented.
 *
 * @param UIView bottomView
 * This is the view in which everything will be presented in.
 */
- (void)presentViewController:(UIViewController*)topViewController inView:(UIView*)bottomView;
@end



/**
 * JFDepthViewDelegate Protocol
 */
@protocol JFDepthViewDelegate <NSObject>

@optional

/**
 * JFDepthViewDelegate - willPresentDepthView
 *
 * If you implement this method it will be called immediately
 * before the animation begins to present the view.
 */
- (void)willPresentDepthView:(JFDepthView*)depthView;

/**
 * JFDepthViewDelegate - didPresentDepthView
 *
 * If you implement this method it will be called immediately
 * after the animation ends which presented the view.
 */
- (void)didPresentDepthView:(JFDepthView*)depthView;

/**
 * JFDepthViewDelegate - willDismissDepthView
 *
 * If you implement this method it will be called immediately
 * before the animation begins to dismiss the view.
 */
- (void)willDismissDepthView:(JFDepthView*)depthView;

/**
 * JFDepthViewDelegate - didDismissDepthView
 *
 * If you implement this method it will be called immediately
 * after the animation ends which dismissed the view.
 */
- (void)didDismissDepthView:(JFDepthView*)depthView;

@end
