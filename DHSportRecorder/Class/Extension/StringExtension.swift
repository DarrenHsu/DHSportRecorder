//
//  StringExtension.swift
//  DHYoutube
//
//  Created by Darren Hsu on 17/10/2017.
//  Copyright © 2017 D.H. All rights reserved.
//

import UIKit

extension String {
    func websiteLink() -> String {
        var str = self
        if str.hasPrefix("http://") {
            str = String(str[str.characters.index(str.startIndex, offsetBy: "http://".characters.count)..<str.endIndex])
        }
        
        if str.hasPrefix("www.") {
            str = String(str[str.characters.index(str.startIndex, offsetBy: "www.".characters.count)..<str.endIndex])
        }
        
        if let index = str.characters.index(of: "/") {
            str = str.substring(to: index)
        }
        
        return str
    }
    
    func trim() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespaces)
    }
    
    func indexOf(_ string: String) -> String.Index? {
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
