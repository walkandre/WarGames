//
//  HIDThing.h
//  WarGames
//
//  Created by Andre Cardozo on 2/15/13.
//  Copyright (c) 2013 rga. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Queue.h"

@interface HIDThing : NSObject {
  

  
}

@property NSMutableArray* commands;

- (void) led:(BOOL) state;
- (void) check_hid;
- (void) move:(NSString*) direction;
- (void) shootWithCommands:(NSArray*) _commands;

@end
