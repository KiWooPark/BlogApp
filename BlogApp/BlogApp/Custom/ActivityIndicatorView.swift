//
//  ActivityIndicator.swift
//  BlogApp
//
//  Created by PKW on 2023/08/08.
//

import Foundation
import UIKit
import Then
import SnapKit

/// 인디케이터 액티비티 뷰의 커스텀 클래스 입니다.
class ActivityIndicatorView: UIView {
    
    deinit {
        print("ActivityIndicatorView 메모리 해제 확인")
    }
    
    // 액티비티 인디케이터 뷰의 바탕이 되는 뷰 
    var activityIndicatorBaseView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .cellColor
        $0.layer.cornerRadius = .cornerRadius
    }
    
    // 인디케이터와 레이블을 포함하는 스택 뷰
    var indicatorStackView = UIStackView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .cellColor
        $0.axis = .vertical
        $0.distribution = .equalSpacing
        $0.spacing = 20
    }
    
    // 인디케이터 액티비티 뷰
    var activityIndicatorView = UIActivityIndicatorView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.color = .buttonColor
        $0.style = .large
    }
    
    // 인디케이터 액티비티 뷰 하단에 표시될 레이블
    var indicatorContentLabel = UILabel().then {
        $0.textAlignment = .center
        $0.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        $0.numberOfLines = 0
    }
   
    // 초기화 메소드
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    // 스토리보드 사용시 초기화 메소드
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
        
    }
    
    func setup() {
        self.backgroundColor = .backgroundColor
            
        self.addSubview(activityIndicatorBaseView)
        
        activityIndicatorBaseView.addSubview(indicatorStackView)
        
        indicatorStackView.addArrangedSubview(activityIndicatorView)
        indicatorStackView.addArrangedSubview(indicatorContentLabel)
        
        
        activityIndicatorBaseView.snp.makeConstraints { make in
            make.centerX.equalTo(self.snp.centerX)
            make.centerY.equalTo(self.snp.centerY)
        }
        
        indicatorContentLabel.setContentCompressionResistancePriority(.init(999), for: .horizontal)
        indicatorContentLabel.setContentCompressionResistancePriority(.init(999), for: .vertical)
        
        indicatorStackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(30)
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }
}
