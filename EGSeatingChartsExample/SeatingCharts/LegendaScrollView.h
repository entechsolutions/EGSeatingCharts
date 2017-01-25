//
//  LegendaScrollView.h
//  EventGridManager
//
//  Created by Anton Kovalchuk on 29.10.15.
//  Copyright © 2015 Entech Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGDatasources.h"

@interface LegendaScrollView : UIScrollView

- (void)fillWithEntity:(id<EventDatasource>)event width:(CGFloat)width;

@end
