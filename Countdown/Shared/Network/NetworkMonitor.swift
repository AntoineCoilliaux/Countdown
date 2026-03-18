//
//  NetworkMonitor.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 18/03/2026.
//

import Combine
import Network

class NetworkMonitor: ObservableObject {
    @Published var isConnected: Bool = true
    private let monitor = NWPathMonitor()
    
    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: DispatchQueue(label: "NetworkMonitor"))
    }
    
    deinit { monitor.cancel() }
}
