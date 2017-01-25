//
//  EnterDonationSeatView.m
//  CustomerApp
//
//  Created by Антон Ковальчук on 20.04.15.
//  Copyright (c) 2015 Антон Ковальчук. All rights reserved.
//

#import "EnterDonationSeatView.h"
#import "UIView+AutoLayout.h"
#import "UIColor+Extensions.h"

@interface EnterDonationSeatView() <UITextFieldDelegate>
@property (nonatomic, strong) UIButton *backgroundGrayView;
@property (nonatomic, strong) UIView   *whiteView;
@property (nonatomic, strong) NSLayoutConstraint *whiteViewShift;
- (void) closeButtonPressed;
- (void) doneButtonPressed;
@end

@implementation EnterDonationSeatView

- (instancetype)init
{
    if(self = [super init])
    {
        self.hidden = YES;
        
        self.backgroundGrayView = [UIButton buttonWithType:UIButtonTypeCustom];
        self.backgroundGrayView.alpha = 0.0f;
        //self.backgroundGrayView.hidden = YES;
        self.backgroundGrayView.backgroundColor = [UIColor blackColor];
        [self.backgroundGrayView addTarget:self action:@selector(closeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        self.backgroundGrayView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.backgroundGrayView];
        [self.backgroundGrayView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0.0f];
        [self.backgroundGrayView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0.0f];
        [self.backgroundGrayView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0.0f];
        [self.backgroundGrayView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0.0f];
        
        self.whiteView = [[UIView alloc] init];
        self.whiteView.backgroundColor = [UIColor whiteColor];
        self.whiteView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.whiteView];
        [self.whiteView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self];
        [self.whiteView autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self];
        self.whiteViewShift = [self.whiteView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self withOffset:180];
        [self.whiteView autoSetDimension:ALDimensionHeight toSize:180.0f];
        
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeueLTStd-Cn" size:18.0];
        self.titleLabel.textColor = [UIColor labelGrayColor];
        self.titleLabel.numberOfLines = 1;
        self.titleLabel.text = @"Donation Seat";
        [self.whiteView addSubview:self.titleLabel];
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.titleLabel autoAlignAxis:ALAxisVertical toSameAxisOfView:self.whiteView];
        [self.titleLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.whiteView withOffset:10.0f];
        
        self.subTitleLabel = [[UILabel alloc] init];
        //self.subTitleLabel.text = @"Test";
        self.subTitleLabel.numberOfLines = 1;
        self.subTitleLabel.font = [UIFont fontWithName:@"HelveticaNeueLTStd-Cn" size:12.0];
        self.subTitleLabel.textColor = [UIColor cellSectionTitleColor];
        [self.whiteView addSubview:self.subTitleLabel];
        self.subTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.subTitleLabel autoAlignAxis:ALAxisVertical toSameAxisOfView:self.whiteView];
        [self.subTitleLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.titleLabel withOffset:2.0f];
        
        self.donationTextField = [[UITextField alloc] init];
        self.donationTextField.keyboardType = UIKeyboardTypeDecimalPad;
        self.donationTextField.delegate = self;
        self.donationTextField.returnKeyType = UIReturnKeyDone;
        self.donationTextField.layer.borderColor = [UIColor disabledButtonColor].CGColor;
        self.donationTextField.layer.borderWidth = 0.5f;
        self.donationTextField.layer.cornerRadius = 2.0f;
        self.donationTextField.textAlignment = NSTextAlignmentCenter;
        self.donationTextField.placeholder = @"Enter Donation";
        self.donationTextField.font = [UIFont fontWithName:@"HelveticaNeueLTStd-Cn" size:18];
        self.donationTextField.textColor = [UIColor labelGrayColor];
        self.donationTextField.translatesAutoresizingMaskIntoConstraints = NO;
        [self.whiteView addSubview:self.donationTextField];
        [self.donationTextField autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.subTitleLabel withOffset:10.0f];
        [self.donationTextField autoAlignAxis:ALAxisVertical toSameAxisOfView:self.whiteView];
        [self.donationTextField autoSetDimension:ALDimensionWidth toSize:140.0f];
        [self.donationTextField autoSetDimension:ALDimensionHeight toSize:44.0f];
        
        self.doneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.doneButton setTitle:@"DONE" forState:UIControlStateNormal];
        
        self.doneButton.backgroundColor = [UIColor lightGreenColor];
        
        self.doneButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeueLTStd-Cn" size:18];
        
        self.doneButton.layer.cornerRadius = 2.0f;
        [self.doneButton setTitleColor:[UIColor whiteColor]
                                forState:UIControlStateNormal];
        [self.doneButton addTarget:self
                              action:@selector(doneButtonPressed)
                    forControlEvents:UIControlEventTouchUpInside];
        [self.whiteView addSubview:self.doneButton];
        self.doneButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.doneButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.whiteView withOffset:20.0f];
        [self.doneButton autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.whiteView withOffset:-20.0f];
        [self.doneButton autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.whiteView withOffset:-20.0f];
        [self.doneButton autoSetDimension:ALDimensionHeight toSize:44.0f];

    }
    return self;
}

- (void) closeButtonPressed
{
    [self.delegate closeDialogAndSave:NO];
    [self showWhiteView:NO];
}
- (void) doneButtonPressed
{
    [self.delegate closeDialogAndSave:YES];
    [self showWhiteView:NO];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void) showWhiteView:(BOOL)flag
{
    if(flag)
    {
        self.donationTextField.text = @"";
        self.hidden = NO;
        [UIView animateWithDuration:0.3f animations:^(){
            self.backgroundGrayView.alpha = 0.3f;
            self.whiteViewShift.constant = 0.0f;
            [self layoutIfNeeded];
        } completion:^(BOOL flag)
         {
             
         }];
    }
    else
    {
        [self.donationTextField resignFirstResponder];
        [UIView animateWithDuration:0.3f animations:^(){
            self.backgroundGrayView.alpha = 0.0f;
            self.whiteViewShift.constant = 180.0f;
            [self layoutIfNeeded];
        } completion:^(BOOL flag) {
            self.hidden = YES;
            //self.backgroundGrayView.hidden = YES;
        }];
    }
}

- (void)shiftKeyboard:(BOOL)up
{
    if(up)
    {
        [UIView animateWithDuration:0.3f animations:^(){
            
            self.whiteViewShift.constant = -200.0f;
            [self layoutIfNeeded];
        }];
    }
    else
    {
        [UIView animateWithDuration:0.3f animations:^(){
            
            self.whiteViewShift.constant = 0.0f;
            [self layoutIfNeeded];
        }];
    }
}

@end
