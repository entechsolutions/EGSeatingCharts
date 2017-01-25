//
//  EGDatasources.h
//  EGSeatingChartsExample
//
//  Created by Danila Parkhomenko on 25/01/2017.
//  Copyright © 2017 ENtechsolutions. All rights reserved.
//

#ifndef EGDatasources_h
#define EGDatasources_h

@protocol ShapeDatasource <NSObject>
- (NSInteger)shapeTypeID;
- (CGSize)scale;
- (CGPoint)pos;
- (float)rotationAngle;
- (NSString *)name;
@end

@protocol SeatDatasource <NSObject>
- (NSInteger)gridRow;
- (NSInteger)gridColumn;
- (BOOL)hidden;
- (BOOL)reserved;
- (BOOL)hasWheelchairAccess;
- (BOOL)hasTicketType;
- (NSString *)number;
@end

@protocol ChartRowDatasource <NSObject>
- (NSNumber *)seatsInRow;
- (NSInteger)gridRow;
- (NSString *)number;
@end

@protocol ChartSectionDatasource <NSObject>
//- (void)enumerateSeats:(void(^)(id<SeatDatasource> seat, NSInteger idx, BOOL *stop)) callback;
- (NSArray <id<SeatDatasource>> *)seats;
- (NSArray <id<ChartRowDatasource>> *)sortedRows;

- (CGPoint)pos;
- (NSInteger)gridWidth;
- (NSInteger)gridHeight;

- (float)skew;
- (float)curvePercent;
- (float)rotation;
- (BOOL)hideName;
- (NSString *)name;
@end

@protocol SeatingChartDatasource
- (NSArray <id<ChartSectionDatasource>> *)sortedSections;
- (NSMutableArray <id<ShapeDatasource>> *)shapes;
@end

@protocol TicketVariantDatasource <NSObject>
@end

@protocol TicketTypeDatasource <NSObject>
//- (void)enumerateVariants:(void(^)(id<TicketVariantDatasource> variant, NSInteger idx, BOOL *stop)) callback;
- (UIColor *)seatColor;
- (NSString *)name;
- (BOOL)hidden;
- (BOOL)isAddon;
- (NSAttributedString *)attributedDescription;
- (BOOL)containsSeat:(id<SeatDatasource>)seat;
@end

@protocol EventDatasource
- (void)enumerateTicketTypes:(void(^)(id<TicketTypeDatasource> ticketType, NSInteger idx, BOOL *stop)) callback;
@end


#endif /* EGDatasources_h */
