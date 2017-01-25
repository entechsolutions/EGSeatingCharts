//
//  LegendaScrollView.m
//  EventGridManager
//
//  Created by Anton Kovalchuk on 29.10.15.
//  Copyright © 2015 Entech Solutions. All rights reserved.
//

#import "LegendaScrollView.h"
#import "Event.h"
#import "Ticket.h"
#import "TicketVariant.h"
#import "Section.h"
#import "Seat.h"
#import "SeatingChart.h"
#import "Helper.h"
#import "UIColor+Extensions.h"
#import "UIView+AutoLayout.h"

@implementation LegendaScrollView


- (void)fillWithEntity:(Event *)event width:(CGFloat)width
{
    [self.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    
    int currentTicket = 0;
    int pageCount = 0;
    for(int i = 0; i < event.ticketTypes.count + 1; ++i)
    {
        Ticket *ticket;
        
        if(i != event.ticketTypes.count)
        {
            ticket = [event.ticketTypes.allObjects objectAtIndex:i];
            
            if(ticket.hidden_attribute.boolValue || ticket.is_addon_attribute.boolValue)
                continue;
        }
        if(!(currentTicket % 3))
            ++pageCount;
        
        UIView *colorView = [[UIView alloc] init];
        if(i == event.ticketTypes.count)
            colorView.backgroundColor = [UIColor lightGrayColor];
        else
            colorView.backgroundColor = [Helper colorFromHexString: ticket.seat_color_attribute];
        
        colorView.layer.cornerRadius = 3.0f;
        colorView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:colorView];
        [colorView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self withOffset:15.0f + (pageCount - 1) * width];
        [colorView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self withOffset:-50.0f + 20.0f * (currentTicket % 3)];
        [colorView autoSetDimension:ALDimensionHeight toSize:12.0f];
        [colorView autoSetDimension:ALDimensionWidth toSize:12.0f];
        
        UILabel *legendaLabel = [[UILabel alloc] init];
        legendaLabel.font = [UIFont fontWithName:@"HelveticaNeueLTStd-Cn" size:12];
        legendaLabel.textColor = [UIColor labelGrayColor];
        legendaLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:legendaLabel];
        [legendaLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:colorView withOffset:5.0f];
        [legendaLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:colorView withOffset:0.0f];
        [legendaLabel autoSetDimension:ALDimensionWidth toSize:width - 50.0f];
        
        if(i == event.ticketTypes.count)
        {
            legendaLabel.text = @"Sold Seats";
        }
        else
        {
            NSUInteger availableTickets = 0;
            
            for(Section *section in event.seating_charts.sections)
            {
                for(Seat *seat in section.seats)
                {
                    if([ticket.seat_ids_attribute containsObject:seat.id_attribute] && !seat.is_reserved_attribute.boolValue)
                    {
                        ++availableTickets;
                    }
                }
            }
            
            
            NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",ticket.name_attribute]];
            
            
            TicketVariant *ticketVariant = ticket.variants.anyObject;
            if(ticketVariant)
            {
                [string appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" (%lu) -",(unsigned long)availableTickets]]];
                
                NSString *price = nil;
                
                if(ticket.variants.count > 1)
                {
                    TicketVariant *minTicketVariant = ticket.variants.allObjects.firstObject;
                    TicketVariant *maxTicketVariant = ticket.variants.allObjects.firstObject;
                    
                    for(TicketVariant *ticketVariant in ticket.variants)
                    {
                        if ([ticketVariant.price_attribute compare:minTicketVariant.price_attribute] == NSOrderedAscending)
                            minTicketVariant = ticketVariant;
                        if ([ticketVariant.price_attribute compare:maxTicketVariant.price_attribute] == NSOrderedDescending)
                            maxTicketVariant = ticketVariant;
                    }
                    
                    price = [NSString stringWithFormat:@"%@ - %@", [Helper convertMoney:minTicketVariant.price_attribute withCode:nil], [Helper convertMoney:maxTicketVariant.price_attribute withCode:nil]];
                }
                else
                {
                    price = [Helper convertMoney:ticketVariant.price_attribute withCode:nil];
                }
                [string appendAttributedString: [[NSAttributedString alloc] initWithString:price
                                                                                attributes:@{NSStrokeWidthAttributeName: [NSNumber numberWithFloat:-3.0], NSStrokeColorAttributeName:[UIColor blackColor]}]];
            }
            
            legendaLabel.attributedText = string;
        }
        
        ++currentTicket;
    }
    
    self.contentSize = CGSizeMake(width * pageCount, 80.0f);
}

@end
