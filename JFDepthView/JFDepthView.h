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

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

typedef enum {
    JFDepthViewBlurAmountLight,
    JFDepthViewBlurAmountMedium,
    JFDepthViewBlurAmountHard
    
} JFDepthViewBlurAmount;

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
 * JFDepthView - presentedViewController
 *
 * This is the view controller that is being presented.
 * This property will be set automatically when you call
 * the presentViewController:inView: method.
 */
@property (nonatomic, weak) UIViewController* presentedViewController;

/**
 * JFDepthView - isPresenting
 *
 * A BOOL that can be used to determine if an instance of JFDepthView is
 * preseting a view.
 */
@property (nonatomic, assign) BOOL isPresenting;

/**
 * JFDepthView - presentedViewWidth
 *
 * A custom float value representing the desired width of the presented view.
 * Default value is 600.
 */
@property (nonatomic, assign) CGFloat presentedViewWidth;

/**
 * JFDepthView - blurAmount
 *
 * A JFDepthViewBlurAmount enum value representing to desired blur amount for the 
 * background view behind the presented view.
 * Default value is JFDepthViewBlurAmountMedium.
 */
@property (nonatomic, assign) JFDepthViewBlurAmount blurAmount;

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

/**
 * JFDepthView - dismissPresentedViewInView
 *
 * Use this method to dismiss the presented view.
 *
 * @param UIView view
 * This must be a reference to the view that contains the presented view or view controller.
 */
- (void)dismissPresentedViewInView:(UIView*)view;
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
