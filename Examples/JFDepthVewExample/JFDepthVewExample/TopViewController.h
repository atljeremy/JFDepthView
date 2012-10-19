//
//  ViewController.h
//  JFDepthVewExample
//
//  Created by Jeremy Fox on 10/17/12.
//  Copyright (c) 2012 Jeremy Fox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JFDepthView/JFDepthView.h>

@interface TopViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) JFDepthView* depthViewReference;
@property (weak, nonatomic) UIView* presentedInView;

- (IBAction)closeView:(id)sender;
@end
