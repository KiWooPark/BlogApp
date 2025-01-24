//
//  NetworkCheck.swift
//  BlogApp
//
//  Created by PKW on 2023/08/14.
//
import Foundation
import Network

final class NetworkCheck {
    static let shared = NetworkCheck()
    private let queue = DispatchQueue.global(qos: .background)
    private let monitor: NWPathMonitor
    public private(set) var isConnected: Bool = false
    public private(set) var connectionType: ConnectionType = .unknown

    // 연결타입
    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown
    }

    // monotior 초기화
    private init() {
        monitor = NWPathMonitor()
    }

    // ## 여러번 호출 -> 한번 호출로 변경
    // Network Monitoring 시작
    public func startMonitoring() {
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }

            self.isConnected = path.status != .unsatisfied
            self.getConnectionType(path)
        }
    }

    // Network Monitoring 종료
    public func stopMonitoring() {
        monitor.cancel()
    }

    // Network 연결 타입
    private func getConnectionType(_ path: NWPath) {
        if path.usesInterfaceType(.wifi) {
            connectionType = .wifi
        } else if path.usesInterfaceType(.cellular) {
            connectionType = .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            connectionType = .ethernet
        } else {
            connectionType = .unknown
        }
    }
}


//class Debouncer {
//    private var workItem: DispatchWorkItem?
//    private var delay: TimeInterval
//
//    init(delay: TimeInterval) {
//        self.delay = delay
//    }
//
//    func debounce(action: @escaping (() -> Void)) {
//        workItem?.cancel()
//        workItem = DispatchWorkItem(block: action)
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem!)
//    }
//
//    private let debouncer = Debouncer(delay: 1)
//}


//final class NetworkCheck {
//    static let shared = NetworkCheck()
//    private let queue = DispatchQueue.global(qos: .background)
//    private let monitor: NWPathMonitor
//    public private(set) var isConnected: Bool = false
//    public private(set) var connectionType: ConnectionType = .unknown
//    public private(set) var previousConnectionType: ConnectionType = .unknown
//
//    private var debounceWorkItem: DispatchWorkItem?
//
//    var networkStatusChange: ((Bool) -> Void)?
//
//    // 연결타입
//    enum ConnectionType {
//        case wifi
//        case cellular
//        case ethernet
//        case unknown
//    }
//
//    // monotior 초기화
//    private init() {
//        monitor = NWPathMonitor()
//    }
//
//    // ## 여러번 호출 -> 한번 호출로 변경
//    // Network Monitoring 시작
//    public func startMonitoring() {
//        monitor.start(queue: queue)
//        monitor.pathUpdateHandler = { [weak self] path in
//            guard let self = self else { return }
//
//            self.isConnected = path.status != .unsatisfied
//            self.getConnectionType(path)
//
////            // 기존 디바운싱이 있으면 취소
////            self.debounceWorkItem?.cancel()
////
////            // 새로운 디바운싱 작업 생성
////            let newWorkItem = DispatchWorkItem { [weak self] in
////                guard let self = self else { return }
////                // 이전 상태와 현재 상태를 비교
////                if self.previousConnectionType != self.connectionType {
////
////                    // 상태가 변경되었을 때만 로그나 다른 작업을 수행
////                    self.networkStatusChange?(self.isConnected)
////
////                    // 현재 상태를 이전 상태로 업데이트
////                    self.previousConnectionType = self.connectionType
////                }
////            }
////
////            // 작업 저장 및 지연실행
////            self.debounceWorkItem = newWorkItem
////            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: newWorkItem) // 1초 디바운스
//        }
//    }
//
//    // Network Monitoring 종료
//    public func stopMonitoring() {
//        monitor.cancel()
//    }
//
//    // Network 연결 타입
//    private func getConnectionType(_ path: NWPath) {
//        if path.usesInterfaceType(.wifi) {
//            connectionType = .wifi
//        } else if path.usesInterfaceType(.cellular) {
//            connectionType = .cellular
//        } else if path.usesInterfaceType(.wiredEthernet) {
//            connectionType = .ethernet
//        } else {
//            connectionType = .unknown
//        }
//    }
//}
