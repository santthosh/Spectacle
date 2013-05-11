//
//  BAMainViewController.m
//  Spectacle
//
//  Created by Santthosh on 5/12/13.
//  Copyright (c) 2013 BrightApps. All rights reserved.
//

#import "BAMainViewController.h"

@interface BAMainViewController ()

@end

@implementation BAMainViewController

#pragma mark - Animation

- (void)startAnimations {
    CGFloat delay = _transitionImageView.animationDuration + 1;
    
    _transitionImageView.animationDirection = AnimationDirectionLeftToRight;
    _transitionImageView.image = [UIImage imageNamed:@"image0.jpg"];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
        _transitionImageView.animationDirection = AnimationDirectionTopToBottom;
        _transitionImageView.image = [UIImage imageNamed:@"image1.jpg"];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
            _transitionImageView.animationDirection = AnimationDirectionRightToLeft;
            _transitionImageView.image = [UIImage imageNamed:@"image2.jpg"];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
                _transitionImageView.animationDirection = AnimationDirectionBottomToTop;
                _transitionImageView.image = [UIImage imageNamed:@"image3.jpg"];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
                    [self startAnimations];
                });
            });
        });
    });
}

-(void)layoutTransitionImageView {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGRect frameRect = CGRectMake(0, 0, screenRect.size.height, screenRect.size.width);
    if(UIDeviceOrientationIsPortrait(self.interfaceOrientation))
        frameRect = CGRectMake(0, 0, screenRect.size.width, screenRect.size.height);
    if(!_transitionImageView)
        _transitionImageView = [[LTransitionImageView alloc] initWithFrame:frameRect];
    _transitionImageView.frame = frameRect;
    _transitionImageView.animationDuration = 3;
    _transitionImageView.image = _transitionImageView.image;
}


#pragma mark - View Controller

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self layoutTransitionImageView];
    [self.view addSubview:_transitionImageView];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
        [self startAnimations];
    });
}

#pragma mark - Flipside View Controller

- (void)flipsideViewControllerDidFinish:(BAFlipsideViewController *)controller {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
    }
}

- (IBAction)showInfo:(id)sender {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        BAFlipsideViewController *controller = [[BAFlipsideViewController alloc] initWithNibName:@"BAFlipsideViewController" bundle:nil];
        controller.delegate = self;
        controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:controller animated:YES completion:nil];
    } else {
        if (!self.flipsidePopoverController) {
            BAFlipsideViewController *controller = [[BAFlipsideViewController alloc] initWithNibName:@"BAFlipsideViewController" bundle:nil];
            controller.delegate = self;
            
            self.flipsidePopoverController = [[UIPopoverController alloc] initWithContentViewController:controller];
        }
        if ([self.flipsidePopoverController isPopoverVisible]) {
            [self.flipsidePopoverController dismissPopoverAnimated:YES];
        } else {
            [self.flipsidePopoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    }
}

#pragma mark - Handle Rotations

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self layoutTransitionImageView];
}

@end
