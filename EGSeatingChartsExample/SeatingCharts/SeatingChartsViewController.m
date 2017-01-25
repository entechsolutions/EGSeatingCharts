//
//  SeatingChartsViewController2.m
//  EventGridManager
//
//  Created by Антон Ковальчук on 14.05.14.
//  Copyright (c) 2014 Антон Ковальчук. All rights reserved.
//

#import "SeatingChartsViewController.h"
#import "EventsNavigationController.h"
#import "SeatingChartsOrdersViewController.h"
#import "SelectTicketVariantViewController.h"
#import "SplitViewController.h"
#import "SeatingChartsScene.h"
#import "DashboardViewController.h"
#import "SelectAddonsViewController.h"

#import "UIColor+Extensions.h"
#import "UIView+AutoLayout.h"

#import "MBProgressHUD.h"
#import "LegendaScrollView.h"
#import "Constants.h"

#import <SpriteKit/SpriteKit.h>
#import <CoreData/CoreData.h>
#import <EasyMapping/EasyMapping.h>
#import "DataManager.h"
#import "MappingProvider.h"
#import "Ticket.h"
#import "Helper.h"
#import "Instance.h"
#import "Event.h"
#import "SeatingChart.h"
#import "NumberingMethod.h"
#import "Section.h"
#import "Seat.h"
#import "Row.h"
#import "TicketVariant.h"
#import "SeatCartItemDto.h"
#import "AvailableSection.h"
#import "AvailableSeat.h"

#import "ServiceLayer.h"
#import "TicketsService.h"
#import "CartService.h"
#import "TicketsCache.h"

#import "EnterDonationSeatView.h"
#import "SeatNode.h"
#import "AppDelegate.h"
#import "InterfaceMode.h"

__attribute__((unused)) static NSUInteger SELECT_TICKETS_CONTROLLER_POSITION = 2;
//#define IS_IPHONE_5 (fabs((double)[[UIScreen mainScreen] bounds].size.height - (double)568) < DBL_EPSILON)

static NSString * kViewTransformChanged = @"view transform changed";

@interface SeatingChartsViewController ()
<UIScrollViewDelegate,
 UIActionSheetDelegate,
 UIViewControllerTransitioningDelegate,
 SeatingChartsProtocol,
 EnterDonationSeatViewProtocol,
 SelectTicketVariantViewControllerProtocol>

@property (nonatomic, strong) SKView                *skView;
@property (nonatomic, strong) SeatingChartsScene    *scene;
@property (nonatomic, strong) UIButton              *addTicketsButton;
@property (nonatomic, strong) EnterDonationSeatView *enterDonationSeatView;
@property (nonatomic, strong) SeatCartItemDto       *lastSeatCartItemDto;
@property (nonatomic, strong) UIView                *transparentView;
@property (nonatomic, strong) UIView                *bottomView;
@property (nonatomic, strong) UIView                *helpView;
@property (nonatomic, strong) LegendaScrollView     *legendaScrollView;
@property (nonatomic, strong) UIPageControl         *pageControl;
@property (nonatomic, strong) MBProgressHUD         *loader;

@property (nonatomic) int total;
@property (nonatomic) int sector;
@property (nonatomic) NSUInteger pageCount;

- (void) zoomOutButtonPressed;
- (void) pageAction:(UIPageControl *)control;
- (void) updateSellButton;
- (void) addTicketsButtonPressed;
- (void) createLegenda;

@end


@implementation SeatingChartsViewController

- (void)loadView
{
    [super loadView];
    
    self.title = @"Seating Chart";
    
    self.legendaScrollView = [[LegendaScrollView alloc] init];
    self.legendaScrollView.scrollEnabled = YES;
    self.legendaScrollView.backgroundColor = [UIColor seatingChartsBackgound];
    self.legendaScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.legendaScrollView.pagingEnabled = YES;
    self.legendaScrollView.delegate = self;
    [self.view addSubview:self.legendaScrollView];
    [self.legendaScrollView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0.0f];
    [self.legendaScrollView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0.0f];
    [self.legendaScrollView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:64.0f];
    [self.legendaScrollView autoSetDimension:ALDimensionHeight toSize:80.0f];
    
    
    self.pageControl = [[UIPageControl alloc] init];
    [self.pageControl addTarget:self action:@selector(pageAction:) forControlEvents:UIControlEventValueChanged];
    self.pageControl.pageIndicatorTintColor = [UIColor grayColor];
    self.pageControl.currentPageIndicatorTintColor = [UIColor redColor];
    self.pageControl.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.pageControl];
    [self.pageControl autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.legendaScrollView withOffset:12.0f];
    [self.pageControl autoAlignAxisToSuperviewAxis:ALAxisVertical];
    
    UIImageView *separator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"legendaSeparator.png"]];
    separator.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:separator];
    [separator autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0.0f];
    [separator autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0.0f];
    [separator autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.legendaScrollView withOffset:-1.0f];
    
    // Configure the view.
    SKView *skView = [[SKView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    skView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview: skView];
    skView.translatesAutoresizingMaskIntoConstraints = NO;
    [skView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0.0f];
    [skView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0.0f];
    [skView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.legendaScrollView withOffset:0.0f];
    [skView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0.0f];
    self.skView = skView;

    // Create and configure the scene.
    self.scene = [[SeatingChartsScene alloc] initWithSize: CGSizeMake(640 * 2, 700 * 2)];
    self.scene.scaleMode = SKSceneScaleModeResizeFill;
    self.scene.delegateSC = self;
    [skView presentScene:self.scene];
    
    UIButton *zoomOutButton = [UIButton buttonWithType:UIButtonTypeCustom];
    zoomOutButton.hidden = YES;
    [zoomOutButton setImage:[UIImage imageNamed:@"zoomOut.png"] forState:UIControlStateNormal];
    [zoomOutButton addTarget:self action:@selector(zoomOutButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:zoomOutButton];
    zoomOutButton.translatesAutoresizingMaskIntoConstraints = NO;
    [zoomOutButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:15.0f];
    [zoomOutButton autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.legendaScrollView withOffset:10.0f];
    self.scene.zoomOutButton = zoomOutButton;
    
    self.bottomView = [[UIView alloc] init];
    self.bottomView.backgroundColor = [UIColor whiteColor];
    self.bottomView.alpha = 0.8f;
    self.bottomView.translatesAutoresizingMaskIntoConstraints = NO;
    self.bottomView.tag = 2;
    [self.view addSubview:self.bottomView];
    [self.bottomView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0.0f];
    [self.bottomView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0.0f];
    [self.bottomView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0.0f];
    [self.bottomView autoSetDimension:ALDimensionHeight toSize: ([InterfaceMode iPadFullScreen]) ? 106.0f : 84.0f];
    
    UIImageView *separatorView = [[UIImageView alloc] init];
    separatorView.image = [UIImage imageNamed:@"buyTicketsShadow.png"];
    [self.bottomView addSubview:separatorView];
    separatorView.translatesAutoresizingMaskIntoConstraints = NO;
    [separatorView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.bottomView withOffset:0.0f];
    [separatorView autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.bottomView withOffset:0.0f];
    [separatorView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.bottomView withOffset:-2.0f];
    [separatorView autoSetDimension:ALDimensionHeight toSize:2.0f];
    
    self.addTicketsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.addTicketsButton.enabled = NO;
    self.addTicketsButton.backgroundColor = [UIColor disabledButtonColor];
    [self.addTicketsButton setTitle:@"NO TICKETS FOR SALE"
                           forState:UIControlStateNormal];
    if ([InterfaceMode iPadFullScreen])
    {
        self.addTicketsButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeueLTStd-Cn" size:22];
    }
    else
    {
        self.addTicketsButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeueLTStd-Cn" size:18];
    }
    self.addTicketsButton.layer.cornerRadius = 2.0f;
    [self.addTicketsButton setTitleColor:[UIColor whiteColor]
                                forState:UIControlStateNormal];
    [self.addTicketsButton addTarget:self
                              action:@selector(addTicketsButtonPressed)
                    forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:self.addTicketsButton];
    self.addTicketsButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.addTicketsButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.bottomView withOffset:20.0f];
    [self.addTicketsButton autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.bottomView withOffset:-20.0f];
    [self.addTicketsButton autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.bottomView withOffset:20.0f];
    [self.addTicketsButton autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.bottomView withOffset:-20.0f];
    
    self.loader = [[MBProgressHUD alloc] initWithView:self.view];
    self.loader.animationType = MBProgressHUDAnimationZoomIn;
    [self.view addSubview:self.loader];
    self.loader.label.text = NSLocalizedString(@"Requesting Seating Chart...", @"");
    
    self.helpView = [[UIView alloc] init];
    self.helpView.translatesAutoresizingMaskIntoConstraints = NO;
    self.helpView.alpha = 0.0f;
    self.helpView.tag = 1;
    [self.view addSubview:self.helpView];
    [self.helpView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0.0f];
    [self.helpView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0.0f];
    [self.helpView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0.0f];
    [self.helpView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0.0f];
    
    UIView *helpBackView = [[UIView alloc] init];
    helpBackView.backgroundColor = [UIColor blackColor];
    helpBackView.alpha = 0.67f;
    helpBackView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.helpView addSubview:helpBackView];
    [helpBackView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.helpView withOffset:0.0f];
    [helpBackView autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.helpView withOffset:0.0f];
    [helpBackView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.helpView withOffset:0.0f];
    [helpBackView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.helpView withOffset:0.0f];
    
    UIImageView *helpImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pinchHelper.png"]];
    helpImage.translatesAutoresizingMaskIntoConstraints = NO;
    [self.helpView addSubview:helpImage];
    [helpImage autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.helpView];
    [helpImage autoAlignAxis:ALAxisVertical toSameAxisOfView:self.helpView];
    
    
    self.enterDonationSeatView = [[EnterDonationSeatView alloc] init];
    self.enterDonationSeatView.delegate = self;
    self.enterDonationSeatView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.enterDonationSeatView];
    [self.enterDonationSeatView autoPinEdge:ALEdgeLeft   toEdge:ALEdgeLeft   ofView:self.view];
    [self.enterDonationSeatView autoPinEdge:ALEdgeRight  toEdge:ALEdgeRight  ofView:self.view];
    [self.enterDonationSeatView autoPinEdge:ALEdgeTop    toEdge:ALEdgeTop    ofView:self.view];
    [self.enterDonationSeatView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.view];
    
    self.transparentView = [[UIView alloc] init];
    self.transparentView.backgroundColor = [UIColor blackColor];
    self.transparentView.alpha = 0.0f;
    self.transparentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.transparentView];
    [self.transparentView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0.0f];
    [self.transparentView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0.0f];
    [self.transparentView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0.0f];
    [self.transparentView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0.0f];
    

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back.png"]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(goBack)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(WillResignActiveNotification)
                                                 name: UIApplicationWillResignActiveNotification
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(DidBecomeActiveNotification)
                                                 name: UIApplicationDidBecomeActiveNotification
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(DidEnterBackgroundNotification)
                                                 name: UIApplicationDidEnterBackgroundNotification
                                               object: nil];

    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(WillEnterForegroundNotification)
                                                 name: UIApplicationWillEnterForegroundNotification
                                               object: nil];
    
    [self.instance.event removeCarts];
    [self requestSeatingChartsWithLoader:YES];
}

- (void) WillResignActiveNotification
{
    self.skView.paused = YES;
}

- (void) DidBecomeActiveNotification
{
    self.skView.paused = NO;
}

- (void) DidEnterBackgroundNotification
{
    self.skView.paused = YES;
}

- (void) WillEnterForegroundNotification
{
    self.skView.paused = NO;
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    [self.enterDonationSeatView shiftKeyboard:YES];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [self.enterDonationSeatView shiftKeyboard:NO];
}

- (void) requestSeatingChartsWithLoader:(BOOL)withLoader
{
    self.loader.label.text = NSLocalizedString(@"Requesting Seating Chart...", @"");
    if(withLoader)
        [self.loader showAnimated:YES];
    __weak SeatingChartsViewController *weakSelf = self;
    [[ServiceLayer instance].ticketsService requestSeatingChartsWithInstance:self.instance
                                                                completionOK:^(){
                                                                    [weakSelf requestTicketsWithLoader:NO];
                                                                } completionError:^(){
                                                                    [weakSelf.loader hideAnimated: YES];
                                                                } completionAnyway:^(){
                                                                    
                                                                } controller:self];
}

- (void) requestTicketsWithLoader:(BOOL)withLoader
{
    self.loader.label.text = NSLocalizedString(@"Requesting Ticket Types...", @"");
    if(withLoader)
        [self.loader showAnimated:YES];
    __weak SeatingChartsViewController *weakSelf = self;
    [[ServiceLayer instance].ticketsService requestTicketTypesWithInstance:self.instance
                                                              completionOK:^(){
                                                                  [weakSelf requestAvailableTicketsWithLoader:NO];
                                                              } completionError:^(){
                                                                  [weakSelf.loader hideAnimated: YES];
                                                              } completionAnyway:^(){
                                                                  
                                                              } controller:self];
}

- (void) requestAvailableTicketsWithLoader:(BOOL)withLoader
{
    self.loader.label.text = NSLocalizedString(@"Requesting Available Seats...", @"");
    __weak SeatingChartsViewController *weakSelf = self;
    if(withLoader)
        [self.loader showAnimated:YES];
    [[ServiceLayer instance].ticketsService requestAvailableTicketsWithInstance:self.instance
                                                                   completionOK:^(){
                                                                       
                                                                       [weakSelf createLegenda];
                                                                       [weakSelf.scene createSeats:weakSelf.instance.event.seating_charts
                                                                                    availableSeats:weakSelf.instance.event.ticketTypes.allObjects];
                                                                       
                                                                       if([[DefaultsWrapper sharedInstance] objectForKey:@"first_start"] == nil)
                                                                       {
                                                                           [UIView animateWithDuration:0.5f animations:^() {
                                                                               weakSelf.helpView.alpha = 1.0f;
                                                                           } completion:^(BOOL flag) {
                                                                               dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                                                                                   [UIView animateWithDuration:0.5f animations:^(){ weakSelf.helpView.alpha = 0.0f; }];
                                                                               });
                                                                           }];
                                                                           [[DefaultsWrapper sharedInstance] setObject:@"lol" forKey:@"first_start"];
                                                                       }
                                                                       
                                                                   }
                                                                completionError:^(){
                                                                    
                                                                }
                                                               completionAnyway:^(){
                                                                   [weakSelf.loader hideAnimated: YES];
                                                               }
                                                                     controller:self];
}

- (void) releaseTicketsWithLoader:(BOOL)withLoader
{
    self.loader.label.text = NSLocalizedString(@"Releasing Ticket Types...", @"");
    if(withLoader)
        [self.loader showAnimated:YES];
    __weak SeatingChartsViewController *weakSelf = self;
    [[ServiceLayer instance].cartService removeCartWithInstance:self.instance
                                                   completionOK:^(){
                                                       [weakSelf requestAvailableTicketsWithLoader:NO];
                                                   }
                                                completionError:^(){
                                                    [weakSelf createLegenda];
                                                    [weakSelf.scene createSeats:weakSelf.instance.event.seating_charts
                                                                 availableSeats:weakSelf.instance.event.ticketTypes.allObjects];
                                                    
                                                    [weakSelf.loader hideAnimated: YES];
                                                }
                                               completionAnyway:^(){
                                                   
                                               }
                                                     controller:self];
}

- (void) zoomOutButtonPressed
{
    [self.scene zoomOut];
}

-(void)pageAction:(UIPageControl *)control
{
    NSInteger whichPage = control.currentPage;
    [UIView animateWithDuration:0.3f animations:^()
     {
         self.legendaScrollView.contentOffset = CGPointMake(self.view.frame.size.width * whichPage, -60.0f);
     }];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.legendaScrollView.contentSize = CGSizeMake(self.view.frame.size.width * self.pageCount, 1.0f);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float width = scrollView.frame.size.width;
    float xPos = scrollView.contentOffset.x+10;
    self.pageControl.currentPage = (int)xPos/width;
}

- (void)addOrderSeat:(SeatNode *)seatNode
{
    for(Ticket *ticket in self.instance.event.ticketTypes)
    {
        if([ticket.id_attribute isEqualToNumber:seatNode.seat.ticket_type_id_attribute])
        {
            if(ticket.variants.count > 1)
            {
                SelectTicketVariantViewController *selectTicketVariantViewController = [[SelectTicketVariantViewController alloc] initWithSeat:seatNode ticketVariants:ticket.variants.allObjects];
                selectTicketVariantViewController.delegate = self;
                
                if ([InterfaceMode iPadFullScreen])
                {
                    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
                    {
                        selectTicketVariantViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
                    }
                    else
                    {
                        selectTicketVariantViewController.modalPresentationStyle = UIModalPresentationCustom;
                        selectTicketVariantViewController.transitioningDelegate = self;
                    }
                    [self.splitViewController presentViewController:selectTicketVariantViewController animated:YES completion:nil];
                    [((SplitViewController *)self.splitViewController) showSemitransparentView:YES];
                }
                else
                {
                    [UIView animateWithDuration:0.5f animations:^() {
                        self.transparentView.alpha = 0.4f;
                    }];
                    
                    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
                    {
                        selectTicketVariantViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
                    }
                    else
                    {
                        selectTicketVariantViewController.modalPresentationStyle = UIModalPresentationCustom;
                        selectTicketVariantViewController.transitioningDelegate = self;
                    }
                    
                    [self.navigationController presentViewController:selectTicketVariantViewController animated:YES completion:nil];
                }
                
                return;
            }
            break;
        }
    }
    
    NSLog(@"addOrderSeat seat=%@",seatNode.seat.number_attribute);
    
    SeatCartItemDto *seatCartItemDto = [NSEntityDescription insertNewObjectForEntityForName:@"SeatCartItemDto"
                                                                     inManagedObjectContext:[DataManager instance].managedObjectContext];
    seatCartItemDto.unique_id_attribute = [Helper uuid];
    seatCartItemDto.type_attribute = [NSNumber numberWithInt: SeatT];
    seatCartItemDto.seat    = seatNode.seat;
    seatNode.seat.seat_cart_item_dto = seatCartItemDto;
    
    self.lastSeatCartItemDto = seatCartItemDto;
    
    for(Ticket *ticket in self.instance.event.ticketTypes)
    {
        if([ticket.id_attribute isEqualToNumber:seatNode.seat.ticket_type_id_attribute])
        {
            seatCartItemDto.ticket_variant = ticket.variants.allObjects.firstObject;
            break;
        }
    }
    
    [self updateSellButton];
    
    if(seatNode.seat.seat_cart_item_dto.ticket_variant.ticket.type_attribute.intValue == Donation)
        [self.enterDonationSeatView showWhiteView:YES];
    
    [[DataManager instance] save];
}

- (void)didPressButtonForSeat:(SeatNode *)seatNode ticketVariant:(TicketVariant *)ticketVariant
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
    if(ticketVariant == nil)
    {
        [seatNode unselectSprite];
        seatNode.select = NO;
        return;
    }
    
    SeatCartItemDto *seatCartItemDto = [NSEntityDescription insertNewObjectForEntityForName:@"SeatCartItemDto"
                                                                     inManagedObjectContext:[DataManager instance].managedObjectContext];
    seatCartItemDto.unique_id_attribute = [Helper uuid];
    seatCartItemDto.type_attribute = [NSNumber numberWithInt: SeatT];
    seatCartItemDto.seat    = seatNode.seat;
    seatNode.seat.seat_cart_item_dto = seatCartItemDto;
    
    self.lastSeatCartItemDto = seatCartItemDto;
    seatCartItemDto.ticket_variant = ticketVariant;
    
    [self updateSellButton];
    
    if(seatNode.seat.seat_cart_item_dto.ticket_variant.ticket.type_attribute.intValue == Donation)
        [self.enterDonationSeatView showWhiteView:YES];
    
    [[DataManager instance] save];
}

- (void)closeDialogAndSave:(BOOL)saveFlag
{
    if(self.enterDonationSeatView.donationTextField.text == nil ||
       [self.enterDonationSeatView.donationTextField.text isEqualToString:@""] ||
       self.enterDonationSeatView.donationTextField.text.intValue == 0)
    {
        self.lastSeatCartItemDto.donation_price_attribute = [NSDecimalNumber decimalNumberWithString:@"1"];
    }
    else
    {
        if([[NSDecimalNumber decimalNumberWithString:self.enterDonationSeatView.donationTextField.text] isEqualToNumber:[NSDecimalNumber notANumber]])
        {
            self.lastSeatCartItemDto.donation_price_attribute = [NSDecimalNumber decimalNumberWithString:@"1"];
        }
        else
        {
            self.lastSeatCartItemDto.donation_price_attribute = [NSDecimalNumber decimalNumberWithString:self.enterDonationSeatView.donationTextField.text];
        }
    }
}

- (void)removeOrderSeat:(SeatNode *)seatNode
{
    SeatCartItemDto *seatCartItemDto = seatNode.seat.seat_cart_item_dto;
    [[DataManager instance].managedObjectContext deleteObject:seatCartItemDto];
    [[DataManager instance] save];
    
    [self updateSellButton];
}

- (void)updateSellButton
{
    if([self.instance.event cartsCount:CartCountingTickets])
    {
        self.addTicketsButton.enabled = YES;
        self.addTicketsButton.backgroundColor = [UIColor lightGreenColor];
        [self.addTicketsButton setTitle:@"ORDER NOW"
                               forState:UIControlStateNormal];
    }
    else
    {
        self.addTicketsButton.enabled = NO;
        self.addTicketsButton.backgroundColor = [UIColor disabledButtonColor];
        if(self.instance.event.has_schedule_attribute.boolValue)
        {
            [self.addTicketsButton setTitle:@"NO REGISTRATIONS FOR SALE"
                                   forState:UIControlStateNormal];
        }
        else
        {
            [self.addTicketsButton setTitle:@"NO TICKETS FOR SALE"
                                   forState:UIControlStateNormal];
        }
    }
}

- (void) createLegenda
{
    self.pageCount = [self.instance.event pagesCountForLegenda];
    
    if(self.pageCount < 2)
        self.pageControl.hidden = YES;
    else
        self.pageControl.numberOfPages = self.pageCount;
    
    [self.legendaScrollView fillWithEntity:self.instance.event width:self.view.frame.size.width];
}


- (void) addTicketsButtonPressed
{
    [self reserveRequest];
    /*
    if([self.instance.event addonVariants])
    {
        SelectAddonsViewController *selectAddonsViewController = [[SelectAddonsViewController alloc] initWithInstance:self.instance];
        [self.navigationController pushViewController:selectAddonsViewController animated:YES];
    }
    else
    {
        [self reserveRequest];
    }
     */
}

- (void) createCart
{
    __weak SeatingChartsViewController *weakSelf = self;
    [[ServiceLayer instance].cartService createCartWithInstance:self.instance
     
                                                   completionOK:^(){
                                                       
                                                       SeatingChartsOrdersViewController *seatingChartsOrdersViewController = [[SeatingChartsOrdersViewController alloc] initWithInstance:weakSelf.instance showEventInfo:NO];
                                                       [weakSelf.navigationController pushViewController:seatingChartsOrdersViewController animated:YES];
                                                       
                                                   } completionError:^(){
                                                       
                                                   } completionAnyway:^(){
                                                       [weakSelf.loader hideAnimated:YES];
                                                   }
                                                     controller:self];

}

- (void) reserveRequest
{
    self.loader.label.text = NSLocalizedString(@"Creating Cart...", @"");
    [self.loader showAnimated:YES];
    if (![self businessPaymentSettingsDtoBase]) {
        __weak SeatingChartsViewController *weakSelf = self;
        [self getPaymentSettingsWithCompletionOK:^{
        } completionError:^(NSDictionary *dict) {
        } completionAnyway:^{
            [weakSelf createCart];
        }];
    } else {
        [self createCart];
    }
}

- (void) updateUI
{
    [self updateSellButton];
    [self.scene updateSelectedSeats:self.instance.event.ticketTypes.allObjects];
}

- (void) removeOrders
{
    [self.instance.event removeCarts];
    [[self.legendaScrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self updateSellButton];
}

- (void)goBack
{
    DashboardViewController *dashboardViewController = ((DashboardViewController *)[self.navigationController.viewControllers objectAtIndex:DASHBOARD_CONTROLLER_POSITION]);
    [dashboardViewController requestDashboard];
    
    [super goBack];
    self.scene.delegate = nil;
}

+ (NSUInteger)controllerPosition
{
    return SELECT_TICKETS_CONTROLLER_POSITION;
}

+ (void)setControllerPosition:(NSUInteger)value
{
    SELECT_TICKETS_CONTROLLER_POSITION = value;
}


@end
