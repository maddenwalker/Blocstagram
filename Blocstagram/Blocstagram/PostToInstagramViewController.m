//
//  PostToInstagramViewController.m
//  Blocstagram
//
//  Created by Ryan Walker on 10/25/15.
//  Copyright © 2015 Ryan Walker. All rights reserved.
//

#import "PostToInstagramViewController.h"
#import "FilterCollectionViewCell.h"

@interface PostToInstagramViewController() <UICollectionViewDataSource, UICollectionViewDelegate, UIDocumentInteractionControllerDelegate>

@property (strong, nonatomic) UIImage *sourceImage;
@property (strong, nonatomic) UIImageView *previewImageView;

@property (strong, nonatomic) NSOperationQueue *photoFilterOperationQueue;
@property (strong, nonatomic) UICollectionView *filterCollectionView;

@property (strong, nonatomic) NSMutableArray *filterImages;
@property (strong, nonatomic) NSMutableArray *filterTitles;

@property (strong, nonatomic) UIButton *sendToInstagramButton;
@property (strong, nonatomic) UIBarButtonItem *sendToInstagramBarButtonItem;

@property (strong, nonatomic) UIDocumentInteractionController *documentController;

@end

@implementation PostToInstagramViewController

- (instancetype) initWithImage:(UIImage *)sourceImage {
    self = [super init];
    
    if (self) {
        self.sourceImage = sourceImage;
        self.previewImageView = [[UIImageView alloc] initWithImage:self.sourceImage];
        
        self.photoFilterOperationQueue = [[NSOperationQueue alloc] init];
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = CGSizeMake(44, 64);
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.minimumInteritemSpacing = 10;
        flowLayout.minimumLineSpacing = 10;
        
        self.filterCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        self.filterCollectionView.dataSource = self;
        self.filterCollectionView.delegate = self;
        self.filterCollectionView.showsHorizontalScrollIndicator = NO;
        
        self.filterImages = [NSMutableArray arrayWithObject:sourceImage];
        self.filterTitles = [NSMutableArray arrayWithObject:NSLocalizedString(@"None", @"Label for when no filter is present")];
        
        self.sendToInstagramButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.sendToInstagramButton.backgroundColor = [UIColor colorWithRed:0.345 green:0.318 blue:0.424 alpha:1]; /*#58516c*/
        self.sendToInstagramButton.layer.cornerRadius = 5;
        [self.sendToInstagramButton setAttributedTitle:[self sendAttributedString] forState:UIControlStateNormal];
        [self.sendToInstagramButton addTarget:self action:@selector(sendToInstagramButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        self.sendToInstagramBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Send", @"Send button") style:UIBarButtonItemStyleDone target:self action:@selector(sendToInstagramButtonPressed:)];
        [self addFiltersToQueue];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *views = @[self.previewImageView, self.filterCollectionView];
    
    for ( UIView *view in views ) {
        [self.view addSubview:view];
    }
    
    if ( CGRectGetHeight(self.view.frame) > 500 ) {
        [self.view addSubview:self.sendToInstagramButton];
    } else {
        self.navigationItem.rightBarButtonItem = self.sendToInstagramBarButtonItem;
    }
    
    [self.filterCollectionView registerClass:[FilterCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    
    self.view.backgroundColor = [UIColor blackColor];
    self.filterCollectionView.backgroundColor = [UIColor blackColor];
    
    self.navigationItem.title = NSLocalizedString(@"Apply Filter", @"apply filter title view");
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGFloat edgeSize = MIN(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    
    if (CGRectGetHeight(self.view.bounds) < edgeSize * 1.5 ) {
        edgeSize /= 1.5;
    }
    
    self.previewImageView.frame = CGRectMake(0, self.topLayoutGuide.length, edgeSize, edgeSize);
    
    CGFloat buttonHeight = 50;
    CGFloat buffer = 10;
    
    CGFloat filterViewYOrigin = CGRectGetMaxY(self.previewImageView.frame) + buffer;
    CGFloat filterViewHeight;
    
    if (CGRectGetHeight(self.view.frame) > 500) {
        self.sendToInstagramButton.frame = CGRectMake(buffer, CGRectGetHeight(self.view.frame) - buffer - buttonHeight, CGRectGetWidth(self.view.frame) - 2 * buffer, buttonHeight);
        
        filterViewHeight = CGRectGetHeight(self.view.frame) - filterViewYOrigin - buffer - buffer - CGRectGetHeight(self.sendToInstagramButton.frame);
    } else {
        filterViewHeight = CGRectGetHeight(self.view.frame) - CGRectGetMaxY(self.previewImageView.frame) - buffer - buffer;
    }
    
    self.filterCollectionView.frame = CGRectMake(0, filterViewYOrigin, CGRectGetWidth(self.view.frame), filterViewHeight);
    
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.filterCollectionView.collectionViewLayout;
    flowLayout.itemSize = CGSizeMake(CGRectGetHeight(self.filterCollectionView.frame) - 20, CGRectGetHeight(self.filterCollectionView.frame));
}

#pragma mark - UICollectionView delegate and data source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.filterImages.count;
}

-(FilterCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FilterCollectionViewCell *cell = (FilterCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    [cell.thumbnail setImage:self.filterImages[indexPath.row]];
    [cell.label setText:self.filterTitles[indexPath.row]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.previewImageView.image = self.filterImages[indexPath.row];
}


#pragma mark - Photo Filters

- (void) addFiltersToQueue {
    CIImage *sourceCIImage = [CIImage imageWithCGImage:self.sourceImage.CGImage];
    
    //Noir Filter
    [self.photoFilterOperationQueue addOperationWithBlock:^{
        CIFilter *noirFilter = [CIFilter filterWithName:@"CIPhotoEffectNoir"];
        
        if (noirFilter) {
            [noirFilter setValue:sourceCIImage forKey:kCIInputImageKey];
            [self addCIImageToCollectionView:noirFilter.outputImage withFilterTitle:NSLocalizedString(@"Noir", @"Noir Filter")];
        }
    }];
    
    // Boom filter
    
    [self.photoFilterOperationQueue addOperationWithBlock:^{
        CIFilter *boomFilter = [CIFilter filterWithName:@"CIPhotoEffectProcess"];
        
        if (boomFilter) {
            [boomFilter setValue:sourceCIImage forKey:kCIInputImageKey];
            [self addCIImageToCollectionView:boomFilter.outputImage withFilterTitle:NSLocalizedString(@"Boom", @"Boom Filter")];
        }
    }];
    
    //Motion Blur Filter
    
    [self.photoFilterOperationQueue addOperationWithBlock:^{
        CIFilter *blurFilter = [CIFilter filterWithName:@"CIMotionBlur"];
        
        if (blurFilter) {
            [blurFilter setValue:sourceCIImage forKey:kCIInputImageKey];
            [blurFilter setValue:[NSNumber numberWithBool:50.0] forKey:@"inputRadius"];
            [blurFilter setValue:[NSNumber numberWithBool:0.0] forKey:@"inputAngle"];
            
            [self addCIImageToCollectionView:blurFilter.outputImage withFilterTitle:NSLocalizedString(@"Blur", @"Blur Filter")];
        }
    }];
    
    // Warm filter
    
    [self.photoFilterOperationQueue addOperationWithBlock:^{
        CIFilter *warmFilter = [CIFilter filterWithName:@"CIPhotoEffectTransfer"];
        
        if (warmFilter) {
            [warmFilter setValue:sourceCIImage forKey:kCIInputImageKey];
            [self addCIImageToCollectionView:warmFilter.outputImage withFilterTitle:NSLocalizedString(@"Warm", @"Warm Filter")];
        }
    }];
    
    // Pixel filter
    
    [self.photoFilterOperationQueue addOperationWithBlock:^{
        CIFilter *pixelFilter = [CIFilter filterWithName:@"CIPixellate"];
        
        if (pixelFilter) {
            [pixelFilter setValue:sourceCIImage forKey:kCIInputImageKey];
            [self addCIImageToCollectionView:pixelFilter.outputImage withFilterTitle:NSLocalizedString(@"Pixel", @"Pixel Filter")];
        }
    }];
    
    // Moody filter
    
    [self.photoFilterOperationQueue addOperationWithBlock:^{
        CIFilter *moodyFilter = [CIFilter filterWithName:@"CISRGBToneCurveToLinear"];
        
        if (moodyFilter) {
            [moodyFilter setValue:sourceCIImage forKey:kCIInputImageKey];
            [self addCIImageToCollectionView:moodyFilter.outputImage withFilterTitle:NSLocalizedString(@"Moody", @"Moody Filter")];
        }
    }];
    
    // Tint filter
    
    [self.photoFilterOperationQueue addOperationWithBlock:^{
        CIFilter *tintFilter = [CIFilter filterWithName:@"CITemperatureAndTint"];
        
        if (tintFilter) {
            [tintFilter setValue:sourceCIImage forKey:kCIInputImageKey];
            [tintFilter setValue:[CIVector vectorWithX:6500 Y:500] forKey:@"inputNeutral"];
            [tintFilter setValue:[CIVector vectorWithX:1000 Y:630] forKey:@"inputTargetNeutral"];
            [self addCIImageToCollectionView:tintFilter.outputImage withFilterTitle:NSLocalizedString(@"Tint", @"Tint Filter")];
        }
    }];
    
    //Drunk Filter
    
    [self.photoFilterOperationQueue addOperationWithBlock:^{
        CIFilter *drunkFilter = [CIFilter filterWithName:@"CIConvolution5x5"];
        CIFilter *tiltFilter = [CIFilter filterWithName:@"CIStraightenFilter"];
        
        if (drunkFilter) {
            [drunkFilter setValue:sourceCIImage forKey:kCIInputImageKey];
            
            CIVector *drunkVector = [CIVector vectorWithString:@"[0.5 0 0 0 0 0 0 0 0 0.05 0 0 0 0 0 0 0 0 0 0 0.05 0 0 0 0.5]"];
            [drunkFilter setValue:drunkVector forKey:@"inputWeights"];
            
            CIImage *result = drunkFilter.outputImage;
            
            if (tiltFilter) {
                [tiltFilter setValue:result forKey:kCIInputImageKey];
                [tiltFilter setValue:@0.2 forKey:kCIInputAngleKey];
                result = tiltFilter.outputImage;
            }
            
            [self addCIImageToCollectionView:result withFilterTitle:NSLocalizedString(@"Drunk", @"Drunk Filter")];
        }
        
    }];
    
    //Film Filter
    
    [self.photoFilterOperationQueue addOperationWithBlock:^{
        CIFilter *sepiaFilter = [CIFilter filterWithName:@"CISepiaTone"];
        [sepiaFilter setValue:@1 forKey:kCIInputIntensityKey];
        [sepiaFilter setValue:sourceCIImage forKey:kCIInputImageKey];
        
        CIFilter *randomFilter = [CIFilter filterWithName:@"CIRandomGenerator"];
        CIImage *randomImage = [CIFilter filterWithName:@"CIRandomGenerator"].outputImage;
        CIImage *otherRandomImage = [randomImage imageByApplyingTransform:CGAffineTransformMakeScale(1.5, 25.0)];
        
        CIFilter *whiteSpecks = [CIFilter filterWithName:@"CIColorMatrix" keysAndValues:kCIInputImageKey, randomImage,
                                 @"inputRVector", [CIVector vectorWithX:0.0 Y:1.0 Z:0.0 W:0.0],
                                 @"inputGVector", [CIVector vectorWithX:0.0 Y:1.0 Z:0.0 W:0.0],
                                 @"inputBVector", [CIVector vectorWithX:0.0 Y:1.0 Z:0.0 W:0.0],
                                 @"inputAVector", [CIVector vectorWithX:0.0 Y:0.01 Z:0.0 W:0.0],
                                 @"inputBiasVector", [CIVector vectorWithX:0.0 Y:0.0 Z:0.0 W:0.0],
                                 nil];
        CIFilter *darkScratches = [CIFilter filterWithName:@"CIColorMatrix" keysAndValues:kCIInputImageKey, otherRandomImage,
                                   @"inputRVector", [CIVector vectorWithX:3.659f Y:0.0 Z:0.0 W:0.0],
                                   @"inputGVector", [CIVector vectorWithX:0.0 Y:0.0 Z:0.0 W:0.0],
                                   @"inputBVector", [CIVector vectorWithX:0.0 Y:0.0 Z:0.0 W:0.0],
                                   @"inputAVector", [CIVector vectorWithX:0.0 Y:0.0 Z:0.0 W:0.0],
                                   @"inputBiasVector", [CIVector vectorWithX:0.0 Y:1.0 Z:1.0 W:1.0],
                                   nil];
        CIFilter *minimumComponent = [CIFilter filterWithName:@"CIMinimumComponent"];
        CIFilter *filterComposite = [CIFilter filterWithName:@"CIMultiplyCompositing"];
        
        if (sepiaFilter && randomFilter && whiteSpecks && darkScratches && minimumComponent && filterComposite) {
            CIImage *sepiaImage = sepiaFilter.outputImage;
            CIImage *whiteSpecksImage = [whiteSpecks.outputImage imageByCroppingToRect:sourceCIImage.extent];
            CIImage *sepiaPlusWhiteSpecksImage = [CIFilter filterWithName:@"CISourceOverComposting" keysAndValues:
                                                  kCIInputImageKey, whiteSpecksImage,
                                                  kCIInputBackgroundImageKey, sepiaImage,
                                                  nil].outputImage;
            CIImage *darkScratchesImage = [darkScratches.outputImage imageByCroppingToRect:sourceCIImage.extent];
            
            [minimumComponent setValue:darkScratchesImage forKey:kCIInputImageKey];
            darkScratchesImage = minimumComponent.outputImage;
            
            [filterComposite setValue:sepiaPlusWhiteSpecksImage forKey:kCIInputImageKey];
            [filterComposite setValue:darkScratchesImage forKey:kCIInputBackgroundImageKey];
            [self addCIImageToCollectionView:filterComposite.outputImage withFilterTitle:NSLocalizedString(@"Film", @"Film Filter")];
        }
    }];
    
    //Sunbeam Filter
    
    [self.photoFilterOperationQueue addOperationWithBlock:^{
        CIFilter *sunBeam = [CIFilter filterWithName:@"CISunbeamsGenerator"];
        
        CIFilter *filterComposite = [CIFilter filterWithName:@"CIMultiplyCompositing"];
        
        if (sunBeam) {
            [sunBeam setValue:[CIVector vectorWithX:200 Y:200] forKey:@"inputCenter"];
            [sunBeam setValue:[CIColor colorWithRed:1 green:1 blue:1 alpha:0.5] forKey:@"inputColor"];
            [sunBeam setValue:@100.0 forKey:@"inputSunRadius"];
            [sunBeam setValue:@0.50 forKey:@"inputStriationStrength"];
            [sunBeam setValue:@2.58 forKey:@"inputMaxStriationRadius"];
            [sunBeam setValue:@1.38 forKey:@"inputStriationContrast"];
            [sunBeam setValue:@0.00 forKey:@"inputTime"];
            
            [filterComposite setValue:sunBeam.outputImage forKey:kCIInputImageKey];
            [filterComposite setValue:sourceCIImage forKey:kCIInputBackgroundImageKey];
            
            CIImage *imagePlusSunbeam = filterComposite.outputImage;
            [self addCIImageToCollectionView:imagePlusSunbeam withFilterTitle:NSLocalizedString(@"Sunburst", @"Sunburst Filter")];
        }
    }];
}

- (void) addCIImageToCollectionView:(CIImage *)CIImage withFilterTitle:(NSString *)filterTitle {
    UIImage *image = [UIImage imageWithCIImage:CIImage scale:self.sourceImage.scale orientation:self.sourceImage.imageOrientation];
    
    if (image) {
        //decompress image
        UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
        [image drawAtPoint:CGPointZero];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSUInteger newIndex = self.filterImages.count;
            
            [self.filterImages addObject:image];
            [self.filterTitles addObject:filterTitle];
            
            [self.filterCollectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:newIndex inSection:0]]];
        });
    }
}

#pragma mark - Send to IG

- (void) sendToInstagramButtonPressed:(id)sender {
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://location?id=1"];
    
    UIAlertController *alertVC;
    
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        alertVC = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"Add a caption and send your image in the Instagram App.", @"send image instructions") preferredStyle:UIAlertControllerStyleAlert];
        [alertVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = NSLocalizedString(@"Caption", @"Caption");
        }];
        
        [alertVC addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"cancel button") style:UIAlertActionStyleCancel handler:nil]];
        [alertVC addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Send", @"send button") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UITextField *textField = alertVC.textFields[0];
            [self sendImageToInstagramWithCapation:textField.text];
        }]];
    } else {
        alertVC = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"No Instagram App", @"No app to open with name Instagram label") message:NSLocalizedString(@"Add a caption and send your image in the Instagram app.", @"send image instructions") preferredStyle:UIAlertControllerStyleAlert];
        [alertVC addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"Ok button") style:UIAlertActionStyleCancel handler:nil]];;
    }
    
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void) sendImageToInstagramWithCapation:(NSString *)caption {
    NSData *imageData = UIImageJPEGRepresentation(self.previewImageView.image, 0.9f);
    
    NSURL *tmpDirURL = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
    NSURL *fileURL = [[tmpDirURL URLByAppendingPathComponent:@"blocstagram"] URLByAppendingPathExtension:@"igo"];
    
    BOOL success = [imageData writeToURL:fileURL atomically:YES];
    
    if (!success) {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Couldn't Save the Image", @"nil") message:NSLocalizedString(@"Your cropped and filter photo couldn't be saved. Make sure you have enough disk space and try again.", nil) preferredStyle:UIAlertControllerStyleAlert];
        [alertVC addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK button") style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alertVC animated:YES completion:nil];
        return;
    }
    
    self.documentController = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
    self.documentController.UTI = @"com.instagram.exclusivegram";
    self.documentController.delegate = self;
    
    if (caption.length > 0) {
        self.documentController.annotation = @{@"InstagramCaption": caption};
    }
    
    if (self.sendToInstagramButton.superview) {
        [self.documentController presentOpenInMenuFromRect:self.sendToInstagramButton.bounds inView:self.sendToInstagramButton animated:YES];
    } else {
        [self.documentController presentOptionsMenuFromBarButtonItem:self.sendToInstagramBarButtonItem animated:YES];
    }
}

#pragma mark - UIDocumentInteractionControllerDelegate 
- (void) documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Buttons

- (NSAttributedString *) sendAttributedString {
    NSString *baseString = NSLocalizedString(@"SEND TO INSTAGRAM", @"send to instagram button text");
    NSRange range = [baseString rangeOfString:baseString];
    
    NSMutableAttributedString *commentString = [[NSMutableAttributedString alloc] initWithString:baseString];
    
    [commentString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:13] range:range];
    [commentString addAttribute:NSKernAttributeName value:@1.3 range:range];
    [commentString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.933 green:0.933 blue:0.933 alpha:1] range:range];
    
    return commentString;
}

@end
