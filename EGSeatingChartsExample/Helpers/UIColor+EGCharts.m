//
//  UIColor+Extensions.m
//  EventGridManager
//
//  Created by Антон Ковальчук on 21.01.14.
//  Copyright (c) 2014 Антон Ковальчук. All rights reserved.
//

#import "UIColor+EGCharts.h"
#import "InterfaceMode.h"

@implementation UIColor (Extensions)

+ (UIColor *)offlineViewColor
{
    return [UIColor colorWithRed:34.0f/255.0f green:34.0f/255.0f blue:34.0f/255.0f alpha:1.0f];
}

+ (UIColor *)eventsBackgoundColor
{
    return [UIColor colorWithRed:15.0f/255.0f green:15.0f/255.0f blue:30.0f/255.0f alpha:0.7f];
}

+ (UIColor *)menuNavigationBarColor
{
    return [UIColor colorWithRed:43.0f/255.0f green:33.0f/255.0f blue:29.0f/255.0f alpha:1.0f];
}

+ (UIColor *) loginButtonColor
{
    return [UIColor colorWithRed:24.0/255.0 green:154.0/255.0 blue:50.0/255.0 alpha:1.0];
}

+ (UIColor *) placeholderTransparentColor
{
    return [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:.7f];
}

+ (UIColor *)lightBlueColor
{
    return [UIColor colorWithRed:38.0f/255.0f green:147.0f/255.0f blue:1.0f alpha:1.0f];
}

+ (UIColor *)lightGreenColor
{
    return [UIColor colorWithRed:88.0f/255.0f green:163.0f/255.0f blue:63.0f/255.0f alpha:1.0f];
}

+ (UIColor *)labelBlueColor
{
    return [UIColor colorWithRed:116.0f/255.0f green:159.0f/255.0f blue:235.0f/255.0f alpha:1.0f];
}

+ (UIColor *)navigationBarColor
{
    return [UIColor colorWithRed:236.0f/255.0f green:102.0f/255.0f blue:91.0f/255.0f alpha:1.0f];
}

+ (UIColor *)labelGrayColor
{
    return [UIColor colorWithRed:68.0f/255.0f green:68.0f/255.0f blue:68.0f/255.0f alpha:1.0f];
}

+ (UIColor *)cellSectionTitleColor
{
    return [UIColor colorWithRed:153.0f/255.0f green:153.0f/255.0f blue:153.0f/255.0f alpha:1.0f];
}

+ (UIColor *)separatorColor
{
    return [UIColor colorWithRed:221.0f/255.0f green:221.0f/255.0f blue:221.0f/255.0f alpha:1.0f];
}

+ (UIColor *)eventCellSeparatorColor
{
    if ([InterfaceMode iPadFullScreen])
        return [UIColor colorWithRed:221.0f/255.0f green:221.0f/255.0f blue:221.0f/255.0f alpha:0.2f];
    return [UIColor colorWithRed:221.0f/255.0f green:221.0f/255.0f blue:221.0f/255.0f alpha:0.4f];
}

+ (UIColor *)tableBackgroundColor
{
    return [UIColor colorWithRed:247.0f/255.0f green:247.0f/255.0f blue:247.0f/255.0f alpha:1.0f];
}

+ (UIColor *)disabledButtonColor
{
    return [UIColor colorWithRed:170.0f/255.0f green:170.0f/255.0f blue:170.0f/255.0f alpha:1.0f];
}

+ (UIColor *)unableSellButtonColor
{
    return [UIColor colorWithRed:237.0f/255.0f green:66.0f/255.0f blue:56.0f/255.0f alpha:1.0f];
}

+ (UIColor *)amountButtonColor
{
    return [UIColor colorWithRed:78.0f/255.0f green:165.0f/255.0f blue:252.0f/255.0f alpha:1.0f];
}

+ (UIColor *)resultBackgroundColor
{
    return [UIColor colorWithRed:238.0f/255.0f green:238.0f/255.0f blue:238.0f/255.0f alpha:1.0f];
}

+ (UIColor *)eventNavigationBarColor
{
    return [UIColor colorWithRed:56.0f/255.0f green:56.0f/255.0f blue:56.0f/255.0f alpha:1.0f];
}

+ (UIColor *)splitViewSeparatorLineColor
{
    return [UIColor colorWithRed:69.0f/255.0f green:56.0f/255.0f blue:55.0f/255.0f alpha:1.0f];
}

+ (UIColor *)dashboardLabelTextForIPadColor
{
    return [UIColor colorWithRed:102.0f/255.0f green:102.0f/255.0f blue:102.0f/255.0f alpha:1.0f];
}

+ (UIColor *)signBackground
{
    return [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
}

+ (UIColor *)clearButtonColor
{
    return [UIColor colorWithRed:255.0f/255.0f green:38.0f/255.0f blue:38.0f/255.0f alpha:1.0f];
}

+ (UIColor *)seatingChartsBackgound
{
    return [UIColor colorWithRed:248.0f/255.0f green:248.0f/255.0f blue:248.0f/255.0f alpha:1.0f];
}

- (BOOL)isEqualToColor:(UIColor *)color
{
    CGFloat red, green, blue, alpha;
    if ([self getRed:&red green:&green blue:&blue alpha:&alpha]) {
        CGFloat otherRed, otherGreen, otherBlue, otherAlpha;
        if ([color getRed:&otherRed green:&otherGreen blue:&otherBlue alpha:&otherAlpha]) {
            if (alpha < 1.0/255.0f) {
                return otherAlpha < 1.0/255.0f;
            }
            return (ABS(red - otherRed) < 1.0/255.0f) && (ABS(green - otherGreen) < 1.0/255.0f) && (ABS(blue - otherBlue) < 1.0/255.0f) && (ABS(alpha - otherAlpha) < 1.0/255.0f);
        }
    }
    return NO;
}

@end
