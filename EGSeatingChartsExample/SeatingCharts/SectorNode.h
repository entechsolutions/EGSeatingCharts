//
//  SectorNode.h
//  CustomerApp
//
//  Created by Антон Ковальчук on 03.06.14.
//  Copyright (c) 2014 Антон Ковальчук. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class SectorNode;

@protocol SectorNodeProtocol <NSObject>
- (void) touchesEnded:(NSSet *)touches;
@end

@interface SectorNode : SKNode
@property (nonatomic, weak) id<SectorNodeProtocol> delegate;
@property (nonatomic) CGSize mySize;
@end
