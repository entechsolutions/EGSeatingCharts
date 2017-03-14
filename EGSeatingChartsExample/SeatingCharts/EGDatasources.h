//
//  EGDatasources.h
//  EGSeatingChartsExample
//
//  Created by Danila Parkhomenko on 25/01/2017.
//  Copyright © 2017 ENtechsolutions. All rights reserved.
//

#ifndef EGDatasources_h
#define EGDatasources_h
#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    ChartShapeTypeNone = 0,
    ChartShapeTypeRectangle = 10,
    ChartShapeTypeLine = 20
} ChartShapeType;

/*
   https://apidoc.eventgrid.com/#2_0_customer_api_events__eventId__seating_chart
   (seatingChart): SeatingChartDatasource
     || \\
     ||  \\
     ||  (seatingChart.sections): ChartSectionDatasource
     ||   [name:                      section name
     ||    pos => posX, posY:         floating point coordinates of the section
     ||    rotation => rotationAngle: rotation angle in degrees
     ||    curvePercent:              ±0-100 curving coefficient of the section
     ||    skew:                      skew factor (0-90 degrees)
     ||    gridWidth:                 column count
     ||    gridHeight:                row count
     ||    hideName:                  if true, section name is not shown on the chart
     ||    || \\
     ||    ||  \\
     ||    || (seatingChart.sections.seats): SeatDatasource
     ||    ||  [id:                  unique seat id
     ||    ||   number:              generic seat name, probably digits or letters
     ||    ||   gridRow:             0-based row coordinate in the section
     ||    ||   gridColumn:          0-based column coordinate of seat in the section
     ||    ||   hidden => isHidden:  true if seat is hidden
     ||    ||   hasWheelchairAccess: true if the seat has wheelchair access
     ||    ||   reserved:            true if seat is reserved to be bought by the customer. Not in the API
     ||    ||   hasTicketType:       true if seat has assigned ticketTypeId in the API]
     ||    ||
     ||    ||
     ||    (seatingChart.sections.rows): ChartRowDatasource
     ||     [gridRow:   0-based row coordinate in the section
     ||      eatsInRow: seats in row (optional)
     ||      number:    generic row name, probably digits or letters]
     ||
     ||
     (seatsArray of SeatDatasource)
      [shapeTypeID => shapeType.id: ShapeType enum value
       name: shape name
       pos => posX, posY: shape coordinates
       scale => scaleX, scaleY: shape size
       rotationAngle: angle of rotation (degrees)]
 
 */

@protocol ShapeDatasource <NSObject>
- (NSInteger)shapeTypeID;
- (CGSize)scale;
- (CGPoint)pos;
- (float)rotationAngle;
- (NSString *)name;
@end

@protocol SeatDatasource <NSObject>
- (NSNumber *)id;
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
- (NSArray <id<SeatDatasource>> *)seatsArray;
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
- (NSMutableArray <id<ShapeDatasource>> *)shapesArray;
@end

@protocol TicketTypeDatasource <NSObject>
- (UIColor *)seatColor;
- (NSString *)name;
- (BOOL)hidden;
- (BOOL)isAddon;
- (NSAttributedString *)attributedDescription;
- (BOOL)containsSeat:(id<SeatDatasource>)seat;
@end

@protocol EventDatasource
- (void)enumerateTicketTypes:(void(^)(id<TicketTypeDatasource> ticketType, BOOL *stop)) callback;
@end


#endif /* EGDatasources_h */
