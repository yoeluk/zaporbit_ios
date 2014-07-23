//
//  YGComposerViewController.h
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 26/04/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YGUser.h"
#import "YGWebService.h"
#import "ListingRecord.h"


@interface YGComposerViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, WebServiceDelegate, NSLayoutManagerDelegate> {
	@private
	ListingRecord *listing;
	NSString *message;
	UIProgressView *progressView;
	NSNumber *convid;
	NSString *convoTitle;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSNumber *replying;

@property (strong, nonatomic) NSDictionary *details;
@property (strong, nonatomic) YGUser *toUser;
@property (strong, nonatomic) YGUser *me;
@end
