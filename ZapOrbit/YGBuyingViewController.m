//
//  YGBuyingViewController.m
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 13/04/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import "YGBuyingViewController.h"

@interface YGBuyingViewController ()

@end

@implementation YGBuyingViewController

- (void)viewDidLoad {
	[super viewDidLoad];
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (IBAction)showInfo:(UIButton *)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"We have contacted the seller and are waiting for a confirmation to procceed with the purchase." delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"OK", nil];
	actionSheet.tag = 0;
	[actionSheet showInView:self.view];
}

- (IBAction)requestCancellation:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Deleting this pending purchase will notify the seller that the purchase request has been retracted." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Ok, delete it" otherButtonTitles:nil];
	int transactionid = (int)[[(UILabel *)[[(UIButton *)sender superview] viewWithTag:101] text] integerValue];
	actionSheet.tag = transactionid;
	[actionSheet showInView:self.view];
}

- (IBAction)showProcessingInfo:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"The seller has confirmed the sale. Please arrange with the seller to make the payment and obtain your item." delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"OK", nil];
	actionSheet.tag = 0;
	[actionSheet showInView:self.view];
}

- (IBAction)completePuchasing:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Only the seller can mark a transaction as completed after they received payment and the item has changed hand. This action will remind the seller to do so." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Request completing", nil];
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
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Backing down from the deal could result in negative feedback. Please ensure that you and the seller are in agreement." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Back down" otherButtonTitles:nil];
	int transactionid = (int)[[(UILabel *)[[(UIButton *)sender superview] viewWithTag:101] text] integerValue];
	actionSheet.tag = transactionid;
	[actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Ok, delete it"] && actionSheet.tag != 0) {
		NSURL *delURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@canceltransaction/%ld", kApiUrl, (long)actionSheet.tag]];
		NSURLSessionDataTask *session = [[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]] dataTaskWithURL:delURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
			if ([(NSHTTPURLResponse *)response statusCode] == 200 && data) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[((YGHomeViewController *)[self.navigationController childViewControllers][self.navigationController.childViewControllers.count-2]) getUsersRecords:0];
					[self.navigationController popViewControllerAnimated:YES];
				});
			}
		}];
		[session resume];
	} else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Request completing"]  && actionSheet.tag != 0) {
		
//#warning Add code here to send a completing request
		
	} else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Back down"]  && actionSheet.tag != 0) {
		NSURL *completeURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@backdownfromdeal/%ld", kApiUrl, (long)actionSheet.tag]];
		NSURLSessionDataTask *session = [[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]] dataTaskWithURL:completeURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
			if ([(NSHTTPURLResponse *)response statusCode] == 200 && data) {
				NSLog(@"transaction failed");
				dispatch_async(dispatch_get_main_queue(), ^{
					[((YGHomeViewController *)[self.navigationController childViewControllers][self.navigationController.childViewControllers.count-2]) getUsersRecords:0];
					[self.navigationController popViewControllerAnimated:YES];
				});
			}
		}];
		[session resume];
	}
}

- (IBAction)giveFeedbackFromCompleted:(id)sender{
	[super giveFeedbackFromCompleted:sender];
}

- (IBAction)giveFeedbackFromFailed:(id)sender {
	[super giveFeedbackFromFailed:sender];
}

-(void)postFeedback:(NSString *)feedback withRating:(NSNumber *)rating forUser:(NSNumber *)userid forTransaction:(NSNumber *)transid {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"FeedbackEnded" object:nil];
	[self httpPostWithCustomDelegate:feedback withRating:rating forUser:userid forTransaction:(NSNumber *)transid];
}

-(void) httpPostWithCustomDelegate:(NSString *)feedback withRating:(NSNumber *)rating forUser:(NSNumber *)userid forTransaction:(NSNumber *)transid {
    
	NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
	
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@submitfeedback", kApiUrl]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	
	NSMutableDictionary *feedbackDict = [[NSMutableDictionary alloc] initWithCapacity:3];
	[feedbackDict setObject:feedback forKey:@"feedback"];
	[feedbackDict setObject:[NSNumber numberWithLong:self->userInfo.user.id] forKey:@"by_userid"];
	[feedbackDict setObject:userid forKey:@"userid"];
	[feedbackDict setObject:transid forKey:@"transid"];
	
	NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithCapacity:3];
	if (rating) {
		[data setObject:rating forKey:@"rating"];
	}
	[data setObject:feedbackDict forKey:@"feedback"];
    
	//NSString * params =@"name=Ravi&loc=India&age=31&submit=true";
    //[urlRequest setHTTPMethod:@"POST"];
    //[urlRequest setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
	
	NSError *error = nil;
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:0 error:&error];
	NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]];
	
	[request setURL:url];
	[request setHTTPMethod:@"POST"];
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
	[request setHTTPBody:jsonData];
	
    NSURLSessionDataTask * dataTask = [defaultSession dataTaskWithRequest:request
													    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
															NSMutableDictionary *dataObj = (NSMutableDictionary *)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:nil];
														   if(error == nil && [(NSHTTPURLResponse *)response statusCode] == 200) {
															   if ([dataObj[@"status"] isEqualToString:@"OK"]) {
																	NSLog(@"feedback successfully submitted: %@", dataObj);
															   }
														   }
														   
													   }];
    [dataTask resume];
}

@end
