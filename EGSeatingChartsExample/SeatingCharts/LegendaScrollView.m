//
//  LegendaScrollView.m
//  EventGridManager
//
//  Created by Anton Kovalchuk on 29.10.15.
//  Copyright © 2015 Entech Solutions. All rights reserved.
//

#import "LegendaScrollView.h"
#import "UIColor+EGCharts.h"
#import <PureLayout/PureLayout.h>

@implementation LegendaScrollView

- (void)fillPageWithTicket:(id<TicketTypeDatasource>) ticket
                     width:(CGFloat)width
                 pageCount:(NSInteger)pageCount
             currentTicket:(NSInteger)currentTicket {
    if ((currentTicket % 3) == 0)
        pageCount++;
    
    UIView *colorView = [[UIView alloc] init];
    if (ticket == nil)
        colorView.backgroundColor = [UIColor lightGrayColor];
    else
        colorView.backgroundColor = [ticket seatColor];
    
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
    
    if (ticket == nil)
    {
        legendaLabel.text = @"Sold Seats";
    }
    else
    {
        legendaLabel.attributedText = [ticket attributedDescription];
    }
    
}

- (void)fillWithEntity:(id<EventDatasource>)event width:(CGFloat)width
{
    [self.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    
    __block NSInteger currentTicket = 0;
    __block NSInteger pageCount = 0;
    
    [event enumerateTicketTypes:^(id<TicketTypeDatasource> ticket, BOOL *stop) {
        if ([ticket hidden] || [ticket isAddon]) {
            
        } else {
            if(!(currentTicket % 3))
                pageCount++;
            [self fillPageWithTicket:ticket
                               width:width
                           pageCount:pageCount
                       currentTicket:currentTicket];
            currentTicket++;
        }
    }];
    if(!(currentTicket % 3))
        pageCount++;
    [self fillPageWithTicket:nil width:width pageCount:pageCount currentTicket:currentTicket];
    
    self.contentSize = CGSizeMake(width * pageCount, 80.0f);
}

@end
