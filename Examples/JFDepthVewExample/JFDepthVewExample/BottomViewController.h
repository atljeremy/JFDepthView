//
//  BottomViewController.h
//  JFDepthVewExample
//
//  Created by Jeremy Fox on 10/17/12.
//  Copyright (c) 2012 Jeremy Fox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <JFDepthView/JFDepthView.h>

@interface BottomViewController : UIViewController <MKMapViewDelegate, JFDepthViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *bottomView;

- (IBAction)presentView:(id)sender;
@end
