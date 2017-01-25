//
//  LegendaScrollView.h
//  EventGridManager
//
//  Created by Anton Kovalchuk on 29.10.15.
//  Copyright © 2015 Entech Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Event;

@interface LegendaScrollView : UIScrollView

- (void)fillWithEntity:(Event *)event width:(CGFloat)width;

@end
