//
//  BasePaddingLabel.swift
//  BlogApp
//
//  Created by PKW on 2023/07/25.
//

import UIKit

@IBDesignable
// MARK:  ===== [Class or Struct] =====
/// 인터페이스 빌더에서 레이블의 패딩을 조절할 수 있는 커스텀 클래스 입니다.
class BasePaddingLabel: UILabel {
    
    // MARK: ===== [Propertys] =====
    // @IBInspectable로 Interface Builder에서 이 속성들을 직접 설정할 수 있게 해줍니다.
    @IBInspectable var topInset: CGFloat = 2.0 // 상단 여백
    @IBInspectable var bottomInset: CGFloat = 2.0 // 하단 여백
    @IBInspectable var leftInset: CGFloat = 4.0 // 왼쪽 여백
    @IBInspectable var rightInset: CGFloat = 4.0 // 오른쪽 여백

    
    // MARK: ===== [Override] =====
    /// 텍스트를 그릴 때 지정된 여백을 고려하여 텍스트를 그립니다.
    /// - Parameter rect: 레이블의 원래 크기
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }
    
    /// intrinsicContentSize는 레이블의 내부 콘텐츠(텍스트) 크기를 반환합니다.
    /// 여기서는 여백을 고려하여 레이블의 총 크기를 반환합니다.
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + leftInset + rightInset,
                      height: size.height + topInset + bottomInset)
    }
    
    /// bounds 속성이 변경될 때마다 (예: 레이블의 크기 변경시) 호출됩니다.
    /// 여기서는 여백을 고려하여 레이블의 최대 너비를 설정합니다.
    override var bounds: CGRect {
        didSet {
            preferredMaxLayoutWidth = bounds.width - (leftInset + rightInset)
        }
    }
}



