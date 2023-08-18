//
//  LoadingIndicator.swift
//  BlogApp
//
//  Created by PKW on 2023/08/08.
//

import Foundation
import UIKit

class LoadingIndicator {
    
    enum IndicatorViewType {
        case fetchPost
        case saveContent
    }
    
    static func showLoading(type: IndicatorViewType) {
        DispatchQueue.main.async {
            // 최상단에 있는 window 객체 획득
            guard let window = UIApplication.shared.windows.last else { return }

            var loadingIndicatorView: UIView
            if let existedView = window.subviews.first(where: { $0 is UIActivityIndicatorView } ) as? UIActivityIndicatorView {
                loadingIndicatorView = existedView
            } else {
                loadingIndicatorView = ActivityIndicatorView()
                
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
  
                /// 다른 UI가 눌리지 않도록 indicatorView의 크기를 full로 할당
                loadingIndicatorView.frame = window.frame
                window.addSubview(loadingIndicatorView)
            }
            
            if let loadingIndicatorView = loadingIndicatorView as? ActivityIndicatorView {
                loadingIndicatorView.activityIndicatorView.startAnimating()
            }
        }
    }

    static func hideLoading() {
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.windows.last else { return }
            window.subviews.filter({ $0 is ActivityIndicatorView }).forEach { $0.removeFromSuperview() }
        }
    }
}
