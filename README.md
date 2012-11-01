JFDepthView
===========

This is an iOS project for presenting views in iPad with a 3D effect to add depth. JFDepthView is only available in ARC and targets iOS 5.0+.

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

    - (void)willPresentDepthView:(JFDepthView)depthView;
    - (void)didPresentDepthView:(JFDepthView)depthView;
    - (void)willDismissDepthView:(JFDepthView)depthView;
    - (void)didDismissDepthView:(JFDepthView)depthView;
    
Installation:
------------

### Add the JFDepthView project to your project

- Simply copy the JFDepthView class (.h and .m files) into your project.

### Add Dependencies

- In your application's project app target settings, find the "Build Phases" section and open the "Link Binary With Libraries" block
- Click the "+" button and select the "CoreImage.framework" & "QuartzCore.framework".

Current Known Issues As Of: Nov. 1st, 2012
-------------------------------------------

- Not set up to work with iPhone just yet.
- Animations are a little slow, working on improving performance.
- Large CoreAnimation memory usage and continues to grow. Working on ensuring this is cleaned up.