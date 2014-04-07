//
//  RiffObject.m
//  RiffTrax DVD Player
//
//  Created by C.W. Betts on 4/6/14.
//
//

#import "RiffObject.h"

@implementation RiffObject
@synthesize discID;

- (NSString *)path;
{
	return [_URL path];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super init]) {
		
	}
	
	return self;
}


@end
