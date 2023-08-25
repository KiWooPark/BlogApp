//
//  LoadingIndicator.swift
//  BlogApp
//
//  Created by PKW on 2023/08/08.
//

import Foundation
import UIKit

// MARK:  ===== [Class or Struct] =====
/// 인디케이터 액티비티 뷰를 보여주거나 숨기는 경우에 사용하는 커스텀 클래스 입니다.
class LoadingIndicator {
    
    // MARK: ===== [Enum] =====
    /// 로딩 인디케이터의 표시 타입을 정의하는 열거형
    enum IndicatorViewType {
        case fetchPost
        case saveContent
    }
    
    // MARK:  ===== [Function] =====
    /// 지정된 타입의 로딩 인디케이터를 화면에 표시합니다.
    /// - Parameter type: 표시할 로딩 인디케이터의 타입
    static func showLoading(type: IndicatorViewType) {
        DispatchQueue.main.async {
            
            // 최상단에 있는 window 객체 획득
            guard let window = UIApplication.shared.windows.last else { return }

            var loadingIndicatorView: UIView
            
            // 만약 화면에 이미 표시된 인디케이터가 있다면, 해당 인디케이터를 사용합니다.
            if let existedView = window.subviews.first(where: { $0 is UIActivityIndicatorView } ) as? UIActivityIndicatorView {
                loadingIndicatorView = existedView
            } else {
                loadingIndicatorView = ActivityIndicatorView()
                
                // 표시할 메시지를 설정합니다.
                switch type {
                case .fetchPost:
                    if let indicatorView = loadingIndicatorView as? ActivityIndicatorView {
                        indicatorView.indicatorContentLabel.text = "작성한 게시물을 확인중 입니다\n잠시만 기다려주세요"
                    }
                case .saveContent:
                    if let indicatorView = loadingIndicatorView as? ActivityIndicatorView {
                        indicatorView.indicatorContentLabel.text = "스터디를 마감중 입니다\n잠시만 기다려주세요"
                    }
                }
  
                // 화면의 다른 UI 요소가 클릭되지 않도록 인디케이터뷰의 크기를 전체 화면 크기로 설정합니다.
                loadingIndicatorView.frame = window.frame
                window.addSubview(loadingIndicatorView)
            }
            
            // 로딩 인디케이터 애니메이션을 시작합니다.
            if let loadingIndicatorView = loadingIndicatorView as? ActivityIndicatorView {
                loadingIndicatorView.activityIndicatorView.startAnimating()
            }
        }
    }
    
    /// 화면에서 로딩 인디케이터를 숨깁니다.
    static func hideLoading() {
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.windows.last else { return }
            window.subviews.filter({ $0 is ActivityIndicatorView }).forEach { $0.removeFromSuperview() }
        }
    }
}
