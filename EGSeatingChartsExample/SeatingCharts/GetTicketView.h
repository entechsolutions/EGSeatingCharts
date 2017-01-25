//
//  GetTicketView.h
//  EventGridManager
//
//  Created by Антон Ковальчук on 27.01.14.
//  Copyright (c) 2014 Антон Ковальчук. All rights reserved.
//

#import <UIKit/UIKit.h>

enum ButtonType
{
    PRINT,
    EMAIL,
    SMS,
    DO_NOTHING = 4
};

@class GetTicketView;
@class TextField;

@protocol GetTicketViewProtocol <NSObject>
-(void) getTicket:(GetTicketView *)getTicketView didPressButton:(NSInteger)button;
@end

@interface GetTicketView : UIView
- (instancetype)initWithTitle:(NSString *)title
                     subTitle:(NSString *)subTitle
                        items:(NSArray *)items
                 cancelButton:(NSString *)cancelButton;
@property (weak, nonatomic) id<GetTicketViewProtocol> delegate;
@property (strong, nonatomic) TextField *emailTextField;
@end
