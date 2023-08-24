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

// MARK:  ===== [Class or Struct] =====
/// 사용자에게 로딩 중임을 알리기 위한 커스텀 액티비티 인디케이터 뷰 클래스입니다.
class ActivityIndicatorView: UIView {
    
    deinit {
        print("ActivityIndicatorView 메모리 해제 확인")
    }
    
    // MARK: ===== [Propertys] =====
    // 액티비티 인디케이터를 포함하며 배경이 되는 뷰
    var activityIndicatorBaseView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .cellColor
        $0.layer.cornerRadius = .cornerRadius
    }
    
    // 액티비티 인디케이터와 하단의 레이블을 포함하는 수직 스택 뷰
    var indicatorStackView = UIStackView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .cellColor
        $0.axis = .vertical
        $0.distribution = .equalSpacing
        $0.spacing = 20
    }
    
    // 로딩 중임을 나타내는 액티비티 인디케이터 뷰
    var activityIndicatorView = UIActivityIndicatorView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.color = .buttonColor
        $0.style = .large
    }
    
    // 액티비티 인디케이터 바로 아래에 위치하는 추가 정보 레이블
    var indicatorContentLabel = UILabel().then {
        $0.textAlignment = .center
        $0.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        $0.numberOfLines = 0
    }
   
    // MARK: ===== [Override] =====
    // 초기화 메소드
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    // MARK: ===== [required] ======
    // 스토리보드 사용시 초기화 메소드
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
        
    }
    
    // MARK: ===== [Function] =====
    /// 액티비티 인디케이터와 관련된 뷰들을 설정하고 제약 조건을 추가합니다.
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
