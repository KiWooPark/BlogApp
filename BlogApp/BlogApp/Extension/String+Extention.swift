//
//  String+Extention.swift
//  BlogApp
//
//  Created by PKW on 2023/06/11.
//

import Foundation
import UIKit

// MARK: ===== [Extention] =====
extension String {
    
    // MARK:  ===== [Function] =====
    
    /// Date 객체를 `yyyy-MM-dd'T'HH:mm:ssZ` 포맷의 Date 객체로 변환합니다.
    ///
    /// - Returns: 날짜를 나타내는 `YY년 MM월 dd일` 형식의 Date 객체
    func toDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"

        return dateFormatter.date(from: self) ?? Date()
    }
    
    /// 중복된 이름인지 검사합니다.
    ///
    /// - Parameters:
    ///   - members: 현재 등록된 멤버 목록
    ///   - isEdit: 이름을 수정 중인지 여부. 수정 중이면 `true`, 아니면 `false` (기본값은 `false`)
    ///   - index: 수정 중인 사용자의 인덱스. 기본값은 `9999` (이 값은 실제 사용자 인덱스로 사용되지 않음)
    ///
    /// - Returns: 이름이 이미 목록에 있으면 `true`, 그렇지 않으면 `false`
    func validateName(members: [User], isEdit: Bool = false, index: Int = 9999) -> Bool  {
        if isEdit {
            if members[index].name == self {
                return false
            } else {
                return members.contains(where: {$0.name == self})
            }
        } else {
            return members.contains(where: {$0.name == self})
        }
    }
}

