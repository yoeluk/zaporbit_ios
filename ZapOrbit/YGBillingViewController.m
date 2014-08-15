//
//  YGBillingViewController.m
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 13/04/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import "YGBillingViewController.h"
#import "YGAppDelegate.h"
#import "VALabel.h"

static NSString *kApiUrl = @"https://zaporbit.com/api/";

@interface YGBillingViewController ()

@end

@implementation YGBillingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self->userInfo = [YGUserInfo sharedInstance];
	YGWebService *ws = [YGWebService initWithDelegate:self];
    [ws getBillingDataForUser:(NSUInteger) userInfo.user.id];
	self->paidBills = [[NSMutableArray alloc] initWithCapacity:3];
	self->unpaidBills = [[NSMutableArray alloc] initWithCapacity:3];
	
	self->progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, -2, self.tableView.frame.size.width, 2)];
	self->progressView.tag = 15;
	self->progressView.hidden = YES;
	self->progressView.progress = 0.0f;
	[self.tableView addSubview:self->progressView];
	[self->progressView setHidden:NO];
	[self->progressView setProgress:0.4 animated:YES];
	
	self.tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
	
	self->dateFormatter = [[NSDateFormatter alloc] init];
	[self->dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	
	[self->dateFormatter setLocale:[NSLocale currentLocale]];
	
	self->currencyFormatter = [[NSNumberFormatter alloc] init];
	[self->currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	[self->currencyFormatter setLocale:[NSLocale currentLocale]];
	[currencyFormatter setMinimumFractionDigits:2];
	[currencyFormatter setMaximumFractionDigits:2];
	
	self->heights = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
	NSLog(@"recieved memory warning");
}

-(void)coughRequestedData:(NSData *)data {
	[self->progressView setProgress:1.0f animated:YES];
	[NSTimer scheduledTimerWithTimeInterval:0.6f target:self selector:@selector(refreshUI:) userInfo:nil repeats:NO];
	if (![data isEqual:[NSNull null]] && data.length) {
		NSMutableDictionary *dataObj = (NSMutableDictionary *)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:nil];
		
		self->unpaidBills = [dataObj[@"billing"] objectForKey:@"unpaid"];
		[self findCellHeights];
		[self.tableView reloadData];
	}
}

-(void)refreshUI:(id)sender {
	[self->progressView setHidden:YES];
	self->progressView.progress = 0.0f;
}

- (void)findCellHeights {
	[self->heights removeAllObjects];
	CGRect frame = CGRectMake(15, 2, 215, 44);
	UITextView *titleTextView = [[UITextView alloc] initWithFrame:frame];
	titleTextView.font = [UIFont systemFontOfSize:14];
	titleTextView.scrollEnabled = NO;
	titleTextView.userInteractionEnabled = NO;
	titleTextView.tag = 5;
	titleTextView.textContainer.lineFragmentPadding = 0;
	NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
	paragraphStyle.lineHeightMultiple = 1.5f;
	NSDictionary *attrs = @{NSFontAttributeName : [UIFont systemFontOfSize:14],
							NSParagraphStyleAttributeName : paragraphStyle};
	for (NSDictionary *billing in self->unpaidBills) {
		NSDictionary *bill = billing[@"bill"];
		NSString *rawUpdateDate = bill[@"created_on"];
		NSString *dateStr = [rawUpdateDate substringToIndex:rawUpdateDate.length-2];
		NSDate *date = [self->dateFormatter dateFromString:dateStr];
		NSMutableAttributedString *titleString = [[NSMutableAttributedString alloc] initWithString:bill[@"offer_title"] attributes:attrs];
		NSMutableAttributedString *detailsString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@\n%@", bill[@"offer_price"], [self->dateFormatter stringFromDate:date]] attributes:attrs];
		[titleString appendAttributedString:detailsString];
		titleTextView.attributedText = titleString;
		[titleTextView sizeToFit];
        [self->heights addObject:@(titleTextView.frame.size.height)];
		titleTextView.frame = frame;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	return indexPath.row == 0? 44 : self->heights.count? self->heights.count < indexPath.row ? 44 : [(self->heights)[indexPath.row - 1] floatValue] : 0;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return section == 0 ? unpaidBills.count? unpaidBills.count+2 : 0 : paidBills.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
	if (indexPath.row == 0) {
		UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 11, 80, 21)];
		headerLabel.font = [UIFont boldSystemFontOfSize:15];
		headerLabel.text = @"Sold Items";
		[cell.contentView addSubview:headerLabel];
		UILabel *feesLabel = (UILabel *)[cell.contentView viewWithTag:10];
		feesLabel.font = [UIFont boldSystemFontOfSize:15];
		feesLabel.text = @"Fee";
		
		[[cell.contentView viewWithTag:4] removeFromSuperview];
		UIView *divider = [[UIView alloc] initWithFrame:CGRectZero];
		divider.tag = 4;
		divider.frame = CGRectMake(15.f, 43.5f, 285, 0.5f);
		divider.backgroundColor = [UIColor lightGrayColor];
		[cell.contentView addSubview:divider];
		
	} else if (indexPath.row > self->unpaidBills.count) {
		cell.selectionStyle = UITableViewCellSelectionStyleDefault;
		UILabel *feesLabel = (UILabel *)[cell.contentView viewWithTag:10];
		NSNumber *feesN = @((float) ([self calculateBillingTotal] * 0.06));
		NSString *fees = [self->currencyFormatter stringFromNumber:feesN];
		feesLabel.text = fees;
		[[cell.contentView viewWithTag:5] removeFromSuperview];
		CGRect frame = CGRectMake(15, 11, 200, 21);
		UILabel *payLable = [[UILabel alloc] initWithFrame:frame];
		payLable.font = [UIFont boldSystemFontOfSize:15];
		payLable.textColor = [UIColor colorWithRed:0 green:122/255.f blue:1 alpha:1];
		payLable.text = @"Pay Fees";
		[cell.contentView addSubview:payLable];
		
		[[cell.contentView viewWithTag:4] removeFromSuperview];
		UIView *divider = [[UIView alloc] initWithFrame:CGRectZero];
		divider.tag = 4;
		divider.frame = CGRectMake(15.f, 0.f, 285, 0.5f);
		divider.backgroundColor = [UIColor lightGrayColor];
		[cell.contentView addSubview:divider];
		
	} else {
		NSDictionary *bill = [(self->unpaidBills)[(NSUInteger) (indexPath.row - 1)] objectForKey:@"bill"];
		NSString *rawUpdateDate = bill[@"created_on"];
		NSString *dateStr = [rawUpdateDate substringToIndex:rawUpdateDate.length-2];
		NSDate *date = [self->dateFormatter dateFromString:dateStr];
		[self->dateFormatter setDateFormat:@"yyyy-MM-dd"];
		NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
		paragraphStyle.lineHeightMultiple = 1.5f;
		NSDictionary *attrs = @{NSFontAttributeName : [UIFont systemFontOfSize:14],
								NSParagraphStyleAttributeName : paragraphStyle};
		CGRect frame = CGRectMake(15, -4, 215, 44);
		[[cell.contentView viewWithTag:5] removeFromSuperview];
		UITextView *titleTextView = [[UITextView alloc] initWithFrame:frame];
		titleTextView.backgroundColor = [UIColor clearColor];
		titleTextView.font = [UIFont systemFontOfSize:14];
		titleTextView.scrollEnabled = NO;
		titleTextView.userInteractionEnabled = NO;
		titleTextView.tag = 5;
		titleTextView.textContainer.lineFragmentPadding = 0;
		NSLocale *locale = [NSLocale localeWithLocaleIdentifier:bill[@"locale"]];
		[self->currencyFormatter setLocale:locale];
		NSMutableAttributedString *titleString = [[NSMutableAttributedString alloc] initWithString:bill[@"offer_title"] attributes:attrs];
		NSMutableAttributedString *detailsString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"\nSale Price: %@\n%@", [self->currencyFormatter stringFromNumber:bill[@"offer_price"]], [self->dateFormatter stringFromDate:date]] attributes:attrs];
		[detailsString addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(0, [detailsString length])];
		[titleString appendAttributedString:detailsString];
		titleTextView.attributedText = titleString;
		[titleTextView sizeToFit];
		[self->dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
		[cell.contentView addSubview:titleTextView];
		[self->currencyFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
		UILabel *feesLabel = (UILabel *)[cell.contentView viewWithTag:10];
		float price = [bill[@"offer_price"] floatValue]*[[(self->unpaidBills)[(NSUInteger) (indexPath.row - 1)] objectForKey:@"USD_Exchange"] floatValue];
		NSNumber *feesN = @((float) (price * 0.06));
		NSString *fees = [self->currencyFormatter stringFromNumber:feesN];
		feesLabel.text = fees;
    }
		
	return cell;
}

- (float)calculateBillingTotal {
	float total = 0;
	for (NSDictionary *bill in self->unpaidBills) {
		float price = [[bill[@"bill"] objectForKey:@"offer_price"] floatValue];
		float exchange = [bill[@"USD_Exchange"] floatValue];
		total += price*exchange;
	}
	return total;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([tableView numberOfRowsInSection:0] == indexPath.row+1) {
		[self payMyBill:self->userInfo.user.id];
	}
}

-(void)payMyBill:(NSInteger)userid {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://zaporbit.com/cart/billingpayout/%ld", (long)userid]]];
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
