//
//  RiffSyncObject.h
//  RiffTrax DVD Player
//
//  Created by C.W. Betts on 4/6/14.
//
//

#import <Foundation/Foundation.h>
#import "RiffObject.h"

@interface RiffSyncObject : NSObject
@property BOOL hasSync;
@property NSTimeInterval riffDelay;
@property NSTimeInterval riffStart;
@property double timeOffset;
@property UInt16 riffTitle;

- (instancetype)initWithRiffObject:(RiffObject*)ro;
@end
