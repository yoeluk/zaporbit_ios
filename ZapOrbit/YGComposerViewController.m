//
//  YGComposerViewController.m
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 26/04/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import "YGComposerViewController.h"
#import "GCPlaceholderTextView.h"

@interface YGComposerViewController ()

@end

@implementation YGComposerViewController
@synthesize details = _details;
@synthesize replying = _replying;

/*
- (id) initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
		//configure self
	}
	return self;
}
*/

-(void) setDetails:(NSDictionary *)details {
	_details = details;
}

-(void)setReplying:(NSNumber *)replying {
	_replying = replying;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0.0f, 0.0f, self.tableView.frame.size.width, 0.5f);
    topBorder.backgroundColor = [UIColor lightGrayColor].CGColor;
	[self.tableView.layer addSublayer:topBorder];
	
	self->progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, -2, self.tableView.frame.size.width, 2)];
	self->progressView.tag = 15;
	self->progressView.hidden = YES;
	self->progressView.progress = 0.0f;
	[self.tableView addSubview:self->progressView];
	
	self.toUser = (self.details)[@"toUser"];
	self.me = (self.details)[@"me"];
	if (![self.replying boolValue]) {
		UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStyleDone target:self action:@selector(sendStartConversation:)];
		[self.navigationItem setRightBarButtonItem:rightBarButton];
		self->listing = (self.details)[@"listing"];
	} else {
		self.navigationItem.rightBarButtonItem.action = @selector(replyToConvo:);
		self.navigationItem.rightBarButtonItem.target = self;
		self->convid = (self.details)[@"convid"];
		self->convoTitle = (self.details)[@"title"];
	}
	self.navigationItem.rightBarButtonItem.enabled = NO;
}

-(void)awakeFromNib {
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillShow:)
												 name:UIKeyboardWillShowNotification
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillHide:)
												 name:UIKeyboardWillHideNotification
											   object:nil];
}

-(void)keyboardWillShow:(NSNotification *)aNotification {
	CGRect aRect = [[aNotification userInfo][UIKeyboardFrameEndUserInfoKey] CGRectValue];
	self.tableView.contentInset = UIEdgeInsetsMake(64, 0, aRect.size.height-44, 0);
	self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(64, 0, aRect.size.height-44, 0);
}

-(void)keyboardWillHide:(NSNotification *)aNotification {
	self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
	self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(64, 0, 0, 0);;
}

-(void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)coughRequestedData:(NSData *)data {
	NSMutableArray *response = (NSMutableArray *)[NSJSONSerialization JSONObjectWithData:data
																				 options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves
																				   error:nil];
	NSLog(@"response: %@", response);
	[self->progressView setProgress:1.0f animated:YES];
	[NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(refreshUI:) userInfo:nil repeats:NO];
}

-(void)replyToConvo:(id)sender {
	if (self->message) {
		[self->progressView setHidden:NO];
		[self->progressView setProgress:0.4 animated:YES];
		
		NSDictionary *messageDict = @{@"received_status" : @"unread", @"senderid" : @(self.me.id), @"recipientid" : @(self.toUser.id), @"convid" : self->convid, @"message" : self->message};
		YGWebService *ws = [YGWebService initWithDelegate:self];
		[ws startConversation:messageDict
				  withService:@"replytoconvo"
					andMethod:@"POST"];
		[self.view endEditing:YES];
	}
}

-(void)sendStartConversation:(id)sender {
	if (self->message) {
		[self->progressView setHidden:NO];
		[self->progressView setProgress:0.4 animated:YES];
		NSDictionary *convo = @{@"user1_status" : @"online", @"user2_status" : @"online", @"user1id" : @(self.me.id), @"user2id" : @(self.toUser.id), @"offerid" : self->listing.id, @"title" : self->listing.title};
		YGWebService *ws = [YGWebService initWithDelegate:self];
		[ws startConversation:@{@"conversation" : convo, @"message" : self->message}
				  withService:@"startconversation"
					andMethod:@"POST"];
		[self.view endEditing:YES];
	}
}

-(void)refreshUI:(id)sender {
	[self->progressView setHidden:YES];
	self->progressView.progress = 0.0f;
	
	// dismiss self
	id target = self.navigationItem.leftBarButtonItem.target;
	SEL selector = self.navigationItem.leftBarButtonItem.action;
	IMP imp = [target methodForSelector:selector];
	void (*func)(id, SEL) = (void *)imp;
	func(target, selector);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	float height;
	switch (indexPath.row) {
		case 0:
			height = 44;
			break;
		case 1:
			height = 35;
			break;
		case 2:
			height = 450;
			break;
		default:
			height = 64;
			break;
	}
	return height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *cellIndentifier = @"Cell";
	static NSString *reCellIndentifier = @"reCell";
	
    UITableViewCell *cell;
	NSMutableDictionary *attrs;
	NSMutableAttributedString *toAttrString;
	GCPlaceholderTextView *messageTextView;
	
	switch (indexPath.section) {
			
		case 0:
			
			if (indexPath.row == 0) {
				
				cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier forIndexPath:indexPath];
				
				attrs = [[NSMutableDictionary alloc] initWithCapacity:3];
				attrs[NSFontAttributeName] = [UIFont systemFontOfSize:15];
				cell.textLabel.font = [UIFont systemFontOfSize:15];
				cell.textLabel.textColor = [UIColor colorWithWhite:0.3 alpha:1];
				
				attrs[NSForegroundColorAttributeName] = [UIColor colorWithRed:0 green:112 / 255.f blue:1 alpha:1];
				
				NSDictionary *senderAttrs = @{NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle)};
				NSMutableAttributedString *senderAttrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", self.toUser.name, self.toUser.surname]];
				[senderAttrString setAttributes:senderAttrs range:NSMakeRange(0, senderAttrString.length)];
				toAttrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"to: "]];
				[toAttrString setAttributes:attrs range:NSMakeRange(0, 3)];
				[toAttrString appendAttributedString:senderAttrString];
				cell.textLabel.attributedText = toAttrString;
				
			} else if (indexPath.row == 1) {
				
				cell = [tableView dequeueReusableCellWithIdentifier:reCellIndentifier forIndexPath:indexPath];
				
				attrs = [[NSMutableDictionary alloc] initWithCapacity:3];
				attrs[NSFontAttributeName] = [UIFont systemFontOfSize:15];
				UILabel *reLabel = (UILabel *)[cell.contentView viewWithTag:44];
				reLabel.font = [UIFont systemFontOfSize:15];
				reLabel.textColor = [UIColor colorWithWhite:0.3 alpha:1];
				attrs[NSForegroundColorAttributeName] = [UIColor grayColor];
				toAttrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"re: %@", [self.replying boolValue] ? self->convoTitle : self->listing.title]];
				[toAttrString setAttributes:attrs range:NSMakeRange(0, 3)];
				reLabel.attributedText = toAttrString;
				
			} else if (indexPath.row == 2) {
				
				cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier forIndexPath:indexPath];
				
				if (![cell.contentView viewWithTag:51]) {
					messageTextView = [[GCPlaceholderTextView alloc] initWithFrame:CGRectMake(12, 0, 293, 400)];
					messageTextView.placeholder = @"Hello seller...";
					messageTextView.font = [UIFont systemFontOfSize:15];
					[messageTextView setTextColor:[UIColor blackColor]];
					messageTextView.layoutManager.delegate = self;
					messageTextView.tag = 51;
					messageTextView.delegate = self;
					UIToolbar *editingToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
					UIBarButtonItem *flexEditingBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
					UIBarButtonItem *doneEditingBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissKeyBoard:)];
					[editingToolBar setItems:@[flexEditingBtn, doneEditingBtn]];
					messageTextView.inputAccessoryView = editingToolBar;
					[cell.contentView addSubview:messageTextView];
				}
			}
			break;
		default:
			cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier forIndexPath:indexPath];
			break;
	}
    return cell;
}

-(void)dismissKeyBoard:(id)sender {
	[self.view endEditing:YES];
}

- (CGFloat)layoutManager:(NSLayoutManager *)layoutManager lineSpacingAfterGlyphAtIndex:(NSUInteger)glyphIndex withProposedLineFragmentRect:(CGRect)rect {
    return 5;
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
	
	return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
	NSString *trimmedText = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if ([trimmedText isEqualToString: @""]) {
		textView.text = nil;
	} else textView.text = trimmedText;
	self->message = trimmedText;
}

-(void)textViewDidChange:(UITextView *)textView {
	self->message = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.navigationItem.rightBarButtonItem.enabled = ![self->message isEqualToString:@""];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
