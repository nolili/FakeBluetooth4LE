//
//  NRViewController.m
//  FakeBluetooth
//
//  Created by nori on 12/07/12.
//  Copyright (c) 2012年 nori. All rights reserved.
//

#import "NRViewController.h"
#import "NRBluetoothPeripheral.h"
@interface NRViewController ()
{
    __strong NRBluetoothPeripheral *_peripheral;
}
@end

@implementation NRViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _peripheral = [[NRBluetoothPeripheral alloc] init];
    [_peripheral startPeripheral];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)zero:(id)sender {
    [_peripheral setBTValue:1];
}

- (IBAction)hyaku:(id)sender {
    [_peripheral setBTValue:100];
}

- (IBAction)max:(id)sender {
    [_peripheral setBTValue:255];
}
@end
