//
//  MediaTableViewCell.m
//  Blocstagram
//
//  Created by Ryan Walker on 10/7/15.
//  Copyright © 2015 Ryan Walker. All rights reserved.
//

#import "MediaTableViewCell.h"
#import "Media.h"
#import "Comment.h"
#import "User.h"

@interface MediaTableViewCell () <UIGestureRecognizerDelegate>

@property (strong, nonatomic) UIImageView *mediaImageView;
@property (strong, nonatomic) UILabel *usernameAndCaptionLabel;
@property (strong, nonatomic) UILabel *commentLabel;
@property (strong, nonatomic) NSLayoutConstraint *imageHeightConstraint;
@property (strong, nonatomic) NSLayoutConstraint *usernameAndCaptionLabelHeightConstraint;
@property (strong, nonatomic) NSLayoutConstraint *commentLabelHeightConstraint;

@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;

@end

static UIFont *lightFont;
static UIFont *boldFont;
static NSNumber *captionKerning;
static UIColor *usernameLabelGray;
static UIColor *commentLabelGray;
static UIColor *firstCommentColorOrange;
static UIColor *linkColor;
static NSParagraphStyle *paragraphStyle;
static NSParagraphStyle *otherCommentsParagraphStyle;

@implementation MediaTableViewCell

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.mediaImageView = [[UIImageView alloc] init];
        self.mediaImageView.userInteractionEnabled = YES;
        
        self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFired:)];
        self.tapGestureRecognizer.delegate = self;
        [self.mediaImageView addGestureRecognizer:self.tapGestureRecognizer];
        
        self.usernameAndCaptionLabel = [[UILabel alloc] init];
        self.usernameAndCaptionLabel.numberOfLines = 0;
        self.usernameAndCaptionLabel.backgroundColor = usernameLabelGray;
        
        self.commentLabel = [[UILabel alloc] init];
        self.commentLabel.numberOfLines = 0;
        self.commentLabel.backgroundColor = commentLabelGray;
        
        for (UIView *view in @[self.mediaImageView, self.usernameAndCaptionLabel, self.commentLabel]) {
            [self.contentView addSubview:view];
            view.translatesAutoresizingMaskIntoConstraints = NO;
        }
        
        NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_mediaImageView, _usernameAndCaptionLabel, _commentLabel);
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_mediaImageView]|"
                                                                                 options:kNilOptions
                                                                                 metrics:nil
                                                                                   views:viewDictionary]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_usernameAndCaptionLabel]|"
                                                                                 options:kNilOptions
                                                                                 metrics:nil
                                                                                   views:viewDictionary]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_commentLabel]|"
                                                                                 options:kNilOptions
                                                                                 metrics:nil
                                                                                   views:viewDictionary]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_mediaImageView][_usernameAndCaptionLabel][_commentLabel]"
                                                                                 options:kNilOptions
                                                                                 metrics:nil
                                                                                   views:viewDictionary]];
        
        self.imageHeightConstraint = [NSLayoutConstraint constraintWithItem:_mediaImageView
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1
                                                                   constant:100];
        
        self.imageHeightConstraint.identifier = @"Image height constraint";
        
        
        self.usernameAndCaptionLabelHeightConstraint = [NSLayoutConstraint constraintWithItem:_usernameAndCaptionLabel
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1
                                                                   constant:100];
        
        self.usernameAndCaptionLabelHeightConstraint.identifier = @"Username and caption Label height constraint";
        
        self.commentLabelHeightConstraint = [NSLayoutConstraint constraintWithItem:_commentLabel
                                                                                    attribute:NSLayoutAttributeHeight
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:nil
                                                                                    attribute:NSLayoutAttributeNotAnAttribute
                                                                                   multiplier:1
                                                                                     constant:100];
        
        self.usernameAndCaptionLabelHeightConstraint.identifier = @"Comment Label height constraint";
        
        [self.contentView addConstraints:@[self.imageHeightConstraint, self.usernameAndCaptionLabelHeightConstraint, self.commentLabelHeightConstraint]];

        
    }
    
    return self;
}

+ (void) load {
    lightFont = [UIFont fontWithName:@"HelveticaNeue-Thin" size:11];
    boldFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:11];
    captionKerning = [NSNumber numberWithFloat:1];
    usernameLabelGray = [UIColor colorWithRed:0.933 green:0.933 blue:0.933 alpha:1];
    commentLabelGray = [UIColor colorWithRed:0.898 green:0.898 blue:0.898 alpha:1];
    linkColor = [UIColor colorWithRed:0.345 green:0.314 blue:0.427 alpha:1];
    firstCommentColorOrange = [UIColor colorWithRed: 239.0 / 255.0 green: 144.0 / 255.0 blue: 0.0 alpha:1];
    
    NSMutableParagraphStyle *mutableParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    mutableParagraphStyle.headIndent = 20.0;
    mutableParagraphStyle.firstLineHeadIndent = 20.0;
    mutableParagraphStyle.tailIndent = -20.0;
    mutableParagraphStyle.paragraphSpacingBefore = 5;
    
    paragraphStyle = mutableParagraphStyle;
    
    NSMutableParagraphStyle *otherCommentMutableParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    otherCommentMutableParagraphStyle.alignment = 2;
    otherCommentMutableParagraphStyle.headIndent = 20.0;
    otherCommentMutableParagraphStyle.firstLineHeadIndent = 20.0;
    otherCommentMutableParagraphStyle.tailIndent = -20.0;
    otherCommentMutableParagraphStyle.paragraphSpacingBefore = 5;
    
    otherCommentsParagraphStyle = otherCommentMutableParagraphStyle;
}

- (void) setMediaItem:(Media *)mediaItem {
    _mediaItem = mediaItem;
    self.mediaImageView.image = _mediaItem.image;
    self.usernameAndCaptionLabel.attributedText = [self usernameAndCaptionString];
    self.commentLabel.attributedText = [self commentString];
}

+ (CGFloat) heightForMediaItem:(Media *)mediaItem width:(CGFloat)width {
    
    MediaTableViewCell *layoutCell = [[MediaTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"layoutCell"];
    layoutCell.mediaItem = mediaItem;
    layoutCell.frame = CGRectMake(0, 0, width, CGRectGetHeight(layoutCell.frame));
    [layoutCell setNeedsLayout];
    [layoutCell layoutIfNeeded];
    
    return CGRectGetMaxY(layoutCell.commentLabel.frame);
    
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    CGSize maxSize = CGSizeMake(CGRectGetWidth(self.bounds), CGFLOAT_MAX);
    CGSize usernameLabelSize = [self.usernameAndCaptionLabel sizeThatFits:maxSize];
    CGSize commentLabelSize = [self.commentLabel sizeThatFits:maxSize];
    
    
    if (usernameLabelSize.height > 0) {
        self.usernameAndCaptionLabelHeightConstraint.constant = usernameLabelSize.height + 20;
    }
    
    if (commentLabelSize.height > 0) {
        self.commentLabelHeightConstraint.constant = commentLabelSize.height + 20;
    }
    
    if (self.mediaItem.image.size.width > 0 && CGRectGetWidth(self.contentView.bounds) > 0) {
        self.imageHeightConstraint.constant = self.mediaItem.image.size.height / self.mediaItem.image.size.width * CGRectGetWidth(self.contentView.bounds);
    }
    
    self.separatorInset = UIEdgeInsetsMake(0, CGRectGetWidth(self.bounds) / 2.0 , 0, CGRectGetWidth(self.bounds) / 2.0 );
}

- (void) setHighlighted:(BOOL)highlighted {
    [super setHighlighted:NO];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:NO animated:animated];
    
    // Configure the view for the selected state
}

#pragma mark - UIImage View

- (void) tapFired:(UITapGestureRecognizer *)sender {
    [self.delegate cell:self didTapImageView:self.mediaImageView];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(nonnull UITouch *)touch {
    return self.isEditing == NO;
}

#pragma mark - formatting of strings

- (NSAttributedString *) usernameAndCaptionString {
    CGFloat usernameFontSize = 15;
    
    NSString *baseString = [NSString stringWithFormat:@"%@ %@", self.mediaItem.user.userName, self.mediaItem.caption];
    
    NSMutableAttributedString *mutableUsernameAndCaptionString = [[NSMutableAttributedString alloc] initWithString:baseString attributes:@{NSFontAttributeName : [lightFont fontWithSize:usernameFontSize], NSParagraphStyleAttributeName : paragraphStyle}];
    
    NSRange usernameRange = [baseString rangeOfString:self.mediaItem.user.userName];
    NSRange captionRange = NSMakeRange(usernameRange.length, [baseString length] - usernameRange.length);
    
    [mutableUsernameAndCaptionString addAttribute:NSFontAttributeName value:[boldFont fontWithSize:usernameFontSize] range:usernameRange];
    [mutableUsernameAndCaptionString addAttribute:NSForegroundColorAttributeName value:linkColor range:usernameRange];
    [mutableUsernameAndCaptionString addAttribute:NSKernAttributeName value:captionKerning range:captionRange];
    
    return mutableUsernameAndCaptionString;
}

- (NSAttributedString *) commentString {
    NSMutableAttributedString *commentString = [[NSMutableAttributedString alloc] init];
    
    for (Comment *comment in self.mediaItem.comments) {
        NSString *baseString = [NSString stringWithFormat:@"%@ %@\n", comment.from.userName, comment.text];
        NSRange usernameRange = [baseString rangeOfString:comment.from.userName];
        NSRange commentRange = NSMakeRange(usernameRange.length, [baseString length] - usernameRange.length);
        
        NSMutableAttributedString *oneCommentString = [[NSMutableAttributedString alloc] initWithString:baseString attributes:@{NSFontAttributeName : lightFont, NSParagraphStyleAttributeName : paragraphStyle}];
        
        if ([self.mediaItem.comments indexOfObject:comment] == 0 ) {
            [oneCommentString addAttribute:NSForegroundColorAttributeName value:firstCommentColorOrange range:commentRange];

        }
        
        if ( ( [self.mediaItem.comments indexOfObject:comment] % 2 ) != 0 ) {
            [oneCommentString addAttribute:NSParagraphStyleAttributeName value:otherCommentsParagraphStyle range:NSMakeRange(0, [oneCommentString length])];
        }
        
        //check to see if odd or even comments and align differently; perhaps using modulo?
        
        [oneCommentString addAttribute:NSFontAttributeName value:boldFont range:usernameRange];
        [oneCommentString addAttribute:NSForegroundColorAttributeName value:linkColor range:usernameRange];
        
        [commentString appendAttributedString:oneCommentString];
    }
    
    return commentString;
}

@end
