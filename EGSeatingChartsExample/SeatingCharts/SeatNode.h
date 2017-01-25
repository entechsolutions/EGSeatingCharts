//
//  SeatNode.h
//  CustomerApp
//
//  Created by Антон Ковальчук on 03.06.14.
//  Copyright (c) 2014 Антон Ковальчук. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "EGDatasources.h"

@class SeatNode;

@protocol SeatNodeProtocol <NSObject>
- (void) didSelectSeat:(SeatNode *)target;
- (void) didClickSeat:(SeatNode *)target;
@end

@interface SeatNode : SKSpriteNode
- (instancetype)initWithSeat:(id<SeatDatasource>)seat
                       event:(id<EventDatasource>)event;
- (void)unselectSprite;
@property (nonatomic, weak) id<SeatDatasource> seat;
@property (nonatomic, weak) id<SeatNodeProtocol> delegate;
@property (nonatomic) BOOL select;
@property (nonatomic) BOOL enable;
@property (nonatomic) BOOL enable4zoom;
@end
