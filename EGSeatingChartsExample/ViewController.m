//
//  ViewController.m
//  EGSeatingChartsExample
//
//  Created by Danila Parkhomenko on 25/01/2017.
//  Copyright © 2017 ENtechsolutions. All rights reserved.
//

#import "ViewController.h"
#import "SeatingChartsScene.h"
#import "ChartSKView.h"
#import "Event.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet ChartSKView *spriteKitView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    SeatingChartsScene *scene = [[SeatingChartsScene alloc] initWithSize:self.view.bounds.size
                                                                 mapSize:CGSizeMake(320.0f, 240.0f)
                                                             bottomSpace:80.0];
    [self.spriteKitView presentScene:scene];
    [scene createSeats:[[DummyChart alloc] init]
                 event:[[DummyEvent alloc] init]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
