//
//  BAMainViewController.h
//  Spectacle
//
//  Created by Santthosh on 5/12/13.
//  Copyright (c) 2013 BrightApps. All rights reserved.
//

#import "BAFlipsideViewController.h"

#import <CoreData/CoreData.h>

@interface BAMainViewController : UIViewController <BAFlipsideViewControllerDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;

- (IBAction)showInfo:(id)sender;

@end
