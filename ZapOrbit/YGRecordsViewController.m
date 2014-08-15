//
//  YGRecordsViewController.m
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 15/04/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import "YGRecordsViewController.h"
#import "YGStarRateView.h"
//#import "YGBlockerView.h"

@interface YGRecordsViewController ()

@end

@implementation YGRecordsViewController
@synthesize records = _records;

-(void)setRecords:(NSMutableDictionary *)records {
	_records = records;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	pendingCount = [(NSMutableArray *) (self.records)[@"pendingRecords"] count];
	processingCount = [(NSMutableArray *) (self.records)[@"processingRecords"] count];
	completedCount = [(NSMutableArray *) (self.records)[@"completedRecords"] count];
	failedCount = [(NSMutableArray *) (self.records)[@"failedRecords"] count];
	
	priceFormatter = [[NSNumberFormatter alloc] init];
	[priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	[priceFormatter setLocale:[NSLocale currentLocale]];
	
	dateFormater = [[NSDateFormatter alloc] init];
	[dateFormater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	
	UIToolbar *topToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 64, self.tableView.bounds.size.width, 49)];
	CGRect aRect;
	NSUInteger size = 14;
	UIFont *font = [UIFont systemFontOfSize:size];
	UIColor *normalColour = [UIColor lightGrayColor];
	UIColor *selectedColour = [UIColor colorWithRed:0 green:122/255.f blue:1 alpha:1];
	UIColor *highlightedColour = [UIColor colorWithWhite:0.85 alpha:1];
	
	UIButton *pendingButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[pendingButton setFrame:CGRectZero];
	[pendingButton setTitle:@"Pending" forState:UIControlStateNormal];
	[pendingButton setTitle:@"Pending" forState:UIControlStateSelected];
	[pendingButton.titleLabel setFont:font];
	[pendingButton sizeToFit];
	aRect = pendingButton.frame;
	aRect.size.width +=10;
	aRect.size.height +=10;
	pendingButton.frame = aRect;
	[pendingButton addTarget:self action:@selector(transactionType:) forControlEvents:UIControlEventTouchUpInside];
	
	UIButton *processingButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[processingButton setFrame:CGRectZero];
	[processingButton setTitle:@"Processing" forState:UIControlStateNormal];
	[processingButton setTitle:@"Processing" forState:UIControlStateSelected];
	[processingButton.titleLabel setFont:font];
	[processingButton sizeToFit];
	aRect = processingButton.frame;
	aRect.size.width +=10;
	aRect.size.height +=10;
	processingButton.frame = aRect;
	[processingButton addTarget:self action:@selector(transactionType:) forControlEvents:UIControlEventTouchUpInside];
	
	UIButton *completedButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[completedButton setFrame:CGRectZero];
	[completedButton setTitle:@"Completed" forState:UIControlStateNormal];
	[completedButton setTitle:@"Completed" forState:UIControlStateSelected];
	[completedButton.titleLabel setFont:font];
	[completedButton sizeToFit];
	aRect = completedButton.frame;
	aRect.size.width +=10;
	aRect.size.height +=10;
	completedButton.frame = aRect;
	[completedButton addTarget:self action:@selector(transactionType:) forControlEvents:UIControlEventTouchUpInside];
	
	UIButton *failedButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[failedButton setFrame:CGRectZero];
	[failedButton setTitle:@"Failed" forState:UIControlStateNormal];
	[failedButton setTitle:@"Failed" forState:UIControlStateSelected];
	[failedButton.titleLabel setFont:font];
	[failedButton sizeToFit];
	aRect = failedButton.frame;
	aRect.size.width +=10;
	aRect.size.height +=10;
	failedButton.frame = aRect;
	[failedButton addTarget:self action:@selector(transactionType:) forControlEvents:UIControlEventTouchUpInside];
	
	UIBarButtonItem *pendingBarButton = [[UIBarButtonItem alloc] initWithCustomView:pendingButton];
	UIBarButtonItem *processingBarButton = [[UIBarButtonItem alloc] initWithCustomView:processingButton];
	UIBarButtonItem *completedBarButton = [[UIBarButtonItem alloc] initWithCustomView:completedButton];
	UIBarButtonItem *failedBarButton = [[UIBarButtonItem alloc] initWithCustomView:failedButton];
	UIBarButtonItem *flex1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	UIBarButtonItem *flex2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	UIBarButtonItem *flex3 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	
	[[UIButton appearanceWhenContainedIn:[UIToolbar class], nil] setTitleColor:normalColour forState:UIControlStateNormal];
	[[UIButton appearanceWhenContainedIn:[UIToolbar class], nil] setTitleColor:selectedColour forState:UIControlStateSelected];
	[[UIButton appearanceWhenContainedIn:[UIToolbar class], nil] setTitleColor:highlightedColour forState:UIControlStateHighlighted];
	
	[topToolbar setItems:@[pendingBarButton,flex1,processingBarButton,flex2,completedBarButton,flex3,failedBarButton]];
	
	[self.view addSubview:topToolbar];
	
	[pendingButton setSelected:YES];
	processingCount = completedCount = failedCount = 0;
	
	UIView *highlighLayer = [[UIView alloc] init];
	CGRect highlightRect = pendingButton.frame;
	highlightRect.size.height = 3;
	highlightRect.origin.y = topToolbar.frame.size.height-3;
	highlighLayer.frame = highlightRect;
	highlighLayer.tag = 20;
	highlighLayer.backgroundColor = [UIColor colorWithRed:0 green:112/255.f blue:1 alpha:1];
	
	[topToolbar addSubview:highlighLayer];
	self.tableView.contentInset = UIEdgeInsetsMake(59, 0, 0, 0);
	self->userInfo = [YGUserInfo sharedInstance];
	[self getRatingsForTrans];
	
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	_scrollingObserver = [center addObserverForName:@"cellScrolled"
											 object:nil
											  queue:nil
										 usingBlock:^(NSNotification *note){}];
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissFeedback:) name:@"FeedbackEnded" object:nil];
	if (!pendingCount && !processingCount && !completedCount && !failedCount) {
		[self emptyTableView:self.tableView];
	}
}

-(void)viewWillDisappear:(BOOL)animated {
	if ([self.navigationController.childViewControllers indexOfObject:self] == NSNotFound) {
		[self.tableView setContentOffset:CGPointMake(0, -59-64)];
		if(_scrollingObserver != nil)[[NSNotificationCenter defaultCenter] removeObserver:_scrollingObserver];
	}
	[super viewWillDisappear:animated];
	if (self->textView) {
		[self->textView resignFirstResponder];
		[self->dTextView resignFirstResponder];
		[[self.tableView viewWithTag:4] removeFromSuperview];
	}
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)dealloc {
	if(_scrollingObserver != nil)[[NSNotificationCenter defaultCenter] removeObserver:_scrollingObserver];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)transactionType:(UIButton *)sender {
	if (sender.selected) return;
	UIView *highlightView = [sender.superview viewWithTag:20];
	
	CGRect highlightRect = sender.frame;
	highlightRect.size.height = highlightView.frame.size.height;
	highlightRect.origin.y = highlightView.frame.origin.y;
	
	[UIView animateWithDuration:0.2 animations:^{
		[highlightView setFrame:highlightRect];
	} completion:^(BOOL finished) {
		
	}];
	for (UIView *subview in [sender.superview subviews]) {
		if ([subview isKindOfClass:[UIButton class]] && ((UIButton *)subview).selected) {
			((UIButton *)subview).selected = NO;
		}
	}
	sender.selected = YES;
	[[self.tableView viewWithTag:88] removeFromSuperview];
	if ([sender.titleLabel.text isEqualToString:@"Pending"]) {
		processingCount = completedCount = failedCount = 0;
		pendingCount = pendingCount = [(NSMutableArray *) (self.records)[@"pendingRecords"] count];
	} else if ([sender.titleLabel.text isEqualToString:@"Processing"]) {
		pendingCount = completedCount = failedCount = 0;
		processingCount = [(NSMutableArray *) (self.records)[@"processingRecords"] count];
	} else if ([sender.titleLabel.text isEqualToString:@"Completed"]) {
		pendingCount = processingCount = failedCount = 0;
		completedCount = [(NSMutableArray *) (self.records)[@"completedRecords"] count];
	} else if ([sender.titleLabel.text isEqualToString:@"Failed"]) {
		pendingCount = completedCount = processingCount = 0;
		failedCount = [(NSMutableArray *) (self.records)[@"failedRecords"] count];
	}
	[self.tableView reloadData];
	if (!pendingCount && !processingCount && !completedCount && !failedCount) {
		[self emptyTableView:self.tableView];
	}
}

-(void)emptyTableView:(UITableView *)tableView {
	UILabel *emptyMessage = [[UILabel alloc] initWithFrame:CGRectMake((self.tableView.frame.size.width/2)-50, (self.tableView.frame.size.height/2)-self.tableView.contentInset.top, self.tableView.frame.size.width, 30)];
	emptyMessage.text = @"None Found";
	emptyMessage.textColor = [UIColor lightGrayColor];
	emptyMessage.tag = 88;
	emptyMessage.font = [UIFont boldSystemFontOfSize:18];
	[tableView addSubview:emptyMessage];
}

#pragma mark - UIScrollViewDelegate methods

-(void)refreshScrollViewUI:(UIScrollView *)scrollView {
	UIPageControl *pageControl = (UIPageControl *)[scrollView.superview viewWithTag:15];
	if (scrollView.contentOffset.x == 0) {
		pageControl.currentPage = 0;
	}
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	if (scrollView != self.tableView) {
		if (_scrollingObserver && scrollView.contentOffset.x == 0) {
			NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
			[center postNotificationName:@"cellScrolled" object:nil];
		}
	}
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
	if (scrollView != self.tableView) {
		[self refreshScrollViewUI:scrollView];
	}
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	if (scrollView != self.tableView) {
		if (scrollView.contentOffset.x == 0) {
			[self refreshScrollViewUI:scrollView];
		} else {
			UIPageControl *pageControl = (UIPageControl *)[scrollView.superview viewWithTag:15];
			pageControl.currentPage = 1;
			if (_scrollingObserver) {
				NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
				[center postNotificationName:@"cellScrolled" object:nil];
			}
			NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
			_scrollingObserver = [center addObserverForName:@"cellScrolled"
													object:nil
													 queue:nil
												usingBlock:^(NSNotification *note) {
													[scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
													[[NSNotificationCenter defaultCenter] removeObserver:_scrollingObserver];
												}];
		}
	}
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if (scrollView != self.tableView) {
		UIPageControl *pageControl = (UIPageControl *)[scrollView.superview viewWithTag:15];
		if (scrollView.contentOffset.x < 33) {
			[pageControl setCurrentPageIndicatorTintColor : [UIColor colorWithRed:0 green:0.478431f blue:1 alpha:1]];
			[pageControl setPageIndicatorTintColor:[UIColor colorWithRed:230/255.f green:229/255.f blue:233/255.f alpha:1.0]];
		} else {
			[pageControl setCurrentPageIndicatorTintColor : [UIColor whiteColor]];
			[pageControl setPageIndicatorTintColor:[UIColor colorWithRed:230/255.f green:229/255.f blue:233/255.f alpha:0.6]];
		}
	}
}

#pragma mark - UITableView methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	float height;
	switch (indexPath.row) {
		case 0:
			height = 88;
			break;
		default:
			height = 88;
			break;
	}
	return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 35)];
	[view setBackgroundColor:[UIColor colorWithRed:230/255.f green:229/255.f blue:233/255.f alpha:0.8]];
	CALayer *bottom = [CALayer layer];
	bottom.frame = CGRectMake(0, 35, tableView.frame.size.width, 0.5f);
	bottom.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1].CGColor;
	[view.layer addSublayer:bottom];
	CALayer *topBorder = [CALayer layer];
	topBorder.frame = CGRectMake(0.0f, 0.0f, tableView.frame.size.width, 0.5f);
	topBorder.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1].CGColor;
	[view.layer addSublayer:topBorder];
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, view.frame.size.height-18, 300, 10)];
	NSString *titleTex = section == 0 ? @"PENDING" : section == 1 ? @"PROCESSING" : section == 2 ? @"COMPLETED": @"FAILED";
	[titleLabel setText:titleTex];
	[titleLabel setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]];
	[titleLabel setTextColor:[UIColor lightGrayColor]];
	[titleLabel setTextColor:section == 0 ? [UIColor colorWithRed:0 green:200/255.f blue:76/255.f alpha:1] : section == 1 ? [UIColor colorWithRed:1 green:156/255.f blue:82/255.f alpha:1] : section == 2 ? [UIColor colorWithRed:0 green:112/255.f blue:1 alpha:1] : [UIColor redColor] ];
	[view addSubview:titleLabel];
	
	return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	int rowsCount = 0;
	switch (section) {
		case 0:
			rowsCount = (int)pendingCount;
			break;
		case 1:
			rowsCount = (int)processingCount;
			break;
		case 2:
			rowsCount = (int)completedCount;
			break;
		case 3:
			rowsCount = (int)failedCount;
			break;
		default:
			break;
	}
    return rowsCount;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	UIScrollView *scrollView = (UIScrollView *)[cell.contentView viewWithTag:10];
	if (scrollView.contentOffset.x > 0) {
		[scrollView setContentOffset:CGPointZero];
		NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
		[center postNotificationName:@"cellScrolled" object:self];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *pendingCellIdentifier = @"pendingCell";
	static NSString *processingCellIdentifier = @"processingCell";
	static NSString *completedCellIdentifier = @"completedCell";
	static NSString *failedCellIdentifier = @"failedCell";
	
	UITableViewCell *cell;
	UILabel *titleLabel;
	UIView *mainView;
	UIView *secondaryView;
	UILabel *offeridLabel;
	UILabel *buyeridLabel;
	UILabel *transidLabel;
	NSDictionary *record;
	NSString *priceStr;
	NSNumber *price;
	NSString *rawUpdateDate;
	NSString *dateStr;
	NSDate *date;
	
	if (indexPath.section == 0) {
		
		cell = [tableView dequeueReusableCellWithIdentifier:pendingCellIdentifier forIndexPath:indexPath];
		record = [(self.records)[@"pendingRecords"] objectAtIndex:(NSUInteger) indexPath.row];
				
		titleLabel = (UILabel *)[cell.contentView viewWithTag:20];
		titleLabel.text = [[(self.records)[@"pendingRecords"] objectAtIndex:(NSUInteger) indexPath.row] objectForKey:@"title"];
		
		mainView = [[[cell.contentView viewWithTag:10] viewWithTag:25] viewWithTag:26];
		secondaryView = [[[cell.contentView viewWithTag:10] viewWithTag:25] viewWithTag:27];
		[mainView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTapped:)]];
		
		offeridLabel = (UILabel *)[mainView viewWithTag:100];
		buyeridLabel = (UILabel *)[mainView viewWithTag:102];
		transidLabel = (UILabel *)[secondaryView viewWithTag:101];
		
		offeridLabel.text = [NSString stringWithFormat:@"%@", record[@"offerid"]];
		buyeridLabel.text = [NSString stringWithFormat:@"%@", record[@"buyerid"]];
		transidLabel.text = [NSString stringWithFormat:@"%@", record[@"transid"]];
		
		price = record[@"price"];
		if ([price floatValue] >= 100) {
			[priceFormatter setMaximumFractionDigits:0];
			priceStr = [priceFormatter stringFromNumber:price];
			[priceFormatter setMinimumFractionDigits:2];
		} else
			priceStr = [priceFormatter stringFromNumber:price];
		
		[(UILabel *)[mainView viewWithTag:30] setText:priceStr];
        [(UILabel *) [mainView viewWithTag:35] setText:record[@"description"]];
		
		rawUpdateDate = record[@"updated_on"];
		dateStr = [rawUpdateDate substringToIndex:rawUpdateDate.length-2];
		date = [dateFormater dateFromString:dateStr];
		[(UILabel *)[mainView viewWithTag:40] setText:[date formattedDateRelativeToNow:date]];
			
	} else if (indexPath.section == 1) {
		
		cell = [tableView dequeueReusableCellWithIdentifier:processingCellIdentifier forIndexPath:indexPath];
		record = [(self.records)[@"processingRecords"] objectAtIndex:(NSUInteger) indexPath.row];
		
		titleLabel = (UILabel *)[cell.contentView viewWithTag:20];
		titleLabel.text = [[(self.records)[@"processingRecords"] objectAtIndex:(NSUInteger) indexPath.row] objectForKey:@"title"];
		
		mainView = [[[cell.contentView viewWithTag:10] viewWithTag:25] viewWithTag:26];
		secondaryView = [[[cell.contentView viewWithTag:10] viewWithTag:25] viewWithTag:27];
		[mainView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTapped:)]];
		
		offeridLabel = (UILabel *)[mainView viewWithTag:100];
		buyeridLabel = (UILabel *)[mainView viewWithTag:102];
		transidLabel = (UILabel *)[secondaryView viewWithTag:101];
		
		offeridLabel.text = [NSString stringWithFormat:@"%@", record[@"offerid"]];
		buyeridLabel.text = [NSString stringWithFormat:@"%@", record[@"buyerid"]];
		transidLabel.text = [NSString stringWithFormat:@"%@", record[@"transid"]];
		
		price = record[@"price"];
		if ([price floatValue] >= 100) {
			[priceFormatter setMaximumFractionDigits:0];
			priceStr = [priceFormatter stringFromNumber:price];
			[priceFormatter setMinimumFractionDigits:2];
		} else
			priceStr = [priceFormatter stringFromNumber:price];
		
		[(UILabel *)[mainView viewWithTag:30] setText:priceStr];
        [(UILabel *) [mainView viewWithTag:35] setText:record[@"description"]];
		
		rawUpdateDate = record[@"updated_on"];
		dateStr = [rawUpdateDate substringToIndex:rawUpdateDate.length-2];
		date = [dateFormater dateFromString:dateStr];
		[(UILabel *)[mainView viewWithTag:40] setText:[date formattedDateRelativeToNow:date]];
			
	} else if (indexPath.section == 2) {
		
		cell = [tableView dequeueReusableCellWithIdentifier:completedCellIdentifier forIndexPath:indexPath];
		record = [(self.records)[@"completedRecords"] objectAtIndex:(NSUInteger) indexPath.row];
		
		titleLabel = (UILabel *)[cell.contentView viewWithTag:20];
		titleLabel.text = [[(self.records)[@"completedRecords"] objectAtIndex:(NSUInteger) indexPath.row] objectForKey:@"title"];
		
		mainView = [[[cell.contentView viewWithTag:10] viewWithTag:25] viewWithTag:26];
		secondaryView = [[[cell.contentView viewWithTag:10] viewWithTag:25] viewWithTag:27];
		
		offeridLabel = (UILabel *)[mainView viewWithTag:100];
		buyeridLabel = (UILabel *)[mainView viewWithTag:102];
		transidLabel = (UILabel *)[secondaryView viewWithTag:101];
		
		offeridLabel.text = [NSString stringWithFormat:@"%@", record[@"offerid"]];
		buyeridLabel.text = [NSString stringWithFormat:@"%@", record[@"buyerid"]];
		transidLabel.text = [NSString stringWithFormat:@"%@", record[@"transid"]];
		
		if (self->completedFeedback && self->completedFeedback.count) {
			BOOL foundFeedback = NO;
			NSDictionary *feedbackDict;
			for (NSDictionary *feedback in self->completedFeedback) {
				if ([[feedback[@"feedback"] objectForKey:@"transid"] integerValue] == [record[@"transid"] integerValue]) {
					foundFeedback = YES;
					feedbackDict = feedback;
					break;
				}
			}
			if (foundFeedback) {
				[(UIButton *)[secondaryView viewWithTag:16] setHidden:YES];
				if (![secondaryView viewWithTag:50]) {
					CGRect rect = CGRectMake(15, 12, 150, 50);
					YGRatingView *ratingView = [[YGRatingView alloc] initWithFrame:rect];
					ratingView.tag = 50;
					[ratingView setRatingTintColor:[UIColor colorWithRed:0 green:195/255.f blue:1 alpha:1]];
					[ratingView setRatingTrackColor:[UIColor colorWithRed:0 green:90/255.f blue:1 alpha:1]];
					[secondaryView addSubview:ratingView];
					[ratingView setRating:[feedbackDict[@"rating"] floatValue]/5 animated:NO];
					UILabel *feedbackLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 40, 240, 35)];
					[feedbackLabel setFont:[UIFont systemFontOfSize:14]];
					[feedbackLabel setTextColor:[UIColor whiteColor]];
					[feedbackLabel setNumberOfLines:2];
					feedbackLabel.tag = 52;
					[feedbackLabel setText:[NSString stringWithFormat:@"\"%@\"", [feedbackDict[@"feedback"] objectForKey:@"feedback"]]];
					[secondaryView addSubview:feedbackLabel];
				}
			} else {
				[(UIButton *)[secondaryView viewWithTag:16] setHidden:NO];
				[[secondaryView viewWithTag:50] removeFromSuperview];
				[[secondaryView viewWithTag:52] removeFromSuperview];
			}
		} else [(UIButton *)[secondaryView viewWithTag:16] setHidden:NO];
		
		price = record[@"price"];
		if ([price floatValue] >= 100) {
			[priceFormatter setMaximumFractionDigits:0];
			priceStr = [priceFormatter stringFromNumber:price];
			[priceFormatter setMinimumFractionDigits:2];
		} else
			priceStr = [priceFormatter stringFromNumber:price];
		
		[(UILabel *)[mainView viewWithTag:30] setText:priceStr];
        [(UILabel *) [mainView viewWithTag:35] setText:record[@"description"]];
		
		rawUpdateDate = record[@"updated_on"];
		dateStr = [rawUpdateDate substringToIndex:rawUpdateDate.length-2];
		date = [dateFormater dateFromString:dateStr];
		[(UILabel *)[mainView viewWithTag:40] setText:[date formattedDateRelativeToNow:date]];
		
	} else if (indexPath.section == 3) {
		
		cell = [tableView dequeueReusableCellWithIdentifier:failedCellIdentifier forIndexPath:indexPath];
		record = [(self.records)[@"failedRecords"] objectAtIndex:(NSUInteger) indexPath.row];
		
		titleLabel = (VALabel *)[cell.contentView viewWithTag:20];
		titleLabel.text = record[@"title"];
		
		mainView = [[[cell.contentView viewWithTag:10] viewWithTag:25] viewWithTag:26];
		secondaryView = [[[cell.contentView viewWithTag:10] viewWithTag:25] viewWithTag:27];
		
		offeridLabel = (UILabel *)[mainView viewWithTag:100];
		buyeridLabel = (UILabel *)[mainView viewWithTag:102];
		transidLabel = (UILabel *)[secondaryView viewWithTag:101];
		
		offeridLabel.text = [NSString stringWithFormat:@"%@", record[@"offerid"]];
		buyeridLabel.text = [NSString stringWithFormat:@"%@", record[@"buyerid"]];
		transidLabel.text = [NSString stringWithFormat:@"%@", record[@"transid"]];
		
		if (self->failedFeedback && self->failedFeedback.count) {
			BOOL foundFeedback = NO;
			NSDictionary *feedbackDict;
			for (NSDictionary *feedback in self->failedFeedback) {
				if ([feedback[@"transid"] integerValue] == [record[@"transid"] integerValue]) {
					foundFeedback = YES;
					feedbackDict = feedback;
					break;
				}
			}
			if (foundFeedback) {
				[(UIButton *)[secondaryView viewWithTag:16] setHidden:YES];
				if (![secondaryView viewWithTag:52]) {
					UILabel *feedbackLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 25, 240, 35)];
					[feedbackLabel setFont:[UIFont systemFontOfSize:14]];
					[feedbackLabel setTextColor:[UIColor whiteColor]];
					[feedbackLabel setNumberOfLines:2];
					feedbackLabel.tag = 52;
					[feedbackLabel setText:[NSString stringWithFormat:@"\"%@\"", feedbackDict[@"feedback"]]];
					[secondaryView addSubview:feedbackLabel];
				}
			} else {
				[(UIButton *)[secondaryView viewWithTag:16] setHidden:NO];
				[[secondaryView viewWithTag:52] removeFromSuperview];
			}
		} else [(UIButton *)[secondaryView viewWithTag:16] setHidden:NO];
		
		price = record[@"price"];
		if ([price floatValue] >= 100) {
			[priceFormatter setMaximumFractionDigits:0];
			priceStr = [priceFormatter stringFromNumber:price];
			[priceFormatter setMinimumFractionDigits:2];
		} else
			priceStr = [priceFormatter stringFromNumber:price];
		
		[(UILabel *)[mainView viewWithTag:30] setText:priceStr];
        [(UILabel *) [mainView viewWithTag:35] setText:record[@"description"]];
		
		rawUpdateDate = record[@"updated_on"];
		dateStr = [rawUpdateDate substringToIndex:rawUpdateDate.length-2];
		date = [dateFormater dateFromString:dateStr];
		[(UILabel *)[mainView viewWithTag:40] setText:[date formattedDateRelativeToNow:date]];
	}
	return cell;
}

-(void)cellTapped:(UITapGestureRecognizer *)gestureRecogniser {
	NSString *offerid = [(UILabel *)[gestureRecogniser.view viewWithTag:100] text];
	NSString *buyerid = [(UILabel *)[gestureRecogniser.view viewWithTag:102] text];
	[self getPreviewingData:offerid buyerId:buyerid];
}

-(void)dismissViewCtrl:(id)sender {
	[self dismissViewControllerAnimated:YES completion:^{
		
	}];
}

-(void)getPreviewingData:(NSString *)offerid buyerId:(NSString *)buyerid {
	NSURL *listingURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@getlistingbyid/%@", kApiUrl, offerid]];
	dispatch_async(dispatch_get_main_queue(), ^{
		NSData *listingData = [NSData dataWithContentsOfURL:listingURL];
		if (listingData) {
			NSDictionary *response = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:listingData options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:nil];
			NSDictionary *listDict = response[@"listing"];
			NSDictionary *locDict = response[@"location"];
			NSDictionary *userDict = response[@"user"];
			YGUser *user = [[YGUser alloc] init];
			user.id = [userDict[@"id"] intValue];
			user.name = userDict[@"name"];
			user.surname = userDict[@"surname"];
			user.email = userDict[@"email"];
			user.fbuserid = userDict[@"fbuserid"];
			
			ListingRecord *listing = [[ListingRecord alloc] init];
			listing.id = @([listDict[@"id"] intValue]);
			listing.title = listDict[@"title"];
			listing.description = listDict[@"description"];
			listing.pictures = [[NSMutableArray alloc] initWithCapacity:5];
			listing.pictureNames = listDict[@"pictures"];
			listing.price = @([listDict[@"price"] floatValue]);
			listing.highlight = [listDict[@"highlight"] boolValue];
			listing.waggle = [listDict[@"waggle"] boolValue];
			listing.shop = listDict[@"shop"];
			listing.picturesCache = [[NSCache alloc] init];
			listing.telephone = listDict[@"telephone"];
			if ([listing.telephone isEqual:[NSNull null]]) {
				listing.telephone = Nil;
			}
			listing.userid = [listDict[@"userid"] intValue];
			NSString *rawUpdateDate = listDict[@"updated_on"];
			NSString *dateStr = [rawUpdateDate substringToIndex:rawUpdateDate.length-2];
			NSDate *date = [dateFormater dateFromString:dateStr];
			listing.updated_on = [date formattedDateRelativeToNow:date];
			listing.location = locDict;
			listing.user = user;
			
			UINavigationController *itemDetailNavViewCtrl = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"navModalItem"];
			YGDetailItemController *itemDetailViewCtrl = [itemDetailNavViewCtrl childViewControllers][0];
			[itemDetailViewCtrl setListing:listing];
			[itemDetailViewCtrl setPreviewing:YES];
			[self configureDetailView:itemDetailViewCtrl buyerId:buyerid];
			itemDetailViewCtrl.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissViewCtrl:)];
			[self presentViewController:itemDetailNavViewCtrl animated:YES completion:^{
				
			}];
		} else NSLog(@"no data");
	});
	
}

-(void) configureDetailView:(YGDetailItemController *)itemDetailViewCtrl buyerId:(NSString *)buyerid {}


-(void)activateFeedbackView:(UITextView *)textView {
	
}

-(void)keyboardWillShow:(NSNotification *)note {}

-(void)keyboardWillHide:(NSNotification *)note {
	[[self.view.window viewWithTag:34] removeFromSuperview];
	[[self.tableView viewWithTag:4] removeFromSuperview];
	[self->dTextView resignFirstResponder];
}

-(void)keyboardDidShow:(NSNotification *)note {
	
}

-(void)keyboardDidHide:(NSNotification *)note {
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center postNotificationName:@"cellScrolled" object:nil];
	[self->dTextView removeFromSuperview];
	self->dTextView = nil;
}

- (BOOL)textView:(UITextView *)aTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
	BOOL isAllowed = YES;
	if ([text isEqualToString:@"\n"]) {
		isAllowed = NO;
	}
	return isAllowed;
}

- (void)textViewDidBeginEditing:(UITextView *)aTextView {
	if (aTextView == self->textView) {
		self->textView.layer.borderColor = [UIColor colorWithRed:0 green:122/255.f blue:1 alpha:0.8].CGColor;
	}
}

- (void)textViewDidChange:(UITextView *)aTextView {
	if (aTextView.tag == 43) {
		UIButton *sendButton;
		for (UIView *subview in [aTextView.superview subviews]) {
			if ([subview isKindOfClass:[UIButton class]]) {
				sendButton = (UIButton *)subview;
			}
		}
		NSString *feedbackString = [aTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		int characterCount = feedbackString ? (int)feedbackString.length : 0;
		int leftAllowedChar = 70-characterCount;
		[(UILabel *)[textView viewWithTag:23] setText:[NSString stringWithFormat:@"%d", leftAllowedChar]];
		if (leftAllowedChar < 0) {
			[sendButton setEnabled:NO];
			[(UILabel *)[textView viewWithTag:23] setTextColor:[UIColor redColor]];
		} else {
            [sendButton setEnabled:characterCount > 0];
			[(UILabel *)[textView viewWithTag:23] setTextColor:[UIColor lightGrayColor]];
		}
		CGPoint startPosition = [aTextView caretRectForPosition:aTextView.beginningOfDocument].origin;
		CGPoint endPosition = [aTextView caretRectForPosition:aTextView.endOfDocument].origin;
		
		float currentDeltaPosition = endPosition.y - startPosition.y;
		
		if (currentDeltaPosition > 15 && currentDeltaPosition > self->deltaPosition ){
            // new line increase
			[self increaseSizeFeedbackView];
			++self->feedbackNumberOfLines;
        } else if (currentDeltaPosition < self->deltaPosition ) {
			// new line decrease
			[self decreaseSizeFeedbackView];
			--self->feedbackNumberOfLines;
		}
		self->deltaPosition = currentDeltaPosition;
	}
}

-(CGRect)getRectFromTwoPoints:(CGPoint)p1 andPoint:(CGPoint)p2 {
	return CGRectMake(MIN(p1.x, p2.x),
					  MIN(p1.y, p2.y),
            (CGFloat) fabs(p1.x - p2.x),
            (CGFloat) fabs(p1.y - p2.y));
}

-(void)dismissFeedback:(id)sender {
	[self->textView resignFirstResponder];
	[self->dTextView resignFirstResponder];
	[[self.view viewWithTag:14] removeFromSuperview];
}

-(void)increaseSizeFeedbackView {
	for (UIView *subview in [self->feedbackView subviews]) {
		if (subview.tag == 43) {
			UITextView *aTextView = (UITextView *)subview;
			[aTextView setFrame:CGRectMake(15, 15, 220, aTextView.frame.size.height+17)];
			UILabel *characterCounterLabel = (UILabel *)[aTextView viewWithTag:23];
			[characterCounterLabel setFrame:CGRectMake(195, characterCounterLabel.frame.origin.y+17, 20, 20)];
		} else if (subview.tag == 42) {
			UIView *ratingView = subview;
			[ratingView setFrame:CGRectMake(5, subview.frame.origin.y+17, 315, 50)];
		}
	}
	[self->feedbackView setFrame:CGRectMake(0, 0, feedbackView.bounds.size.width, feedbackView.bounds.size.height+17)];
}

-(void)decreaseSizeFeedbackView {
	for (UIView *subview in [self->feedbackView subviews]) {
		if (subview.tag == 43) {
			UITextView *aTextView = (UITextView *)subview;
			[aTextView setFrame:CGRectMake(15, 15, 220, aTextView.frame.size.height-17)];
			UILabel *characterCounterLabel = (UILabel *)[aTextView viewWithTag:23];
			[characterCounterLabel setFrame:CGRectMake(195, characterCounterLabel.frame.origin.y-17, 20, 20)];
		} else if (subview.tag == 42) {
			UIView *ratingView = subview;
			[ratingView setFrame:CGRectMake(5, subview.frame.origin.y-17, 315, 50)];
		}
	}
	[self->feedbackView setFrame:CGRectMake(0, 0, feedbackView.bounds.size.width, feedbackView.bounds.size.height-17)];
}

-(void)configureFeedbackView {
	
	UIView *blocker = [[UIView alloc] initWithFrame:CGRectMake(0, 64, self.tableView.frame.size.width, self.tableView.frame.size.height)];
	[blocker setBackgroundColor:[UIColor colorWithWhite:0.9 alpha:0.98]];
	blocker.userInteractionEnabled = YES;
	blocker.tag = 14;
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissFeedback:)];
	[blocker addGestureRecognizer:tap];
	[self.view addSubview:blocker];
}

-(UIView *)feedbackViewWithFrame:(CGRect)aRect forUser:(NSNumber *)userid forTransaction:(NSNumber *)transid {
	CGRect dFrame = CGRectMake(0, self.view.window.frame.size.height, 320, 88);
	UIView *dBaseView = [[UIView alloc] initWithFrame:dFrame];
	[self.view addSubview:dBaseView];
	self->dTextView = [[UITextView alloc] initWithFrame:CGRectZero];
	self->dTextView.backgroundColor = [UIColor clearColor];
	self->dTextView.tag = 34;
	self->dTextView.delegate = self;
	[dBaseView addSubview:self->dTextView];
	
	UIView *accessoryView = [[UIView alloc] initWithFrame:aRect];
	self->textView = [[GCPlaceholderTextView alloc] initWithFrame:CGRectMake(15, 15, 220, 50)];
	accessoryView.backgroundColor = [UIColor colorWithWhite:0.92 alpha:1];
	self->textView.font = [UIFont systemFontOfSize:14];
	[accessoryView addSubview:self->textView];
	self->textView.layer.borderColor = [UIColor colorWithWhite:0.7 alpha:1].CGColor;
	self->textView.layer.borderWidth = 0.75;
	self->textView.layer.cornerRadius = 5;
	self->textView.delegate = self;
	self->textView.contentInset = UIEdgeInsetsZero;
	self->textView.contentSize = CGSizeMake(220, 250);
	self->textView.tag = 43;
	self->textView.placeholder = @"Submit a feeback for the seller based on this transaction...";
	self->textView.scrollEnabled = NO;
	
	UILabel *characterCounter = [[UILabel alloc] initWithFrame:CGRectMake(195, 30, 20, 20)];
	[characterCounter setTextAlignment:NSTextAlignmentRight];
	characterCounter.font = [UIFont systemFontOfSize:12];
	characterCounter.text = @"70";
	characterCounter.tag = 23;
	characterCounter.textColor = [UIColor lightGrayColor];
	[self->textView addSubview:characterCounter];
	
	UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[sendButton setFrame:CGRectMake(250, 15, 50, 25)];
	[sendButton setTitle:@"Send" forState:UIControlStateNormal];
	sendButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
	[sendButton setTitleColor:[UIColor colorWithRed:0 green:122/255.f blue:1 alpha:1] forState:UIControlStateNormal];
	[sendButton setTitleColor:[UIColor colorWithWhite:0.8 alpha:0.8] forState:UIControlStateDisabled];
	sendButton.tag = [userid integerValue];
	[sendButton setEnabled:NO];
	[sendButton addTarget:self action:@selector(composeFeedback:) forControlEvents:UIControlEventTouchUpInside];
	
	CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0.0f, 0.0f, 320, 0.5f);
    topBorder.backgroundColor = [UIColor lightGrayColor].CGColor;
	[accessoryView.layer addSublayer:topBorder];
	
	UILabel *transLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	[transLabel setHidden:YES];
	transLabel.tag = [transid integerValue];
	[accessoryView addSubview:transLabel];
	
	[accessoryView addSubview:sendButton];
	accessoryView.tag = 44;
	
	self->feedbackNumberOfLines = 1;
	self->feedbackView = accessoryView;
	return accessoryView;
}

-(YGStarRateView *)ratingView {
	YGStarRateView *ratingView = [[YGStarRateView alloc] initWithFrame:CGRectMake(5, 65, 315, 50)];
	ratingView.tag = 42;
	return ratingView;
}

-(void)composeFeedback:(id)sender {
	UIView *superview;
	NSNumber *userid;
	NSNumber *transid;
	if ([sender isKindOfClass:[UIButton class]]) {
		superview = [(UIButton *)sender superview];
		userid = @((int) ((UIButton *) sender).tag);
	}
	NSString *feedback;
	NSNumber *rating;
	if (superview) {
		for (UIView *subview in [superview subviews]) {
			if (subview.tag == 43) {
				feedback = [[(UITextView*)subview text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			} else if (subview.tag == 42) {
				rating = [(YGStarRateView *)subview rating];
			} else if ([subview isKindOfClass:[UILabel class]]) {
				transid = @((int) ((UILabel *) subview).tag);
			}
		}
	}
	[self postFeedback:feedback withRating:rating forUser:userid forTransaction:transid];
}

-(void)postFeedback:(NSString *)feedback withRating:(NSNumber *)rating forUser:(NSNumber *)userid forTransaction:(NSNumber *)transid {}

- (void)giveFeedbackFromCompleted:(id)sender {
	UIButton *feedbackButton = (UIButton *)sender;
	CGPoint point = [self.tableView convertPoint:feedbackButton.frame.origin fromView:feedbackButton.superview];
	NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
	NSNumber *userid;
	NSNumber *transid;
	if (completedCount) {
		NSDictionary *record = [(self.records)[@"completedRecords"] objectAtIndex:(NSUInteger) indexPath.row];
		if (record[@"sellerid"]) {
			userid = record[@"sellerid"];
		} else userid = record[@"buyerid"];
		transid = record[@"transid"];
	}
	UIView *accessoryView = [self feedbackViewWithFrame:CGRectMake(0, 0, 320, 117) forUser:userid forTransaction:transid];
	[accessoryView addSubview:[self ratingView]];
	self->dTextView.inputAccessoryView = accessoryView;
	[self->dTextView becomeFirstResponder];
	[self configureFeedbackView];
}

- (void)giveFeedbackFromFailed:(id)sender {
	UIButton *feedbackButton = (UIButton *)sender;
	CGPoint point = [self.tableView convertPoint:feedbackButton.frame.origin fromView:feedbackButton.superview];
	NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
	NSNumber *userid;
	NSNumber *transid;
	NSDictionary *record;
	if (completedCount) {
		record = [(self.records)[@"completedRecords"] objectAtIndex:(NSUInteger) indexPath.row];
	} else if (failedCount)
		record = [(self.records)[@"failedRecords"] objectAtIndex:(NSUInteger) indexPath.row];
	if (record[@"sellerid"]) {
		userid = record[@"sellerid"];
	} else userid = record[@"buyerid"];
	transid = record[@"transid"];
	UIView *accessoryView = [self feedbackViewWithFrame:CGRectMake(0, 0, 320, 80) forUser:userid forTransaction:transid];
	self->dTextView.inputAccessoryView = accessoryView;
	[self->dTextView becomeFirstResponder];
	[self configureFeedbackView];
}

-(void)getRatingsForTrans {
	
	NSMutableArray *completedTransids = [[NSMutableArray alloc] initWithCapacity:2];
	NSMutableArray *failedTransids = [[NSMutableArray alloc] initWithCapacity:2];
	int completedLength = (int)[(self.records)[@"completedRecords"] count];
	int failedLength = (int)[(self.records)[@"failedRecords"] count];
	
	if (completedLength) {
		for (NSDictionary *record in (self.records)[@"completedRecords"]) {
            [completedTransids addObject:record[@"transid"]];
		}
	}
	if (failedLength) {
		for (NSDictionary *record in (self.records)[@"failedRecords"]) {
            [failedTransids addObject:record[@"transid"]];
		}
	}
	
	if (completedTransids.count || failedTransids.count) {
		
		NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
		NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
		
		NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@getratingsfortrans/%lu", kApiUrl, (unsigned long)userInfo.user.id]];
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
		
		NSError *error = nil;
		NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"completedTransids":completedTransids,@"failedTransids":failedTransids} options:0 error:&error];
		NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]];
		
		[request setURL:url];
		[request setHTTPMethod:@"POST"];
		[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
		[request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
		[request setHTTPBody:jsonData];
		
		NSURLSessionDataTask *dataTask = [defaultSession dataTaskWithRequest:request
														   completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
																
																if (error == nil && [(NSHTTPURLResponse *)response statusCode] == 200) {
																	NSDictionary *dataObj = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
																	if ([dataObj[@"status"] isEqualToString:@"OK"]) {
																		if (dataObj[@"completedFeedbacks"]) self->completedFeedback = dataObj[@"completedFeedbacks"];
																		if (dataObj[@"failedFeedbacks"]) self->failedFeedback = dataObj[@"failedFeedbacks"];
																	}
																}
															}];
		[dataTask resume];
	}
}

@end
