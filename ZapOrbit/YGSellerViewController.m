//
//  YGSellerViewController.m
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 10/04/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import "YGSellerViewController.h"
#import "YGRatingView.h"

static NSString *kApiUrl = @"https://zaporbit.com/api/";

@interface YGSellerViewController ()

@end

@implementation YGSellerViewController

-(void)setUser:(YGUser *)user {
	_user = user;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	self.tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
	
	CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0.0f, 0.0f, self.tableView.frame.size.width, 0.5f);
    topBorder.backgroundColor = [UIColor lightGrayColor].CGColor;
    [self.tableViewHeader.layer addSublayer:topBorder];
	
	self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", _user.name, _user.surname];
	
	CGRect rect = CGRectMake(105, 39, 150, 50);
	YGRatingView *tempRating = [[YGRatingView alloc] initWithFrame:rect];
	tempRating.tag = 50;
	[self.tableViewHeader addSubview:tempRating];
	[tempRating setRating:1.0 animated:YES];
	[tempRating setRatingText:@"Basic Level"];
	
	NSURL *picURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", _user.fbuserid]];
	NSURLSessionDataTask *session = [[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]] dataTaskWithURL:picURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
		if ([(NSHTTPURLResponse *)response statusCode] == 200 && data) {
			dispatch_async(dispatch_get_main_queue(), ^{
				[self fetchedUserPic:data];
			});
		} else NSLog(@"no pic data");
	}];
	[session resume];
	
	NSURL *ratingURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@getfeedbacksforuser/%lu", kApiUrl, (unsigned long)_user.id]];
	NSURLSessionDataTask *ratingSession = [[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]] dataTaskWithURL:ratingURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
		if ([(NSHTTPURLResponse *)response statusCode] == 200 && data) {
			dispatch_async(dispatch_get_main_queue(), ^{
				NSDictionary *dataObj = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
				self->feedbacks = [dataObj objectForKey:@"feedbacks"];
				self->rating = [dataObj objectForKey:@"rating"];
				if (![self->rating isEqual:[NSNull null]]) {
					float ratingValue = [[self->rating objectForKey:@"rating"] floatValue];
					[(YGRatingView *)[self.tableViewHeader viewWithTag:50] setRating:0 animated:NO];
					[(YGRatingView *)[self.tableViewHeader viewWithTag:50] setRating:ratingValue animated:YES];
				}
				[self.tableView reloadData];
			});
		}
	}];
	[ratingSession resume];
}

-(void)fetchedUserPic:(NSData *)picData {
	[[_ovalPicView viewWithTag:55] removeFromSuperview];
	UIImageView *picView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:picData]];
	picView.contentMode = UIViewContentModeScaleAspectFill;
	picView.tag = 55;
	[picView setFrame:CGRectMake(-25, 15, 70, 70)];
	[_ovalPicView addSubview:picView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	CGFloat height = section == 0 || section == 2 ? 0 : 35;
	return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	float height = indexPath.section == 0 && indexPath.row == 0 ? 2 : 49;
	return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 35)];
	[view setBackgroundColor:[UIColor colorWithRed:230/255.f green:229/255.f blue:233/255.f alpha:1]];
	CALayer *bottom = [CALayer layer];
	bottom.frame = CGRectMake(0, 35, tableView.frame.size.width, 0.5f);
	bottom.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1].CGColor;
	[view.layer addSublayer:bottom];
	CALayer *topBorder = [CALayer layer];
	topBorder.frame = CGRectMake(0.0f, 0.0f, tableView.frame.size.width, 0.5f);
	topBorder.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1].CGColor;
	[view.layer addSublayer:topBorder];
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, view.frame.size.height-18, 300, 10)];
	NSString *titleTex = @"FEEDBACKS";
	[titleLabel setText:titleTex];
	[titleLabel setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]];
	[titleLabel setTextColor:[UIColor lightGrayColor]];
	[view addSubview:titleLabel];
	return section == 0 || section == 2 ? nil : view;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return section == 0 ? 2 : self->feedbacks ? self->feedbacks.count : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *cellIdentifier = @"Cell";
	static NSString *feedbackCellIdentifier = @"feedbackCell";
	
	UITableViewCell *cell;
	
	switch (indexPath.section) {
		case 0:
			cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
			if (indexPath.row == 0) {
				cell.accessoryType = UITableViewCellAccessoryNone;
				cell.separatorInset = UIEdgeInsetsMake(0, 55, 0, 0);
			} else if (indexPath.row == 1) {
				cell.accessoryType = UITableViewCellAccessoryNone;
				UIImageView *picView = (UIImageView *)[cell.contentView viewWithTag:10];
				picView.image = [[UIImage imageNamed:@"754-scale"] imageWithTintColor:[UIColor colorWithRed:0 green:122/255.f blue:1 alpha:1]];
				picView.contentMode = UIViewContentModeScaleAspectFit;
				UILabel *cellTitle = (UILabel *)[cell.contentView viewWithTag:11];
				cellTitle.text = @"Ratings";
				UILabel *amountLabel = (UILabel *)[cell.contentView viewWithTag:12];
				if ([self->rating isEqual:[NSNull null]]) amountLabel.text = @"0";
				else amountLabel.text = [NSString stringWithFormat:@"%ld", (long)[[self->rating objectForKey:@"total_ratings"] integerValue]];
				[amountLabel sizeToFit];
				CGRect rect = amountLabel.frame;
				rect.size.height += 4;
				rect.size.width += 12;
				rect.origin.x = self.view.bounds.size.width-(rect.size.width+15);
				amountLabel.frame = rect;
				amountLabel.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
				amountLabel.textColor = [UIColor whiteColor];
				amountLabel.font = [UIFont boldSystemFontOfSize:14];
				[amountLabel.layer setCornerRadius:10.f];
			}
			break;
		case 1:
			cell = [tableView dequeueReusableCellWithIdentifier:feedbackCellIdentifier forIndexPath:indexPath];
			cell.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0);
			if (self->feedbacks) {
				NSString *feedback = [[self->feedbacks objectAtIndex:indexPath.row] objectForKey:@"feedback"];
				cell.textLabel.text = [NSString stringWithFormat:@"\"%@\"", feedback];
				cell.textLabel.font = [UIFont systemFontOfSize:14];
				cell.textLabel.numberOfLines = 2;
			}
			break;
			
		default:
			break;
	}
	return cell;
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
