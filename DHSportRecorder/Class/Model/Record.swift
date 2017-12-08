//
//  Record.swift
//  DHSportRecorder
//
//  Created by Darren Hsu on 06/12/2017.
//  Copyright © 2017 D.H. All rights reserved.
//

import UIKit

class Record: ModelObject {
    var _id: String?
    var userId: String?
    var name: String?
    var distance: NSNumber?
    var startTime: Date?
    var endTime: Date?
    var avgSpeed: NSNumber?
    var maxSpeed: NSNumber?
    var locations: [coordinate]?
    var imglocations: [Int]?
    var modifyAt: Date?
}

class coordinate: NSObject {
    var longitude: NSNumber?
    var latitude: NSNumber?
}
