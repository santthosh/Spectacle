//
//  BAMainViewController.m
//  Spectacle
//
//  Created by Santthosh on 5/12/13.
//  Copyright (c) 2013 BrightApps. All rights reserved.
//

#import "BAMainViewController.h"
#import "PXAPI.h"
#import "SDWebImagePrefetcher.h"
#import "SDWebImageManager.h"
#import "SDImageCache.h"

#define IMAGE_PREFETCH_THRESHOLD 25
#define IMAGE_ANIMATION_DELAY 1

@interface SDWebImageManager (Private)

- (NSString *)cacheKeyForURL:(NSURL *)url;

@end

@interface BAMainViewController ()

@property (strong, nonatomic) NSMutableArray *objects;

@property (strong, nonatomic) NSMutableArray *placeholders;

@property (nonatomic, assign) NSUInteger currentIndex;

@property (nonatomic, assign) NSUInteger currentPage;

@property (nonatomic, assign) NSUInteger currentPlaceholderIndex;

@end

@implementation BAMainViewController

@synthesize objects, placeholders, currentPage, currentIndex, currentPlaceholderIndex;

#pragma mark - Animation

-(void)prefetchImages {
    [PXRequest requestForPhotoFeature:kPXAPIHelperDefaultFeature resultsPerPage:kPXAPIHelperMaximumResultsPerPage page:currentPage completion:^(NSDictionary *results, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if (results) {
            [self.objects addObjectsFromArray:[results valueForKey:@"photos"]];
            NSMutableArray *prefetchURLs = [NSMutableArray array];
            for(NSDictionary *dictionary in self.objects) {
                [prefetchURLs addObject:[[dictionary objectForKey:@"image_url"] lastObject]];
            }
            [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:prefetchURLs];
            
            if([self.objects count] < kPXAPIHelperMaximumResultsPerPage) {
                currentPage = 0;
            } else {
                currentPage++;
            }
        }
    }];
}

- (UIImage *)getNextImage {
    if(currentIndex >= [self.objects count] - 1)
        currentIndex = 0;
    
    NSLog(@"CurrentIndex: %d %d",currentIndex,[self.objects count]);
    
    if(currentPlaceholderIndex >= [self.placeholders count] - 1)
        currentPlaceholderIndex = 0;
    
    UIImage *image = nil;
    if(self.objects && [self.objects count]) {
        NSString *url_string = [[[self.objects objectAtIndex:currentIndex] objectForKey:@"image_url"] lastObject];
        image =  [[SDImageCache sharedImageCache] imageFromKey:[[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:url_string]] fromDisk:YES];
    }
    
    if(!image) {
        image = [placeholders objectAtIndex:currentPlaceholderIndex];
        currentPlaceholderIndex++;
        if(currentIndex > 0)
            currentIndex++;
    } else {
        currentIndex++;
        if(([self.objects count] - currentIndex) < IMAGE_PREFETCH_THRESHOLD) {
            [self prefetchImages];
        }
    }
    
    return image;
}

- (void)startAnimations {
    CGFloat delay = _transitionImageView.animationDuration + 1;
    
    _transitionImageView.animationDirection = AnimationDirectionLeftToRight;
    _transitionImageView.image = [self getNextImage];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
        _transitionImageView.animationDirection = AnimationDirectionTopToBottom;
        _transitionImageView.image = [self getNextImage];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
            _transitionImageView.animationDirection = AnimationDirectionRightToLeft;
            _transitionImageView.image = [self getNextImage];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
                _transitionImageView.animationDirection = AnimationDirectionBottomToTop;
                _transitionImageView.image = [self getNextImage];
                
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
    _transitionImageView.animationDuration = IMAGE_ANIMATION_DELAY;
    _transitionImageView.image = _transitionImageView.image;
}


#pragma mark - View Controller

- (void)viewDidLoad {
    [super viewDidLoad];
    
    objects = [NSMutableArray array];
    placeholders = [NSMutableArray arrayWithObjects:[UIImage imageNamed:@"image0.jpg"],[UIImage imageNamed:@"image1.jpg"],[UIImage imageNamed:@"image2.jpg"],[UIImage imageNamed:@"image3.jpg"],nil];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    currentPage = 1;
    [self prefetchImages];
    
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
