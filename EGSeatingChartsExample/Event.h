//
//  Event.h
//  EGSeatingChartsExample
//
//  Created by Danila Parkhomenko on 26/01/2017.
//  Copyright © 2017 ENtechsolutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EGDatasources.h"

@class DummyRow, DummySeat;

@interface DummyEvent : NSObject <EventDatasource>

- (void)enumerateTicketTypes:(void(^)(id<TicketTypeDatasource> ticketType, BOOL *stop)) callback;

@end

@interface DummyTicketType : NSObject <TicketTypeDatasource>

@end

@interface DummyChart : NSObject <SeatingChartDatasource>

@end

@interface DummySection : NSObject <ChartSectionDatasource>

@property (nonatomic, strong) NSArray <DummyRow *> *rows;

@end

@interface DummyShape : NSObject <ShapeDatasource>

@end

@interface DummyRow : NSObject <ChartRowDatasource>

@property (nonatomic, strong) NSArray <DummySeat *> *seats;
@property (nonatomic, strong) NSString *name;
@property (nonatomic) NSInteger rowInGrid;

- (id) initWithName:(NSString *)name gridRow:(NSInteger)gridTow;

@end

@interface DummySeat : NSObject <SeatDatasource>

@property (nonatomic, strong) NSNumber *id;
@property (nonatomic) NSInteger gridRow;
@property (nonatomic) NSInteger gridColumn;
@property (nonatomic, strong) NSString *number;
@property (nonatomic) BOOL reserved;
@property (nonatomic) BOOL hasWheelchairAccess;
@property (nonatomic) BOOL hasTicketType;

- (id)   initWithID:(NSNumber *)id
            gridRow:(NSInteger)gridRow
         gridColumn:(NSInteger)gridColumn
             number:(NSString *)number
           reserved:(BOOL)reserved
hasWheelchairAccess:(BOOL)hasWheelchairAccess
      hasTicketType:(BOOL)hasTicketType;

@end
