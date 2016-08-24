//
//  RiffObject.swift
//  MacRiffPlayer
//
//  Created by C.W. Betts on 3/24/15.
//  Copyright (c) 2015 C.W. Betts. All rights reserved.
//

import Foundation

class RiffObject: NSObject {
	let riffAudioURL: URL
	fileprivate(set) var riffSyncURL: URL?
	fileprivate(set) var hasSync: Bool
	fileprivate(set) var riffInfo: (delay: TimeInterval, start: TimeInterval, timeOffset: Double, title: UInt16) = (0,0,0,0)

	var riffDelay: TimeInterval {
		return riffInfo.delay
	}
	
	var riffStart: TimeInterval {
		return riffInfo.start
	}
	
	var timeOffset: Double {
		return riffInfo.timeOffset
	}
	
	var riffTitle: UInt16 {
		return riffInfo.title
	}
	
	init(fileURL: URL) {
		riffAudioURL = fileURL
		let aRiffSyncURL: URL = {
			return fileURL.deletingPathExtension().appendingPathExtension("sync")
		}()
		
			do {
				let isReached = try aRiffSyncURL.checkResourceIsReachable()
				if isReached {
					riffSyncURL = aRiffSyncURL
				} else {
					riffSyncURL = nil
				}
			} catch {
				riffSyncURL = nil
		}
		
		if riffSyncURL == nil {
			hasSync = false
		} else {
			var theEncoding = String.Encoding.utf8
			if let syncString = try? String(contentsOf: riffSyncURL!, usedEncoding: &theEncoding) {
				var isValid = 0
				let fileVals = syncString.components(separatedBy: CharacterSet.newlines)
				for aVar in fileVals {
					if let currentRange = aVar.range(of: "=") {
						let preRangeStr = aVar[aVar.startIndex..<currentRange.lowerBound]
						let afterRangeStr = aVar[currentRange.upperBound..<aVar.endIndex]
						
						switch preRangeStr {
						case "riffdelay_init":
							let numScanner = Scanner(string: afterRangeStr)
							var aDouble: Double = 0
							numScanner.scanDouble(&aDouble)
							riffInfo.delay = aDouble
							isValid += 1
							
						case "riffstart":
							let numScanner = Scanner(string: afterRangeStr)
							var aDouble: Double = 0
							numScanner.scanDouble(&aDouble)
							riffInfo.start = aDouble
							isValid += 1

						case "time_offset":
							let numScanner = Scanner(string: afterRangeStr)
							var aDouble: Double = 0
							numScanner.scanDouble(&aDouble)
							riffInfo.timeOffset = aDouble
							isValid += 1
							
						case "title_ID":
							riffInfo.title = UInt16(Int(afterRangeStr) ?? 0)
							
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
