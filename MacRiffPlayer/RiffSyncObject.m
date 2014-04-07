//
//  RiffSyncObject.m
//  RiffTrax DVD Player
//
//  Created by C.W. Betts on 4/6/14.
//
//

#import "RiffSyncObject.h"

@interface RiffSyncObject ()
@property (strong) RiffObject *riffObject;
@end


@implementation RiffSyncObject

- (BOOL)fillOutBasedOnURL:(NSURL*)theURL
{
	NSStringEncoding theEncoding = NSUTF8StringEncoding;
	NSString *syncString = [[NSString alloc] initWithContentsOfURL:theURL usedEncoding:&theEncoding error:NULL];
	int isValid = 0;
	if (!syncString) {
		return NO;
	}
	NSArray *fileVals = [syncString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
	if (!fileVals) {
		return NO;
	}
	for (NSString *var in fileVals) {
		NSRange currentRange;
		NSString *rangeString, *afterRangeStr;
		currentRange = [var rangeOfString:@"="];
		if (currentRange.location == NSNotFound) {
			continue;
		}
		rangeString = [var substringToIndex:NSMaxRange(currentRange)];
		afterRangeStr = [var substringFromIndex:NSMaxRange(currentRange)];
		if ([rangeString isEqualToString:@"riffdelay_init"]) {
			self.riffDelay = [afterRangeStr doubleValue];
			isValid += 1;
		} else if ([rangeString isEqualToString:@"riffstart"]) {
			self.riffStart = [afterRangeStr doubleValue];
			isValid += 1;
		} else if ([rangeString isEqualToString:@"time_offset"]) {
			self.timeOffset = [afterRangeStr doubleValue];
			isValid += 1;
		} else if ([rangeString isEqualToString:@"title_ID"]) {
			self.riffTitle = [afterRangeStr intValue];
		}
	}
	
	if (_riffTitle == 0) {
		self.riffTitle = 1;
	}
	
	if (isValid == 3) {
		return YES;
	} else {
		self.riffDelay = 0;
		self.riffStart = 0;
		self.timeOffset = 0;
		self.riffTitle = 0;
		return NO;
	}
}

- (instancetype)initWithRiffObject:(RiffObject*)ro
{
	if (self = [super init]) {
		self.riffObject = ro;
		if (_riffObject.hasSync) {
			NSURL *syncURL = [[_riffObject.URL URLByDeletingPathExtension] URLByAppendingPathExtension:@"sync"];
			if ([self fillOutBasedOnURL:syncURL]) {
				self.hasSync = YES;
			} else {
				self.hasSync = NO;
			}
		} else {
			self.hasSync = NO;
		}
	}
	
	return self;
}

@end
