//
//  RiffObject.h
//  RiffTrax DVD Player
//
//  Created by C.W. Betts on 4/6/14.
//
//

#import <Foundation/Foundation.h>

@interface RiffObject : NSObject <NSCoding>

@property BOOL hasSync;
@property (strong) NSString* riffName;
@property (strong) NSURL *URL;
@property (strong) NSData *discID;

- (NSString *)path;

@end
