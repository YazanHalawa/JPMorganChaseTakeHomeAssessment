//
//  Logging.swift
//  JPMorganChase Take-Home Assessment
//
//  Created by Yazan Halawa on 9/17/22.
//

import OSLog
import Foundation

extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!

    /// Logs the view cycles like viewDidLoad.
    static let viewCycle = Logger(subsystem: subsystem, category: "viewcycle")
    static let networking = Logger(subsystem: subsystem, category: "networking")
    static let businessLogic = Logger(subsystem: subsystem, category: "businessLogic")
}
