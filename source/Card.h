//
//  Card.h
//  MUW SIP Trainer
//
//  Created by Philipp König on 04.05.14.
//  Copyright (c) 2014 Philipp König. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Card : NSObject

@property (strong, nonatomic) NSString *front;
@property (strong, nonatomic) NSString *back;

-(id) init;

@end
