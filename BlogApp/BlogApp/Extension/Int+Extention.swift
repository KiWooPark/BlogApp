//
//  Int+Extention.swift
//  BlogApp
//
//  Created by PKW on 2023/06/21.
//

import Foundation

extension Int {
    
    func convertSetDayStr() -> String {
        switch self {
        case 101:
            return "매주 월요일"
        case 102:
            return "매주 화요일"
        case 103:
            return "매주 수요일"
        case 104:
            return "매주 목요일"
        case 105:
            return "매주 금요일"
        case 106:
            return "매주 토요일"
        case 107:
            return "매주 일요일"
        default:
            return ""
        }
    }

    
    func convertFineStr() -> String {
        switch self {
        case 201:
            return "1,000원"
        case 202:
            return "3,000원"
        case 203:
            return "5,000원"
        case 204:
            return "7,000원"
        case 205:
            return "10,000원"
        default:
            return ""
        }
    }
    
    func convertFineInt() -> Int {
        switch self {
        case 201:
            return 1000
        case 202:
            return 3000
        case 203:
            return 5000
        case 204:
            return 7000
        case 205:
            return 10000
        default:
            return 0
        }
    }
    
}
