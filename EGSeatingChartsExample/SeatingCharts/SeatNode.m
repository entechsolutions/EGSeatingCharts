//
//  SeatNode.m
//  CustomerApp
//
//  Created by Антон Ковальчук on 03.06.14.
//  Copyright (c) 2014 Антон Ковальчук. All rights reserved.
//

#import "SeatNode.h"
#import "UIColor+EGCharts.h"

typedef enum : NSUInteger {
    SeatStateBought = 0,
    SeatStateHiddenType = 1,
    SeatStateColoured = 2
} SeatState;

@interface SeatNode()
@property (nonatomic, strong) SKSpriteNode *backgroundSprite;
@property (nonatomic, strong) SKSpriteNode *selectSprite;
@property (nonatomic, strong) SKSpriteNode *wheelchairSprite;
@end

@implementation SeatNode

- (instancetype)initWithSeat:(id<SeatDatasource>)seat event:(id<EventDatasource>)event
{
    if(self = [super init])
    {
        self.size = CGSizeMake(40, 40);
        self.seat = seat;
        self.userInteractionEnabled = YES;
        
        __block SeatState seatState = SeatStateBought;
        
        __block UIColor *ticketColor;
        [event enumerateTicketTypes:^(id<TicketTypeDatasource> ticketType, BOOL *stop) {
            if ([ticketType containsSeat:seat])
            {
                ticketColor = [ticketType seatColor];
                seatState = [ticketType hidden]?SeatStateHiddenType:SeatStateColoured;
                *stop = YES;
            }
        }];
        
        UIColor *color;
        
        if([seat hidden])
        {
            self.enable = NO;
            color = [UIColor clearColor];
        }
        else if(![seat hasTicketType] ||
                seatState == SeatStateBought ||
                seatState == SeatStateHiddenType)
        {
            self.enable = NO;
            color = [UIColor disabledButtonColor];
        }
        else
        {
            self.enable = YES;
            color = ticketColor;
        }

        if(![seat hidden])
        {
            self.backgroundSprite = [[SKSpriteNode alloc] initWithTexture:[SKTexture textureWithImageNamed:@"seat.png"] color:color size:CGSizeMake(30, 30)];
            self.backgroundSprite.colorBlendFactor = 1.0f;
            [self addChild:self.backgroundSprite];
            
            self.selectSprite = [[SKSpriteNode alloc] initWithTexture:[SKTexture textureWithImageNamed:@"seatBorder.png"]];
            self.selectSprite.size = CGSizeMake(30, 30);
            self.selectSprite.alpha = 0.0f;
            [self addChild:self.selectSprite];
            
            if ([seat hasWheelchairAccess])
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
                numLabel.text = [self.seat number];
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
