//
//  String+Extention.swift
//  BlogApp
//
//  Created by PKW on 2023/06/11.
//

import Foundation
import UIKit

enum BoldStringType: String {
    case startDate = "진행중인 주차 : "
    case setDay = "마감 : "
}

extension String {
    func convertBoldString(boldString: BoldStringType) -> NSAttributedString {
        let fontSize = UIFont.boldSystemFont(ofSize: 17)
        let attributedStr = NSMutableAttributedString(string: self)
        attributedStr.addAttribute(.font, value: fontSize, range: (self as NSString).range(of: boldString.rawValue))
        return attributedStr
    }
    
    func getCurrentDay() -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        
        let date = dateFormatter.date(from: self) ?? Date()
        
        let day = calendar.dateComponents([.day], from: date).day!
        
        return day
    }
    
    // 날짜 형식 변환
    // return Date로 변경 
    func convertDateFormat(type: DateFormatType) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let date = dateFormatter.date(from: self) ?? Date()
        
        switch type {
        case .yyyymmdd:
            dateFormatter.dateFormat = "YYYY-MM-dd"
            return dateFormatter.string(from: date)
        case .mmdd:
            dateFormatter.dateFormat = "MM-dd"
            return dateFormatter.string(from: date)
        case .yyyyMMddHHmmssZ:
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            return dateFormatter.string(from: date)
        }
    }
    
    func convertToDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return dateFormatter.date(from: self)
    }
}

