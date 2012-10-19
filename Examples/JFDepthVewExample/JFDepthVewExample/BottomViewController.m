//
//  BottomViewController.m
//  JFDepthVewExample
//
//  Created by Jeremy Fox on 10/17/12.
//  Copyright (c) 2012 Jeremy Fox. All rights reserved.
//

#import "BottomViewController.h"
#import "TopViewController.h"

@interface BottomViewController ()
@property (nonatomic, strong) JFDepthView* depthView;
@property (nonatomic, strong) TopViewController* topViewController;
@end

@implementation BottomViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.topViewController = [[TopViewController alloc] initWithNibName:@"TopViewController" bundle:nil];
    UITapGestureRecognizer* tapRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    self.depthView = [[JFDepthView alloc] initWithGestureRecognizer:tapRec];
    self.depthView.delegate = self;
    
}

- (void)dismiss {
    [self.depthView dismissPresentedViewInView:self.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)presentView:(id)sender {
    
    [self.depthView presentView:self.topViewController.view inView:self.view];
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
    return YES;
}

- (void)willPresentDepthView {
    NSLog(@"willPresentDepthView called!!!");
}

- (void)didPresentDepthView {
    NSLog(@"didPresentDepthView called!!!");
}

- (void)willDismissDepthView {
    NSLog(@"willDismissDepthView called!!!");
}

- (void)didDismissDepthView {
    NSLog(@"didDismissDepthView called!!!");
}

@end
