//
//  NotificationExtension.swift
//  DHSportRecorder
//
//  Created by Darren Hsu on 29/12/2017.
//  Copyright © 2017 D.H. All rights reserved.
//

import UIKit

extension Notification.Name  {
    static let needReloadRoute = Notification.Name("needReloadRoute")
    static let loadHistoryFinished = Notification.Name("loadHistoryFinished")
    static let loadRouteFinished = Notification.Name("loadRouteFinished")
    static let loadRecordFinished = Notification.Name("loadRecordFinished")
}
