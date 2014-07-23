//
//  YGConvoCollectionViewController.h
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 30/04/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YGUser.h"
#import "YGUserInfo.h"
#import "YGImage.h"
#import "YGRatingView.h"
#import "YGAppDelegate.h"


@interface YGConvoCollectionViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UITextViewDelegate, UICollectionViewDelegateFlowLayout, NSLayoutManagerDelegate> {
	@private
	NSDateFormatter *dateFormater;
	NSMutableArray *messagesHeights;
	YGImage *mePicImage;
	YGImage *uPicImage;
	UIBarButtonItem *upBarButton;
	UIBarButtonItem *downBarButton;
	YGUserInfo *userInfo;
	CATransition *textTransition;
	NSMutableArray *imageViewsOfMe;
	NSMutableArray *imageViewsOfU;
}



@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
- (IBAction)replyToConvo:(id)sender;

@property (strong, nonatomic) NSDictionary *details;
@property (strong, nonatomic) NSDictionary *conversation;
@property (strong, nonatomic) NSDictionary *convo;
@property (strong, nonatomic) NSArray *conversations;
@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) NSNumber *convid;
@property (strong, nonatomic) YGUser *toUser;
@property (strong, nonatomic) YGUser *me;
@property (strong, nonatomic) UICollectionViewFlowLayout *listLayout;
@end
