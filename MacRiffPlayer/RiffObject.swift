//
//  RiffObject.swift
//  MacRiffPlayer
//
//  Created by C.W. Betts on 3/24/15.
//  Copyright (c) 2015 C.W. Betts. All rights reserved.
//

import Foundation

class RiffObject: NSObject {
	let riffAudioURL: NSURL
	private(set) var riffSyncURL: NSURL?
	private(set) var hasSync: Bool
	private(set) var riffInfo: (delay: NSTimeInterval, start: NSTimeInterval, timeOffset: Double, title: UInt16) = (0,0,0,0)

	var riffDelay: NSTimeInterval {
		return riffInfo.delay
	}
	
	var riffStart: NSTimeInterval {
		return riffInfo.start
	}
	
	var timeOffset: Double {
		return riffInfo.timeOffset
	}
	
	var riffTitle: UInt16 {
		return riffInfo.title
	}
	
	init(fileURL: NSURL) {
		riffAudioURL = fileURL
		var aRiffSyncURL: NSURL = {
			return fileURL.URLByDeletingPathExtension!.URLByAppendingPathExtension("sync")
		}()
		
		riffSyncURL = aRiffSyncURL.checkResourceIsReachableAndReturnError(nil) ? aRiffSyncURL : nil
		
		if riffSyncURL == nil {
			hasSync = false
		} else {
			var theEncoding = NSUTF8StringEncoding
			if let syncString = String(contentsOfURL: riffSyncURL!, usedEncoding: &theEncoding, error: nil) {
				var isValid = 0
				let fileVals = syncString.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
				for aVar in fileVals {
					if let currentRange = aVar.rangeOfString("=") {
						var preRangeStr = aVar[aVar.startIndex..<currentRange.startIndex]
						var afterRangeStr = aVar[currentRange.endIndex..<aVar.endIndex]
						
						switch preRangeStr {
						case "riffdelay_init":
							let numScanner = NSScanner(string: afterRangeStr)
							var aDouble: Double = 0
							numScanner.scanDouble(&aDouble)
							riffInfo.delay = aDouble
							isValid++
							
						case "riffstart":
							let numScanner = NSScanner(string: afterRangeStr)
							var aDouble: Double = 0
							numScanner.scanDouble(&aDouble)
							riffInfo.start = aDouble
							isValid++

						case "time_offset":
							let numScanner = NSScanner(string: afterRangeStr)
							var aDouble: Double = 0
							numScanner.scanDouble(&aDouble)
							riffInfo.timeOffset = aDouble
							isValid++
							
						case "title_ID":
							riffInfo.title = UInt16(afterRangeStr.toInt() ?? 0)
							
						default:
							break
						}
					}
				}
				
				if riffInfo.title == 0 {
					riffInfo.title = 1
				}
				
				if isValid == 3 {
					hasSync = true
				} else {
					hasSync = false
				}
			} else {
				hasSync = false
			}
		}
		
		if !hasSync {
			riffInfo = (0,0,0,0)
		}
		
		super.init()
	}
}
