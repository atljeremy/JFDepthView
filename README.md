JFDepthView
===========

This is an iOS project for presenting views in iPad with a 3D effect to add depth. JFDepthView is only available in ARC and targets iOS 5.0+.

JFDepthView uses a blurring algorithm that can be found [here](http://indieambitions.com/idevblogaday/perform-blur-vimage-accelerate-framework-tutorial/?utm_source=feedburner&utm_medium=feed&utm_campaign=Feed%3A+IndieAmbitions+%28Indie+Ambitions%29 "here") to blur the background view.

What It Looks Like:
------------------

### Before Presentation
![Before Presentation](http://imageshack.us/a/img853/6004/screenshot20121102at813.png)

### Mid Presentation
![Mid Presentation](http://imageshack.us/a/img525/5831/screenshot20121102at814.png)

### Final Presentation
![Final Presentation](http://imageshack.us/a/img209/6004/screenshot20121102at813.png)

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
    self.depthView = [[JFDepthView alloc] initWithGestureRecognizer:tapRec];
    self.depthView.delegate = self;
    
    // Optional properties, use these to customize your presentations
    self.depthView.presentedViewWidth = 700;
    self.depthView.blurAmount = JFDepthViewBlurAmountHard;
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
```

### Add rotation support to your Presenting UIViewController
```objective-c

#pragma mark - JFDepthView Rotation Support For Presenting UIViewController

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self.depthView didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}
```


### JFDepthView will notify your Presented UIViewController of the didRotate... event
### so you can do what ever customizations need to be done to your presented view
```objective-c

#pragma mark - JFDepthView Rotation Support for Presented UIViewController

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    NSLog(@"Top View Controller Received didRotateFromInterfaceOrientation: event from JFDepthView");
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

- Simply copy the JFDepthView class (.h and .m files) into your project.

### Add Dependencies

- In your application's project app target settings, find the "Build Phases" section and open the "Link Binary With Libraries" block
- Click the "+" button and select the "CoreImage.framework", "QuartzCore.framework" & "Accelerate.framework".

Current Known Issues As Of: Nov. 1st, 2012
-------------------------------------------

- Not set up to work with iPhone just yet.

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