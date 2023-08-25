//
//  Date+Extention.swift
//  BlogApp
//
//  Created by PKW on 2023/06/11.
//

import Foundation

// MARK: ===== [Extention] =====
extension Date {
    
    // MARK: ===== [Enum] =====
    /// 날짜 비교 유형을 나타내는 열거형 입니다.
    enum CompareDateType {
        // 시작 날짜 비교
        case startDate
        // 마감 날짜 비교
        case deadlineDate
        
        // 시작 날짜나 마감 날짜와 특정 날짜를 비교했을 때의 결과를 나타내는 열거형 입니다.
        enum CompareResult {
            /// 비교 대상 날짜가 시작 날짜보다 이전
            case pastStartDate
           
            /// 비교 대상 날짜가 마감 날짜보다 이전
            case pastDeadlineDate
           
            /// 비교 대상 날짜가 시작 날짜보다 이후
            case futureStartDate
           
            /// 비교 대상 날짜가 마감 날짜보다 이후
            case futureDeadlineDate
          
            /// 비교 대상 날짜와 시작 날짜가 같음
            case sameStartDate
          
            /// 비교 대상 날짜와 마감 날짜가 같음
            case sameDeadlineDate
        }
    }
    
    // MARK:  ===== [Function] =====
    
    /// Date 객체를 `YY년 MM월 dd일` 포맷의 문자열로 변환합니다.
    ///
    /// - Returns: 날짜를 나타내는 `YY년 MM월 dd일` 형식의 문자열
    func toString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YY년 MM월 dd일"
    
        return dateFormatter.string(from: self)
    }

    /// 해당 Date 객체를 나타내는 마감 날짜(23:59:59)에서 1초를 더하여 다음 날의 시작 날짜(00:00:00)로 변환합니다.
    ///
    /// - Returns: 현재 Date에서 1초가 추가된 다음 날의 시작 날짜. 변환 중 에러가 발생하면 nil을 반환합니다.
    func convertDeadlineToStartDate() -> Date? {
        return Calendar.current.date(byAdding: .second, value: 1, to: self)
    }
    
    /// 해당 날짜를 기반으로 시간을 00:00:00으로 설정하여 새로운 시작 날짜를 생성합니다.
    ///
    /// - Returns: 시간이 00:00:00으로 설정된 시작 날짜. 해당 날짜의 생성에 문제가 있을 경우 nil을 반환합니다.
    func makeStartDate() -> Date? {
        var calendar = Calendar.current
        
        let date = calendar.dateComponents([.year, .month, .day], from: self)
        let components = DateComponents(year: date.year ,month: date.month, day: date.day ,hour: 0,minute: 0,second: 0)
        return calendar.date(from: components)
    }

    /// 해당 날짜를 기반으로 시간을 23:59:59으로 설정하여 새로운 마감 날짜를 생성합니다.
    ///
    /// - Returns: 시간이 23:59:59으로 설정된 마감 날짜. 해당 날짜의 생성에 문제가 있을 경우 nil을 반환합니다.
    func makeDeadlineDate() -> Date? {
        var calendar = Calendar.current
        
        let date = calendar.dateComponents([.year, .month, .day], from: self)
        let components = DateComponents(year: date.year ,month: date.month, day: date.day ,hour: 23,minute: 59,second: 59)
        return calendar.date(from: components)
    }
    
    /// 마감 날짜를 기준으로 이전 주의 시작 날짜와 마감 날짜를 생성합니다.
    /// 만약 마감일이 월요일이라면, 반환되는 기간은 [지난주 월 ~ 이번주 월] 입니다.
    ///
    /// - Returns: 시작 날짜와 마감날짜, 시작 날짜의 생성세 문제가 있을 경우 현재 날짜를 기반으로 생성된 마감 날짜만 반환됩니다.
    func getStartDateAndDeadlineDate() -> (startDate: Date?, deadlineDate: Date?) {
        var calendar = Calendar.current
        
        let finishDate = self
        var startDate = calendar.date(byAdding: .day, value: -7, to: finishDate)
        startDate = calendar.date(byAdding: .second, value: 1, to: startDate ?? Date())
        
        return (startDate, finishDate)
    }

    /// 현재 날짜의 요일 값을 반환합니다.
    /// ISO8601 캘린더를 기준으로, 월요일을 시작으로 해서 1(월요일) ~ 7(일요일)의 값으로 반환됩니다.
    ///
    /// - Note: [1: 일] [2: 월] [3: 화] [4: 수] [5: 목] [6: 금] [7: 토]
    ///
    /// - Returns: 현재 날짜의 요일 값을 나타내는 정수. 값이 없을 경우 0을 반환합니다.
    func getDayOfCurrentDate() -> Int {
        var calendar = Calendar(identifier: .iso8601)
        calendar.firstWeekday = 2
        
        let day = calendar.dateComponents([.weekday], from: self)
        return day.weekday ?? 0
    }

    
    /// 주어진 날짜와 현재 날짜를 비교하여, 해당 날짜가 과거, 현재 또는 미래인지 판단합니다.
    /// 이를 통해 주어진 `editType`에 따라 적절한 `CompareResult` 값을 반환합니다.
    ///
    /// - Parameters:
    ///   - fromDate: 비교 대상이 될 날짜. `nil`인 경우 현재 날짜를 사용합니다.
    ///   - editType: 비교 기준이 될 날짜 유형 (`startDate` 또는 `deadlineDate`)
    ///
    /// - Returns: 날짜 비교 결과를 나타내는 `CompareDateType.CompareResult` 값.
    func dateCompare(fromDate: Date?, editType: CompareDateType) -> CompareDateType.CompareResult {
       
        let calendar = Calendar.current
        
        // 비교 대상이 될 날짜(선택한 날짜)
        let targetDateComponents = calendar.dateComponents([.year, .month, .day], from: self)
        
        // 비교 기준이 될 날짜 (현재 날짜 또는 마지막 공지사항 날짜)
        let fromDateComponents = calendar.dateComponents([.year, .month, .day], from: fromDate ?? Date())
        
        let targetDate = calendar.date(from: targetDateComponents) ?? Date()
        let fromDate = calendar.date(from: fromDateComponents) ?? Date()
        
        let result: ComparisonResult = targetDate.compare(fromDate)
        
        switch result {
        case .orderedAscending: // 과거
            switch editType {
            case .startDate:
                return .pastStartDate
            case .deadlineDate:
                return .pastDeadlineDate
            }
        case .orderedDescending: // 미래
            switch editType {
            case .startDate:
                return .futureStartDate
            case .deadlineDate:
                return .futureDeadlineDate
            }
        case .orderedSame: // 현재
            switch editType {
            case .startDate:
                return .sameStartDate
            case .deadlineDate:
                return .sameDeadlineDate
            }
        }
    }
   
    /// 주어진 마감 날짜 `deadlineDay(정수)`를 기준으로 현재 날짜와 다음 주의 마감 날짜를 계산합니다.
    ///
    /// - Parameter deadlineDay: 마감 날짜로 설정된 요일(1: 일요일 ~ 7: 토요일)
    ///
    /// - Returns:
    ///   - currentDate: 주어진 `deadlineDay`에 따라 계산된 현재 주의 마감 날짜.
    ///   - nextWeekFinishDate: 주어진 `deadlineDay`에 따라 계산된 다음 주의 마감 날짜.
    func calculateDeadlineDate(deadlineDay: Int) -> (currentDate: Date?, nextWeekFinishDate: Date?) {

        var calendar = Calendar(identifier: .iso8601)
        calendar.firstWeekday = 2
    
        // 현재 날짜의 요일
        let nowDay = calendar.dateComponents([.weekday], from: self).weekday ?? 0
   
        var currentDate: Date?
        var nextWeekDeadlineDate: Date?
        
        let calcDay = (deadlineDay + 7 - nowDay) % 7
        
        // 현재 요일과 마감 요일이 같지 않은 경우
        if nowDay != deadlineDay {
            currentDate = calendar.date(byAdding: .day, value: calcDay, to: self) ?? Date()
            let year = calendar.dateComponents([.year], from: currentDate ?? Date()).year
            let month = calendar.dateComponents([.month], from: currentDate ?? Date()).month
            let day = calendar.dateComponents([.day], from: currentDate ?? Date()).day

            let components = DateComponents(year: year, month: month, day: day, hour: 23, minute: 59, second: 59)
            currentDate = calendar.date(from: components)
            
            return (currentDate, nil)
        } else { // 현재 요일과 마감 요일이 같은 경우
            currentDate = calendar.date(byAdding: .day, value: calcDay, to: self) ?? Date()
            let currentDateYear = calendar.dateComponents([.year], from: currentDate ?? Date()).year
            let currentDateMonth = calendar.dateComponents([.month], from: currentDate ?? Date()).month
            let currentDateDay = calendar.dateComponents([.day], from: currentDate ?? Date()).day

            let currentDateComponents = DateComponents(year: currentDateYear, month: currentDateMonth, day: currentDateDay, hour: 23, minute: 59, second: 59)
            currentDate = calendar.date(from: currentDateComponents)
            
            let addDate = calendar.date(byAdding: .day, value: 7, to: self) ?? Date()
            
            let nextDateYear = calendar.dateComponents([.year], from: addDate).year
            let nextDateMonth = calendar.dateComponents([.month], from: addDate).month
            let nextDateDay = calendar.dateComponents([.day], from: addDate).day

            let nextDeadlineDateComponents = DateComponents(year: nextDateYear, month: nextDateMonth, day: nextDateDay, hour: 23, minute: 59, second: 59)
            
            nextWeekDeadlineDate = calendar.date(from: nextDeadlineDateComponents)
            
            return (currentDate, nextWeekDeadlineDate)
        }
    }
}
