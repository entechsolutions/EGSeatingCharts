//
//  SectorNode.m
//  CustomerApp
//
//  Created by Антон Ковальчук on 03.06.14.
//  Copyright (c) 2014 Антон Ковальчук. All rights reserved.
//

#import "SectorNode.h"

@implementation SectorNode

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.delegate touchesEnded:touches];
}

@end
