//
//  SeatingChartsOrdersViewController.m
//  CustomerApp
//
//  Created by Антон Ковальчук on 10.04.15.
//  Copyright (c) 2015 Антон Ковальчук. All rights reserved.
//

#import "SeatingChartsOrdersViewController.h"
#import "EventsNavigationController.h"
#import "SelectPaymentTypeViewController.h"
#import "TakePaymentNavigationController.h"
#import "PromoCodeViewController.h"
#import "SeatingChartsViewController.h"
#import "SplitViewController.h"
#import "Instance.h"
#import "Event.h"
#import "Venue.h"
#import "UIView+AutoLayout.h"
#import "UIColor+Extensions.h"

#import "Constants.h"
#import "Helper.h"
#import "MBProgressHUD.h"

#import "ServiceLayer.h"
#import "OrdersService.h"
#import "OrdersCache.h"
#import "CustomerInformationViewController.h"
#import "Ticket.h"
#import "TicketVariant.h"
#import "TicketTypeCartItemDto.h"
#import "OrderWithoutSessionCell.h"
#import "SeatCartItemDto.h"
#import "Seat.h"
#import "Row.h"
#import "Section.h"

#import "TotalAmount.h"
#import "SeatingChartsOrderCell.h"
#import "TitleView.h"
#import "BusinessPaymentSettingsDtoBase.h"
#import "InterfaceMode.h"

@interface SeatingChartsOrdersViewController ()
<UITableViewDataSource,
 UITableViewDelegate,
 UIViewControllerTransitioningDelegate,
 UIPopoverControllerDelegate,
 SelectPaymentTypeViewControllerProtocol,
 PromoCodeViewControllerDelegate>

@property (strong, nonatomic) UITableView   *ordersTableView;
@property (strong, nonatomic) Instance      *instance;
@property (strong, nonatomic) UIButton      *orderButton;
@property (strong, nonatomic) UIButton      *cashButton;
@property (strong, nonatomic) UIButton      *creditButton;
@property (strong, nonatomic) UIButton      *squareCreditButton;
@property (strong, nonatomic) MBProgressHUD *loader;
@property (nonatomic) BOOL showEventInfo;
@property (strong, nonatomic) UIView                     *transparentView;
@property (strong, nonatomic) UIPopoverController *promoPopoverController;
@end

@implementation SeatingChartsOrdersViewController

- (instancetype) initWithInstance:(Instance *)instance showEventInfo:(BOOL)showEventInfo
{
    if(self = [super init])
    {
        self.instance = instance;
        self.showEventInfo = showEventInfo;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    [((EventsNavigationController *)self.navigationController) showTimer:YES];
    
    if(self.showEventInfo)
    {
        self.title = @"View Order";
    }
    else
    {
        TitleView *titleView = [[TitleView alloc] initWithFrame:CGRectZero width:[InterfaceMode iPadFullScreen] ? 700.0f : self.view.frame.size.width];
        titleView.titleLabel.text = self.instance.event.title_attribute;
        titleView.dateLabel.text = [Helper convertDateFromString: self.instance.start_date_time_attribute
                                                     andTimeZone: self.instance.event.timezone_id_attribute];
        self.navigationItem.titleView = titleView;
    }
    
    self.ordersTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.ordersTableView.delegate   = self;
    self.ordersTableView.dataSource = self;
    self.ordersTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.ordersTableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.ordersTableView];
    self.ordersTableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.ordersTableView autoPinEdge:ALEdgeLeft   toEdge:ALEdgeLeft   ofView:self.view withOffset:0.0f];
    [self.ordersTableView autoPinEdge:ALEdgeRight  toEdge:ALEdgeRight  ofView:self.view withOffset:0.0f];
    [self.ordersTableView autoPinEdge:ALEdgeTop    toEdge:ALEdgeTop    ofView:self.view withOffset:40.0f];
    [self.ordersTableView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.view withOffset:0.0f];
    
    BOOL useSquare = [self businessPaymentSettingsDtoBase].use_square_register_attribute.boolValue;

    if (![InterfaceMode iPadFullScreen])
    {
        self.orderButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.orderButton.backgroundColor = [UIColor lightGreenColor];
        self.orderButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeueLTStd-Cn" size:18];
        self.orderButton.titleEdgeInsets = UIEdgeInsetsMake(2.0f, 0.0f, 0.0f, 0.0f);
        self.orderButton.layer.cornerRadius = 2.0f;
        [self.orderButton setTitle:@"ORDER NOW" forState:UIControlStateNormal];
        [self.orderButton setTitleColor:[UIColor whiteColor]
                               forState:UIControlStateNormal];
        [self.orderButton addTarget:self
                             action:@selector(orderButtonPressed)
                   forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.orderButton];
        self.orderButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.orderButton autoPinEdge:ALEdgeLeft   toEdge:ALEdgeLeft   ofView:self.view withOffset:15.0f];
        [self.orderButton autoPinEdge:ALEdgeRight  toEdge:ALEdgeRight  ofView:self.view withOffset:-15.0f];
        [self.orderButton autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.view withOffset:-15.0f];
        [self.orderButton autoSetDimension:ALDimensionHeight toSize:44.0f];
    }
    else
    {
        UIButton *cashButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        cashButton.tintColor = [UIColor whiteColor];
        [cashButton setImage:[UIImage imageNamed:@"cashIcon.png"]
                    forState:UIControlStateNormal];
        cashButton.tag = PaymentTypeCash;
        [cashButton setTitle:@"CASH"
                    forState:UIControlStateNormal];
        cashButton.backgroundColor = [UIColor lightGreenColor];
        cashButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeueLTStd-Cn" size:22];
        cashButton.titleEdgeInsets = UIEdgeInsetsMake(0.0f, 15.0f, 0.0f, 0.0f);
        cashButton.layer.cornerRadius = 2.0f;
        [cashButton setTitleColor:[UIColor whiteColor]
                         forState:UIControlStateNormal];
        [cashButton addTarget:self
                       action:@selector(pressedPaymentTypeButton:)
             forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:cashButton];
        cashButton.translatesAutoresizingMaskIntoConstraints = NO;
        [cashButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.view withOffset:20.0f];
        [cashButton autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.view withOffset:-20.0f];
        [cashButton autoSetDimension:ALDimensionWidth toSize:315.0f];
        [cashButton autoSetDimension:ALDimensionHeight toSize:60.0f];
        self.cashButton = cashButton;
        
        UIButton *creditButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        creditButton.tintColor = [UIColor whiteColor];
        [creditButton setImage:[UIImage imageNamed:@"creditCardIcon.png"]
                      forState:UIControlStateNormal];
        creditButton.tag = PaymentTypeCreditCard;
        [creditButton setTitle:@"CREDIT CARD"
                      forState:UIControlStateNormal];
        creditButton.backgroundColor = [UIColor lightGreenColor];
        creditButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeueLTStd-Cn" size:22];
        creditButton.titleEdgeInsets = UIEdgeInsetsMake(0.0f, 15.0f, 0.0f, 0.0f);
        creditButton.layer.cornerRadius = 2.0f;
        [creditButton setTitleColor:[UIColor whiteColor]
                           forState:UIControlStateNormal];
        [creditButton addTarget:self
                         action:@selector(pressedPaymentTypeButton:)
               forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:creditButton];
        creditButton.translatesAutoresizingMaskIntoConstraints = NO;
        [creditButton autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.view withOffset:-20.0f];
        [creditButton autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.view withOffset:-20.0f];
        [creditButton autoSetDimension:ALDimensionWidth toSize:315.0f];
        [creditButton autoSetDimension:ALDimensionHeight toSize:60.0f];
        self.creditButton = creditButton;
        
        if (useSquare) {
            UIButton *squareCreditButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            squareCreditButton.tintColor = [UIColor whiteColor];
            [squareCreditButton setImage:[UIImage imageNamed:@"creditCardIcon.png"]
                          forState:UIControlStateNormal];
            squareCreditButton.tag = PaymentTypeCreditCard;
            [squareCreditButton setTitle:@"SQUARE REGISTER"
                          forState:UIControlStateNormal];
            squareCreditButton.backgroundColor = [UIColor lightGreenColor];
            squareCreditButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeueLTStd-Cn" size:22];
            squareCreditButton.titleEdgeInsets = UIEdgeInsetsMake(0.0f, 15.0f, 0.0f, 0.0f);
            squareCreditButton.layer.cornerRadius = 2.0f;
            [squareCreditButton setTitleColor:[UIColor whiteColor]
                               forState:UIControlStateNormal];
            [squareCreditButton addTarget:self
                             action:@selector(pressedPaymentTypeButton:)
                   forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:squareCreditButton];
            squareCreditButton.translatesAutoresizingMaskIntoConstraints = NO;
            [squareCreditButton autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.view withOffset:-20.0f];
            [squareCreditButton autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.view withOffset:-20.0f];
            [squareCreditButton autoSetDimension:ALDimensionWidth toSize:315.0f];
            [squareCreditButton autoSetDimension:ALDimensionHeight toSize:60.0f];
            self.squareCreditButton = squareCreditButton;
        }
    }
    
    if(self.showEventInfo)
    {
        self.orderButton.hidden            = YES;
        self.creditButton.hidden           = YES;
        if (useSquare) {
            self.squareCreditButton.hidden = YES;
        }
        self.cashButton.hidden             = YES;
    }
    else
    {
        self.orderButton.hidden            = NO;
        self.creditButton.hidden           = NO;
        if (useSquare) {
            self.squareCreditButton.hidden = NO;
        }
        self.cashButton.hidden             = NO;
    }
    
    self.transparentView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.transparentView.backgroundColor = [UIColor blackColor];
    self.transparentView.alpha = 0.0f;
    [self.navigationController.view addSubview:self.transparentView];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back.png"]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(goBack)];
    
    if(!self.showEventInfo)
    {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"promoCodeIcon.png"]
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self
                                                                                 action:@selector(showPromo)];
    }
    
    self.loader = [[MBProgressHUD alloc] initWithView:self.view];
    self.loader.label.text = NSLocalizedString(@"Calculating Total...", @"");
    self.loader.animationType = MBProgressHUDAnimationZoomIn;
    [self.view addSubview:self.loader];
}

- (void) orderButtonPressed
{
    SelectPaymentTypeViewController *selectPaymentTypeViewController = [[SelectPaymentTypeViewController alloc] initWithInstance:self.instance useSquareRegister:[self businessPaymentSettingsDtoBase].use_square_register_attribute.boolValue];
    selectPaymentTypeViewController.delegate = self;
    
    if ([InterfaceMode iPadFullScreen])
    {
        if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
        {
            selectPaymentTypeViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        }
        else
        {
            selectPaymentTypeViewController.modalPresentationStyle = UIModalPresentationCustom;
            selectPaymentTypeViewController.transitioningDelegate = self;
        }
        [self.splitViewController presentViewController:selectPaymentTypeViewController animated:YES completion:nil];
        [((SplitViewController *)self.splitViewController) showSemitransparentView:YES];
    }
    else
    {
        [UIView animateWithDuration:0.5f animations:^() {
            self.transparentView.alpha = 0.4f;
        }];
        
        if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
        {
            selectPaymentTypeViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        }
        else
        {
            selectPaymentTypeViewController.modalPresentationStyle = UIModalPresentationCustom;
            selectPaymentTypeViewController.transitioningDelegate = self;
        }
        
        [self.navigationController presentViewController:selectPaymentTypeViewController animated:YES completion:nil];
    }
}

- (void)didPressButton:(NSInteger)button
{
    if ([InterfaceMode iPadFullScreen])
    {
        [((SplitViewController *)self.splitViewController) showSemitransparentView:NO];
    }
    else
    {
        [UIView animateWithDuration:0.5f animations:^() {
            self.transparentView.alpha = 0.0f;
        }];
    }
    
    if(button != -1)
    {
        [self go2CustomerInfoWithPaymentType:button];
    }
}

- (void)go2CustomerInfoWithPaymentType:(NSInteger)paymentType
{
    [((OrdersCache *)[ServiceLayer instance].ordersService.abstractCache) clearBuyers];
    
    BOOL flag = self.instance.event.collect_guest_info_attribute.boolValue ||
    (self.instance.event.has_schedule_attribute.boolValue && self.instance.event.allow_register_for_sessions_attribute.boolValue);
    
    CustomerInformationViewController *customerInformationViewController = [[CustomerInformationViewController alloc] initWithInstance:self.instance andCustomerIndex:flag ? 0 : -1 paymentType:(int)paymentType];
    [self.navigationController pushViewController:customerInformationViewController animated:YES];
}

- (void) pressedPaymentTypeButton:(UIButton *)button
{
    [self go2CustomerInfoWithPaymentType:button.tag];
}

- (void) goBack
{
    if ([InterfaceMode iPadFullScreen])
    {
        if(self.promoPopoverController)
        {
            [self.promoPopoverController dismissPopoverAnimated:YES];
            self.promoPopoverController = nil;
            [((SplitViewController *)self.splitViewController) showSemitransparentView:NO];
        }
    }
    if(!self.showEventInfo)
    {
        [((EventsNavigationController *)self.navigationController) showTimer:NO];
    
        SeatingChartsViewController *seatingChartsViewController = ((SeatingChartsViewController *)[self.navigationController.viewControllers objectAtIndex:SeatingChartsViewController.controllerPosition]);
        [self.navigationController popToViewController:seatingChartsViewController animated:YES];
        [seatingChartsViewController removeOrders];
        [seatingChartsViewController releaseTicketsWithLoader:YES];
        [seatingChartsViewController clearPromocode];
    }
    else
    {
        [super goBack];
    }
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.instance.event cartsCount:CartCountingTickets];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    SeatingChartsOrderCell *cell = (SeatingChartsOrderCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[SeatingChartsOrderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    SeatCartItemDto *findSeatCartItemDto = (SeatCartItemDto *)[self.instance.event cartItemDtoBaseForIndex:indexPath.row];
    [cell fillWithEntity:findSeatCartItemDto instance:self.instance];
    
    if(indexPath.row == [self.instance.event cartsCount:CartCountingTickets] - 1)
    {
        cell.bottomLine.hidden = NO;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(self.showEventInfo)
    {
        return [self.instance headerView];
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(self.showEventInfo)
        return 110.0f;
    return 1.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [self.instance footerView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(!self.showEventInfo)
    {
        [self.loader showAnimated:YES];
        [self calculateTotal];
    }
}

- (void) showPromo
{
    if ([InterfaceMode iPadFullScreen])
    {
        if(!self.promoPopoverController)
        {
            PromoCodeViewController *promoCodeController = [[PromoCodeViewController alloc] initWithInstance:self.instance];
            promoCodeController.delegate = self;
            
            self.promoPopoverController = [[UIPopoverController alloc] initWithContentViewController:promoCodeController];
            self.promoPopoverController.delegate = self;
            self.promoPopoverController.popoverContentSize = CGSizeMake(320, 140);
            [self.promoPopoverController presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionLeft | UIPopoverArrowDirectionUp animated:YES];
            
            [((SplitViewController *)self.splitViewController) showSemitransparentView:YES];
        }
        else
        {
            [self.promoPopoverController dismissPopoverAnimated:YES];
            self.promoPopoverController = nil;
            [((SplitViewController *)self.splitViewController) showSemitransparentView:NO];
        }
    }
    else
    {
        PromoCodeViewController *promoCodeController = [[PromoCodeViewController alloc] initWithInstance:self.instance];
        promoCodeController.delegate = self;
        NavigationController *navController = [[NavigationController alloc ] initWithRootViewController:promoCodeController andBarTintColor:[UIColor navigationBarColor] inPopover:NO];
        
        [self.navigationController presentViewController:navController animated:YES completion:nil];
    }
}

- (void)promocodeApplied
{
    if ([InterfaceMode iPadFullScreen])
    {
        if(self.promoPopoverController)
        {
            [self.promoPopoverController dismissPopoverAnimated:YES];
            self.promoPopoverController = nil;
            [((SplitViewController *)self.splitViewController) showSemitransparentView:NO];
        }
    }
    [self.loader showAnimated:YES];
    [self calculateTotal];
}

- (void)calculateTotal {
    __weak SeatingChartsOrdersViewController *weakSelf = self;
    [[ServiceLayer instance].ordersService calculateTotalWithInstance:self.instance
                                                       processingType:CC_PROCESS
                                                         completionOK:^(){
                                                             [weakSelf.ordersTableView reloadData];
                                                         }
                                                      completionError:^(){
                                                          
                                                      }
                                                     completionAnyway:^(){
                                                         [weakSelf.loader hideAnimated:YES];
                                                     }
                                                           controller:self];
}

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
    [((SplitViewController *)self.splitViewController) showSemitransparentView:NO];
    return YES;
}

-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.promoPopoverController = nil;
}

@end

