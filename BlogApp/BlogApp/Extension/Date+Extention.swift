//
//  Date+Extention.swift
//  BlogApp
//
//  Created by PKW on 2023/06/11.
//

import Foundation

enum DateFormatType {
    case yyyymmdd
    case mmdd
    case yyyyMMddHHmmssZ
    
}

extension Date {
    // 시작 날짜 포맷 변환
    func convertStartDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        return dateFormatter.string(from: self)
    }
    
    
    
    enum WeekNumberType {
        case currnetDate
        case finishDate
    }
    
    
    func calculateWeekNumber(finishDate: Date) -> Int {
        var currentWeekNum = 0
        
        var calendar = Calendar(identifier: .iso8601)
        calendar.firstWeekday = 2
        
        // 시작 2023-06-06
        var startYear = calendar.component(.year, from: self)
        let weekNumberForStartWeek = calendar.component(.weekOfYear, from: self)
        // 끝 2023-06-11
        let endYear = calendar.component(.year, from: finishDate)
        let weekNumberForEndWeek = calendar.component(.weekOfYear, from: finishDate)
        
        // 년도가 같은지 비교
        if startYear == endYear {
            // 같은 년도면 (현재 날짜 기준 주 - 시작 날짜 기준 주)
            currentWeekNum = weekNumberForEndWeek - weekNumberForStartWeek
        } else {
            // 시작 날짜 년도부터 현재 날짜 년도까지 차이
            let subtractYear = endYear - startYear

            // 1년 이상 차이날경우
            if subtractYear >= 1 {
                // 시작 년도부터 현재 년도까지 계산
                for i in 0...subtractYear {

                    // 이전 년도 마지막 날짜
                    let lastDayComponents = DateComponents(year: startYear, month: 12, day: 31, hour: 23, minute: 59, second: 59)
                    let lastDay = calendar.date(from: lastDayComponents)!

                    // 12월 31일이 몇주차인지
                    let maxWeekOfYearNum = calendar.component(.weekOfYear, from: lastDay)

                    // 2021/05/10(0) 2022(1) 2023(2)
                    // 1. 2021/05/10 -> 19주 (52주에서 19주 빼기)
                    // 2. 2022/12/31 -> 52주 (52주 전체 더하기)
                    // 3. 2023/07/12 -> 28주 (28주 더하기
                    
                    // 1번인 경우
                    if i == 0 {
                        currentWeekNum += maxWeekOfYearNum - weekNumberForStartWeek
                    } else if i == subtractYear { // 3번인 경우
                        currentWeekNum += weekNumberForEndWeek
                    } else { // 2번인 경우
                        currentWeekNum += maxWeekOfYearNum
                    }
                    startYear += 1
                }
            }
        }
        return currentWeekNum
    }
    
    // 현재 날짜에서 선택한 마감 요일의 날짜를 구하는 메소드
    func calcCurrentFinishDate(setDay: Int) -> Date? {
        // 현재 주차에서 마감일이 몇일인지 확인
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        calendar.locale = Locale(identifier: "ko_kr")

        // 무슨 요일인지 (월:2 화:3 수:4 목:5 금:6 토:7 일:1)
        let nowDay = calendar.dateComponents([.weekday], from: self)
        var calcDay = Date()

        switch setDay {
        case 101:
            //월 2
            let day = (2 + 7 - nowDay.weekday!) % 7
            calcDay = calendar.date(byAdding: .day, value: day, to: self) ?? Date()
        case 102:
            //화 3
            let day = (3 + 7 - nowDay.weekday!) % 7
            calcDay = calendar.date(byAdding: .day, value: day, to: self) ?? Date()
        case 103:
            //수 4
            let day = (4 + 7 - nowDay.weekday!) % 7
            calcDay = calendar.date(byAdding: .day, value: day, to: self) ?? Date()
        case 104:
            //목 5
            let day = (5 + 7 - nowDay.weekday!) % 7
            calcDay = calendar.date(byAdding: .day, value: day, to: self) ?? Date()
        case 105:
            //금 6
            let day = (6 + 7 - nowDay.weekday!) % 7
            calcDay = calendar.date(byAdding: .day, value: day, to: self) ?? Date()
        case 106:
            //토 7
            let day = (7 + 7 - nowDay.weekday!) % 7
            calcDay = calendar.date(byAdding: .day, value: day, to: self) ?? Date()
        case 107:
            //일 1
            let day = (1 + 7 - nowDay.weekday!) % 7
            calcDay = calendar.date(byAdding: .day, value: day, to: self) ?? Date()
        default:
            calcDay = Date()
        }
        
        let year = calendar.dateComponents([.year], from: calcDay).year
        let month = calendar.dateComponents([.month], from: calcDay).month
        let day = calendar.dateComponents([.day], from: calcDay).day

        let components = DateComponents(year: year, month: month, day: day, hour: 23, minute: 59, second: 59)

        let resultDay = calendar.date(from: components)

        return resultDay
    }
    
    enum FinishDateType {
        case nextWeek
        case currentWeek
    }
    
    // 현재 주에서 마감 날짜 구하기 / 한주 뒤에서 마감날짜 구하기
    func getFinishDate(finishDayNum: Int, type: FinishDateType) -> Date? {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        
        var date = self
        
        if type == .nextWeek {
            date = calendar.date(byAdding: .weekOfYear, value: 1, to: self)!
        }
      
        // 월 ~ 일 구하기
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        let startOfWeek = calendar.date(from: components)!
        var resultFinishDate = Date()
        
        switch finishDayNum {
        case 101:
            resultFinishDate = startOfWeek
        case 102:
            resultFinishDate = calendar.date(byAdding: .day, value: 1, to: startOfWeek)!
        case 103:
            resultFinishDate = calendar.date(byAdding: .day, value: 2, to: startOfWeek)!
        case 104:
            resultFinishDate = calendar.date(byAdding: .day, value: 3, to: startOfWeek)!
        case 105:
            resultFinishDate = calendar.date(byAdding: .day, value: 4, to: startOfWeek)!
        case 106:
            resultFinishDate = calendar.date(byAdding: .day, value: 5, to: startOfWeek)!
        case 107:
            resultFinishDate = calendar.date(byAdding: .day, value: 6, to: startOfWeek)!
        default:
            print("")
        }
    
        let year = calendar.dateComponents([.year], from: resultFinishDate).year
        let month = calendar.dateComponents([.month], from: resultFinishDate).month
        let day = calendar.dateComponents([.day], from: resultFinishDate).day

        let resultComponents = DateComponents(year: year, month: month, day: day, hour: 23, minute: 59, second: 59)
        
        return calendar.date(from: resultComponents)
    }
    
    // 마감일을 기준으로 시작날짜와 마감 날짜를 구하는 메소드
    // 토 ~ 토, 월 ~ 월, 수 ~ 수
    func getStartDateAndEndDate() -> (Date, Date, Date) {

        var calendar = Calendar.current
        calendar.firstWeekday = 2

        let endDate = self
        let startDate = calendar.date(byAdding: .day, value: -7, to: endDate)!
        let subtractOneSecond = calendar.date(byAdding: .second, value: -1, to: endDate)!
    
        return (startDate, endDate, subtractOneSecond)
    }
    
    // 해당 날짜를 기준으로 한주의 월요일과 일요일을 구하는 메소드
    func getMondayAndSunDay() -> (Date, Date) {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        
        let lastContentDate = self
        
        var mondayComponent = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: lastContentDate)
        mondayComponent.weekday = 2 // 2는 월요일
   
        // 00:00:00초로 바꿔야함
        let monday = calendar.date(from: mondayComponent)!
        mondayComponent = calendar.dateComponents([.year, .month, .day], from: monday)
        let changeMondayTime = DateComponents(year: mondayComponent.year, month: mondayComponent.month, day: mondayComponent.day, hour: 00, minute: 00, second: 00)
        let resultMonday = calendar.date(from: changeMondayTime)!
        
        // 23:59:59초로 바꿔야함
        let sunday = calendar.date(byAdding: .day, value: 6, to: monday)!
        let sundayComponent = calendar.dateComponents([.year, .month, .day], from: sunday)
        let changeSundayTime = DateComponents(year: sundayComponent.year, month: sundayComponent.month, day: sundayComponent.day, hour: 23, minute: 59, second: 59)
        let resultSunday = calendar.date(from: changeSundayTime)!
    
        return (monday: resultMonday, sunday: resultSunday)
    }
    
//    // 마감 날짜 계산하기
//    // 현재 주차에서 마감일 계산
//    func calculateDeadline(endDay: Int) -> Date {
//        var calendar = Calendar(identifier: .iso8601)
//        calendar.firstWeekday = 2 //Monday
//        calendar.locale = Locale(identifier: "ko_kr")
//
//        // 무슨 요일인지
//        let now = calendar.dateComponents([.weekday], from: self)
//
//        var resultDay = Date()
//
//        switch endDay {
//        case 101:
//            //월 2
//            let day = (2 + 7 - now.weekday!) % 7
//            resultDay = calendar.date(byAdding: .day, value: day, to: self)!
//        case 102:
//            //화 3
//            let day = (3 + 7 - now.weekday!) % 7
//            resultDay = calendar.date(byAdding: .day, value: day, to: self)!
//        case 103:
//            //수 4
//            let day = (4 + 7 - now.weekday!) % 7
//            resultDay = calendar.date(byAdding: .day, value: day, to: self)!
//        case 104:
//            //목 5
//            let day = (5 + 7 - now.weekday!) % 7
//            resultDay = calendar.date(byAdding: .day, value: day, to: self)!
//        case 105:
//            //금 6
//            let day = (6 + 7 - now.weekday!) % 7
//            resultDay = calendar.date(byAdding: .day, value: day, to: self)!
//        case 106:
//            //토 7
//            let day = (7 + 7 - now.weekday!) % 7
//            resultDay = calendar.date(byAdding: .day, value: day, to: self)!
//        case 107:
//            //일 1
//            let day = (1 + 7 - now.weekday!) % 7
//            resultDay = calendar.date(byAdding: .day, value: day, to: self)!
//        default:
//            return Date()
//        }
//
//        let year = calendar.dateComponents([.year], from: resultDay).year
//        let month = calendar.dateComponents([.month], from: resultDay).month
//        let day = calendar.dateComponents([.day], from: resultDay).day
//
//        let resultComponents = DateComponents(year: year, month: month, day: day, hour: 23, minute: 59, second: 59)
//
//        return calendar.date(from: resultComponents)!
//    }
    
    // xxxx년 xx월의 x주 인지 구하는 메소드
    func getWeekOfMonth() -> String {
        
        var calendar = Calendar.current
        calendar.firstWeekday = 2 //Monday
        
        let year = calendar.component(.year, from: self)
        let month = calendar.component(.month, from: self)
        let weekOfYear = calendar.component(.weekOfMonth, from: self)
        
        return "\(year)년 \(month)월 \(weekOfYear)주"
    }
    
    
    /// 마감 날짜를 "\(month)-\(day) \(hour):\(minute):\(second)까지"로 변환하는 메소드 입니다.
    /// - Returns: 마감 날짜
    func convertFinishDate() -> String {
        
        var calendar = Calendar.current
        calendar.firstWeekday = 2 //Monday
        
        let month = calendar.component(.month, from: self)
        let day = calendar.component(.day, from: self)
        let hour = calendar.component(.hour, from: self)
        let minute = calendar.component(.minute, from: self)
        let second = calendar.component(.second, from: self)
        
        return "\(month)-\(day) \(hour):\(minute):\(second)까지"
    }
}
