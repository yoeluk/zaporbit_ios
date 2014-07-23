//
//  YGHomeViewController.h
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 21/03/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import <GooglePlus/GooglePlus.h>
#import "YGWebService.h"
#import "YGUserInfo.h"
#import "YGOvalView.h"
#import "AppSettings.h"
#import "YGAppDelegate.h"
#import "YGRatingView.h"

@class GPPSignInButton;

@interface YGHomeViewController : UITableViewController <FBLoginViewDelegate, WebServiceDelegate, GPPSignInDelegate> {
	YGUserInfo *userInfo;
	AppSettings *appSetting;
	YGRatingView *ratingView;
}

@property (strong, nonatomic) IBOutlet YGOvalView *ovalPicView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *loginButton;
- (IBAction)loginAction:(id)sender forEvent:(UIEvent *)event;

@property (strong, nonatomic) UIButton *signOutButton;
@property (strong, nonatomic) GPPSignInButton *signInButton;
@property (strong, nonatomic) GPPSignIn *signIn;
@property (strong, nonatomic) IBOutlet UIView *tableViewFooterView;

@property (strong, nonatomic) IBOutlet UIView *tableViewHeaderView;
@property (strong, nonatomic) FBLoginView *fbLoginView;
@property (strong, nonatomic) FBProfilePictureView *profilePictureView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;

-(void)getUsersRecords:(int)page;

@property (strong, nonatomic) UIProgressView *progressView;

@property (strong, nonatomic) NSMutableDictionary *records;
@end
