//
//  MediaFullScreenViewController.m
//  Blocstagram
//
//  Created by Ryan Walker on 10/12/15.
//  Copyright © 2015 Ryan Walker. All rights reserved.
//

#import "MediaFullScreenViewController.h"
#import "Media.h"

@interface MediaFullScreenViewController () <UIScrollViewDelegate>

@property (strong, nonatomic) UIBarButtonItem *shareButton;
@property (strong, nonatomic) UITapGestureRecognizer *tap;
@property (strong, nonatomic) UITapGestureRecognizer *tapOnGrayBorder;
@property (strong, nonatomic) UITapGestureRecognizer *doubleTap;

@property (strong, nonatomic) UIWindow *dimmedView;

@end

@implementation MediaFullScreenViewController

- (instancetype) initWithMedia:(Media *)media {
    self = [super init];
    
    if (self) {
        self.media = media;
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self centerScrollView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.scrollView = [UIScrollView new];
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = [UIColor whiteColor];
    
    for (UIView *viewsToAdd in @[self.scrollView]) {
        [self.view addSubview:viewsToAdd];
    }
    
    self.imageView = [UIImageView new];
    self.imageView.image = self.media.image;
    
    [self.scrollView addSubview:self.imageView];
    
    self.scrollView.contentSize = self.media.image.size;
    
    [self enableButtons];
    
    
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFired:)];
    
    self.tapOnGrayBorder = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGrayBorderFired:)];
//    [self.tapOnGrayBorder setCancelsTouchesInView:NO];
    
    self.doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapFired:)];
    self.doubleTap.numberOfTapsRequired = 2;
    
    [self.tap requireGestureRecognizerToFail:self.doubleTap];

    [self.scrollView addGestureRecognizer:self.tap];
    [self.scrollView addGestureRecognizer:self.doubleTap];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.scrollView.frame = self.view.bounds;
    [self.scrollView.window addGestureRecognizer:self.tapOnGrayBorder];
    
    [self recalculateZoomScale];
}

- (void) recalculateZoomScale {
    
    CGSize scrollViewFrameSize = self.scrollView.frame.size;
    CGSize scrollViewContentSize = self.scrollView.contentSize;
    
    scrollViewContentSize.height /= self.scrollView.zoomScale;
    scrollViewContentSize.width /= self.scrollView.zoomScale;
    
    CGFloat scaleWidth = scrollViewFrameSize.width / scrollViewContentSize.width;
    CGFloat scaleHeight = scrollViewFrameSize.height / scrollViewContentSize.height;
    
    CGFloat minScale = MIN(scaleHeight, scaleWidth);
    
    self.scrollView.minimumZoomScale = minScale;
    self.scrollView.maximumZoomScale = 1;


}

#pragma mark - instance methods

- (void) centerScrollView {
    [self.imageView sizeToFit];
    
    CGSize boundSize = self.scrollView.bounds.size;
    CGRect contentsFrame = self.imageView.frame;
    
    if (contentsFrame.size.width < boundSize.width) {
        contentsFrame.origin.x = ( boundSize.width - CGRectGetWidth(contentsFrame) ) / 2;
    } else {
        contentsFrame.origin.x = 0;
    }
    
    if (contentsFrame.size.height < boundSize.height) {
        contentsFrame.origin.y = ( boundSize.height - CGRectGetHeight(contentsFrame)) / 2;
    } else {
        contentsFrame.origin.y = 0;
    }
    
    self.imageView.frame = contentsFrame;
}

#pragma mark - button taps

- (void) shareButtonTapped {
    [self.navigationController popViewControllerAnimated:YES];
    [self.delegate didTapShareButton:self.media];
}

#pragma mark - UIGestureRecognizer Methods

- (void) tapFired:(UITapGestureRecognizer *)sender {
    if (self.traitCollection.userInterfaceIdiom != UIUserInterfaceIdiomPad) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void) tapGrayBorderFired:(UITapGestureRecognizer *)sender {
    NSLog(@"I am here in tapGrayBorderFired:");
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) doubleTapFired:(UITapGestureRecognizer *)sender {
    if (self.scrollView.zoomScale == self.scrollView.minimumZoomScale) {
        CGPoint locationPoint = [sender locationInView:self.imageView];
        
        CGSize scrollViewSize = self.scrollView.bounds.size;
        
        CGFloat width = scrollViewSize.width / self.scrollView.maximumZoomScale;
        CGFloat height = scrollViewSize.height / self.scrollView.maximumZoomScale;
        
        CGFloat x = locationPoint.x - ( width / 2 );
        CGFloat y = locationPoint.y - ( height / 2 );
        
        [self.scrollView zoomToRect:CGRectMake(x, y, width, height) animated:YES];
    } else {
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
    }
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self centerScrollView];
}

#pragma mark - Helper Methods

- (void) enableButtons {
    
    self.shareButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Share", @"Share") style:UIBarButtonItemStylePlain target:self action:@selector(shareButtonTapped)];

    [self.navigationItem setRightBarButtonItem:self.shareButton];

}

@end
