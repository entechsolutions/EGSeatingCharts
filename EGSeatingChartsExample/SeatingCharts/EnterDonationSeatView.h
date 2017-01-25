//
//  EnterDonationSeatView.h
//  CustomerApp
//
//  Created by Антон Ковальчук on 20.04.15.
//  Copyright (c) 2015 Антон Ковальчук. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EnterDonationSeatViewProtocol <NSObject>
- (void) closeDialogAndSave:(BOOL)saveFlag;
@end

@interface EnterDonationSeatView : UIView
@property (nonatomic, strong) UILabel     *titleLabel;
@property (nonatomic, strong) UILabel     *subTitleLabel;
@property (nonatomic, strong) UITextField *donationTextField;
@property (nonatomic, strong) UIButton    *doneButton;
@property (nonatomic, weak) id<EnterDonationSeatViewProtocol> delegate;
- (void) showWhiteView:(BOOL)flag;
- (void) shiftKeyboard:(BOOL)up;
@end
