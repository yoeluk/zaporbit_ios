//
//  YGSellingViewController.h
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 13/04/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YGRecordsViewController.h"

@interface YGSellingViewController : YGRecordsViewController <UIActionSheetDelegate>

- (IBAction)showInfo:(id)sender;

- (IBAction)acceptPurchasing:(id)sender;
- (IBAction)rejectPurchasing:(id)sender;
- (IBAction)showProcessingInfo:(id)sender;
- (IBAction)completePuchasing:(id)sender;
- (IBAction)showCompletedInfo:(id)sender;
- (IBAction)backdownPurchasing:(id)sender;
- (IBAction)giveFeedbackFromCompleted:(id)sender;
- (IBAction)giveFeedbackFromFailed:(id)sender;


@end
