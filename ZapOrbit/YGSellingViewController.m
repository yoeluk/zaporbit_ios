//
//  YGSellingViewController.m
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 13/04/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import "YGSellingViewController.h"


@interface YGSellingViewController ()

@end

@implementation YGSellingViewController

- (void)viewDidLoad {
	[super viewDidLoad];
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

-(void) configureDetailView:(YGDetailItemController *)itemDetailViewCtrl  buyerId:(NSString *)buyerid {
    [itemDetailViewCtrl setBuyerId:@((int) [buyerid integerValue])];
}

- (IBAction)showInfo:(UIButton *)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"A buyer has requested to purchase this item. Verify the request and accept/reject purchasing." delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"OK", nil];
	[actionSheet showInView:self.view];
}

- (IBAction)acceptPurchasing:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Acepting this purchase will move it to the processing lane and alert the buyer that the item is ready for collecting/delivering upon payment." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Accept", nil];
	int transid = (int)[[(UILabel *)[[(UIButton *)sender superview] viewWithTag:101] text] integerValue];
	actionSheet.tag = transid;
	[actionSheet showInView:self.view];
}

- (IBAction)rejectPurchasing:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Rejecting this purchase will delete it permanently and will notify the buyer of the cancellation." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Reject" otherButtonTitles:nil];
	int transid = (int)[[(UILabel *)[[(UIButton *)sender superview] viewWithTag:101] text] integerValue];
	actionSheet.tag = transid;
	[actionSheet showInView:self.view];
}

- (IBAction)showProcessingInfo:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"You have confirmed the sale. Please arrange with the buyer to make the payment for the item." delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"OK", nil];
	actionSheet.tag = 0;
	[actionSheet showInView:self.view];
}

- (IBAction)completePuchasing:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Marking this action as completed will unlock rating for seller and for the buyer." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Mark as completed", nil];
	int transactionid = (int)[[(UILabel *)[[(UIButton *)sender superview] viewWithTag:101] text] integerValue];
	actionSheet.tag = transactionid;
	[actionSheet showInView:self.view];
}

- (IBAction)showCompletedInfo:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"The sale has been marked as completed. You can now rate the other party based on this transaction." delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"OK", nil];
	actionSheet.tag = 0;
	[actionSheet showInView:self.view];
}

- (IBAction)backdownPurchasing:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Backing down from the deal could result in negative feedback. Please ensure that you and the buyer are in agreement." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Back down" otherButtonTitles:nil];
	int transactionid = (int)[[(UILabel *)[[(UIButton *)sender superview] viewWithTag:101] text] integerValue];
	actionSheet.tag = transactionid;
	[actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Accept"] && actionSheet.tag) {
		NSURL *acceptURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@accepttransaction/%ld", kApiUrl, (long)actionSheet.tag]];
		NSURLSessionDataTask *session = [[NSURLSession sessionWithConfiguration:sessionConfig] dataTaskWithURL:acceptURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
			if ([(NSHTTPURLResponse *)response statusCode] == 200 && data) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[((YGHomeViewController *)[self.navigationController childViewControllers][self.navigationController.childViewControllers.count-2]) getUsersRecords:0];
					[self.navigationController popViewControllerAnimated:YES];
				});
			}
		}];
		[session resume];
	} else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Reject"]  && actionSheet.tag != 0) {
		NSURL *completeURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@canceltransaction/%ld", kApiUrl, (long)actionSheet.tag]];
		NSURLSessionDataTask *session = [[NSURLSession sessionWithConfiguration:sessionConfig] dataTaskWithURL:completeURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
			if ([(NSHTTPURLResponse *)response statusCode] == 200 && data) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[((YGHomeViewController *)[self.navigationController childViewControllers][self.navigationController.childViewControllers.count-2]) getUsersRecords:0];
					[self.navigationController popViewControllerAnimated:YES];
				});
			}
		}];
		[session resume];
	} else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Mark as completed"]  && actionSheet.tag != 0) {
		NSURL *completeURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@completetransaction/%ld", kApiUrl, (long)actionSheet.tag]];
		NSURLSessionDataTask *session = [[NSURLSession sessionWithConfiguration:sessionConfig] dataTaskWithURL:completeURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
			if ([(NSHTTPURLResponse *)response statusCode] == 200 && data) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[((YGHomeViewController *)[self.navigationController childViewControllers][self.navigationController.childViewControllers.count-2]) getUsersRecords:0];
					[self.navigationController popViewControllerAnimated:YES];
				});
			}
		}];
		[session resume];
	} else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Back down"]  && actionSheet.tag != 0) {
		NSURL *completeURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@backdownfromdeal/%ld", kApiUrl, (long)actionSheet.tag]];
		NSURLSessionDataTask *session = [[NSURLSession sessionWithConfiguration:sessionConfig] dataTaskWithURL:completeURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
			if ([(NSHTTPURLResponse *)response statusCode] == 200 && data) {
				dispatch_async(dispatch_get_main_queue(), ^{
					NSLog(@"transaction failed");
					[((YGHomeViewController *)[self.navigationController childViewControllers][self.navigationController.childViewControllers.count-2]) getUsersRecords:0];
					[self.navigationController popViewControllerAnimated:YES];
				});
			}
		}];
		[session resume];
	}
}

- (IBAction)giveFeedbackFromCompleted:(id)sender {
	[super giveFeedbackFromCompleted:sender];
}

- (IBAction)giveFeedbackFromFailed:(id)sender {
	[super giveFeedbackFromFailed:sender];
}

-(void)postFeedback:(NSString *)feedback withRating:(NSNumber *)rating forUser:(NSNumber *)userid forTransaction:(NSNumber *)transid {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"FeedbackEnded" object:nil];
	[self httpPostWithCustomDelegate:feedback withRating:rating forUser:userid forTransaction:transid];
}

-(void) httpPostWithCustomDelegate:(NSString *)feedback withRating:(NSNumber *)rating forUser:(NSNumber *)userid forTransaction:(NSNumber *)transid {
    
	NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
	
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@submitfeedback", kApiUrl]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	
	NSMutableDictionary *feedbackDict = [[NSMutableDictionary alloc] initWithCapacity:3];
	feedbackDict[@"feedback"] = feedback;
    feedbackDict[@"by_userid"] = @((int) self->userInfo.user.id);
	feedbackDict[@"userid"] = userid;
	feedbackDict[@"transid"] = transid;
	
	NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithCapacity:3];
	if (rating) {
		data[@"rating"] = rating;
	}
	data[@"feedback"] = feedbackDict;
	
	NSError *error = nil;
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:0 error:&error];
	NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]];
	
	[request setURL:url];
	[request setHTTPMethod:@"POST"];
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	[request setHTTPBody:jsonData];
	
    NSURLSessionDataTask * dataTask = [defaultSession dataTaskWithRequest:request
													    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
															if(error == nil && [(NSHTTPURLResponse *)response statusCode] == 200) {
																NSMutableDictionary *dataObj = (NSMutableDictionary *)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:nil];
																if ([dataObj[@"status"] isEqualToString:@"OK"]) {
																	NSLog(@"feedback successfully submitted: %@", dataObj);
																}
															}
															
														}];
    [dataTask resume];
}

@end
