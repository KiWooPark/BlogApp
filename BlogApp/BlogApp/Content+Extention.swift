//
//  Content+Extention.swift
//  BlogApp
//
//  Created by PKW on 1/23/25.
//

import Foundation

extension Content {
    func isDeadlinePassed() -> Bool {
        let deadline = deadlineDate?.compare(Date())
        
        switch deadline {
        case .orderedAscending: // 과거
            return true
        case .orderedDescending, .orderedSame: // 미래, 현재
            return false
        case .none:
            return true
        }
    }
    
    func calculateDday() -> Int {
        let startOfDayForDate1 = Calendar.current.startOfDay(for: deadlineDate ?? Date())
        let startOfDayForDate2 = Calendar.current.startOfDay(for: Date())
        
        let daysDifference = Calendar.current.dateComponents([.day],
                                                             from: startOfDayForDate2,
                                                             to: startOfDayForDate1).day
        
        return daysDifference ?? 0
    }
}
