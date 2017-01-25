//
//  SelectTicketVariantViewController.m
//  EventGridManager
//
//  Created by Anton Kovalchuk on 03.06.15.
//  Copyright (c) 2015 Entech Solutions. All rights reserved.
//

#import "SelectTicketVariantViewController.h"
#import "CustomerInformationViewController.h"
#import "SplitViewController.h"
#import "TakePaymentNavigationController.h"

#import "GetTicketView.h"

#import "UIView+AutoLayout.h"
#import "UIColor+Extensions.h"
#import "Helper.h"

#import "Instance.h"
#import "Event.h"
#import "Seat.h"
#import "SeatNode.h"
#import "TicketVariant.h"

#import "DataManager.h"
#import "SeatCartItemDto.h"
#import "InterfaceMode.h"

@interface SelectTicketVariantViewController () <GetTicketViewProtocol>
@property (strong, nonatomic) GetTicketView  *getTicketView;
@property (strong, nonatomic) UIButton       *transparentView;
@property (nonatomic, strong) SeatNode       *seatNode;
@property (nonatomic, strong) NSArray        *ticketVariants;
@property (nonatomic, strong) UIScrollView   *scrollView;
- (void) hideControl;
@end

@implementation SelectTicketVariantViewController


- (instancetype) initWithSeat:(SeatNode *)seatNode ticketVariants:(NSArray *)ticketVariants
{
    if(self = [self init])
    {
        self.seatNode = seatNode;
        self.ticketVariants = ticketVariants;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    self.navigationController.navigationBarHidden = YES;
    self.view.backgroundColor = [UIColor clearColor];
    

    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    NSArray *sortedVariants = [self.ticketVariants sortedArrayUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"id_attribute" ascending:YES]]];
    
    for(int i = 0; i < sortedVariants.count; ++i)
    {
        TicketVariant *ticketVariant = sortedVariants[i];
        [items addObject:@[ticketVariant.name_attribute, [NSNumber numberWithInt:i]]];
    }
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.scrollView];
    //[self.scrollView autoPinEdge:ALEdgeLeft   toEdge:ALEdgeLeft   ofView:self.view];
    //[self.scrollView autoPinEdge:ALEdgeRight  toEdge:ALEdgeRight  ofView:self.view];
    [self.scrollView autoPinEdge:ALEdgeTop    toEdge:ALEdgeTop    ofView:self.view];
    [self.scrollView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.view];
    [self.scrollView autoSetDimension:ALDimensionWidth toSize:self.view.frame.size.width];
    [self.scrollView autoAlignAxis:ALAxisVertical toSameAxisOfView:self.view];
    
    self.transparentView = [[UIButton alloc] init];
    [self.transparentView addTarget:self action:@selector(hideControl) forControlEvents:UIControlEventTouchUpInside];
    //self.transparentView.hidden = YES;
    self.transparentView.backgroundColor = [UIColor clearColor];
    //self.transparentView.alpha = 0.0f;
    self.transparentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView addSubview:self.transparentView];
    [self.transparentView autoSetDimension:ALDimensionWidth toSize:self.view.frame.size.width];
    [self.transparentView autoSetDimension:ALDimensionHeight toSize:self.view.frame.size.height];
    [self.transparentView autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.scrollView];
    [self.transparentView autoAlignAxis:ALAxisVertical toSameAxisOfView:self.scrollView];
    /*
    [self.transparentView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0.0f];
    [self.transparentView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0.0f];
    [self.transparentView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0.0f];
    [self.transparentView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0.0f];
    */
    self.getTicketView = [[GetTicketView alloc] initWithTitle:@"Order Now"
                                                     subTitle:@"Select ticket type"
                                                        items:items
                                                 cancelButton:nil];
    
    float height = items.count * 60.0f + 80.0f;
    
    self.getTicketView.delegate = self;
    self.getTicketView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView addSubview:self.getTicketView];
    if ([InterfaceMode iPadFullScreen])
    {
        [self.getTicketView autoAlignAxis:ALAxisVertical toSameAxisOfView:self.scrollView];
        //[self.getTicketView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.scrollView];
        [self.getTicketView autoSetDimension:ALDimensionWidth toSize:320.0f];
        [self.getTicketView autoSetDimension:ALDimensionHeight toSize:height];
    }
    else
    {
        [self.getTicketView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.scrollView withOffset:0.0f];

        
        [self.getTicketView autoSetDimension:ALDimensionHeight toSize:height];
        [self.getTicketView autoSetDimension:ALDimensionWidth toSize:self.view.frame.size.width];
    }
    if(height > self.view.frame.size.height)
        [self.getTicketView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.scrollView];
    else
        [self.getTicketView autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.scrollView];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.ticketVariants.count * 60.0f + 80.0f);
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (![InterfaceMode iPadFullScreen])
    {
        [UIView animateWithDuration:0.5f animations:^()
         {
             self.transparentView.alpha = 0.3f;
         }];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (![InterfaceMode iPadFullScreen])
    {
        [UIView animateWithDuration:0.5f animations:^()
         {
             self.transparentView.alpha = 0.0f;
         }];
    }
    [super viewWillDisappear:animated];
}

- (void)hideControl
{
    [self.delegate didPressButtonForSeat:self.seatNode ticketVariant:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)getTicket:(GetTicketView *)getTicketView didPressButton:(NSInteger)button
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.delegate didPressButtonForSeat:self.seatNode ticketVariant:(button == -1) ? nil : self.ticketVariants[button]];
}


@end
