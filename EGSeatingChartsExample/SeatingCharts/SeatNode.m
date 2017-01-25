//
//  SeatNode.m
//  CustomerApp
//
//  Created by Антон Ковальчук on 03.06.14.
//  Copyright (c) 2014 Антон Ковальчук. All rights reserved.
//

#import "SeatNode.h"
#import "Seat.h"
#import "Ticket.h"
#import "Helper.h"
#import "UIColor+Extensions.h"

enum SeatState
{
    WasBuyed,
    HiddenType,
    Colored
};

@interface SeatNode()
@property (nonatomic, strong) SKSpriteNode *backgroundSprite;
@property (nonatomic, strong) SKSpriteNode *selectSprite;
@property (nonatomic, strong) SKSpriteNode *wheelchairSprite;
@end

@implementation SeatNode

- (instancetype)initWithSeat:(Seat *)seat ticketTypes:(NSArray *)ticketTypes
{
    if(self = [super init])
    {
        self.size = CGSizeMake(40, 40);
        self.seat = seat;
        self.userInteractionEnabled = YES;
        
        // 0 куплен
        // 1 скрытый тикет тайп
        // 2 цветной
        
        enum SeatState seatState = WasBuyed;
        
        NSString *ticketColor;
        for(Ticket *ticket in ticketTypes)
        {
            NSArray *_seats = ticket.seat_ids_attribute;
            
            if([_seats containsObject:seat.id_attribute])
            {
                ticketColor = ticket.seat_color_attribute;
                if(!ticket.hidden_attribute.boolValue)
                {
                    seatState = Colored;
                    break;
                }
                else
                {
                    seatState = HiddenType;
                    break;
                }
            }
        }
        
        UIColor *color;
        
        if(seat.is_hidden_attribute.boolValue)
        {
            self.enable = NO;
            color = [UIColor clearColor];
        }
        else if(!seat.ticket_type_id_attribute ||
                seatState == WasBuyed ||
                seatState == HiddenType)
        {
            self.enable = NO;
            color = [UIColor disabledButtonColor];
        }
        else
        {
            self.enable = YES;
            color = [Helper colorFromHexString: ticketColor];
        }

        if(!seat.is_hidden_attribute.boolValue)
        {
            self.backgroundSprite = [[SKSpriteNode alloc] initWithTexture:[SKTexture textureWithImageNamed:@"seat.png"] color:color size:CGSizeMake(30, 30)];
            self.backgroundSprite.colorBlendFactor = 1.0f;
            [self addChild:self.backgroundSprite];
            
            self.selectSprite = [[SKSpriteNode alloc] initWithTexture:[SKTexture textureWithImageNamed:@"seatBorder.png"]];
            self.selectSprite.size = CGSizeMake(30, 30);
            self.selectSprite.alpha = 0.0f;
            [self addChild:self.selectSprite];
            
            if(seat.has_wheelchair_access_attribute.boolValue)
            {
                self.wheelchairSprite = [[SKSpriteNode alloc] initWithTexture:[SKTexture textureWithImageNamed:@"wheelchair.png"]];
                self.wheelchairSprite.size = CGSizeMake(23, 23);
                self.wheelchairSprite.alpha = 1.0f;
                self.wheelchairSprite.position = CGPointMake(2.5, -2.5);
                [self addChild:self.wheelchairSprite];
            }
            else
            {
                SKLabelNode *numLabel = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
                numLabel.text = self.seat.number_attribute;
                numLabel.fontSize = 16.0f;
                numLabel.position = CGPointMake(0, -7.5);
                [self.backgroundSprite addChild:numLabel];
            }
        }
        else
        {
            self.hidden = YES;
        }
    }
    return self;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(self.enable4zoom)
    {
        if(self.enable)
        {
            if(self.select)
            {
                [self.selectSprite runAction:[SKAction fadeOutWithDuration:0.2]];
            }
            else
            {
                [self.selectSprite runAction:[SKAction fadeInWithDuration:0.2]];
            }
            self.select = !self.select;
            [self.delegate didSelectSeat:self];
        }
    }
    else
    {
        [self.delegate didClickSeat:self];
    }
}

- (void)unselectSprite
{
    self.selectSprite.alpha = 0.0f;
}

@end
