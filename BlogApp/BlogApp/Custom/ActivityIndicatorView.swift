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

class ActivityIndicatorView: UIView {
    
    deinit {
        print("ActivityIndicatorView 해제")
    }
    
    var activityIndicatorBaseView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .cellColor
        $0.layer.cornerRadius = .cornerRadius
    }
    
    var indicatorStackView = UIStackView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .cellColor
        $0.axis = .vertical
        $0.distribution = .equalSpacing
        $0.spacing = 20
    }
    
    var activityIndicatorView = UIActivityIndicatorView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.color = .buttonColor
        $0.style = .large
    }
    
    var indicatorContentLabel = UILabel().then {
        $0.textAlignment = .center
        $0.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        $0.numberOfLines = 0
    }
   
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
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
