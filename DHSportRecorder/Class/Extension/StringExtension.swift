//
//  StringExtension.swift
//  DHYoutube
//
//  Created by Darren Hsu on 17/10/2017.
//  Copyright © 2017 D.H. All rights reserved.
//

import UIKit

extension String {
    
    public static func getUUID() -> String {
        return UUID().uuidString
    }
    
    private static func sha256(_ data: Data) -> Data? {
        guard let res = NSMutableData(length: Int(CC_SHA256_DIGEST_LENGTH)) else { return nil }
        CC_SHA256((data as NSData).bytes, CC_LONG(data.count), res.mutableBytes.assumingMemoryBound(to: UInt8.self))
        return res as Data
    }
    
    public static func sha256(_ str: String) -> String? {
        guard let data = str.data(using: String.Encoding.utf8), let shaData = sha256(data) else {
            return nil
        }
        
        let rc = shaData.base64EncodedString(options: [])
        return rc
    }
}

extension String {
    
    public func transferToString(_ format1: String, format2: String) -> String {
        return Date.getDateFromString(self, format: format1).stringDate(format2)
    }
    
    public func trim() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespaces)
    }
    
    public func indexOf(_ string: String) -> String.Index? {
        return range(of: string, options: .literal, range: nil, locale: nil)?.lowerBound
    }
    
    public func urlEncode() -> String {
        let encodedURL = self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        return encodedURL!
    }
}

public func merge(one: [String: String]?, _ two: [String:String]?) -> [String: String]? {
    var dict: [String: String]?
    if let one = one {
        dict = one
        if let two = two {
            for (key, value) in two {
                dict![key] = value
            }
        }
    } else {
        dict = two
    }
    return dict
}

public func LString(_ string: String) -> String {
    return  NSLocalizedString(string, comment: "")
}
