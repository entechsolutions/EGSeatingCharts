//
//  SeatingChartsScene.h
//  EventGridManager
//
//  Created by Антон Ковальчук on 14.05.14.
//  Copyright (c) 2014 Антон Ковальчук. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class SeatingChart;
@class SeatNode;

@protocol SeatingChartsProtocol <NSObject>
- (void) addOrderSeat:(SeatNode *)seatNode;
- (void) removeOrderSeat:(SeatNode *)seatNode;
@end

@interface SeatingChartsScene : SKScene

@property (nonatomic) CGSize contentSize;
@property (nonatomic) CGPoint contentOffset;
@property (weak, nonatomic) id<SeatingChartsProtocol> delegateSC;
@property (weak, nonatomic) UIButton *zoomOutButton;

- (instancetype) initWithSize:(CGSize)size;
- (void) createSeats:(SeatingChart *)seatingChart availableSeats:(NSArray *)availableSeats;
- (void) updateSelectedSeats:(NSArray *)ticketTypes;
- (void) zoomOut;

@end
