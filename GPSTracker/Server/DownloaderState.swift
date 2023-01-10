//
//  DownloaderState.swift
//  GPSTracker
//
//  Created by Guntis on 04/01/2023.
//  Copyright © 2023 . All rights reserved.
//

import UIKit

enum DownloaderState: Int, Codable {
	case downloading  	// Not started, or in progress, just as long as it’s allowed
	case downloaded		// Downloaded (Server responded) (If data or if no data), but was a success.
	case timeout  		// Timeout (app internet or server problem. (maybe need retrying? ))
	case serverError	// Server error (not timeout, but some error, maybe server is down or .. )
	case parsingError	// Parsing error locally.
}

enum DownloaderLastResult: Int, Codable {
	case none			// First time
	case success
	case timeout
	case serverError
	case parsingError
}
