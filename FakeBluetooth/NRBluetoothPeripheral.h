//
//  NRBluetoothServer.h
//  BTTestiOS6
//
//  Created by nori on 12/07/04.
//  Copyright (c) 2012年 nori. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NRBluetoothPeripheral : NSObject
- (void)startPeripheral;
- (void)stopPeripheral;
- (void)setBTValue:(uint8_t)value;

@end
