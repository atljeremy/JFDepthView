JFDepthView
===========

This is an iOS project for presenting views in iOS with a 3D effect to add depth. JFDepthView is only available in ARC and targets iOS 7.0+.

What's New:
----------
### February 26th, 2014
- Added new animation options. In addition to the normal blur/push back affect you can now choose any of the following animation options.
    - JFDepthViewAnimationOptionPushBack
    - JFDepthViewAnimationOptionPushBackAndBlur
    - JFDepthViewAnimationOptionPerspectiveTransform
    - JFDepthViewAnimationOptionPerspectiveTransformAndBlur
  
- Removed previously deprecated initializer `initWithGestureRecognizer:`
- Removed GPUImage dependency (Bad idea to add it in the first place, my bad)
- Reduced the number of frameworks needed down to only 3 (win!)
- Now targets iOS 7+ only
- Code refactoring and optimization
- Added subtle bounce to presented view (Trust me, it's beautiful, like a baby unicorn)

### January 29th, 2013
- JFDepthView now supports both iPad and iPhone.

What It Looks Like:
------------------

### iPad

![iPad](https://github.com/atljeremy/JFDepthView/blob/master/ipad-example.gif?raw=true)

### iPhone

![iPhone](https://github.com/atljeremy/JFDepthView/blob/master/iphone-example.gif?raw=true)

### Video (Shows all presentation animations for both iPhone and iPad)

See it in action here: [http://www.youtube.com/watch?v=X5lmn5y-FUw](http://www.youtube.com/watch?v=X5lmn5y-FUw)

How To Use It:
-------------

### Basic Example

```objective-c
#import <JFDepthView/JFDepthView.h>

...

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.topViewController = [[TopViewController alloc] initWithNibName:@"TopViewController" bundle:nil];
    UITapGestureRecognizer* tapRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    self.depthView = [[JFDepthView alloc] init];
    self.depthView.delegate = self;
    
    // Optional properties, use these to customize your presentations
    // self.depthView.presentedViewWidth = 700;
    // self.depthView.presentedViewOriginY = 200;
    // self.depthView.blurAmount = JFDepthViewBlurAmountHard;
    // self.depthView.animationOption = JFDepthViewAnimationOptionPushBackAndBlur;
	self.depthView.recognizer = tapRec;
}

// Here is an IBAction that is called via a UIButton
- (IBAction)presentView:(id)sender {
    
    // Pass in the view controller you want to present (self.topViewController) 
    // and the view you want it to be displayed within (self.view)
    [self.depthView presentViewController:self.topViewController inView:self.view];
    
    // Optionally, if you don't care about rotation support, you can just pass in 
    // the view you want to present (self.topViewController.view) 
    // and the view you want it to be displayed within (self.view)
    // [self.depthView presentView:self.topViewController.view inView:self.view];
}

// Here is the simple dismissal method called from the tap recognizer passed into init method of JFDepthView
- (void)dismiss {
    [self.depthView dismissPresentedViewInView:self.view];
}
```
### Customizable Properties
```objective-c
/**
 * JFDepthView - presentedViewWidth
 *
 * @return A custom float value representing the desired width of the presented view. Default value is 600.
 */
@property (nonatomic, assign) CGFloat presentedViewWidth;

/**
 * JFDepthView - presentedViewOriginY
 *
 * @return A custom float value representing the desired y origin of the presented view.
 * This is the space from the top of the presented view to the top of the view that it is contained in.
 */
@property (nonatomic, assign) CGFloat presentedViewOriginY;

/**
 * JFDepthView - blurAmount
 *
 * @return A JFDepthViewBlurAmount enum value representing to desired blur amount for the background view behind the presented view. Default value is JFDepthViewBlurAmountMedium.
 */
@property (nonatomic, assign) JFDepthViewBlurAmount blurAmount;

/**
 * JFDepthView - animationOption
 *
 * @return A JFDepthViewAnimationOption enum value representing the desired animation for the presentation. Default value is JFDepthViewAnimationOptionPerspectiveTransform.
 */
@property (nonatomic, assign) JFDepthViewAnimationOption animationOption;

/**
 * JFDepthView - hideStatusBarDuringPresentation
 *
 * @return A BOOL to tell JFDepthView to hide the status bar while presenting or not. Default is NO.
 */
@property (nonatomic, assign) BOOL hideStatusBarDuringPresentation;

/**
 * JFDepthView - recognizer
 *
 * @return The UIGestureRecognizer to be used on the area around the presentedView to dismiss the presentedView.
 */
@property (nonatomic, strong) UIGestureRecognizer* recognizer;
```

### Add rotation support to your Presenting UIViewController
```objective-c

#pragma mark - JFDepthView Rotation Support For Presenting UIViewController

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self.depthView didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.depthView willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}
```

JFDepthView will notify your Presented UIViewController of the didRotate... and willRotate... events so you can do what ever customizations need to be done to your presented view

```objective-c

#pragma mark - JFDepthView Rotation Support for Presented UIViewController

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    NSLog(@"Top View Controller Received didRotateFromInterfaceOrientation: event from JFDepthView");
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    NSLog(@"Top View Controller Received willRotateToInterfaceOrientation:duration: event from JFDepthView");
}
```


Please see the example project include in this repo for an example of how to use this project.
    
Delegate Methods:
----------------

    - (void)willPresentDepthView:(JFDepthView*)depthView;
    - (void)didPresentDepthView:(JFDepthView*)depthView;
    - (void)willDismissDepthView:(JFDepthView*)depthView;
    - (void)didDismissDepthView:(JFDepthView*)depthView;
    
Installation:
------------

### Add the JFDepthView project to your project

- Simply copy the JFDepthView folder (containing the JFDepthView class and Vendor/ folder) into your project.

### Add Dependencies

- In your application's project app target settings, find the "Build Phases" section and open the "Link Binary With Libraries" block
- Click the "+" button and add the following frameworks
![frameworks](https://www.evernote.com/shard/s4/sh/63b77bb2-2433-4410-8d85-62760153b47a/06a14407a3f3b98757b87fae7ed1ce88/deep/0/Screenshot%202/27/14,%201:23%20PM.jpg)

Current Known Issues As Of: Oct. 23rd, 2013
-------------------------------------------

- No known issues. If you find any, please report them using a GitHub Issue. Thanks! :)

License
-------
Copyright (c) 2012 Jeremy Fox ([jeremyfox.me](http://www.jeremyfox.me)). All rights reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
