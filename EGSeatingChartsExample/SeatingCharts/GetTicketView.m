//
//  GetTicketView.m
//  EventGridManager
//
//  Created by Антон Ковальчук on 27.01.14.
//  Copyright (c) 2014 Антон Ковальчук. All rights reserved.
//

#import "GetTicketView.h"
#import "UIColor+EGCharts.h"
#import "UIView+AutoLayout.h"
#import "TextField.h"
#import "ValidationHelper.h"
#import "Helper.h"

@interface GetTicketView() <UITextFieldDelegate>

- (void) didPressButton:(UIButton *)target;

@property (nonatomic, strong) UIButton *sendEmailButton;
@property (nonatomic, strong) UIButton *showEmailButton;

@end

@implementation GetTicketView

- (instancetype)initWithTitle:(NSString *)title
                     subTitle:(NSString *)subTitle
                        items:(NSArray *)items
                 cancelButton:(NSString *)cancelButtonTitle
{
    if(self = [super init])
    {
        self.backgroundColor = [UIColor whiteColor];
        
        self.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.layer.shadowOffset = CGSizeMake(0.0f,2.0f);
        self.layer.shadowOpacity = .3f;
        self.layer.shadowRadius = 2.0f;
        
        UILabel *titleLabel = [[UILabel alloc] init];//WithFrame:CGRectMake(0, 16, frame.size.width, 20)];
        titleLabel.text = title;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = [UIColor labelGrayColor];
        titleLabel.font = [UIFont fontWithName:@"HelveticaNeueLTStd-Cn" size:20];
        [self addSubview:titleLabel];
        titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [titleLabel autoAlignAxis:ALAxisVertical toSameAxisOfView:self];
        [titleLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self withOffset:7.0f];
        
        UILabel *infoLabel = [[UILabel alloc] init];//WithFrame:CGRectMake(0, 34, frame.size.width, 20)];
        infoLabel.text = subTitle;
        infoLabel.textAlignment = NSTextAlignmentCenter;
        infoLabel.textColor = [UIColor labelGrayColor];
        infoLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:13];
        [self addSubview:infoLabel];
        infoLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [infoLabel autoAlignAxis:ALAxisVertical toSameAxisOfView:self];
        [infoLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:titleLabel withOffset:3.0f];
        
        
        UIView *separatorLine = [[UIView alloc] init];//WithFrame:CGRectMake(0, 65, frame.size.width, 0.5f)];
        separatorLine.backgroundColor = [UIColor separatorColor];
        [self addSubview:separatorLine];
        separatorLine.translatesAutoresizingMaskIntoConstraints = NO;
        [separatorLine autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self withOffset:0.0f];
        [separatorLine autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self withOffset:0.0f];
        [separatorLine autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:infoLabel withOffset:5.0f];
        [separatorLine autoSetDimension:ALDimensionHeight toSize:[InterfaceMode isRetina] ? 0.5f : 1.0f];
        
        UIButton *button;
        for(int i = 0; i < items.count; ++i)
        {
            NSArray *item = [items objectAtIndex:i];
            
            NSString *buttonLabel = [item objectAtIndex:0];
            button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            button.tintColor = [UIColor whiteColor];
            button.tag = [[item objectAtIndex:1] intValue];
            [button setTitle:buttonLabel
                         forState:UIControlStateNormal];
            button.backgroundColor = [UIColor lightGreenColor];
            
            button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeueLTStd-Cn" size:18];
            
            button.layer.cornerRadius = 2.0f;
            [button setTitleColor:[UIColor whiteColor]
                              forState:UIControlStateNormal];
            [button addTarget:self
                            action:@selector(didPressButton:)
                  forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:button];
            button.translatesAutoresizingMaskIntoConstraints = NO;
            [button autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self withOffset:15.0f];
            [button autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self withOffset:-15.0f];
            [button autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:separatorLine withOffset:10.0f + i * 60];
            [button autoSetDimension:ALDimensionHeight toSize:44.0f];
        }
        
        if(cancelButtonTitle)
        {
            UIView *grayLine = [[UIView alloc] init];
            grayLine.backgroundColor = [UIColor separatorColor];
            [self addSubview:grayLine];
            grayLine.translatesAutoresizingMaskIntoConstraints = NO;
            [grayLine autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self withOffset:0.0f];
            [grayLine autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self withOffset:0.0f];
            [grayLine autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:button withOffset:10.0f];
            [grayLine autoSetDimension:ALDimensionHeight toSize:[InterfaceMode isRetina] ? 0.5f : 1.0f];
            
            UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            cancelButton.tag = -1;
            [cancelButton setTitle:cancelButtonTitle
                          forState:UIControlStateNormal];
            cancelButton.backgroundColor = [UIColor unableSellButtonColor];
            cancelButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeueLTStd-Cn" size:18];
            cancelButton.layer.cornerRadius = 2.0f;
            [cancelButton setTitleColor:[UIColor whiteColor]
                               forState:UIControlStateNormal];
            [cancelButton addTarget:self
                             action:@selector(didPressButton:)
                   forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:cancelButton];
            cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
            [cancelButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self withOffset:15.0f];
            [cancelButton autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self withOffset:-15.0f];
            [cancelButton autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:grayLine withOffset:10.0f];
            [cancelButton autoSetDimension:ALDimensionHeight toSize:44.0f];
        }
    }
    return self;
}

- (void) showEmail
{
    [UIView animateWithDuration:0.5f animations:^()
    {
        self.emailTextField.alpha = 1.0f;
        self.sendEmailButton.alpha = 1.0f;
        self.showEmailButton.alpha = 0.0f;
    }
    completion:^(BOOL flag)
    {
        self.emailTextField.hidden  = NO;
        self.sendEmailButton.hidden = NO;
        self.showEmailButton.hidden = YES;
        
    }];
}

- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    if (![InterfaceMode iPadFullScreen])
    {
        CGRect newRect = CGRectMake(self.frame.origin.x, self.frame.origin.y - 210, self.frame.size.width, self.frame.size.height);
        
        [UIView animateWithDuration:0.5f animations:^()
         {
             self.frame = newRect;
         }];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if([ValidationHelper isValidEmail:newString])
    {
        self.sendEmailButton.backgroundColor = [UIColor lightGreenColor];
        self.sendEmailButton.enabled = YES;
    }
    else
    {
        self.sendEmailButton.backgroundColor = [UIColor disabledButtonColor];
        self.sendEmailButton.enabled = NO;
    }
    return YES;
}

- (void)didPressButton:(UIButton *)target
{
    //[self.emailTextField resignFirstResponder];
    [self.delegate getTicket:self didPressButton:target.tag];
}

@end
