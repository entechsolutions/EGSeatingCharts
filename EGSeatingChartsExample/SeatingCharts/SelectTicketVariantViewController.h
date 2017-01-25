//
//  SelectTicketVariantViewController.h
//  EventGridManager
//
//  Created by Anton Kovalchuk on 03.06.15.
//  Copyright (c) 2015 Entech Solutions. All rights reserved.
//
@class SeatNode, TicketVariant;

#import <UIKit/UIKit.h>

@protocol SelectTicketVariantViewControllerProtocol <NSObject>
- (void)didPressButtonForSeat:(SeatNode *)seatNode ticketVariant:(TicketVariant *)ticketVariant;
@end

@interface SelectTicketVariantViewController : UIViewController
- (instancetype) initWithSeat:(SeatNode *)seatNode ticketVariants:(NSArray *)ticketVariants;
@property (nonatomic, weak) id<SelectTicketVariantViewControllerProtocol> delegate;
@end
