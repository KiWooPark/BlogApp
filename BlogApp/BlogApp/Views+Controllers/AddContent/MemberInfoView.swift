//
//  MemberInfoView.swift
//  BlogApp
//
//  Created by PKW on 2023/07/14.
//

import UIKit
import SnapKit
import Then

class MemberInfoView: UIView {
    
    let baseStackView = UIStackView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .blue
        $0.axis = .horizontal
        $0.distribution = .fill
        $0.spacing = 5
    }
    
    let memberInfoStackView = UIStackView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .gray
        $0.axis = .vertical
        $0.distribution = .equalSpacing
        $0.spacing = 5
    }
    
    let nameLabel = UILabel().then {
        $0.text = "123123"
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    let fineLabel = UILabel().then {
        $0.text = "10,000원"
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    let blogPostTitleLabel = UILabel().then {
        $0.text = "www.wwww.wwww"
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    let editButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .brown
        $0.setTitle("수정", for: .normal)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // 여기서 사용자 정의 뷰의 설정을 할 수 있습니다.
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        // inset = superView와의 간격
        // offset = 다른 요소와의 간격
        self.backgroundColor = .blue
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(baseStackView)
        
        baseStackView.addArrangedSubview(memberInfoStackView)
        baseStackView.addArrangedSubview(editButton)
        
        editButton.setContentHuggingPriority(.init(rawValue: 998), for: .horizontal)
        
        memberInfoStackView.addArrangedSubview(nameLabel)
        memberInfoStackView.addArrangedSubview(fineLabel)
        memberInfoStackView.addArrangedSubview(blogPostTitleLabel)
  
        baseStackView.snp.makeConstraints { make in
            make.top.equalTo(self.snp.top)
            make.leading.equalTo(self.snp.leading)
            make.trailing.equalTo(self.snp.trailing)
            make.bottom.equalToSuperview().inset(10)
        }
    }
}
