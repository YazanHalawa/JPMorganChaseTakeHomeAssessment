//
//  ReachabilityMonitor.swift
//  JPMorganChase Take-Home Assessment
//
//  Created by Yazan Halawa on 9/17/22.
//

import Foundation
import Network

/// This class monitors for network reachability and has an isReachable property to let us know whether we are connected to wifi/cellular. You can also check whether we are reachable specifically on cellular
/// This class should be set-up in the App Delegate `didFinishLaunching()` method to start monitoring immediately on app launch
class NetworkMonitor {
    static let shared = NetworkMonitor()

    let monitor = NWPathMonitor()
    private var status: NWPath.Status = .requiresConnection
    var isReachable: Bool { status == .satisfied }
    var isReachableOnCellular: Bool = true
    
    private init() {}

    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.status = path.status
            self?.isReachableOnCellular = path.isExpensive

            if path.status == .satisfied {
                print("We're connected!")
                // post connected notification
            } else {
                print("No connection.")
                // post disconnected notification
            }
            print(path.isExpensive)
        }

        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }

    func stopMonitoring() {
        monitor.cancel()
    }
}
