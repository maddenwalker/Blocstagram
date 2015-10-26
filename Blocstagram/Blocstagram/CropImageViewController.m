//
//  CropImageViewController.m
//  Blocstagram
//
//  Created by Ryan Walker on 10/23/15.
//  Copyright © 2015 Ryan Walker. All rights reserved.
//

#import "CropImageViewController.h"
#import "Media.h"
#import "CropBox.h"
#import "UIImage+ImageUtilities.h"

@interface CropImageViewController()

@property (strong, nonatomic) CropBox *cropBox;
@property (assign, nonatomic) BOOL hasLoadedOnce;

@end

@implementation CropImageViewController

- (instancetype) initWithImage:(UIImage *)sourceImage {
    self = [super init];
    
    if (self) {
        self.media = [[Media alloc] init];
        self.media.image = sourceImage;
        
        self.cropBox = [CropBox new];
        
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.clipsToBounds = NO;
    
    [self.view addSubview:self.cropBox];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Crop", @"Crop Command") style:UIBarButtonItemStyleDone target:self action:@selector(cropPressed:)];
    
    self.navigationItem.title = NSLocalizedString(@"Crop Image", nil);
    self.navigationItem.rightBarButtonItem = rightButton;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
}

- (void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGFloat topBar = self.topLayoutGuide.length;
    
    CGRect cropRect = CGRectMake(0, topBar, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - topBar);
    
    CGSize size = cropRect.size;
    
    self.cropBox.frame = cropRect;
    self.cropBox.center = CGPointMake( size.width / 2, size.height / 2 + topBar );
    self.scrollView.frame = self.cropBox.frame;
    self.scrollView.clipsToBounds = YES;
    
    [self recalculateZoomScale];
    [self centerScrollView];
    
    if (self.hasLoadedOnce == NO) {
        self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
        self.hasLoadedOnce = YES;
    }
}

- (void) cropPressed:(UIBarButtonItem *)sender {
    CGRect visibleRect;
    
    float scale = 1.0f / self.scrollView.zoomScale / self.media.image.scale;
    visibleRect.origin.x = self.scrollView.contentOffset.x * scale;
    visibleRect.origin.y = self.scrollView.contentOffset.y * scale;
    visibleRect.size.width = self.scrollView.bounds.size.width * scale;
    visibleRect.size.height = self.scrollView.bounds.size.height * scale;
    
    UIImage *scrollViewCrop = [self.media.image imagewithFixedOrientation];
    scrollViewCrop = [scrollViewCrop imageCroppedToRect:visibleRect];
    
    [self.cropImagedelegate cropControllerFinishedWithImage:scrollViewCrop];
    
}

@end
