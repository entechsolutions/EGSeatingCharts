//
//  Event.m
//  EGSeatingChartsExample
//
//  Created by Danila Parkhomenko on 26/01/2017.
//  Copyright © 2017 ENtechsolutions. All rights reserved.
//

#import "Event.h"

@implementation DummyEvent

- (void)enumerateTicketTypes:(void(^)(id<TicketTypeDatasource> ticketType, BOOL *stop)) callback {
    DummyTicketType *ticket = [[DummyTicketType alloc] init];
    BOOL stop = false;
    callback(ticket, &stop);
}

@end

@implementation DummyTicketType

- (UIColor *)seatColor {
    return [UIColor greenColor];
}

- (NSString *)name {
    return @"Ticket";
}

- (BOOL)hidden {
    return false;
}

- (BOOL)isAddon {
    return false;
}

- (NSAttributedString *)attributedDescription {
    return [[NSAttributedString alloc] initWithString:@"Description and price"];
}

- (BOOL)containsSeat:(id<SeatDatasource>)seat {
    return true;
}

@end

@implementation DummyChart

- (NSArray <id<ChartSectionDatasource>> *)sortedSections {
    return @[[[DummySection alloc] init]];
}
             
- (NSMutableArray <id<ShapeDatasource>> *)shapesArray {
    return [@[[[DummyShape alloc] init]] mutableCopy];
}

@end

@implementation DummySection

- (id)init {
    if (self = [super init]) {
        self.rows = @[[[DummyRow alloc] initWithName:@"A"
                                             gridRow:0],
                      [[DummyRow alloc] initWithName:@"B"
                                             gridRow:1],
                      [[DummyRow alloc] initWithName:@"C"
                                             gridRow:2]];
    }
    return self;
}

- (NSArray <id<SeatDatasource>> *)seatsArray {
    NSMutableArray *result = [NSMutableArray array];
    for (DummyRow *row in self.rows) {
        [result addObjectsFromArray:row.seats];
    }
    return result;
}

- (NSArray <id<ChartRowDatasource>> *)sortedRows {
    return self.rows;
}

- (CGPoint)pos {
    return CGPointMake(100, 100);
}

- (NSInteger)gridWidth {
    return 3;
}

- (NSInteger)gridHeight {
    return 3;
}

- (float)skew {
    return 5;
}

- (float)curvePercent {
    return 10;
}

- (float)rotation {
    return 10;
}

- (BOOL)hideName {
    return false;
}

- (NSString *)name {
    return @"Section";
}

@end

@implementation DummyShape

- (NSInteger)shapeTypeID {
    return 10;
}

- (CGSize)scale {
    return CGSizeMake(100, 10);
}

- (CGPoint)pos {
    return CGPointMake(10, 80);
}

- (float)rotationAngle {
    return -10;
}

- (NSString *)name {
    return @"Shape";
}

@end

@implementation DummyRow

- (id) initWithName:(NSString *)name gridRow:(NSInteger)gridRow {
    if (self = [super init]) {
        self.name = name;
        self.rowInGrid = gridRow;
        NSMutableArray *items = [NSMutableArray array];
        for (NSInteger i = 0; i < 4; i++) {
            NSInteger seatVaraint = gridRow * 4 + i;
            [items addObject:[[DummySeat alloc] initWithID:@(seatVaraint)
                                                   gridRow:gridRow
                                                gridColumn:i
                                                    number:[NSString stringWithFormat:@"%ld", (long)(i + 1)]
                                                  reserved:seatVaraint & 1
                                       hasWheelchairAccess:seatVaraint & 2
                                             hasTicketType:seatVaraint & 4]];
        }
        self.seats = [items copy];
    }
    return self;
}

- (NSNumber *)seatsInRow {
    return @([self.seats count]);
}

- (NSInteger)gridRow {
    return self.rowInGrid;
}

- (NSString *)number {
    return self.name;
}

@end

@implementation DummySeat

- (id) initWithID:(NSNumber *)id gridRow:(NSInteger)gridRow gridColumn:(NSInteger)gridColumn number:(NSString *)number reserved:(BOOL)reserved hasWheelchairAccess:(BOOL)hasWheelchairAccess hasTicketType:(BOOL)hasTicketType {
    if (self = [super init]) {
        self.id = id;
        self.gridRow = gridRow;
        self.gridColumn = gridColumn;
        self.number = number;
        self.reserved = reserved;
        self.hasWheelchairAccess = hasWheelchairAccess;
        self.hasTicketType = hasTicketType;
    }
    return self;
}

- (BOOL)hidden {
    return false;
}

@end

