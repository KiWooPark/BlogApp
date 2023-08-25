//
//  Size+Extention.swift
//  BlogApp
//
//  Created by PKW on 2023/07/25.
//

import Foundation
import UIKit

// MARK: ===== [Extention] =====
extension CGFloat {
    // 공통적으로 사용되는 cornerRadius값
    static let cornerRadius = 10.0
}

extension UIAlertAction {
    
    // MARK: ===== [Enum] =====
    /// 버튼의 색상을 변경하기위한 `Alert`의 타입을 정의하는 열거형
    enum ActionType {
        // 확인
        case ok
        // 수정
        case edit
        // 마감 내역 보기
        case history
        // 삭제
        case delete
        // 취소
        case cancel
    }
    
    /// `Alert`에 사용되는 버튼의 색상을 변경 합니다.
    /// - Parameter type: 버튼의 색상을 변경하기위한 `Alert`의 타입
    func setTextColor(type: ActionType) {
        switch type {
        case .ok, .edit, .history:
            self.setValue(UIColor.buttonColor, forKey: "titleTextColor")
        case .delete:
            self.setValue(UIColor.finishColor, forKey: "titleTextColor")
        case .cancel:
            self.setValue(UIColor.finishColor, forKey: "titleTextColor")
        }
    }
}
