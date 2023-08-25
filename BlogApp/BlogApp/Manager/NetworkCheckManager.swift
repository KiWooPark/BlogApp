//
//  NetworkCheck.swift
//  BlogApp
//
//  Created by PKW on 2023/08/14.
//
import Foundation
import Network

// MARK:  ===== [Class or Struct] =====
/// 네트워크 상태를 확인하는 클래스 입니다.
final class NetworkCheckManager {
    
    // MARK:  ===== [Propertys] =====
    
    // 싱글톤 인스턴스
    static let shared = NetworkCheckManager()
    // 백그라운드에서 동작할 dispatch queue
    private let queue = DispatchQueue.global(qos: .background)
    // 네트워크 상태를 모니터링하기 위한 객체
    private let monitor: NWPathMonitor
    // 현재 연결된 상태인지 나타내는 변수
    public private(set) var isConnected: Bool = false
    // 현재 연결된 네트워크 타입을 나타내는 변수
    public private(set) var connectionType: ConnectionType = .unknown

    // MARK:  ===== [Enum] =====
    
    // 네트워크 연결 타입 열거형
    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown
    }

    // MARK:  ===== [init] =====
    
    // monotior 초기화
    private init() {
        monitor = NWPathMonitor()
    }

    // MARK:  ===== [Function] =====
    
    /// 네트워크 모니터링을 시작합니다.
    public func startMonitoring() {
        
        // 모니터링 시작
        monitor.start(queue: queue)
        
        // 네트워크 상태가 변경될 때마다 호출될 핸들러 설정
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            
            // 네트워크 연결 상태 업데이트
            self.isConnected = path.status != .unsatisfied
            
            // 네트워크 연결 타입 업데이트
            self.getConnectionType(path)
        }
    }

    /// 네트워크 모니터링을 종료합니다.
    public func stopMonitoring() {
        monitor.cancel()
    }

    /// `NWPath`에서 연결 타입을 추출하여 `connectionType`를 업데이트합니다.
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
