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

@interface MediaTableViewCell ()

@property (strong, nonatomic) UIImageView *mediaImageView;
@property (strong, nonatomic) UILabel *usernameAndCaptionLabel;
@property (strong, nonatomic) UILabel *commentLabel;

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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.mediaImageView = [[UIImageView alloc] init];
        self.usernameAndCaptionLabel = [[UILabel alloc] init];
        self.usernameAndCaptionLabel.numberOfLines = 0;
        self.usernameAndCaptionLabel.backgroundColor = usernameLabelGray;
        
        self.commentLabel = [[UILabel alloc] init];
        self.commentLabel.numberOfLines = 0;
        self.commentLabel.backgroundColor = commentLabelGray;
        
        for (UIView *view in @[self.mediaImageView, self.usernameAndCaptionLabel, self.commentLabel]) {
            [self.contentView addSubview:view];
        }
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
    layoutCell.frame = CGRectMake(0,0,width,CGFLOAT_MAX);
    layoutCell.mediaItem = mediaItem;
    [layoutCell layoutSubviews];
    
    return CGRectGetMaxY(layoutCell.commentLabel.frame);
    
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    if (self.mediaItem) {
        CGFloat imageHeight = ( self.mediaItem.image.size.height / self.mediaItem.image.size.width ) * CGRectGetWidth(self.contentView.bounds);
        self.mediaImageView.frame = CGRectMake(0, 0, CGRectGetWidth(self.contentView.bounds), imageHeight);
    }

    
    CGSize sizeOfUsernameAndCaptionLabel = [self sizeOfString:self.usernameAndCaptionLabel.attributedText];
    self.usernameAndCaptionLabel.frame = CGRectMake(0, CGRectGetMaxY(self.mediaImageView.frame), CGRectGetWidth(self.contentView.bounds), sizeOfUsernameAndCaptionLabel.height);
    
    CGSize sizeOfCommentLabel = [self sizeOfString:self.commentLabel.attributedText];
    self.commentLabel.frame = CGRectMake(0, CGRectGetMaxY(self.usernameAndCaptionLabel.frame), CGRectGetWidth(self.bounds), sizeOfCommentLabel.height);
    
    self.separatorInset = UIEdgeInsetsMake(0, CGRectGetWidth(self.bounds) / 2.0 , 0, CGRectGetWidth(self.bounds) / 2.0 );
}

- (CGSize) sizeOfString:(NSAttributedString *) string {
    CGSize maxSize = CGSizeMake(CGRectGetWidth(self.contentView.bounds) - 40, 0.0);
    CGRect sizeRect = [string boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    sizeRect.size.height += 20;
    sizeRect = CGRectIntegral(sizeRect);
    return sizeRect.size;
}

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
