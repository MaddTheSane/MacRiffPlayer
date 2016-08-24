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
		case title
		case root
		case subPicture
		case audio
		case angle
		case ptt
		case none
	}
	
	enum State: OSStatus {
		case unknown
		
		/// playing 1x or less (slow mo)
		case playing
		case playingStill
		/// pause and step frame
		case paused
		
		///the DVDEvent for stopping has a 2nd parameter to indicate that the stop was initiated by the DVD disc.
		///0: user, 1: disc initiated
		case stopped
		
		/// playing greater than 1x
		case scanning
		
		case idle
		
		/// playing less than 1x
		case playingSlow
	}
	
	///DVDErrorCode - Errors returned by the framework (`-70000` to `-70099`)
	enum ErrorCode: OSStatus {
		///No Error encountered
		case noErr = 0
		
		/// Catch all error
		case unknown = -70001
		
		/// There was an error initializing the playback framework
		case initializingLib = -70002
		
		/// The playback framework has not been initialized.
		case uninitializedLib = -70003
		
		/// action is not allowed during playback
		case notAllowedDiringPlayback = -70004
		
		///A grafport was not set.
		case unassignedGrafPort			= -70005
		
		/// Media is already being played.
		case alreadyPlaying				= -70006
		
		/// The application did not install a callback routine for fatal errors returned by the framework.
		case noFatalErrCallBack			= -70007
		
		///The framework has already been notified to sleep.
		case isAlreadySleeping			= -70008
		
		///DVDWakeUp was called when the framework was not asleep.
		case dontNeedWakeup				= -70009
		
		///Time code is outside the valid range for the current title.
		case timeOutOfRange				= -70010
		
		///The operation was not allowed by the media at this time.
		case userActionNoOp				= -70011
		
		///The DVD drive is not available.
		case missingDrive				= -70012
		
		///The current system configuration is not supported.
		case notSupportedConfiguration	= -70013
		
		///The operation is not supported. For example, trying to slow mo backwards.
		case notSupportedFunction		= -70014
		
		///The media was not valid for playback.
		case noValidMedia				= -70015
		
		///The invalid parameter was passed.
		case wrongParam					= -70016
		
		///A valid graphics device is not available.
		case missingGraphicsDevice		= -70017
		
		///A graphics device error was encountered.
		case graphicsDevice				= -70018
		
		///The framework is already open (probably by another process).
		case playbackOpen				= -70019
		
		///The region code was not valid.
		case invalidRegionCode			= -70020
		
		///The region manager was not properly installed or missing from the system.
		case rgnMgrInstall				= -70021
		
		///The disc region code and the drive region code do not match.
		case mismatchedRegionCode		= -70022
		
		///The drive does not have any region changes left.
		case noMoreRegionSets			= -70023
		
		///The drive region code was not initialized.
		case dRegionCodeUninitialized	= -70024
		
		///The user attempting to change the region code could not be authenticated.
		case authentification			= -70025
		
		///The video driver does not have enough video memory available to playback the media.
		case outOfVideoMemory			= -70026
		
		///An appropriate audio output device could not be found.
		case noAudioOutputDevice		= -70027
		
		///A system error was encountered.
		case system						= -70028
		
		///The user has made a selection not supported in the current menu.
		case navigation					= -70029
		
		///invalid bookmark version
		case invalidBookmarkVersion		= -70030
		
		///invalid bookmark size
		case invalidBookmarkSize		= -70031
		
		///invalid bookmark for media
		case invalidBookmarkForMedia	= -70032
		
		///no valid last play bookmark
		case noValidBookmarkForLastPlay	= -70033
		
		///invalid display authentication: e.g. HDCP failure, ...
		case displayAuthentification	= -70034
	}
	
	enum BoolOrError {
		case boolean(Bool)
		case error(ErrorCode)
	}
	
	///DVDAspectRatio - The current aspect ratio (could be different when on menus or in the body of the title).
	enum AspectRatio: Int16 {
		case uninitialized
		case ratio4x3
		case ratio4x3PanAndScan
		case ratio16x9
		case letterBox
	}
	
	///DVDUserNavigation - The direction the user is trying to navigate on the menu.
	enum UserNavigation: UInt32 {
		case moveUp = 1
		case moveDown
		case moveLeft
		case moveRight
		case enter
	}
	
	///DVDScan Direction -	Direction of play (backward or forward). Backward is currently not supported.
	enum ScanDirection: Int8 {
		case forward
		case backward
	};
	
	
	///DVDScanRate - The rate at which to scan (used with DVDScanDirection).
	enum ScanRate: Int16 {
		case oneEigth	= -8
		case oneFourth	= -4
		case oneHalf	= -2
		case rate1x		= 1
		case rate2x		= 2
		case rate4x		= 4
		case rate8x		= 8
		case rate16x	= 16
		case rate32x	= 32
	};

	/// DVDFormat - The format of the title.
	enum Format: Int16 {
		case uninitialized
		case ntsc
		case pal
		case ntsc_HDTV
		case pal_HDTV
	};
	
	///DVDAudioStreamFormat - The different possible audio stream formats.
	enum AudioFormat: Int16 {
		case unknown
		case ac3
		case mpeg1
		case mpeg2
		case pcm
		case dts
		case sdds
		case mlp
		case ddPlus
		case dtshd
	};

	///DVDUOPCode - The DVD UOP code(s)...
	struct UOPCode : OptionSet {
		typealias RawValue = UInt32
		fileprivate var value: RawValue = 0
		init(_ value: RawValue) { self.value = value }
		init(rawValue value: RawValue) { self.value = value }
		init(nilLiteral: ()) { self.value = 0 }
		var rawValue: RawValue { return self.value }
		
		static var None: UOPCode { return UOPCode(0) }
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
		case uninitialized	= 0xff
		case code1 			= 0xfe
		case code2 			= 0xfd
		case code3 			= 0xfb
		case code4 			= 0xf7
		case code5 			= 0xef
		case code6 			= 0xdf
		case code7 			= 0xbf
		case code8 			= 0x7f
	};
	
	
	/// DVDDomainCode - The DVD Domain code...
	enum DomainCode: UInt32 {
		///First Play Domain
		case fpDomain		= 0
		
		///Video Manager Menu Domain
		case vmgmDomain		= 1
		
		///Video Title Set Menu Domain
		case vtsmDomain		= 2
		
		///Title Domain
		case ttDomain		= 3
		
		///Stop State
		case stopDomain		= 4
		
		///Audio Manager Menu Domain (DVD-Audio only, not used)
		case amgmDomain		= 5
		
		///Title Group Domain (DVD-Audio only, not used)
		case ttgrDomain		= 6
	};

	
	/// DVDAudioMode - The supported audio output formats
	struct AudioMode : OptionSet {
		typealias RawValue = Int32
		fileprivate var value: RawValue = 0
		fileprivate init(_ value: RawValue) { self.value = value }
		init(rawValue value: RawValue) { self.value = value }
		init(nilLiteral: ()) { self.value = 0 }
		var rawValue: RawValue { return self.value }
		
		static var Uninitialized: AudioMode { return AudioMode(0) }
		static var ProLogic: AudioMode { return AudioMode(1 << 0) }
		static var SPDIF: AudioMode { return AudioMode(1 << 1) }
	}
	
	//-----------------------------------------------------
	// DVDEventCode - The different event a client can register for to get notified (return value: UInt32)
	//-----------------------------------------------------
	enum EventCode: UInt32 {
		/// Returned value1: Title
		case title				= 1
		
		/// Returned value1: Chapter
		case ptt				= 2
		
		/// Returned value1: UOP code mask (DVDUOPCode)
		case validUOP			= 3
		
		/// Returned value1: StreamID
		case angle				= 4
		
		/// Returned value1: StreamID
		case audioStream		= 5
		
		/// Returned value1: streamID  / (value2 != 0): visible
		case subpictureStream	= 6
		
		/// Returned value1: DVDAspectRatio
		case displayMode		= 7
		
		/// Returned value1: DVDDomainCode
		case domain				= 8
		
		/// Returned value1: Bits / sec
		case bitrate			= 9
		
		/// Returned value1: On (1) - Off (0)
		case still				= 10
		
		/// Returned value1: DVDState
		case playback			= 11
		
		/// Returned value1: DVDFormat
		case videoStandard		= 12
		
		/// Returned value1: None (trigger for general stream change)
		case streams			= 13
		
		/// Returned value1: Speed (1x2x3x...)
		case scanSpeed			= 14
		
		/// Returned value1: DVDMenu
		case menuCalled			= 15
		
		/// Returned value1: parental level number
		case parental			= 16
		
		/// Returned value1: PGC number
		case pgc				= 17
		
		/// Returned value1: GPRM index / value2: data
		case gprm				= 18
		
		/// Returned value1: disc region
		case regionMismatch		= 19
		
		/// Returned value1: elapsed time / value2: duration of title [ms]
		case titleTime			= 20
		
		/// Returned value1: number of subpicture streams in title
		case subpictureStreamNumbers = 21
		
		/// Returned value1: number of audio streams in title
		case audioStreamNumbers = 22
		
		/// Returned value1: number of angles in title
		case angleNumbers 		= 23
		
		/// Returned value1: DVDErrorCode
		case error		 		= 24
		
		/// Returned value1: cc event opcode value2: cc event data
		case ccInfo				= 25
		
		/// Returned value1: elapsed time / value2: duration of current chapter [ms]
		case chapterTime		= 26
	}
	
	/// DVDTimeCode -	Used in conjunction with the DVDTimePosition to find an exact temporal location within the current title/chapter.
	enum TimeCode: Int16 {
		case uninitialized
		case elapsedSeconds
		case remainingSeconds
		
		/// only useable for GetTime
		case titleDurationSeconds
		
		/// only useable for GetTime
		case chapterElapsedSeconds
		
		/// only useable for GetTime
		case chapterRemainingSeconds
		
		/// only useable for GetTime
		case chapterDurationSeconds
	}
	
	//typedef void	(*DVDFatalErrCallBackFunctionPtr)(DVDErrorCode inError, void *inRefCon);
	typealias FatalErrCallback = (ErrorCode) -> Void

	//typedef void	(*DVDEventCallBackFunctionPtr)(DVDEventCode inEventCode, DVDEventValue inEventValue1, DVDEventValue inEventValue2, void *inRefCon);
	typealias EventCallback = (EventCode, DVDEventValue, DVDEventValue) -> Void
	
	fileprivate(set) var lastError = ErrorCode.noErr
	init?(error: inout ErrorCode) {
		if let anErr = ErrorCode(rawValue: DVDInitialize()) {
			if anErr == .noErr {
				error = .noErr
				return
			} else {
				error = anErr
				return nil
			}
		} else {
			error = .unknown
			return nil
		}
	}
	
	deinit {
		DVDDispose()
	}
	
	func validMedia(URL inRef: URL) -> BoolOrError {
		var isValid: DarwinBoolean = false
		let iErr = DVDIsValidMediaURL(inRef as CFURL, &isValid)
		
		if iErr == noErr {
			return .boolean(isValid.boolValue)
		} else {
			lastError = ErrorCode(rawValue: iErr) ?? .unknown
			return .error(ErrorCode(rawValue: iErr) ?? .unknown)
		}
	}
	
	func hasMedia() -> BoolOrError {
		var isValid: DarwinBoolean = false
		let iErr = DVDHasMedia(&isValid)
		
		if iErr == noErr {
			return .boolean(isValid.boolValue)
		} else {
			lastError = ErrorCode(rawValue: iErr) ?? .unknown
			return .error(ErrorCode(rawValue: iErr) ?? .unknown)
		}
	}
	
	func openMediaFile(URL inFile: URL) -> ErrorCode {
		let iErr = DVDOpenMediaFileWithURL(inFile as CFURL)
		lastError = ErrorCode(rawValue: iErr) ?? .unknown
		return ErrorCode(rawValue: iErr) ?? .unknown
	}
	
	func closeMediaFile() -> ErrorCode {
		let iErr = ErrorCode(rawValue: DVDCloseMediaFile()) ?? .unknown
		lastError = iErr
		return iErr
	}
	
	func openMediaVolume(URL inVolume: URL) -> ErrorCode {
		let iErr = DVDOpenMediaVolumeWithURL(inVolume as CFURL)
		
		lastError = ErrorCode(rawValue: iErr) ?? .unknown
		return ErrorCode(rawValue: iErr) ?? .unknown
	}
	
	func closeMediaVolume() -> ErrorCode {
		let iErr = ErrorCode(rawValue: DVDCloseMediaVolume()) ?? .unknown
		lastError = iErr
		return iErr
	}
	
	var videoDisplay: CGDirectDisplayID {
		get {
			var tmp: CGDirectDisplayID = 0
			
			lastError = ErrorCode(rawValue: DVDGetVideoDisplay(&tmp)) ?? .unknown
			return tmp
		}
		set {
			lastError = ErrorCode(rawValue: DVDSetVideoDisplay(newValue)) ?? .unknown
		}
	}
	
	func isDisplaySupported(_ inDisplay: CGDirectDisplayID) -> BoolOrError {
		var outSupported: DarwinBoolean = false
		let iErr = DVDIsSupportedDisplay(inDisplay, &outSupported)
		
		if iErr == noErr {
			return .boolean(outSupported.boolValue)
		} else {
			lastError = ErrorCode(rawValue: iErr) ?? .unknown
			return .error(ErrorCode(rawValue: iErr) ?? .unknown)
		}
	}
	
	func switchToDisplay(_ inDisplay: CGDirectDisplayID) -> BoolOrError {
		var outSupported: DarwinBoolean = false
		let iErr = DVDSwitchToDisplay(inDisplay, &outSupported)
		
		if iErr == noErr {
			return .boolean(outSupported.boolValue)
		} else {
			lastError = ErrorCode(rawValue: iErr) ?? .unknown
			return .error(ErrorCode(rawValue: iErr) ?? .unknown)
		}
	}
	
	var videoWindowID: UInt32 {
		get {
			var tmp: UInt32 = 0
			lastError = ErrorCode(rawValue: DVDGetVideoWindowID(&tmp)) ?? .unknown
			return tmp
		}
		set {
			lastError = ErrorCode(rawValue: DVDSetVideoWindowID(newValue)) ?? .unknown
		}
	}
	
	var nativeVideoSize: (width: UInt16, height: UInt16) {
		var tmpWidth: UInt16 = 0
		var tmpHeight: UInt16 = 0
		
		let iErr = DVDGetNativeVideoSize(&tmpWidth, &tmpHeight)
		lastError = ErrorCode(rawValue: iErr) ?? .unknown
		
		return (tmpWidth, tmpHeight)
	}
	
	var aspectRatio: AspectRatio {
		get {
			var tmpRat: DVDAspectRatio = .ratioUninitialized
			let iErr = DVDGetAspectRatio(&tmpRat)
			lastError = ErrorCode(rawValue: iErr) ?? .unknown
			
			return AspectRatio(rawValue: tmpRat.rawValue) ?? .uninitialized
		}
		set {
			let iErr = DVDSetAspectRatio(DVDAspectRatio(rawValue: newValue.rawValue)!)
			lastError = ErrorCode(rawValue: iErr) ?? .unknown
		}
	}
	
	var formatStandard: Format? {
		var aForm: DVDFormat = .uninitialized
		let iErr = DVDGetFormatStandard(&aForm)
		lastError = ErrorCode(rawValue: iErr) ?? .unknown
		
		return Format(rawValue: aForm.rawValue)
	}
	
	var videoBounds: CGRect {
		get {
			var toRet = CGRect()
			let iErr = DVDGetVideoCGBounds(&toRet)
			lastError = ErrorCode(rawValue: iErr) ?? .unknown
			
			return toRet
		}
		set {
			var toSet = newValue
			let iErr = DVDSetVideoCGBounds(&toSet)
			lastError = ErrorCode(rawValue: iErr) ?? .unknown
		}
	}
	
	var videoWindowRef: WindowRef {
		get {
			var inWinRef: WindowRef? = nil
			let iErr = DVDGetVideoWindowRef(&inWinRef!)
			lastError = ErrorCode(rawValue: iErr) ?? .unknown
			
			return inWinRef!
		}
		set {
			let iErr = DVDSetVideoWindowRef(newValue)
			lastError = ErrorCode(rawValue: iErr) ?? .unknown
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

