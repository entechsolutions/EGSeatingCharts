//
//  UIColor+Extensions.h
//  EventGridManager
//
//  Created by Антон Ковальчук on 21.01.14.
//  Copyright (c) 2014 Антон Ковальчук. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (EGCharts)
+ (UIColor *)offlineViewColor;
+ (UIColor *)eventsBackgoundColor;
+ (UIColor *)menuNavigationBarColor;
+ (UIColor *)loginButtonColor;
+ (UIColor *)lightBlueColor;
+ (UIColor *)lightGreenColor;
+ (UIColor *)placeholderTransparentColor;
+ (UIColor *)labelGrayColor;
+ (UIColor *)labelBlueColor;
+ (UIColor *)navigationBarColor;
+ (UIColor *)cellSectionTitleColor;
+ (UIColor *)separatorColor;
+ (UIColor *)eventCellSeparatorColor;
+ (UIColor *)tableBackgroundColor;
+ (UIColor *)unableSellButtonColor;
+ (UIColor *)disabledButtonColor;
+ (UIColor *)amountButtonColor;
+ (UIColor *)resultBackgroundColor;
+ (UIColor *)eventNavigationBarColor;
+ (UIColor *)splitViewSeparatorLineColor;
+ (UIColor *)dashboardLabelTextForIPadColor;
+ (UIColor *)signBackground;
+ (UIColor *)clearButtonColor;
+ (UIColor *)seatingChartsBackgound;

- (BOOL)isEqualToColor:(UIColor *)color;

@end
