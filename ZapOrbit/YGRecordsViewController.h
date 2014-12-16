//
//  YGRecordsViewController.h
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 15/04/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import "ListingRecord.h"
#import "VALabel.h"
#import "YGDetailItemController.h"
#import "YGHomeViewController.h"
#import "GCPlaceholderTextView.h"
#import "YGUserInfo.h"

@interface YGRecordsViewController : UIViewController <UITextViewDelegate> {
	@protected
	NSInteger pendingCount;
	NSInteger processingCount;
	NSInteger completedCount;
	NSInteger failedCount;
	NSNumberFormatter *priceFormatter;
	NSDateFormatter *dateFormater;
	GCPlaceholderTextView *textView;
	UITextView *dTextView;
	float deltaPosition;
	int feedbackNumberOfLines;
	UIView *feedbackView;
	YGUserInfo *userInfo;
	NSArray *completedFeedback;
	NSArray *failedFeedback;
	NSString *kApiUrl;
	NSURLSessionConfiguration *sessionConfig;
}

@property (strong, nonatomic) id scrollingObserver;
@property (strong, nonatomic) NSMutableDictionary *records;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

-(void)dismissViewCtrl:(id)sender;
-(void)giveFeedbackFromCompleted:(id)sender;
-(void)giveFeedbackFromFailed:(id)sender;

@end
