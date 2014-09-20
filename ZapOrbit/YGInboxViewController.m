//
//  YGInboxViewController.m
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 25/04/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import "YGInboxViewController.h"
#import "YGConvoCollectionViewController.h"

@interface YGInboxViewController ()

@end

@implementation YGInboxViewController
@synthesize conversations = _conversations;

-(void)setConversations:(NSMutableArray *)conversations {
	_conversations = conversations;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	userInfo = [YGUserInfo sharedInstance];
	
	self->kUrlHead = [YGWebService baseApiUrl];
	
	self->appSettings = [(YGAppDelegate *)[[UIApplication sharedApplication] delegate] appSettings];
	
	/*
	CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0.0f, 0.0f, self.tableView.frame.size.width, 0.5f);
    topBorder.backgroundColor = [UIColor lightGrayColor].CGColor;
	[self.tableView.layer addSublayer:topBorder];
	*/
	
	self.tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
	
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
	[self sortConverstionsUnreadFirst:self.conversations];
	
	UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	infoLabel.font = [UIFont systemFontOfSize:12];
	infoLabel.text = @"";
	infoLabel.textAlignment = NSTextAlignmentCenter;
	[infoLabel sizeToFit];
	
	self.toolbarInfoView.customView = infoLabel;
	
	self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, -2, self.tableView.frame.size.width, 2)];
	self.progressView.tag = 15;
	self.progressView.hidden = YES;
	self.progressView.progress = 0.0f;
	
	[self.tableView addSubview:self.progressView];
	
	self->textTransition = [CATransition animation];
	self->textTransition.duration = 0.3;
	self->textTransition.type = kCATransitionFade;
	self->textTransition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
}

-(void)updateInfoView:(id)sender {
	NSString *timeString = [self->appSettings.dataRetrievalDate formattedDateRelativeToNow:self->appSettings.dataRetrievalDate];
	[((UILabel *)self.toolbarInfoView.customView).layer addAnimation:self->textTransition forKey:@"changeTextTransition"];
	[(UILabel *)self.toolbarInfoView.customView setText:[NSString stringWithFormat:@"Updated %@ Ago", timeString]];
	[(UILabel *)self.toolbarInfoView.customView sizeToFit];
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(swipedCellToDelete:) name:@"swipeToDeleteDetected" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endedSwipeCellToDelete:) name:@"endedSwipeToDeleteDetected" object:nil];
	if (self.conversations.count == 0 && ![self.tableView viewWithTag:88]) {
		[self emptyTableViewUI:self.tableView];
	} else if (self.conversations.count > 0) [[self.tableView viewWithTag:88] removeFromSuperview];
}

-(void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)endedSwipeCellToDelete:(NSNotification *)note {
	[self setEditing:NO];
}

-(void)swipedCellToDelete:(NSNotification *)note {
	[self setEditing:YES];
}

-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self updateConversations:0];
}

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
	return UIBarPositionBottom;
}

-(void)emptyTableViewUI:(UITableView *)tableView {
	UILabel *emptyMessage = [[UILabel alloc] initWithFrame:CGRectMake((self.tableView.frame.size.width/2)-50, (self.tableView.frame.size.height/2)-self.tableView.contentInset.top, self.tableView.frame.size.width, 30)];
	emptyMessage.text = @"None Found";
	emptyMessage.textColor = [UIColor lightGrayColor];
	emptyMessage.tag = 88;
	emptyMessage.font = [UIFont boldSystemFontOfSize:18];
	[tableView addSubview:emptyMessage];
}

-(void)sortConverstionsUnreadFirst:(NSArray *)unsorted {
	//
	NSMutableArray *sortedConvos = [[NSMutableArray alloc] initWithCapacity:5];
	for (int i = 0; i < unsorted.count; ++i) {
		NSArray *messages = [[unsorted[(NSUInteger) i] objectForKey:@"conversation"] objectForKey:@"messages"];
		if ([[messages[0] objectForKey:@"received_status"] isEqualToString:@"unread"] && [[messages[0] objectForKey:@"senderid"] longLongValue] != userInfo.user.id) {
            [sortedConvos insertObject:unsorted[(NSUInteger) i] atIndex:0];
			//[sortedConvos addObject:[unsorted objectAtIndex:i]];
		} else {
            [sortedConvos addObject:unsorted[(NSUInteger) i]];
			//[sortedConvos insertObject:[unsorted objectAtIndex:i] atIndex:0];
		}
	}
	self.conversations = sortedConvos;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:YES];
}

-(void)updateConversations:(int)page {
	if (userInfo.user) {
		NSURL *readURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@getconversationsforuser/%d/%ld", kUrlHead, page, (unsigned long)userInfo.user.id]];
		NSURLSessionDataTask *session = [[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]] dataTaskWithURL:readURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
		   if (data) {
			   NSMutableDictionary *dataObj = (NSMutableDictionary *)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:nil];
			   if (dataObj && [dataObj[@"status"] isEqualToString:@"OK"]) {
                   [self sortConverstionsUnreadFirst:dataObj[@"conversations"]];
				   self->appSettings.dataRetrievalDate = [NSDate date];
				   dispatch_async(dispatch_get_main_queue(), ^{
					   [self.progressView setProgress:1.0f animated:YES];
					   [self performSelector:@selector(refreshUI) withObject:nil afterDelay:0.5f];
				   });
			   }
		   }
		}];
		[session resume];
		[self.progressView setHidden:NO];
		[self.progressView setProgress:0.4 animated:YES];
		[((UILabel *)self.toolbarInfoView.customView).layer addAnimation:self->textTransition forKey:@"changeTextTransition"];
		[(UILabel *)self.toolbarInfoView.customView setText:@"Checking Messages..."];
		[(UILabel *)self.toolbarInfoView.customView sizeToFit];
	}
}

-(void)refreshUI {
	[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
	[self.progressView setHidden:YES];
	self.progressView.progress = 0.0f;
	[((UILabel *)self.toolbarInfoView.customView).layer addAnimation:self->textTransition forKey:@"changeTextTransition"];
	[(UILabel *)self.toolbarInfoView.customView setText:@"Updated Just Now"];
	[self->updateInfoTimer invalidate];
	self->updateInfoTimer = [NSTimer scheduledTimerWithTimeInterval:65.0f target:self selector:@selector(updateInfoView:) userInfo:nil repeats:YES];
	if (self.conversations.count == 0 && ![self.tableView viewWithTag:88]) {
		[self emptyTableViewUI:self.tableView];
	} else if (self.conversations.count > 0) [[self.tableView viewWithTag:88] removeFromSuperview];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
	if (-scrollView.contentOffset.y > 125) {
		[self updateConversations:0];
	}
}

-(void)deleteConvoOnServer:(NSDictionary *)convo fromIndexPath:(NSIndexPath *)indexPath {
	
	NSURL *readURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@leaveconvo/%lld/%ld", kUrlHead,
												[[convo[@"conversation"] objectForKey:@"id"] longLongValue], (unsigned long)userInfo.user.id]];
	NSURLSessionDataTask *session = [[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]] dataTaskWithURL:readURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
		if (data) {
		   NSDictionary *dataObj = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:nil];
		   if (dataObj && [dataObj[@"status"] isEqualToString:@"OK"]) {
			   dispatch_async(dispatch_get_main_queue(), ^{
				   [self.tableView reloadData];
			   });
		   } else {
			   dispatch_async(dispatch_get_main_queue(), ^{
                   [self.conversations insertObject:convo atIndex:(NSUInteger) indexPath.row];
				   [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
			   });
		   }
		} else {
			dispatch_async(dispatch_get_main_queue(), ^{
                [self.conversations insertObject:convo atIndex:(NSUInteger) indexPath.row];
				[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
			});
		}
	}];
	[session resume];
}

#pragma mark - Table view data source and delegate

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		id deletedConvo = self.conversations[(NSUInteger) indexPath.row];
        [self.conversations removeObjectAtIndex:(NSUInteger) indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
		[self deleteConvoOnServer:deletedConvo fromIndexPath:indexPath];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	float height = 74
	;
	return height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.conversations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *cellIndentifier = @"Cell";
	
    UITableViewCell *cell;
	UILabel *headingLabel;
	UILabel *reLabel;
	UILabel *messageLabel;
	NSDictionary *convo;
	NSArray *messages;
	NSDictionary *newestMessage;
	NSDictionary *conversation;
	NSDictionary *user1;
	NSDictionary *user2;
	NSString *heading;
	NSMutableAttributedString *attributedHeading;
	NSMutableAttributedString *attributedStrCount;
	
	NSMutableDictionary *headingAttrs;
	NSMutableDictionary *countAttrs;
	
	switch (indexPath.section) {
		case 0:
			cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier forIndexPath:indexPath];
			
			convo = (self.conversations)[(NSUInteger) indexPath.row];
			conversation = convo[@"conversation"];
			messages = conversation[@"messages"];
			newestMessage = messages[messages.count - 1];
			user1 = convo[@"user1"];
			user2 = convo[@"user2"];
			
			headingLabel = (UILabel *)[cell.contentView viewWithTag:10];
			reLabel = (UILabel *)[cell.contentView viewWithTag:20];
			messageLabel = (UILabel *)[cell.contentView viewWithTag:30];
			
			headingAttrs = [[NSMutableDictionary alloc] initWithCapacity:3];
			headingAttrs[NSFontAttributeName] = [UIFont systemFontOfSize:20];
			headingAttrs[NSForegroundColorAttributeName] = [UIColor grayColor];
            headingAttrs[NSBaselineOffsetAttributeName] = @(-1);
			
			if ([messages count]) {
				messageLabel.text = newestMessage[@"message"];
			}
			if ([newestMessage[@"senderid"] longLongValue] == userInfo.user.id) {
				if ([newestMessage[@"senderid"] longLongValue] == [user2[@"id"] longLongValue]) {
					heading = [NSString stringWithFormat:@"me \u00BB %@ %@", user1[@"name"], user1[@"surname"]];
				} else heading = [NSString stringWithFormat:@"me \u00BB %@ %@", user2[@"name"], user2[@"surname"]];
				attributedHeading = [[NSMutableAttributedString alloc] initWithString:heading];
				[attributedHeading setAttributes:headingAttrs range:NSMakeRange(3, 2)];
			} else {
				if ([newestMessage[@"senderid"] longLongValue] == [user2[@"id"] longLongValue]) {
					heading = [NSString stringWithFormat:@"%@ %@ \u00BB me", user2[@"name"], user2[@"surname"]];
				} else heading = [NSString stringWithFormat:@"%@ %@ \u00BB me", user1[@"name"], user1[@"surname"]];
				attributedHeading = [[NSMutableAttributedString alloc] initWithString:heading];
				[attributedHeading setAttributes:headingAttrs range:NSMakeRange(heading.length-5, 2)];
			}
			if ([messages count] > 1) {
				int count = 1;
				for (NSDictionary *message in messages) {
					if ([message[@"senderid"] longLongValue] == [newestMessage[@"senderid"] longLongValue]) {
						++count;
					}
				}
				if (count > 1) {
					attributedStrCount = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"  %d", count]];
					countAttrs = [[NSMutableDictionary alloc] initWithCapacity:3];
					countAttrs[NSFontAttributeName] = [UIFont systemFontOfSize:13];
					countAttrs[NSForegroundColorAttributeName] = [UIColor grayColor];
                    countAttrs[NSBaselineOffsetAttributeName] = @0;
					[attributedStrCount setAttributes:countAttrs range:NSMakeRange(0, attributedStrCount.length)];
					[attributedHeading appendAttributedString:attributedStrCount];
				}
			}
			
			if ([newestMessage[@"received_status"] isEqualToString:@"unread"] && [newestMessage[@"senderid"] longLongValue] != userInfo.user.id)
				headingLabel.textColor = [UIColor colorWithRed:0 green:112/255.f blue:1 alpha:1];
			else
				headingLabel.textColor = [UIColor blackColor];
			
			
			headingLabel.attributedText = attributedHeading;
			reLabel.text = [NSString stringWithFormat:@"re: %@", conversation[@"title"]];
			
			if (indexPath.row == 0) {
				
			}
			
			break;
		default:
			break;
	}
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSDictionary *convo;
	NSDictionary *conversation;
	NSArray *messages;
	NSDictionary *user1;
	NSDictionary *user2;
	convo = (self.conversations)[(NSUInteger) indexPath.row];
	conversation = convo[@"conversation"];
	messages = conversation[@"messages"];
	user1 = convo[@"user1"];
	user2 = convo[@"user2"];
	BOOL foundUnread = false;
	for (NSMutableDictionary *message in messages) {
		if ([message[@"received_status"] isEqualToString:@"unread"] && [[messages[0] objectForKey:@"senderid"] longLongValue] != userInfo.user.id) {
			foundUnread = true;
			break;
		}
	}
	if (foundUnread) {
		NSURL *readURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@markconvoread/%lld", kUrlHead,
														[[[(self.conversations)[(NSUInteger) indexPath.row] objectForKey:@"conversation"] objectForKey:@"id"] longLongValue]]];
		NSURLSessionDataTask *session = [[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]] dataTaskWithURL:readURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
			if (data) {
				NSDictionary *dataObj = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:nil];
				if (dataObj && [dataObj[@"status"] isEqualToString:@"OK"]) {
					
					for (NSMutableDictionary *message in messages) {
						if ([message[@"received_status"] isEqualToString:@"unread"] && [message[@"senderid"] longLongValue] != userInfo.user.id) {
							message[@"received_status"] = @"read";
						}
					}
					dispatch_async(dispatch_get_main_queue(), ^{
						[self.tableView reloadData];
					});
				}
			} else NSLog(@"no data");
		}];
		[session resume];
	}
	NSMutableDictionary *convoDetails = [[NSMutableDictionary alloc] initWithCapacity:3];
	if ([user1[@"id"] longLongValue] == userInfo.user.id) {
		convoDetails[@"toUser"] = user2;
	} else convoDetails[@"toUser"] = user1;
	convoDetails[@"me"] = userInfo.user;
    convoDetails[@"convid"] = conversation[@"id"];
	convoDetails[@"convo"] = convo;
	convoDetails[@"allConversations"] = self.conversations;
	convoDetails[@"messages"] = messages;
	[self performSegueWithIdentifier:@"convoColSegue" sender:convoDetails];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"convoSegue"] || [segue.identifier isEqualToString:@"convoColSegue"]) {
		[[segue destinationViewController] setDetails:sender];
	}
}


@end
