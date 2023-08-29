//
//  StudyMemberInfoView.swift
//  BlogApp
//
//  Created by PKW on 2023/07/25.
//

import UIKit
import SnapKit
import Then

/// 스터디에 참여중인 멤버의 정보를 보여줄 뷰의 커스텀 클래스 입니다.
class StudyMemberInfoView: UIView {

    // MARK: ===== [Property] =====
    
    // 멤버 정보를 표시할 바탕 수직 스택 뷰
    let baseStackView = UIStackView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .clear
        $0.axis = .vertical
        $0.distribution = .equalSpacing
        $0.spacing = 10
    }
    
    // 벌금 정보를 표시할 수직 스택 뷰
    let fineStackView = UIStackView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .clear
        $0.axis = .vertical
        $0.distribution = .equalSpacing
        $0.spacing = 5
    }
    
    // 이름을 표시할 레이블
    let nameLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "이름"
        $0.font = UIFont.systemFont(ofSize: 17, weight: .bold)
    }
    
    // '보증금'을 표시할 레이블
    let fineTitleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        $0.text = "보증금"
        $0.textColor = .restColor
    }
    
    // 벌금을 표시할 레이블
    let fineSubTitle = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "10,000원"
        $0.font = UIFont.systemFont(ofSize: 17, weight: .bold)
    }
    
    // 경계선을 표시할 뷰
    let underlineView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .systemGray5
    }
    
    // '블로그 보러가기' 버튼
    let showBlogButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .buttonColor
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        $0.setTitle("블로그 보러가기", for: .normal)
        $0.layer.cornerRadius = .cornerRadius
    }
    
    
    
    // MARK: ===== [Override] =====
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
    }
    
    
    
    // MARK:  ===== [Function] =====
    
    /// 멤버 정보를 표시할 뷰들을 설정하고 제약조건을 추가합니다.
    func setup() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor.cellColor
        self.layer.cornerRadius = .cornerRadius
        
        self.addSubview(baseStackView)
        baseStackView.addArrangedSubview(nameLabel)
        
        fineStackView.addArrangedSubview(fineTitleLabel)
        fineStackView.addArrangedSubview(fineSubTitle)
        
        baseStackView.addArrangedSubview(fineStackView)
        baseStackView.addArrangedSubview(underlineView)
        
        baseStackView.addArrangedSubview(showBlogButton)

        baseStackView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview().inset(20)
        }
        
        underlineView.snp.makeConstraints { make in
            make.height.equalTo(1)
        }
    }
}
