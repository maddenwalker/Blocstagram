//
//  ComposeCommentView.h
//  Blocstagram
//
//  Created by Ryan Walker on 10/22/15.
//  Copyright © 2015 Ryan Walker. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ComposeCommentView;

@protocol ComposeCommentViewDelegate <NSObject>

- (void) commentViewDidPressCommentButton:(ComposeCommentView *)sender;
- (void) commentView:(ComposeCommentView *)sender textDidChange:(NSString *)text;
- (void) commentWillStartEditing:(ComposeCommentView *)sender;

@end

@interface ComposeCommentView : UIView

@property (weak, nonatomic) NSObject <ComposeCommentViewDelegate> *delegate;
@property (assign, nonatomic) BOOL isWritingComment;
@property (strong, nonatomic) NSString *text;

- (void) stopComposingComment;

@end
