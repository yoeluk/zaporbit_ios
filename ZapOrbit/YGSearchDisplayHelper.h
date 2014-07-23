//
//  YGSearchDisplayHelper.h
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 22/04/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppSettings.h"

@interface YGSearchDisplayHelper : UITableViewController <UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate> {
	AppSettings *appSettings;
}

@property (assign) id shoppingController;
@property (strong, nonatomic) NSMutableArray *history;

+ (YGSearchDisplayHelper *)initWithShoppingController:(id)shoppingController;

@end
