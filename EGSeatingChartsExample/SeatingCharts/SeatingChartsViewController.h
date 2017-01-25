//
//  SeatingChartsViewController2.h
//  EventGridManager
//
//  Created by Антон Ковальчук on 14.05.14.
//  Copyright (c) 2014 Антон Ковальчук. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import "TicketsViewController.h"

@interface SeatingChartsViewController : TicketsViewController
- (void) requestSeatingChartsWithLoader:(BOOL)withLoader;
+ (NSUInteger)controllerPosition;
+ (void)setControllerPosition:(NSUInteger)value;
@end
