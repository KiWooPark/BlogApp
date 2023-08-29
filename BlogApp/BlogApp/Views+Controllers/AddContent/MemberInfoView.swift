//
//  MemberInfoView.swift
//  BlogApp
//
//  Created by PKW on 2023/07/14.
//

import UIKit
import SnapKit
import Then

/// 새로 추가할 멤버의 정보를 보여줄 뷰의 커스텀 클래스 입니다.
class MemberInfoView: UIView {
    
    // MARK: ===== [Property] =====
    
    // 멤버 정보를 표시할 바탕 수직 스택 뷰
    let baseStackView = UIStackView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .blue
        $0.axis = .horizontal
        $0.distribution = .fill
        $0.spacing = 5
    }
    
    // 멤버 정보를 표시할 수직 스택 뷰
    let memberInfoStackView = UIStackView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .gray
        $0.axis = .vertical
        $0.distribution = .equalSpacing
        $0.spacing = 5
    }
    
    // 이름을 표시할 레이블
    let nameLabel = UILabel().then {
        $0.text = "이름"
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // 벌금을 표시할 레이블
    let fineLabel = UILabel().then {
        $0.text = "10,000원"
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // 블로그 게시글 제목을 표시할 레이블
    let blogPostTitleLabel = UILabel().then {
        $0.text = "www.wwww.wwww"
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // 수정 버튼
    let editButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .brown
        $0.setTitle("수정", for: .normal)
    }
    
    
    
    // MARK: ===== [Override] =====
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // 여기서 사용자 정의 뷰의 설정을 할 수 있습니다.
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    
    
    // MARK:  ===== [Function] =====
    
    /// 멤버 정보를 표시할 뷰들을 설정하고 제약조건을 추가합니다.
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
