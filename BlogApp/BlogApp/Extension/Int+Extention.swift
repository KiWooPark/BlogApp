//
//  Int+Extention.swift
//  BlogApp
//
//  Created by PKW on 2023/06/21.
//

import Foundation

// MARK: ===== [Extention] =====
extension Int {
    
    // MARK:  ===== [Function] =====
    
    /// 숫자를 콤마(,)가 포함된 문자열로 변환하여 반환합니다.
    /// 예) 1000 -> "1,000", 10000 -> "10,000"
    ///
    /// - Returns: 콤마(,)가 포함된 숫자 문자열
    func insertComma() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        return numberFormatter.string(from: NSNumber(value: self))!
    }
    
    /// 주어진 숫자를 해당하는 요일의 문자열로 변환합니다.
    /// 예) 2 -> "매주 월요일", 3 -> "매주 화요일"
    ///
    /// - Note: 1부터 7까지의 숫자는 각각 일요일부터 토요일까지를 나타냅니다.
    ///
    /// - Returns: 해당 요일에 대한 문자열. 올바르지 않은 숫자의 경우 빈 문자열을 반환합니다.
    func convertDeadlineDayToString() -> String {
        switch self {
        case 2:
            return "매주 월요일"
        case 3:
            return "매주 화요일"
        case 4:
            return "매주 수요일"
        case 5:
            return "매주 목요일"
        case 6:
            return "매주 금요일"
        case 7:
            return "매주 토요일"
        case 1:
            return "매주 일요일"
        default:
            return ""
        }
    }
    
    /// 주어진 숫자를 해당하는 요일의 문자열로 변환합니다.
    /// 예) 2 -> "월요일", 3 -> "화요일"
    ///
    /// - Note: 1부터 7까지의 숫자는 각각 일요일부터 토요일까지를 나타냅니다.
    ///
    /// - Returns: 해당 요일에 대한 문자열. 올바르지 않은 숫자의 경우 빈 문자열을 반환합니다.
    func convertWeekDayToString() -> String {
        switch self {
        case 2:
            return "월요일"
        case 3:
            return "화요일"
        case 4:
            return "수요일"
        case 5:
            return "목요일"
        case 6:
            return "금요일"
        case 7:
            return "토요일"
        case 1:
            return "일요일"
        default:
            return ""
        }
    }
    
}
