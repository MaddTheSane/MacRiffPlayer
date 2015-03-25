//
//  DVDSwiftBridge.swift
//  MacRiffPlayer
//
//  Created by C.W. Betts on 3/25/15.
//  Copyright (c) 2015 C.W. Betts. All rights reserved.
//

import Foundation
import ApplicationServices
import Security.Authorization

class DVD {
	enum Menu: UInt32 {
		case Title
		case Root
		case SubPicture
		case Audio
		case Angle
		case PTT
		case None
	}
	
	enum State: OSStatus {
		case Unknown
		
		/// playing 1x or less (slow mo)
		case Playing
		case PlayingStill
		/// pause and step frame
		case Paused
		
		///the DVDEvent for stopping has a 2nd parameter to indicate that the stop was initiated by the DVD disc.
		///0: user, 1: disc initiated
		case Stopped
		
		/// playing greater than 1x
		case Scanning
		
		case Idle
		
		/// playing less than 1x
		case PlayingSlow
	}
	
	///DVDErrorCode - Errors returned by the framework (`-70000` to `-70099`)
	enum ErrorCode: OSStatus {
		///No Error encountered
		case NoErr = 0
		
		/// Catch all error
		case Unknown = -70001
		
		/// There was an error initializing the playback framework
		case InitializingLib = -70002
		
		/// The playback framework has not been initialized.
		case UninitializedLib = -70003
		
		/// action is not allowed during playback
		case NotAllowedDiringPlayback = -70004
		
		///A grafport was not set.
		case UnassignedGrafPort			= -70005
		
		/// Media is already being played.
		case AlreadyPlaying				= -70006
		
		/// The application did not install a callback routine for fatal errors returned by the framework.
		case NoFatalErrCallBack			= -70007
		
		///The framework has already been notified to sleep.
		case IsAlreadySleeping			= -70008
		
		///DVDWakeUp was called when the framework was not asleep.
		case DontNeedWakeup				= -70009
		
		///Time code is outside the valid range for the current title.
		case TimeOutOfRange				= -70010
		
		///The operation was not allowed by the media at this time.
		case UserActionNoOp				= -70011
		
		///The DVD drive is not available.
		case MissingDrive				= -70012
		
		///The current system configuration is not supported.
		case NotSupportedConfiguration	= -70013
		
		///The operation is not supported. For example, trying to slow mo backwards.
		case NotSupportedFunction		= -70014
		
		///The media was not valid for playback.
		case NoValidMedia				= -70015
		
		///The invalid parameter was passed.
		case WrongParam					= -70016
		
		///A valid graphics device is not available.
		case MissingGraphicsDevice		= -70017
		
		///A graphics device error was encountered.
		case GraphicsDevice				= -70018
		
		///The framework is already open (probably by another process).
		case PlaybackOpen				= -70019
		
		///The region code was not valid.
		case InvalidRegionCode			= -70020
		
		///The region manager was not properly installed or missing from the system.
		case RgnMgrInstall				= -70021
		
		///The disc region code and the drive region code do not match.
		case MismatchedRegionCode		= -70022
		
		///The drive does not have any region changes left.
		case NoMoreRegionSets			= -70023
		
		///The drive region code was not initialized.
		case dRegionCodeUninitialized	= -70024
		
		///The user attempting to change the region code could not be authenticated.
		case Authentification			= -70025
		
		///The video driver does not have enough video memory available to playback the media.
		case OutOfVideoMemory			= -70026
		
		///An appropriate audio output device could not be found.
		case NoAudioOutputDevice		= -70027
		
		///A system error was encountered.
		case System						= -70028
		
		///The user has made a selection not supported in the current menu.
		case Navigation					= -70029
		
		///invalid bookmark version
		case InvalidBookmarkVersion		= -70030
		
		///invalid bookmark size
		case InvalidBookmarkSize		= -70031
		
		///invalid bookmark for media
		case InvalidBookmarkForMedia	= -70032
		
		///no valid last play bookmark
		case NoValidBookmarkForLastPlay	= -70033
		
		///invalid display authentication: e.g. HDCP failure, ...
		case DisplayAuthentification	= -70034
	}
	
	enum BoolOrError {
		case Boolean(Bool)
		case Error(ErrorCode)
	}
	
	///DVDAspectRatio - The current aspect ratio (could be different when on menus or in the body of the title).
	enum AspectRatio: Int16 {
		case Uninitialized
		case Ratio4x3
		case Ratio4x3PanAndScan
		case Ratio16x9
		case LetterBox
	}
	
	///DVDUserNavigation - The direction the user is trying to navigate on the menu.
	enum UserNavigation: UInt32 {
		case MoveUp = 1
		case MoveDown
		case MoveLeft
		case MoveRight
		case Enter
	}
	
	///DVDScan Direction -	Direction of play (backward or forward). Backward is currently not supported.
	enum ScanDirection: Int8 {
		case Forward
		case Backward
	};
	
	
	///DVDScanRate - The rate at which to scan (used with DVDScanDirection).
	enum ScanRate: Int16 {
		case OneEigth	= -8
		case OneFourth	= -4
		case OneHalf	= -2
		case Rate1x		= 1
		case Rate2x		= 2
		case Rate4x		= 4
		case Rate8x		= 8
		case Rate16x	= 16
		case Rate32x	= 32
	};

	/// DVDFormat - The format of the title.
	enum Format: Int16 {
		case Uninitialized
		case NTSC
		case PAL
		case NTSC_HDTV
		case PAL_HDTV
	};
	
	///DVDAudioStreamFormat - The different possible audio stream formats.
	enum AudioFormat: Int16 {
		case Unknown
		case AC3
		case MPEG1
		case MPEG2
		case PCM
		case DTS
		case SDDS
		case MLP
		case DDPlus
		case DTSHD
	};

	///DVDUOPCode - The DVD UOP code(s)...
	struct UOPCode : RawOptionSetType {
		typealias RawValue = UInt32
		private var value: RawValue = 0
		init(_ value: RawValue) { self.value = value }
		init(rawValue value: RawValue) { self.value = value }
		init(nilLiteral: ()) { self.value = 0 }
		static var allZeros: UOPCode { return self(0) }
		static func fromMask(raw: RawValue) -> UOPCode { return self(raw) }
		var rawValue: RawValue { return self.value }
		
		static var None: UOPCode { return self(0) }
		static var TimePlaySearch: UOPCode { return UOPCode(1 << 0) }
		static var PTTPlaySearch: UOPCode { return UOPCode(1 << 1) }
		static var TitlePlay: UOPCode { return UOPCode(1 << 2) }
		static var Stop: UOPCode { return UOPCode(1 << 3) }
		static var GoUp: UOPCode { return UOPCode(1 << 4) }
		static var TimePTTSearch: UOPCode { return UOPCode(1 << 5) }
		static var PrevTopPGSearch: UOPCode { return UOPCode(1 << 6) }
		static var NextPGSearch: UOPCode { return UOPCode(1 << 7) }
		static var ForwardScan: UOPCode { return UOPCode(1 << 8) }
		static var BackgroundScan: UOPCode { return UOPCode(1 << 9) }
		static var MenuCallTitle: UOPCode { return UOPCode(1 << 10) }
		static var MenuCallRoot: UOPCode { return UOPCode(1 << 11) }
		static var MenuCallSubPicture: UOPCode { return UOPCode(1 << 12) }
		static var MenuCallAudio: UOPCode { return UOPCode(1 << 13) }
		static var MenuCallAngle: UOPCode { return UOPCode(1 << 14) }
		static var MenuCallPTT: UOPCode { return UOPCode(1 << 15) }
		static var Resume: UOPCode { return UOPCode(1 << 16) }
		static var Button: UOPCode { return UOPCode(1 << 17) }
		static var StillOff: UOPCode { return UOPCode(1 << 18) }
		static var PauseOn: UOPCode { return UOPCode(1 << 19) }
		static var AudioStreamChange: UOPCode { return UOPCode(1 << 20) }
		static var SubPictureStreamChange: UOPCode { return UOPCode(1 << 21) }
		static var AngleChange: UOPCode { return UOPCode(1 << 22) }
		static var KaraokeModeChange: UOPCode { return UOPCode(1 << 23) }
		static var VideoModeChange: UOPCode { return UOPCode(1 << 24) }
		static var ScanOff: UOPCode { return UOPCode(1 << 25) }
		static var PauseOff: UOPCode { return UOPCode(1 << 26) }
	}
	
	/// DVDRegionCode - The different possible region codes (used for both the disc and the drive).
	enum RegionCode: UInt32 {
		case Uninitialized	= 0xff
		case Code1 			= 0xfe
		case Code2 			= 0xfd
		case Code3 			= 0xfb
		case Code4 			= 0xf7
		case Code5 			= 0xef
		case Code6 			= 0xdf
		case Code7 			= 0xbf
		case Code8 			= 0x7f
	};
	
	
	/// DVDDomainCode - The DVD Domain code...
	enum DomainCode: UInt32 {
		///First Play Domain
		case FPDomain		= 0
		
		///Video Manager Menu Domain
		case VMGMDomain		= 1
		
		///Video Title Set Menu Domain
		case VTSMDomain		= 2
		
		///Title Domain
		case TTDomain		= 3
		
		///Stop State
		case STOPDomain		= 4
		
		///Audio Manager Menu Domain (DVD-Audio only, not used)
		case AMGMDomain		= 5
		
		///Title Group Domain (DVD-Audio only, not used)
		case TTGRDomain		= 6
	};

	
	/// DVDAudioMode - The supported audio output formats
	struct AudioMode : RawOptionSetType {
		typealias RawValue = Int32
		private var value: RawValue = 0
		init(_ value: RawValue) { self.value = value }
		init(rawValue value: RawValue) { self.value = value }
		init(nilLiteral: ()) { self.value = 0 }
		static var allZeros: AudioMode { return self(0) }
		static func fromMask(raw: RawValue) -> AudioMode { return self(raw) }
		var rawValue: RawValue { return self.value }
		
		static var Uninitialized: AudioMode { return self(0) }
		static var ProLogic: AudioMode { return AudioMode(1 << 0) }
		static var SPDIF: AudioMode { return AudioMode(1 << 1) }
	}
	
	//-----------------------------------------------------
	// DVDEventCode - The different event a client can register for to get notified (return value: UInt32)
	//-----------------------------------------------------
	enum EventCode: UInt32 {
		/// Returned value1: Title
		case Title				= 1
		
		/// Returned value1: Chapter
		case PTT				= 2
		
		/// Returned value1: UOP code mask (DVDUOPCode)
		case ValidUOP			= 3
		
		/// Returned value1: StreamID
		case Angle				= 4
		
		/// Returned value1: StreamID
		case AudioStream		= 5
		
		/// Returned value1: streamID  / (value2 != 0): visible
		case SubpictureStream	= 6
		
		/// Returned value1: DVDAspectRatio
		case DisplayMode		= 7
		
		/// Returned value1: DVDDomainCode
		case Domain				= 8
		
		/// Returned value1: Bits / sec
		case Bitrate			= 9
		
		/// Returned value1: On (1) - Off (0)
		case Still				= 10
		
		/// Returned value1: DVDState
		case Playback			= 11
		
		/// Returned value1: DVDFormat
		case VideoStandard		= 12
		
		/// Returned value1: None (trigger for general stream change)
		case Streams			= 13
		
		/// Returned value1: Speed (1x2x3x...)
		case ScanSpeed			= 14
		
		/// Returned value1: DVDMenu
		case MenuCalled			= 15
		
		/// Returned value1: parental level number
		case Parental			= 16
		
		/// Returned value1: PGC number
		case PGC				= 17
		
		/// Returned value1: GPRM index / value2: data
		case GPRM				= 18
		
		/// Returned value1: disc region
		case RegionMismatch		= 19
		
		/// Returned value1: elapsed time / value2: duration of title [ms]
		case TitleTime			= 20
		
		/// Returned value1: number of subpicture streams in title
		case SubpictureStreamNumbers = 21
		
		/// Returned value1: number of audio streams in title
		case AudioStreamNumbers = 22
		
		/// Returned value1: number of angles in title
		case AngleNumbers 		= 23
		
		/// Returned value1: DVDErrorCode
		case Error		 		= 24
		
		/// Returned value1: cc event opcode value2: cc event data
		case CCInfo				= 25
		
		/// Returned value1: elapsed time / value2: duration of current chapter [ms]
		case ChapterTime		= 26
	}
	
	/// DVDTimeCode -	Used in conjunction with the DVDTimePosition to find an exact temporal location within the current title/chapter.
	enum TimeCode: Int16 {
		case Uninitialized
		case ElapsedSeconds
		case RemainingSeconds
		
		/// only useable for GetTime
		case TitleDurationSeconds
		
		/// only useable for GetTime
		case ChapterElapsedSeconds
		
		/// only useable for GetTime
		case ChapterRemainingSeconds
		
		/// only useable for GetTime
		case ChapterDurationSeconds
	}
	
	//typedef void	(*DVDFatalErrCallBackFunctionPtr)(DVDErrorCode inError, void *inRefCon);
	typealias FatalErrCallback = (ErrorCode) -> Void

	//typedef void	(*DVDEventCallBackFunctionPtr)(DVDEventCode inEventCode, DVDEventValue inEventValue1, DVDEventValue inEventValue2, void *inRefCon);
	typealias EventCallback = (EventCode, DVDEventValue, DVDEventValue) -> Void
	
	private(set) var lastError = ErrorCode.NoErr
	init?(inout error: ErrorCode) {
		if let anErr = ErrorCode(rawValue: DVDInitialize()) {
			if anErr == .NoErr {
				error = .NoErr
				return
			} else {
				error = anErr
				return nil
			}
		} else {
			error = .Unknown
			return nil
		}
	}
	
	deinit {
		DVDDispose()
	}
	
	func validMedia(URL inRef: NSURL) -> BoolOrError {
		var isValid: Boolean = 0
		let iErr = DVDIsValidMediaURL(inRef, &isValid)
		
		if iErr == noErr {
			return .Boolean(isValid != 0)
		} else {
			lastError = ErrorCode(rawValue: iErr) ?? .Unknown
			return .Error(ErrorCode(rawValue: iErr) ?? .Unknown)
		}
	}
	
	func hasMedia() -> BoolOrError {
		var isValid: Boolean = 0
		let iErr = DVDHasMedia(&isValid)
		
		if iErr == noErr {
			return .Boolean(isValid != 0)
		} else {
			lastError = ErrorCode(rawValue: iErr) ?? .Unknown
			return .Error(ErrorCode(rawValue: iErr) ?? .Unknown)
		}
	}
	
	func openMediaFile(URL inFile: NSURL) -> ErrorCode {
		let iErr = DVDOpenMediaFileWithURL(inFile)
		lastError = ErrorCode(rawValue: iErr) ?? .Unknown
		return ErrorCode(rawValue: iErr) ?? .Unknown
	}
	
	func closeMediaFile() -> ErrorCode {
		let iErr = ErrorCode(rawValue: DVDCloseMediaFile()) ?? .Unknown
		lastError = iErr
		return iErr
	}
	
	func openMediaVolume(URL inVolume: NSURL) -> ErrorCode {
		let iErr = DVDOpenMediaVolumeWithURL(inVolume)
		
		lastError = ErrorCode(rawValue: iErr) ?? .Unknown
		return ErrorCode(rawValue: iErr) ?? .Unknown
	}
	
	func closeMediaVolume() -> ErrorCode {
		let iErr = ErrorCode(rawValue: DVDCloseMediaVolume()) ?? .Unknown
		lastError = iErr
		return iErr
	}
	
	var videoDisplay: CGDirectDisplayID {
		get {
			var tmp: CGDirectDisplayID = 0
			
			lastError = ErrorCode(rawValue: DVDGetVideoDisplay(&tmp)) ?? .Unknown
			return tmp
		}
		set {
			lastError = ErrorCode(rawValue: DVDSetVideoDisplay(newValue)) ?? .Unknown
		}
	}
	
	func isDisplaySupported(inDisplay: CGDirectDisplayID) -> BoolOrError {
		var outSupported: Boolean = 0
		let iErr = DVDIsSupportedDisplay(inDisplay, &outSupported)
		
		if iErr == noErr {
			return .Boolean(outSupported != 0)
		} else {
			lastError = ErrorCode(rawValue: iErr) ?? .Unknown
			return .Error(ErrorCode(rawValue: iErr) ?? .Unknown)
		}
	}
	
	func switchToDisplay(inDisplay: CGDirectDisplayID) -> BoolOrError {
		var outSupported: Boolean = 0
		let iErr = DVDSwitchToDisplay(inDisplay, &outSupported)
		
		if iErr == noErr {
			return .Boolean(outSupported != 0)
		} else {
			lastError = ErrorCode(rawValue: iErr) ?? .Unknown
			return .Error(ErrorCode(rawValue: iErr) ?? .Unknown)
		}
	}
	
	var videoWindowID: UInt32 {
		get {
			var tmp: UInt32 = 0
			lastError = ErrorCode(rawValue: DVDGetVideoWindowID(&tmp)) ?? .Unknown
			return tmp
		}
		set {
			lastError = ErrorCode(rawValue: DVDSetVideoWindowID(newValue)) ?? .Unknown
		}
	}
	
	var nativeVideoSize: (width: UInt16, height: UInt16) {
		var tmpWidth: UInt16 = 0
		var tmpHeight: UInt16 = 0
		
		let iErr = DVDGetNativeVideoSize(&tmpWidth, &tmpHeight)
		lastError = ErrorCode(rawValue: iErr) ?? .Unknown
		
		return (tmpWidth, tmpHeight)
	}
	
	var aspectRatio: AspectRatio {
		get {
			var tmpRat: DVDAspectRatio = 0
			let iErr = DVDGetAspectRatio(&tmpRat)
			lastError = ErrorCode(rawValue: iErr) ?? .Unknown
			
			return AspectRatio(rawValue: tmpRat) ?? .Uninitialized
		}
		set {
			let iErr = DVDSetAspectRatio(newValue.rawValue)
			lastError = ErrorCode(rawValue: iErr) ?? .Unknown
		}
	}
	
	var formatStandard: Format? {
		var aForm: DVDFormat = 0
		let iErr = DVDGetFormatStandard(&aForm)
		lastError = ErrorCode(rawValue: iErr) ?? .Unknown
		
		return Format(rawValue: aForm)
	}
	
	var videoBounds: CGRect {
		get {
			var toRet = CGRect()
			let iErr = DVDGetVideoCGBounds(&toRet)
			lastError = ErrorCode(rawValue: iErr) ?? .Unknown
			
			return toRet
		}
		set {
			var toSet = newValue
			let iErr = DVDSetVideoCGBounds(&toSet)
			lastError = ErrorCode(rawValue: iErr) ?? .Unknown
		}
	}
	
	var videoWindowRef: WindowRef {
		get {
			var inWinRef: WindowRef = nil
			let iErr = DVDGetVideoWindowRef(&inWinRef)
			lastError = ErrorCode(rawValue: iErr) ?? .Unknown
			
			return inWinRef
		}
		set {
			let iErr = DVDSetVideoWindowRef(newValue)
			lastError = ErrorCode(rawValue: iErr) ?? .Unknown
		}
	}
	/*
	
	extern	OSStatus	DVDGetAudioStreamFormat(DVDAudioFormat *outFormat, UInt32 *outBitsPerSample, UInt32 *outSamplesPerSecond, UInt32 *outChannels)								AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER;
	extern	OSStatus	DVDGetAudioStreamFormatByStream(UInt32 inStreamNum, DVDAudioFormat *outFormat, UInt32 *outBitsPerSample, UInt32 *outSamplesPerSecond, UInt32 *outChannels)	AVAILABLE_MAC_OS_X_VERSION_10_4_AND_LATER;
	
	extern	OSStatus	DVDGetAudioOutputModeCapabilities(DVDAudioMode *outModes)									AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER;
	extern	OSStatus	DVDSetAudioOutputMode(DVDAudioMode inMode)													AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER;
	extern	OSStatus	DVDGetAudioOutputMode(DVDAudioMode *outMode)												AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER;
	extern	OSStatus	DVDGetSPDIFDataOutDeviceCount(UInt32 *outCount)												AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER;
	extern	OSStatus	DVDGetSPDIFDataOutDeviceCFName(UInt32 inIndex, CFStringRef *outName)						AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER;
	extern	OSStatus	DVDSetSPDIFDataOutDevice(UInt32 inIndex)													AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER;
	extern	OSStatus	DVDGetSPDIFDataOutDevice(UInt32 *outIndex)													AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER;

*/
}

