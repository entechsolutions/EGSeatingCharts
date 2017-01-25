//
//  SeatingChartsOrderCell.h
//  CustomerApp
//
//  Created by Антон Ковальчук on 10.04.15.
//  Copyright (c) 2015 Антон Ковальчук. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CartItemDtoBase;
@class Instance;

@interface SeatingChartsOrderCell : UITableViewCell
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subTitleLabel;
@property (nonatomic, strong) UILabel *priceLabel;
@property (nonatomic, strong) UIView *topLine;
@property (nonatomic, strong) UIView *bottomLine;
- (void)fillWithEntity:(CartItemDtoBase *)cartItemDtoBase instance:(Instance *)instance;
@end
