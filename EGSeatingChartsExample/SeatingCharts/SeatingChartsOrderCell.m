//
//  SeatingChartsOrderCell.m
//  CustomerApp
//
//  Created by Антон Ковальчук on 10.04.15.
//  Copyright (c) 2015 Антон Ковальчук. All rights reserved.
//

#import "SeatingChartsOrderCell.h"
#import "UIView+AutoLayout.h"
#import "UIColor+Extensions.h"
#import "Helper.h"
#import "TicketVariant.h"
#import "Ticket.h"
#import "Instance.h"
#import "Venue.h"
#import "Event.h"
#import "SeatCartItemDto.h"
#import "Seat.h"
#import "Row.h"
#import "Section.h"

@implementation SeatingChartsOrderCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeueLTStd-Cn" size:18];
        self.titleLabel.textColor = [UIColor labelGrayColor];
        [self addSubview:self.titleLabel];
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.titleLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self withOffset:15.0f];
        [self.titleLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self withOffset:-100.0f];
        [self.titleLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self withOffset:-10.0f];
        
        self.subTitleLabel = [[UILabel alloc] init];
        self.subTitleLabel.font = [UIFont fontWithName:@"HelveticaNeueLTStd-Cn" size:14];
        self.subTitleLabel.textColor = [UIColor cellSectionTitleColor];
        [self addSubview:self.subTitleLabel];
        self.subTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.subTitleLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self withOffset:15.0f];
        [self.subTitleLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self withOffset:10.0f];
        
        self.priceLabel = [[UILabel alloc] init];
        self.priceLabel.font = [UIFont fontWithName:@"HelveticaNeueLTStd-Cn" size:18];
        self.priceLabel.textColor = [UIColor navigationBarColor];
        [self addSubview:self.priceLabel];
        self.priceLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.priceLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self withOffset:-15.0f];
        [self.priceLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self withOffset:0.0f];
        
        self.topLine = [[UIView alloc] init];
        self.topLine.backgroundColor = [UIColor separatorColor];
        [self addSubview:self.topLine];
        self.topLine.translatesAutoresizingMaskIntoConstraints = NO;
        [self.topLine autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:15.0f];
        [self.topLine autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:15.0f];
        [self.topLine autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0.0f];
        [self.topLine autoSetDimension:ALDimensionHeight toSize:[InterfaceMode isRetina] ? 0.5f : 1.0f];
        
        self.bottomLine = [[UIView alloc] init];
        self.bottomLine.hidden = YES;
        self.bottomLine.backgroundColor = [UIColor separatorColor];
        [self addSubview:self.bottomLine];
        self.bottomLine.translatesAutoresizingMaskIntoConstraints = NO;
        [self.bottomLine autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:15.0f];
        [self.bottomLine autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:15.0f];
        [self.bottomLine autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0.0f];
        [self.bottomLine autoSetDimension:ALDimensionHeight toSize:[InterfaceMode isRetina] ? 0.5f : 1.0f];
    }
    return self;
}

- (void)fillWithEntity:(CartItemDtoBase *)cartItemDtoBase instance:(Instance *)instance
{
    if(cartItemDtoBase.type_attribute.intValue == SeatT)
    {
        SeatCartItemDto *findSeatCartItemDto = (SeatCartItemDto *)cartItemDtoBase;
        
        self.tag = findSeatCartItemDto.seat.id_attribute.intValue;
        
        Row *thisRow = nil;
        for(Row *row in findSeatCartItemDto.seat.section.rows)
        {
            if([row.grid_row_attribute isEqualToNumber:findSeatCartItemDto.seat.grid_row_attribute])
                thisRow = row;
        }
        
        
        self.subTitleLabel.text = [NSString stringWithFormat:@"Section:%@ Row:%@ Seat:%@",findSeatCartItemDto.seat.section.name_attribute, thisRow.number_attribute, findSeatCartItemDto.seat.number_attribute];
    }
    else
    {
        
    }
    
    NSString *name;
    if(cartItemDtoBase.ticket_variant.name_attribute)
        name = [NSString stringWithFormat:@"%@ (%@)",cartItemDtoBase.ticket_variant.ticket.name_attribute, cartItemDtoBase.ticket_variant.name_attribute];
    else
        name = cartItemDtoBase.ticket_variant.ticket.name_attribute;
    self.titleLabel.text = name;

    
    NSString *price;
    if(cartItemDtoBase.ticket_variant.ticket.type_attribute.intValue == Donation)
        price = [Helper convertMoney:cartItemDtoBase.donation_price_attribute withCode:nil];
    else
        price = [Helper convertMoney:cartItemDtoBase.ticket_variant.price_attribute withCode:nil];
    
    if(instance.event.has_schedule_attribute.boolValue ||
       instance.event.venue.has_reserved_seatings_attribute.boolValue)
    {
        self.priceLabel.text = price;
    }
    else
    {
        NSMutableAttributedString *infoAttributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ldx %@", (unsigned long)cartItemDtoBase.ticket_variant.cart_items_dto_base.count,price]];
        
        [infoAttributedString addAttribute: NSForegroundColorAttributeName value: [UIColor labelGrayColor] range: NSMakeRange(0,  [NSString stringWithFormat:@"%ldx", (unsigned long)cartItemDtoBase.ticket_variant.cart_items_dto_base.count].length)];
        [infoAttributedString addAttribute: NSForegroundColorAttributeName value: [UIColor navigationBarColor] range: NSMakeRange([NSString stringWithFormat:@"%ldx", (unsigned long)cartItemDtoBase.ticket_variant.cart_items_dto_base.count].length + 1,price.length)];
        
        self.priceLabel.attributedText = infoAttributedString;
    }
}


@end
