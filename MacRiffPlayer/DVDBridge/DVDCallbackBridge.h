//
//  DVDCallbackBridge.h
//  MacRiffPlayer
//
//  Created by C.W. Betts on 3/25/15.
//  Copyright (c) 2015 C.W. Betts. All rights reserved.
//

#ifndef MacRiffPlayer_DVDCallbackBridge_h
#define MacRiffPlayer_DVDCallbackBridge_h

#include <DVDPlayback/DVDPlayback.h>
#import <Foundation/Foundation.h>

typedef void (^DVDFatalErrCallBackBlock)(DVDErrorCode inError, void *inRefCon);
typedef void (^DVDEventCallBackBlock)(DVDEventCode inEventCode, DVDEventValue inEventValue1, DVDEventValue inEventValue2, void *inRefCon);


#endif
