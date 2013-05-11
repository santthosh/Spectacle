//
//  BAFlipsideViewController.h
//  Spectacle
//
//  Created by Santthosh on 5/12/13.
//  Copyright (c) 2013 BrightApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BAFlipsideViewController;

@protocol BAFlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(BAFlipsideViewController *)controller;
@end

@interface BAFlipsideViewController : UIViewController

@property (weak, nonatomic) id <BAFlipsideViewControllerDelegate> delegate;

- (IBAction)done:(id)sender;

@end
