//
//  Int+Extention.swift
//  BlogApp
//
//  Created by PKW on 2023/06/21.
//

import Foundation

extension Int {
    
    // 3자리마다 콤마 찍기
    func insertComma() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        return numberFormatter.string(from: NSNumber(value: self))!
    }
    
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
