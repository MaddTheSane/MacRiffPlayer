//
//  DVDCallbackBridge.m
//  MacRiffPlayer
//
//  Created by C.W. Betts on 3/25/15.
//  Copyright (c) 2015 C.W. Betts. All rights reserved.
//

#import "DVDCallbackBridge.h"

OSStatus DVDSetFatalCallBackBlock(DVDFatalErrCallBackBlock inCallbackBlock)
{

	
	return noErr;
}

/*
 extern	OSStatus	DVDSetFatalErrorCallBack(DVDFatalErrCallBackFunctionPtr inCallBackProc, void *inRefCon)		AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER;
 
 extern	OSStatus	DVDRegisterEventCallBack(DVDEventCallBackFunctionPtr inCallBackProc, DVDEventCode *inCode, UInt32 inCodeCount, void *inRefCon, DVDEventCallBackRef *outCallBackID)	AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER;
 extern	OSStatus	DVDUnregisterEventCallBack(DVDEventCallBackRef inCallBackID)								AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER;
 extern	Boolean		DVDIsRegisteredEventCallBack(DVDEventCallBackRef inCallBackID)								AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER;
*/
