//
//  NSDataToSha256String.swift
//  GPS Tracker
//
//  Created by Guntis on 09/02/2020.
//  Copyright © 2020 . All rights reserved.
//

import UIKit
import CommonCrypto

class NSDataToSha256String: NSObject {

	class func sha256(data: Data) -> String {

		var digest = [UInt8](repeating: 0, count:Int(CC_SHA256_DIGEST_LENGTH))

		_ = data.withUnsafeBytes {
			CC_SHA256($0.baseAddress, UInt32(data.count), &digest)
		}

		var sha256String = ""
		/// Unpack each byte in the digest array and add them to the sha256String
		for byte in digest {
			sha256String += String(format:"%02x", UInt8(byte))
		}

		return sha256String
	}
	
}
