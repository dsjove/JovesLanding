//
//  Data+Fog.swift
//  BTByJove
//
//  Created by David Giovannini on 7/29/17.
//  Copyright © 2017 Software by Jove. All rights reserved.
//

import Foundation

public extension Data {
	var fogHexDescription: String {
		"\n\(fogHexFormat(bytesPerRow: 16, indent: "\t"))"
	}
	
	func fogHexFormat(bytesPerRow: Int = Int.max, indent: String = "") -> String {
		if self.isEmpty {
			return "\(indent)-\n)"
		}
		var desc = reduce(("", 1)) { a, e in
			var iter = a
			let i = (iter.1-1) % bytesPerRow == 0 ? indent : ""
			let val = String(format: "%02x", e)
			let term = iter.1 % bytesPerRow == 0 ? "\n" : iter.1 % 2  == 0 ? " " :  "."
			iter.0 = iter.0 + "\(i)\(val)\(term)"
			iter.1 += 1
			return iter
		}
		desc.0.removeLast()
		return desc.0
    }
    
    mutating func fogAppend<T>(value: T) {
		withUnsafePointer(to: value) { (ptr: UnsafePointer<T>) in
			self.append(UnsafeBufferPointer(start: ptr, count: 1))
		}
	}

	func fogExtract<T>(_ cursor: inout Int) -> T {
		return self.withUnsafeBytes { (u8Ptr: UnsafePointer<UInt8>) in
			let pos = u8Ptr.advanced(by: cursor)
			return pos.withMemoryRebound(to: T.self, capacity: 1) { (c) -> T in
				cursor += MemoryLayout<T>.size
				return c.pointee
			}
		}
	}
}

