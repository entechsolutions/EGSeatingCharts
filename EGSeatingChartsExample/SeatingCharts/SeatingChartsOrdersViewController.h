//
//  SeatingChartsOrdersViewController.h
//  CustomerApp
//
//  Created by Антон Ковальчук on 10.04.15.
//  Copyright (c) 2015 Антон Ковальчук. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@class Instance;

@interface SeatingChartsOrdersViewController : BaseViewController
- (instancetype) initWithInstance:(Instance *)instance showEventInfo:(BOOL)showEventInfo;
@end
