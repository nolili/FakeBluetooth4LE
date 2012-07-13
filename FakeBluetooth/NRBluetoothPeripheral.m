//
//  NRBluetoothServer.m
//  BTTestiOS6
//
//  Created by nori on 12/07/04.
//  Copyright (c) 2012年 nori. All rights reserved.
//

#import "NRBluetoothPeripheral.h"
#import <CoreBluetooth/CoreBluetooth.h>
//#import "NRUUIDS.h"

@interface NRBluetoothPeripheral() <CBPeripheralManagerDelegate>
{
    // サーバ側
    __strong CBPeripheralManager     *_peripheralManager;
    __strong CBCentral               *_central;
    __strong CBMutableCharacteristic *_heartRateChar;
    __strong CBMutableCharacteristic *_sensorLocationChar;
    __strong CBMutableCharacteristic *_controlPointChar;
    BOOL _isSubscribed;
}
@end
@implementation NRBluetoothPeripheral

- (id)init
{
    self = [super init];
    if (self) {
        
        
    }
    return self;
}
- (void)dealloc
{
    _peripheralManager.delegate = nil;
    
}

- (void)setupPeripheralManager
{
    // UUID for service
    CBUUID *serviceUUID = [CBUUID UUIDWithString:@"180D"];
    CBMutableService *service = [[CBMutableService alloc] initWithType:serviceUUID primary:YES];
    
    // Initialize Characteristics
    _heartRateChar = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:@"2A37"]
                                                        properties:CBCharacteristicPropertyNotify
                                                             value:nil
                                                       permissions:CBAttributePermissionsReadable];
    
    uint8_t data = 0x01;
    NSLog(@"%x", data);
    _sensorLocationChar = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:@"2A38"]
                                                             properties:CBCharacteristicPropertyRead
                                                                  value:[NSData dataWithBytes:&data length:sizeof(uint8_t)]
                                                            permissions:CBAttributePermissionsReadable];
    
    _controlPointChar = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:@"2A39"] properties:CBCharacteristicPropertyWrite value:nil permissions:CBAttributePermissionsWriteable];
     
    // set Characetristics array
    service.characteristics = @[ _heartRateChar, _sensorLocationChar, _controlPointChar ];
    
    // add service to manager
    [_peripheralManager addService:service];
    
    // build advertise data
    NSDictionary *dict =
    @{
    CBAdvertisementDataServiceUUIDsKey     : @[service.UUID],
    CBAdvertisementDataLocalNameKey        : @"Hello", // 10文字まで
    CBAdvertisementDataManufacturerDataKey : @"IAMAS"
    };
    
    // Start sending packet for advertising
    [_peripheralManager startAdvertising:dict];
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    if (peripheral.state == CBPeripheralManagerStatePoweredOn){
        [self setupPeripheralManager];
    }
    else{
        [self stopPeripheral];
    }
}

// CBCentralManagerDelegateRequredMethod

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
{
    if (error)
        NSLog(@"%@", error);
    NSLog(@"%s", __FUNCTION__);
    
    if (peripheral.isAdvertising)
    {
        NSLog(@"advertising");
        
    }
}

// peripheralに接続が完了した際に呼び出される
- (void)peripheralManager:(CBPeripheralManager *)peripheral centralDidConnect:(CBCentral *)central
{
    [peripheral stopAdvertising];
    _central = central;
    
   
    
}

// peripheralの接続が切断した際に呼び出される
- (void)peripheralManager:(CBPeripheralManager *)peripheral centralDidDisconnect:(CBCentral *)central
{
    _central = nil;
    [self stopPeripheral];
}

// peripheralManagerにサービスが追加された際に呼び出される
- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error
{
    if (error)
        NSLog(@"%s %@", __FUNCTION__ , error);
    
    NSLog(@"%s", __FUNCTION__);
    NSLog(@"%@", peripheral);
}

// characteristicの監視が開始された際に呼び出される
- (void)peripheralManager:(CBPeripheralManager *)peripheral
                  central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic

{
    NSLog(@"%s", __FUNCTION__);
    _isSubscribed = YES;
     [self setBTValue:10];
    
}

// characteristicの監視が終了した際に呼び出される
- (void)peripheralManager:(CBPeripheralManager *)peripheral
                  central:(CBCentral *)central
didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"%s", __FUNCTION__);
    _isSubscribed = NO;
}

// characteristicへのread要求があった際に呼び出される
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request
{
    NSLog(@"%s", __FUNCTION__);
}

// characteristicへのwrite要求があった際に呼び出される
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests
{
    for (CBATTRequest *req in requests) {
        NSMutableData *data = [[NSMutableData alloc] init];
        if ([req.characteristic isEqual:_controlPointChar])
        {
            [data appendData:req.value];
        }
        NSLog(@">>書き込まれたデータ%@", data);
        
        uint8_t value = *(uint8_t *)[data bytes];
        if (value == 1){
            _isSubscribed = YES;
            [self setBTValue:0];
        }
    }
    NSLog(@"%s", __FUNCTION__);
    //NSLog(@"%@", requests);
}

- (void)startPeripheral
{
    if (!_peripheralManager){
        _peripheralManager = [[CBPeripheralManager alloc]
                             initWithDelegate:self queue:nil];
        _isSubscribed = NO;
    }
}

- (void)stopPeripheral
{
    [_peripheralManager stopAdvertising];
    [_peripheralManager removeAllServices];
    _heartRateChar = nil;
    _sensorLocationChar = nil;
    _controlPointChar = nil;
    _peripheralManager.delegate = nil;
    _peripheralManager = nil;
}

- (void)setBTValue:(uint8_t)value
{
    if (_isSubscribed && _heartRateChar){
    static const uint8_t datalength = 2;
    uint8_t data[datalength];
    data[0] = 0;
    data[1] = value;
    
    [_peripheralManager
     updateValue:[NSData dataWithBytes:data length:datalength] forCharacteristic:_heartRateChar onSubscribedCentrals:nil];
    }
}

@end
