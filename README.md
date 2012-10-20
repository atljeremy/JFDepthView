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
    
    // Pass in the view you want to present (self.topViewController.view) 
    // and the view you want it to be displayed within (self.view)
    [self.depthView presentView:self.topViewController.view inView:self.view];
}
```

Please see the example project include in this repo for an example of how to use this project.
    
Delegate Methods:
----------------

    - (void)willPresentDepthView;
    - (void)didPresentDepthView;
    - (void)willDismissDepthView;
    - (void)didDismissDepthView;
    
Installation:
------------

### Add the JFDepthView project to your project

- Clone this repository to your local disk
- Right click your project in Xcode, select "Add Files to ..."
- Navigate to where you cloned this repo on your local disk and select JFDepthView.xcodeproj.
- Select "Copy items into destination group's folder (if needed)" & "Create folder references for any added folders"
- In your projects build target, select "Build Phases"
- Click the "+" under Target Dependencies and choose "JFDepthView"
- Click the "+" under Link Binary With Libraries and choose "libJFDepthView.a"

### Add Dependencies

In your application's project app target settings, find the "Build Phases" section and open the "Link Binary With Libraries" block:
Click the "+" button and select the "CoreImage.framework" & "QuartzCore.framework".

Current Known Issues As Of: Oct. 19th, 2012
-------------------------------------------

- Currently doesn't resize presented views on rotation so it is highly encouraged that you return NO in your overridden implementation of shouldAutoRotate (iOS 6.0+) or shouldAutorotateToInterfaceOrientation: (iOS < 6.0).
- Not set up to work with iPhone just yet.
- Animations are a little slow, will be replacing drops shadows with images to help improve performance.