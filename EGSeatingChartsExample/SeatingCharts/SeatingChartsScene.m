//
//  SeatingChartsScene.m
//  EventGridManager
//
//  Created by Антон Ковальчук on 14.05.14.
//  Copyright (c) 2014 Антон Ковальчук. All rights reserved.
//

#import "SeatingChartsScene.h"
#import "SeatNode.h"
#import "SectorNode.h"
#import <GLKit/GLKMath.h>
#import <CoreGraphics/CoreGraphics.h>
#import "UIColor+EGCharts.h"

static int borderShift    = 0;
static int seatWidth      = 30;
static int oneSeatWidth   = 40;
static float scaleFromWeb   = 2.0f;
static float scaleFactor    = 0.8f;
static float mapScreenWidth;
static float mapScreenHeight;
static float bottomShift;

static float config_seat_size = 30.0f;
static float config_seat_diff = 10.0f;
static float config_seat_maxCurveRadius = 200.0f ;

#define RAD_TO_DEGREE(angle) ((angle) * 180.0 / M_PI)
#define DEGREES_RADIANS(angle) ((angle) / 180.0 * M_PI)
#define SKT_INLINE static __inline__

SKT_INLINE CGPoint CGPointAdd(CGPoint point1, CGPoint point2)
{
    return CGPointMake(point1.x + point2.x, point1.y + point2.y);
}

SKT_INLINE CGPoint CGPointSubtract(CGPoint point1, CGPoint point2)
{
    return CGPointMake(point1.x - point2.x, point1.y - point2.y);
}

typedef NS_ENUM(NSInteger, IIMySceneZPosition)
{
    Background,
    ActiveElements
};

@interface SeatingChartsScene() <SectorNodeProtocol, SeatNodeProtocol>
@property (nonatomic, strong) NSMutableArray *sectors;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGestureRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer   *panGestureRecognizer;
@property (nonatomic, strong) SKSpriteNode *mySkNode;
@property (nonatomic) float lastScale;
@property (nonatomic) float lastX;
@property (nonatomic) float minScale;
@property (nonatomic) BOOL flag;
@property (nonatomic) CGSize mySKNodeSize;
- (CGSize)sectionSize:(id<ChartSectionDatasource>)section;
- (float)yCircleForX:(float)x curve:(float)curveValue section:(id<ChartSectionDatasource>)section;
- (void)handleZoomFrom:(UIPinchGestureRecognizer *)recognizer;
- (void)handlePanFrom:(UIPanGestureRecognizer *)recognizer;
@end

@implementation SeatingChartsScene

- (instancetype)initWithSize:(CGSize)size mapSize:(CGSize)mapSize bottomSpace:(CGFloat)bottomSpace
{
    if (self = [super initWithSize:size])
    {
        self.backgroundColor = [UIColor seatingChartsBackgound];
        
        mapScreenWidth  = mapSize.width;
        mapScreenHeight = mapSize.height;
        bottomShift = bottomSpace;
    }
    return self;
}

- (void) createSeats:(id<SeatingChartDatasource>)seatingChart event:(id<EventDatasource>)event// availableSeats:(NSArray<id<TicketTypeDatasource>> *)availableSeats
{
    CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
    
    [self removeAllChildren];
        
    id<ChartSectionDatasource> sectionMinX, sectionMaxX;
    id<ChartSectionDatasource> sectionMinY, sectionMaxY;
    
    NSArray <id<ChartSectionDatasource>> *seactionsArray = [seatingChart sortedSections];
    
    sectionMinX = sectionMaxX = seactionsArray[0];
    sectionMinY = sectionMaxY = seactionsArray[0];
    
    for (id<ChartSectionDatasource> section in seactionsArray) {        
        if([section pos].x < [sectionMinX pos].x)
            sectionMinX = section;
        if([section pos].x > [sectionMaxX pos].x)
            sectionMaxX = section;
        
        if([section pos].y < [sectionMinY pos].y)
            sectionMinY = section;
        if([section pos].y > [sectionMaxY pos].y)
            sectionMaxY = section;
    }

    CGSize size = CGSizeMake(([sectionMaxX pos].x - [sectionMinX pos].x) * scaleFromWeb + [self sectionSize:sectionMaxX].width,
                             ([sectionMaxY pos].y - [sectionMinY pos].y) * scaleFromWeb + [self sectionSize:sectionMinY].height * 0.5f + [self sectionSize:sectionMaxY].height * 0.5f);

    if (size.width < 0) {
        size.width = 0;
    }
    if (size.height < 0) {
        size.height = 0;
    }
    self.mySKNodeSize = size;
    
    if(size.height > size.width)
        self.minScale =  mapScreenHeight/size.height;
    else
        self.minScale = mapScreenWidth/size.width;
    
    self.minScale *= scaleFactor;
    
    self.mySkNode = [SKSpriteNode spriteNodeWithColor:[SKColor seatingChartsBackgound] size:size];
    [_mySkNode setScale:self.minScale];
    [self.mySkNode setAnchorPoint:CGPointMake(0,0)];
    
    //self.mySkNode.position = CGPointMake(0, bottomShift + (mapScreenHeight - size.height * self.minScale) * 0.5f);
    self.mySkNode.position = CGPointMake((mapScreenWidth - size.width * self.minScale) * 0.5f, bottomShift + (mapScreenHeight - size.height * self.minScale) * 0.5f);
    
    [self addChild:self.mySkNode];
    
    self.sectors = [[NSMutableArray alloc] init];
    
    for (id<ChartSectionDatasource> section in [seatingChart sortedSections])
    {
        NSLog(@"section0 elapsed time: %.3f", CFAbsoluteTimeGetCurrent() - start);
        
        float sectionWidth = ([section gridWidth] + 1) * (config_seat_size + config_seat_diff) - config_seat_diff+ 2*config_seat_size;

        //section.curve_percent_attribute = [NSNumber numberWithFloat:-section.curve_percent_attribute.floatValue];
        //NSLog(@"section=%@",section.name_attribute);
        
        float seatWithMaxY = 0.0f;
        float seatWithMinY = 0.0f;
        
        BOOL firstSeatMax = YES;
        BOOL firstSeatMin = YES;
        
        NSMutableArray *elements = [[NSMutableArray alloc] init];
        
        for(id<ChartRowDatasource> row in [section sortedRows])
        {
            float PI = 3.14f;
            float tan_val = tan((90.0f - fabs([section skew])) * PI / 180.0f);
            
            float fullLength = [section gridWidth] * (config_seat_size + config_seat_diff) - config_seat_diff;
            
            float currentLength;
            
            if ([row seatsInRow] == nil)
            {
                currentLength = fullLength;
            }
            else
            {
                if ([[row seatsInRow] integerValue]> [section gridWidth])
                    currentLength = [section gridWidth] * (config_seat_size + config_seat_diff) - config_seat_diff;
                else
                    currentLength = [[row seatsInRow] integerValue] * (config_seat_size + config_seat_diff) - config_seat_diff;
            }
            
            float boundSeatSize = config_seat_size + config_seat_diff; // seat size
            
            float mx = (trunc([section pos].x) - [sectionMinX pos].x) * scaleFromWeb + boundSeatSize + ([section gridWidth] * boundSeatSize - config_seat_diff) / 2.0f;
            float my = size.height - (trunc([section pos].y) - [sectionMinY pos].y) * scaleFromWeb - ([row gridRow] * boundSeatSize + config_seat_size / 2.0f);
            
            
            float cy = my - (([section curvePercent] < 0 ? -1 : 1) * [section gridWidth] * config_seat_maxCurveRadius * (1.1f - log(fabs([section curvePercent])) / log(100.0f)));
            
            //cy -= (section.curve_percent_attribute.floatValue < 0) ? - 3 * config_seat_size : 3 * config_seat_size;
            
            
            float leftX = mx - (boundSeatSize * [section gridWidth] + config_seat_diff) / 2.0f + config_seat_diff + config_seat_size / 2.0f;
            
            float leftY = my - config_seat_size / 2.0f;
            float radius = sqrtf((leftX - mx)*(leftX - mx) + (leftY - cy)*(leftY - cy));
            
            BOOL wasNumber = NO;
            
            NSArray <id<SeatDatasource>> *sortedSeats = [[section seatsArray] sortedArrayUsingComparator:^NSComparisonResult(id <SeatDatasource> _Nonnull obj1, id <SeatDatasource> _Nonnull obj2) {
                if ([obj1 gridColumn] < [obj2 gridColumn]) {
                    return NSOrderedAscending;
                }
                if ([obj1 gridColumn] == [obj2 gridColumn]) {
                    return NSOrderedSame;
                }
                return NSOrderedDescending;
            }];
            
            for (id<SeatDatasource> seat in sortedSeats) {
                if([seat gridRow] == [row gridRow]) {
                    NSInteger seatIndex = [seat gridColumn];
                    float rx = (trunc([section pos].x) - [sectionMinX pos].x) * scaleFromWeb + (fullLength - currentLength) / 2.0f + (seatIndex + 1) * boundSeatSize;
                    float ry = size.height - (trunc([section pos].y) - [sectionMinY pos].y) * scaleFromWeb - [row gridRow] * (config_seat_size + config_seat_diff);
                    
                    
                    if ([section curvePercent] != 0)
                    {
                        float rmx = rx + config_seat_size / 2.0f;
                        ry = cy - (([section curvePercent] < 0 ? 1 : -1) *
                                   ((my - ry) + sqrt(radius * radius - (rmx - mx) * (rmx - mx)) + config_seat_size / 2.0f))
                        + config_seat_size;
                    }
                    
                    float ax = (fullLength - currentLength) / 2.0f +  seatIndex * (config_seat_diff + config_seat_size) + config_seat_size / 2.0f;
                    
                    float dx = fabs(ax - fullLength / 2.0f);
                    float dy = tan_val != 0.0f ? fabs(dx / tan_val) : 0.0f;
                    if ([section skew] > 0)
                        dy = ax < fullLength / 2.0f ? -dy : dy;
                    else
                        dy = ax < fullLength / 2.0f ? dy : -dy;
                    
                    
                    SeatNode *seatNode = [[SeatNode alloc] initWithSeat:seat event:event];
                    seatNode.size = CGSizeMake(40, 40);
                    seatNode.enable4zoom = NO;
                    seatNode.position =  (CGPoint){ rx + 15, ry+dy - 15};
                    
                    if ([seat gridRow] == [section sortedRows].count - 1)
                    {
                        if(firstSeatMin)
                        {
                            seatWithMinY = ry+dy;
                            firstSeatMin = NO;
                        }
                        else
                        {
                            if(seatWithMinY > ry+dy)
                                seatWithMinY = ry+dy;
                        }
                    }
                    if ([seat gridRow] == 0)
                    {
                        if(firstSeatMax)
                        {
                            seatWithMaxY = ry+dy;
                            firstSeatMax = NO;
                        }
                        else
                        {
                            if(seatWithMaxY < ry+dy)
                                seatWithMaxY = ry+dy;
                        }
                    }
          
                    if(!wasNumber && ![seat hidden])
                    {
                        wasNumber = YES;
                        SKLabelNode *numLabel = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
                        numLabel.fontColor = [UIColor blackColor];
                        numLabel.text = [row number];
                        numLabel.fontSize = 16.0f;
                        numLabel.position = (CGPoint){ rx + 15 - config_seat_size - config_seat_diff, ry+dy - 15 - 5};
                        //(CGPoint){(section.pos_x_attribute.intValue - sectionMinX.pos_x_attribute.floatValue) * scaleFromWeb + config_seat_diff,ry+dy - config_seat_size + config_seat_diff};
                        
                        [elements addObject:numLabel];
                    }
             
                    
                    seatNode.delegate = self;
                    [elements addObject:seatNode];
                    
                    NSLog(@"seat1 elapsed time: %.3f", CFAbsoluteTimeGetCurrent() - start);
                }
            }
        }
        
        // creating section cover and adding elements there
        SectorNode *sectorCower = [[SectorNode alloc] init];
        sectorCower.userInteractionEnabled = YES;
        //[sectorCower setAnchorPoint:(CGPoint){0.5,0.5}];
        sectorCower.mySize = CGSizeMake(sectionWidth, seatWithMaxY- seatWithMinY + config_seat_size * 4);
        sectorCower.position = (CGPoint)
        {
            (trunc([section pos].x) - [sectionMinX pos].x) * scaleFromWeb + sectorCower.mySize.width * 0.5f - config_seat_size, seatWithMinY + (seatWithMaxY- seatWithMinY) * 0.5f
        };
        sectorCower.delegate = self;
        [self.mySkNode addChild:sectorCower];
        [self.sectors addObject:sectorCower];
        
        if(![section hideName])
        {
            SKLabelNode *name = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
            name.fontColor = [UIColor blackColor];
            name.text = [section name];
            name.fontSize = 30.0f;
            name.position =  (CGPoint){0, sectorCower.mySize.height * 0.5f - 35};
            [sectorCower addChild:name];
        }
        
        for(SKNode *seatNode in elements)
        {
            seatNode.position = CGPointMake(seatNode.position.x - ([section pos].x - [sectionMinX pos].x) * scaleFromWeb - sectorCower.mySize.width * 0.5f + config_seat_size, seatNode.position.y - sectorCower.position.y);
            [sectorCower addChild:seatNode];
        }
        
        sectorCower.zRotation = -DEGREES_RADIANS([section rotation]);
        
        NSLog(@"section1 elapsed time: %.3f", CFAbsoluteTimeGetCurrent() - start);
    }
    
    for(id<ShapeDatasource> shape in [seatingChart shapesArray])
    {
        CGSize scale = [shape scale];
        if ([shape shapeTypeID] == ChartShapeTypeRectangle)
        {
            SKShapeNode *shapeNode = [SKShapeNode shapeNodeWithRectOfSize:CGSizeMake(scale.width * scaleFromWeb, scale.height * scaleFromWeb)];
            
            shapeNode.strokeColor = [SKColor blackColor];
            shapeNode.lineWidth = 3;
            shapeNode.position = (CGPoint)
            {
                (trunc([shape pos].x) - [sectionMinX pos].x) * scaleFromWeb + shapeNode.frame.size.width * 0.5f,
                size.height - ((trunc([shape pos].y) - [sectionMinY pos].y) * scaleFromWeb + shapeNode.frame.size.height * 0.5f)
            };
            
            shapeNode.zRotation = -DEGREES_RADIANS([shape rotationAngle]);
            
            SKLabelNode *name = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
            name.fontColor = [UIColor blackColor];
            name.text = [shape name];
            name.fontSize = 20.0f;
            name.position =  (CGPoint){0, -8};
            [shapeNode addChild:name];
            
            [self.mySkNode addChild:shapeNode];
        }
        else if([shape shapeTypeID] == ChartShapeTypeLine)
        {
            SKShapeNode *yourline = [SKShapeNode node];
            CGMutablePathRef pathToDraw = CGPathCreateMutable();
            CGPathMoveToPoint(pathToDraw, NULL, (trunc([shape pos].x) - [sectionMinX pos].x) * scaleFromWeb, size.height - (trunc([shape pos].y) - [sectionMinY pos].y) * scaleFromWeb );
            CGPathAddLineToPoint(pathToDraw, NULL, (trunc([shape pos].x) - [sectionMinX pos].x) * scaleFromWeb + scale.width * scaleFromWeb, size.height - (trunc([shape pos].y) - [sectionMinY pos].y) * scaleFromWeb - scale.height * scaleFromWeb);
            yourline.path = pathToDraw;
            yourline.lineWidth = 3.0f;
            [yourline setStrokeColor:[UIColor blackColor]];
            [self.mySkNode addChild:yourline];
        }
    }
    CFTimeInterval elapsed = CFAbsoluteTimeGetCurrent() - start;
    NSLog(@"SC elapsed time: %.3f", elapsed);
}

- (CGSize)sectionSize:(id<ChartSectionDatasource>)section
{
    return CGSizeMake(oneSeatWidth * ([section gridWidth] + 1) - 10 + borderShift * 2,
                      oneSeatWidth * ([section gridHeight]) - 10 + borderShift * 2);
}

- (float)yCircleForX:(float)x curve:(float)curveValue section:(id<ChartSectionDatasource>) section
{
    float maxCurveRadius = 500.0f;
    //float curveValue = 100.0f;
    float height = maxCurveRadius * (1.1f - log(fabs(curveValue)) / log(100.0f));
    
    CGSize normalSectorSize = [self sectionSize:section];
    
    float x0 = - normalSectorSize.width * 0.5f + borderShift + oneSeatWidth + ([section gridWidth] - 1) * oneSeatWidth * 0.5f;
    float y0 =  - height - normalSectorSize.height * 0.5f + borderShift + seatWidth;
    
    CGPoint leftLowSeatPoint = (CGPoint){borderShift + oneSeatWidth - normalSectorSize.width * 0.5f, -borderShift - ([section gridHeight] - 1) * oneSeatWidth + normalSectorSize.height * 0.5f};
    float R = sqrtf((leftLowSeatPoint.x - x0)*(leftLowSeatPoint.x - x0) + (leftLowSeatPoint.y - y0)*(leftLowSeatPoint.y - y0));
    
    return sqrtf(R*R - (x - x0)*(x - x0)) + y0;
}

- (void)didMoveToView:(SKView *)view
{
    _pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handleZoomFrom:)];
    [self.view addGestureRecognizer:_pinchGestureRecognizer];
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanFrom:)];
    [self.view addGestureRecognizer:_panGestureRecognizer];
}

// Method that is called by my UIPinchGestureRecognizer.
- (void)handleZoomFrom:(UIPinchGestureRecognizer *)recognizer
{
    CGPoint anchorPoint = [recognizer locationInView:recognizer.view];
    anchorPoint = [self convertPointFromView:anchorPoint];
    
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        // No code needed for zooming...
        self.lastScale = recognizer.scale;//_mySkNode.xScale;
    }
    if (recognizer.state == UIGestureRecognizerStateBegan ||
        recognizer.state == UIGestureRecognizerStateChanged)
    {
        CGPoint anchorPointInMySkNode = [_mySkNode convertPoint:anchorPoint fromNode:self];
        
        const CGFloat kMaxScale = 1.0;
        const CGFloat kMinScale = self.minScale;
        
        CGFloat newScale = 1 -  (self.lastScale - recognizer.scale);
        newScale = MIN(newScale, kMaxScale/_mySkNode.xScale);
        newScale = MAX(newScale, kMinScale/_mySkNode.xScale);
        
        NSLog(@"_mySkNode.xScale=%f",_mySkNode.xScale);
     
        
        [_mySkNode setScale:(_mySkNode.xScale * newScale)];
        
        CGPoint mySkNodeAnchorPointInScene = [self convertPoint:anchorPointInMySkNode fromNode:_mySkNode];
        CGPoint translationOfAnchorInScene = CGPointSubtract(anchorPoint, mySkNodeAnchorPointInScene);
        _mySkNode.position = CGPointAdd(_mySkNode.position, translationOfAnchorInScene);
        
        
        self.lastScale = recognizer.scale;//_mySkNode.xScale;// = 1.0;
        
        
        if(_mySkNode.xScale == self.minScale && self.flag)
        {
            self.flag = NO;
            NSLog(@"fire1");
            
            for(SectorNode *sector in self.sectors)
            {
                for(SKSpriteNode *node in sector.children)
                {
                    if([node isKindOfClass:[SeatNode class]])
                        ((SeatNode *)node).enable4zoom = NO;
                }
            }
        }
        if(_mySkNode.xScale == 1.0f && !self.flag)
        {
            self.flag = YES;
            NSLog(@"fire2");
            for(SectorNode *sector in self.sectors)
            {
                for(SKSpriteNode *node in sector.children)
                {
                    if([node isKindOfClass:[SeatNode class]])
                        ((SeatNode *)node).enable4zoom = YES;
                }
            }
        }
        if(_mySkNode.xScale != self.minScale)
            self.zoomOutButton.hidden = NO;
        else
            self.zoomOutButton.hidden = YES;
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        // No code needed here for zooming...
    }
}

- (void)handlePanFrom:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        [recognizer setTranslation:CGPointZero inView:recognizer.view];
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        CGPoint translation = [recognizer translationInView:recognizer.view];
        translation = CGPointMake(-translation.x, translation.y);
        
        _mySkNode.position = CGPointSubtract(_mySkNode.position, translation);

        [recognizer setTranslation:CGPointZero inView:recognizer.view];
        
        self.lastX = translation.x;
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        // No code needed for panning.
    }
}

- (void)touchesEnded:(NSSet *)touches
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    NSArray *touchedNodes = [self nodesAtPoint:location];
    for (SKNode *node in touchedNodes)
    {
        if([node isKindOfClass:[SeatNode class]])
        {
            [((SeatNode *)node) touchesEnded:touches withEvent:nil];
            break;
        }
    }
}

- (void)didClickSeat:(SeatNode *)target
{
    self.zoomOutButton.hidden = NO;
    
    SectorNode *findSection;
    for(SectorNode *sectorNode in self.sectors)
    {
        for(SeatNode *node in sectorNode.children)
        {
            if(node == target)
            {
                findSection = sectorNode;
                break;
            }
        }
    }
    
    for(SectorNode *sectorNode in self.sectors)
    {
        for(SKSpriteNode *node in sectorNode.children)
        {
            if([node isKindOfClass:[SeatNode class]])
                ((SeatNode *)node).enable4zoom = YES;
        }
    }
    
    float scale =  MIN(mapScreenWidth/findSection.mySize.width,mapScreenWidth/findSection.mySize.height);
    
    if(self.mySkNode.xScale < scale)
    {
        SKAction *actionZoom = [SKAction scaleTo:scale duration:0.4];
        [self.mySkNode runAction:actionZoom];
        
        SKAction *actionMove = [SKAction moveTo:CGPointMake(-(findSection.position.x * scale - mapScreenWidth * 0.5f), -findSection.position.y * scale + mapScreenHeight /2.0f + bottomShift) duration:0.4];
        [self.mySkNode runAction:actionMove];
    }
}

- (void)didSelectSeat:(SeatNode *)target
{
    if(target.select)
        [self.delegateSC addOrderSeat:target];
    else
        [self.delegateSC removeOrderSeat:target];
}

- (void) zoomOut
{
    self.zoomOutButton.hidden = YES;
    
    if(self.mySkNode.xScale != self.minScale)
    {
        SKAction *action = [SKAction scaleTo:self.minScale duration:0.4f];
        [self.mySkNode runAction:action];
    }
    
    SKAction *action2 = [SKAction moveTo:CGPointMake((mapScreenWidth - self.mySKNodeSize.width * self.minScale) * 0.5f, bottomShift + (mapScreenHeight - self.mySKNodeSize.height * self.minScale) * 0.5f) duration:0.4f];
    [self.mySkNode runAction:action2];
    
    for(SectorNode *sector in self.sectors)
    {
        for(SKSpriteNode *node in sector.children)
        {
            if([node isKindOfClass:[SeatNode class]])
                ((SeatNode *)node).enable4zoom = NO;
        }
    }    
}

- (void) updateSelectedSeats:(BOOL (^)(id<SeatDatasource>))selectedCallback
{
    for(SectorNode *sector in self.sectors)
    {
        for(SKNode *node in sector.children)
        {
            if([node isKindOfClass:[SeatNode class]])
            {
                BOOL selected = selectedCallback(((SeatNode *)node).seat);

                if(!selected)
                    [((SeatNode *)node) unselectSprite];
                ((SeatNode *)node).select = selected;
            }
        }
    }
    
}

@end
