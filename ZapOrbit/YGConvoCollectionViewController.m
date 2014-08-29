//
//  YGConvoCollectionViewController.m
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 30/04/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import "YGConvoCollectionViewController.h"
#import "YGComposerViewController.h"

@interface YGConvoCollectionViewController ()

@end

@implementation YGConvoCollectionViewController
@synthesize details = _details;

- (void)setDetails:(NSDictionary *)details {
    _details = details;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.listLayout = [[UICollectionViewFlowLayout alloc] init];
    self.listLayout.itemSize = CGSizeMake(305, 74);
    self.listLayout.minimumLineSpacing = 5;
    self.listLayout.minimumInteritemSpacing = 5;
    self.listLayout.headerReferenceSize = CGSizeMake(310, 54);
    self.collectionView.collectionViewLayout = self.listLayout;

    self->userInfo = [YGUserInfo sharedInstance];

    self->dateFormater = [[NSDateFormatter alloc] init];
    [self->dateFormater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

    self->upBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"763-arrow-up"] style:UIBarButtonItemStylePlain target:self action:@selector(changetoConversation:)];
    self->downBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"764-arrow-down"] style:UIBarButtonItemStylePlain target:self action:@selector(changetoConversation:)];
    self->upBarButton.imageInsets = UIEdgeInsetsMake(3, 3, 3, 3);
    self->downBarButton.imageInsets = UIEdgeInsetsMake(4, 4, 4, 4);
    self->upBarButton.tag = 8;
    self->downBarButton.tag = 9;
    self->downBarButton.enabled = NO;
    self->upBarButton.enabled = NO;
    self.navigationItem.rightBarButtonItems = @[self->downBarButton, self->upBarButton];

    self.toUser = [YGUser userWithDictionary:(self.details)[@"toUser"]];
    self.me = (self.details)[@"me"];
    self.convid = (self.details)[@"convid"];
    self.convo = (self.details)[@"convo"];
    self.conversation = (self.convo)[@"conversation"];
    self.messages = (self.details)[@"messages"];
    self.conversations = (self.details)[@"allConversations"];
    [self getUsersPictures];

    int convoIndex = (int) [self.conversations indexOfObject:self.convo];
    if (convoIndex + 1 < self.conversations.count) {
        self->downBarButton.enabled = YES;
    }
    if (convoIndex - 1 > -1) {
        self->upBarButton.enabled = YES;
    }
    /*
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0.0f, self.collectionView.bounds.size.height-0.5, self.tableView.frame.size.width, 0.5f);
    topBorder.backgroundColor = [UIColor lightGrayColor].CGColor;
    [self.tableView.tableHeaderView.layer addSublayer:topBorder];
    [(UILabel *)[self.tableView.tableHeaderView viewWithTag:10] setText:[NSString stringWithFormat:@"re: %@", [self.conversation objectForKey:@"title"]]];
    */

    self->messagesHeights = [[NSMutableArray alloc] initWithCapacity:3];
    [self messagesHeights];

    self->textTransition = [CATransition animation];
    self->textTransition.duration = 0.3;
    self->textTransition.type = kCATransitionFade;
    self->textTransition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];

    self->imageViewsOfU = [[NSMutableArray alloc] initWithCapacity:2];
    self->imageViewsOfMe = [[NSMutableArray alloc] initWithCapacity:2];

    self.collectionView.contentInset = UIEdgeInsetsMake(0, 0, 5, 0);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getUsersPictures {
    self->uPicImage = nil;
    NSURL *picUserURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", self.toUser.fbuserid]];
    NSURLSessionDataTask *meSession = [[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]]
									   dataTaskWithURL:picUserURL
									   completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if ([(NSHTTPURLResponse *) response statusCode] == 200 && data) {
            self->uPicImage = (YGImage *) [UIImage imageWithData:data];
        }
        if (self->mePicImage == nil) {
            NSURL *picMeURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", self.me.fbuserid]];
            NSURLSessionDataTask *uSession = [[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]]
											  dataTaskWithURL:picMeURL
											  completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                if ([(NSHTTPURLResponse *) response statusCode] == 200 && data) {
                    self->mePicImage = (YGImage *) [UIImage imageWithData:data];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.collectionView reloadData];
                });
            }];
            [uSession resume];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
            });
        }
    }];
    [meSession resume];
}

- (void)messagesHeights {
    [self->messagesHeights removeAllObjects];
    CGRect frame = CGRectMake(0, 0, 260, 26);
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:frame];
    messageLabel.numberOfLines = 0;
    NSMutableParagraphStyle *messageStyle = [[NSMutableParagraphStyle alloc] init];
    messageStyle.lineHeightMultiple = 1.5f;
    NSDictionary *attrs = @{NSFontAttributeName : [UIFont systemFontOfSize:14],
            NSParagraphStyleAttributeName : messageStyle};
    for (NSDictionary *message in self.messages) {
        [messageLabel setFrame:frame];
        messageLabel.attributedText = [[NSAttributedString alloc] initWithString:message[@"message"] attributes:attrs];
        [messageLabel sizeToFit];
        [messagesHeights addObject:@(messageLabel.bounds.size.height)];
    }
}

- (void)changetoConversation:(UIBarButtonItem *)sender {

    int convoIndex = (int) [self.conversations indexOfObject:self.convo];

    if (sender.tag == 9 && convoIndex + 1 < self.conversations.count) {
        self.convo = (self.conversations)[(NSUInteger) (convoIndex + 1)];

        if (convoIndex + 2 < self.conversations.count) {
            self->upBarButton.enabled = YES;
        }

        if (convoIndex + 2 == self.conversations.count) {
            [self->downBarButton setEnabled:NO];
        }

    } else if (sender.tag == 8 && convoIndex - 1 > -1) {
        self.convo = (self.conversations)[(NSUInteger) (convoIndex - 1)];

        if (convoIndex - 1 > -1) {
            self->downBarButton.enabled = YES;
        }

        if (convoIndex - 2 < 0) {
            [self->upBarButton setEnabled:NO];
        }

    } else return;

    self.conversation = (self.convo)[@"conversation"];
    NSDictionary *user1 = (self.convo)[@"user1"];
    NSDictionary *user2 = (self.convo)[@"user2"];
    if ([user1[@"id"] longLongValue] == self->userInfo.user.id) {
        self.toUser = [YGUser userWithDictionary:user2];
    } else self.toUser = [YGUser userWithDictionary:user1];
    self.convid = (self.conversation)[@"id"];

    self.messages = (self.conversation)[@"messages"];
    self.me = self->userInfo.user;
    [self messagesHeights];
    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];

    [self getUsersPictures];
}

#pragma mark - CollectionView related methods

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(305, [(self->messagesHeights)[self.messages.count - indexPath.row - 1] floatValue] + 110);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.messages.count;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    static NSString *headerIdentifier = @"collectionViewHeader";
    UICollectionReusableView *collectionViewHeather;
    collectionViewHeather = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:headerIdentifier forIndexPath:indexPath];
    UICollectionViewLayoutAttributes *attrs = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:kind withIndexPath:indexPath];
    [collectionViewHeather applyLayoutAttributes:attrs];
    if ([collectionViewHeather viewWithTag:10]) {
        [(UILabel *) [collectionViewHeather viewWithTag:10] setText:(self.conversation)[@"title"]];
    }
    return collectionViewHeather;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *cellIdentifier = @"cellIdentifier";

    UICollectionViewCell *cell;


    NSDictionary *message;
    NSDate *createdDate;
    NSString *dateString;
    UITextView *messageView;
    //CGSize messageSize;
    //NSLayoutConstraint *heightConstraint;
    //NSLayoutConstraint *widthConstraint;
    YGRatingView *rating;

    switch (indexPath.section) {
        case 0:
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
            cell.contentView.layer.cornerRadius = 2;
            message = (self.messages)[self.messages.count - indexPath.row - 1];

            [(UILabel *) [cell.contentView viewWithTag:12] setText:[message[@"senderid"] longLongValue] == self.me.id ? self.me.fullName : self.toUser.fullName];
            dateString = message[@"created_on"];
            createdDate = [self->dateFormater dateFromString:[dateString substringToIndex:dateString.length - 2]];
            [(UILabel *) [cell.contentView viewWithTag:16] setText:[createdDate formattedDateRelativeToNow:createdDate]];
            [(UILabel *) [cell.contentView viewWithTag:14] setNumberOfLines:2];

            messageView = (UITextView *) [cell.contentView viewWithTag:45];
            messageView.layoutManager.delegate = self;
            messageView.text = [NSString stringWithFormat:@"\u00BB %@", message[@"message"]];
            //messageSize = CGSizeMake(messageView.bounds.size.width, [[self->messagesHeights objectAtIndex:self.messages.count-indexPath.row-1] floatValue]);
            //[messageView setContentSize:messageSize];

            if ([message[@"senderid"] longLongValue] == self.me.id) {
                if (self->mePicImage) {
                    [[[cell.contentView viewWithTag:66] viewWithTag:55] removeFromSuperview];
                    UIImageView *picView = [[UIImageView alloc] initWithImage:[self->mePicImage copy]];
                    picView.contentMode = UIViewContentModeScaleAspectFill;
                    picView.tag = 55;
                    [picView setFrame:CGRectMake(0, 0, 60, 60)];
                    [[cell.contentView viewWithTag:66] addSubview:picView];
                }
            } else if ([message[@"senderid"] longLongValue] == self.toUser.id) {
                if (self->uPicImage) {
                    [[[cell.contentView viewWithTag:66] viewWithTag:55] removeFromSuperview];
                    UIImageView *picView = [[UIImageView alloc] initWithImage:[self->uPicImage copy]];
                    picView.contentMode = UIViewContentModeScaleAspectFill;
                    picView.tag = 55;
                    [picView setFrame:CGRectMake(0, 0, 60, 60)];
                    [[cell.contentView viewWithTag:66] addSubview:picView];
                }
            }
            if ([message[@"senderid"] longLongValue] == self.toUser.id) {
                UIColor *backgroundColor = [UIColor colorWithRed:247 / 255.f green:248 / 255.f blue:249 / 255.f alpha:1];
                [messageView setBackgroundColor:backgroundColor];
                [cell.contentView setBackgroundColor:backgroundColor];
            } else {
                [messageView setBackgroundColor:[UIColor whiteColor]];
                [cell.contentView setBackgroundColor:[UIColor whiteColor]];
            }
            rating = (YGRatingView *) [cell.contentView viewWithTag:50];
            [rating setRating:1.0 animated:NO];
            [rating setRatingText:@"Basic Level"];

            break;
        default:
            break;
    }
    return cell;
}

- (void)messageSent {
    [self dismissViewControllerAnimated:YES completion:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)messageDiscarded {
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (CGFloat)layoutManager:(NSLayoutManager *)layoutManager lineSpacingAfterGlyphAtIndex:(NSUInteger)glyphIndex withProposedLineFragmentRect:(CGRect)rect {
    return 7.5;
}

- (IBAction)replyToConvo:(id)sender {
    UIStoryboard *sb = [self.navigationController storyboard];
    UINavigationController *composerNav = [sb instantiateViewControllerWithIdentifier:@"composerNav"];
    UIBarButtonItem *discardButton = [[UIBarButtonItem alloc] initWithTitle:@"Discard" style:UIBarButtonItemStylePlain target:self action:@selector(messageDiscarded)];
    UIBarButtonItem *sendButton = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStyleDone target:self action:@selector(messageSent)];
    [[composerNav.childViewControllers[0] navigationItem] setLeftBarButtonItem:discardButton];
    [[composerNav.childViewControllers[0] navigationItem] setRightBarButtonItem:sendButton];
    NSDictionary *details = @{@"toUser" : self.toUser, @"me" : self.me, @"convid" : self.convid, @"title" : (self.conversation)[@"title"]};
    [composerNav.childViewControllers[0] setDetails:details];
    [composerNav.childViewControllers[0] setReplying:@1];
    [self presentViewController:composerNav animated:YES completion:^{

    }];
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
