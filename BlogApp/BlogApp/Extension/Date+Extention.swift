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

enum CompareDateType {
    case startDate
    case deadlineDate
    
    enum CompareResult {
        case pastStartDate
        case pastDeadlineDate
        case futureStartDate
        case futureDeadlineDate
        case sameStartDate
        case sameDeadlineDate
    }
}

extension Date {
    func toString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YY년 MM월 dd일"
        
        return dateFormatter.string(from: self)
    }
    
//    // 한국 날짜로 변환
//    func convertToKoreaDate() -> Date? {
//        if let koreaTimeZone = TimeZone(identifier: "Asia/Seoul") {
//            let koreaDate = self.addingTimeInterval(TimeInterval(koreaTimeZone.secondsFromGMT()))
//            return koreaDate
//        }
//        return nil
//    }
//    
//    // UTC 날짜로 변환
//    func convertToUTCDate() -> Date? {
//        if let koreaTimeZone = TimeZone(identifier: "Asia/Seoul") {
//            let utcDate = self.addingTimeInterval(-TimeInterval(koreaTimeZone.secondsFromGMT()))
//            return utcDate
//        }
//        return nil
//    }
    
    
    // 마감 날짜에 1초를 더해서 시작 날짜 생성
    func convertDeadlineToStartDate() -> Date? {
        var calendar = Calendar(identifier: .iso8601)
        calendar.firstWeekday = 2
        
        return calendar.date(byAdding: .second, value: 1, to: self)
    }
    
    // 00:00:00으로 시작 날짜 생성
    func makeStartDate() -> Date? {
        var calendar = Calendar(identifier: .iso8601)
        calendar.firstWeekday = 2
        
        let date = calendar.dateComponents([.year, .month, .day], from: self)
        let components = DateComponents(year: date.year ,month: date.month, day: date.day ,hour: 0,minute: 0,second: 0)
        return calendar.date(from: components)
    }
    
    // 23:59:59로 마감 날짜 생성
    func makeDeadlineDate() -> Date? {
        var calendar = Calendar(identifier: .iso8601)
        calendar.firstWeekday = 2
        
        let date = calendar.dateComponents([.year, .month, .day], from: self)
        let components = DateComponents(year: date.year ,month: date.month, day: date.day ,hour: 23,minute: 59,second: 59)
        return calendar.date(from: components)
    }
    
    
    /// 날짜를 기준으로 시작 날짜와 마감 날짜를 구하는 메소드 입니다.
    /// 마감 날짜가 월요일이라면 [월 ~ 월], [수 ~ 수], [토 ~ 토]
    /// - Returns: 시작 날짜와 마감 날짜
    func getStartDateAndDeadlineDate() -> (startDate: Date?, deadlineDate: Date?) {
        var calendar = Calendar(identifier: .iso8601)
        calendar.firstWeekday = 2
        
        let finishDate = self
        var startDate = calendar.date(byAdding: .day, value: -7, to: finishDate)
        startDate = calendar.date(byAdding: .second, value: 1, to: startDate ?? Date())
        
        return (startDate, finishDate)
    }
    
    func getDayOfCurrentDate() -> Int {
        var calendar = Calendar(identifier: .iso8601)
        calendar.firstWeekday = 2
        
        // 2월 3화 4수 5목 6금 7토 1일
        let day = calendar.dateComponents([.weekday], from: self)
        return day.weekday ?? 0
    }
    
   
    /*
     공지사항에 시작 날짜가 없을때
     - 마감 날짜 / 현재 날짜
     
     공지사항에 시작 날짜가 있을때
     
     # 시작 날짜
     - 마지막 공지사항 마감 날짜 / 마감 날짜 / 현재 날짜
     
     # 마감 날짜
     - 시작 날짜 / 현재 날짜
     */
    
    
    
        
    // 날짜 비교
    //func dateCompare(fromDate: Date?, editType: EditDateType, compareType: EditDateType.CompareType)
    func dateCompare(fromDate: Date?, editType: CompareDateType) -> CompareDateType.CompareResult {
       
        var calendar = Calendar(identifier: .iso8601)
        calendar.firstWeekday = 2
        
        // 선택한 날짜
        let targetDateComponents = calendar.dateComponents([.year, .month, .day], from: self)
        
        // 비교할 날짜 (현재 날짜 또는 마지막 공지사항 날짜)
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
        
    
//        switch result {
//        case .orderedAscending: // 과거
//            switch editType {
//            case .startDate:
//                switch compareType {
//                case .startDate:
//                    return .pastLastContentDeadlineDate // "마지막 마감일보다 과거"
//                case .deadlineDate:
//                    return .pastDeadlineDate // "마감일보다 과거"
//                default:
//                    return .none
//                }
//            case .deadlineDate:
//                switch compareType {
//                case .startDate:
//                    return .pastLastContentDeadlineDate // "마지막 마감일보다 과거"
//                case .deadlineDate:
//                    return .pastToday // "오늘보다 과거"
//                default:
//                    return .none
//                }
//            }
//        case .orderedDescending: // 미래
//            switch editType {
//            case .startDate:
//                switch compareType {
//                case .startDate:
//                    return .futureLastContentDeadlineDate // "마지막 마감일보다 미래"
//                case .deadlineDate:
//                    return .futureDeadlineDate // "마감일보다 미래"
//                default:
//                    return .none
//                }
//            case .deadlineDate:
//                switch compareType {
//                case .startDate:
//                    return .futureLastContentDeadlineDate // "마지막 마감일보다 미래"
//                case .deadlineDate:
//                    return .futureToday // "오늘보다 미래"
//                default:
//                    return .none
//                }
//            }
//        case .orderedSame: // 현재
//            switch editType {
//            case .startDate:
//                switch compareType {
//                case .startDate:
//                    return .sameLastContentDeadlineDate // "마지막 마감일과 같음"
//                case .deadlineDate:
//                    return .sameDeadlineDate // "마감일과 같음"
//                default:
//                    return .none
//                }
//            case .deadlineDate:
//                switch compareType {
//                case .startDate:
//                    return .sameLastContentDeadlineDate // "마지막 마감일과 같음"
//                case .deadlineDate:
//                    return .sameToday // "오늘과 같음"
//                default:
//                    return .none
//                }
//            }
//        }
    }
    
    
    /// 기준이 되는 날짜에서 마감일을 구하는 메소드 입니다.
    /// 기준이 되는 날짜가 마감하려고 하는 날짜와 같다면 현재 날짜 또는 일주일뒤 날짜로 선택하도록 합니다.
    /// 바텀시트 뷰컨트롤러에서만 적용(날짜 선택이 가능함)
    ///
    /// - Parameter deadlineDay: <#deadlineDay description#>
    /// - Returns: <#description#>
    func calculateFinishDate(deadlineDay: Int) -> (currentDate: Date?, nextWeekFinishDate: Date?) {

        var calendar = Calendar(identifier: .iso8601)
        calendar.firstWeekday = 2
        //calendar.locale = Locale(identifier: "ko_kr")
        
        let nowDay = calendar.dateComponents([.weekday], from: self).weekday ?? 0
   
        var currentDate: Date?
        var nextWeekFinishDate: Date?
        
        // 다음주 마감날짜 구하기
        if nowDay != deadlineDay {
            let calcDay = (deadlineDay + 7 - nowDay) % 7
            currentDate = calendar.date(byAdding: .day, value: calcDay, to: self) ?? Date()
            let year = calendar.dateComponents([.year], from: currentDate ?? Date()).year
            let month = calendar.dateComponents([.month], from: currentDate ?? Date()).month
            let day = calendar.dateComponents([.day], from: currentDate ?? Date()).day

            let components = DateComponents(year: year, month: month, day: day, hour: 23, minute: 59, second: 59)
            currentDate = calendar.date(from: components)
            
            return (currentDate, nil)
        } else {
            let calcDay = (deadlineDay + 7 - nowDay) % 7
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

            let nextDateComponents = DateComponents(year: nextDateYear, month: nextDateMonth, day: nextDateDay, hour: 23, minute: 59, second: 59)
            
            nextWeekFinishDate = calendar.date(from: nextDateComponents)
            
            return (currentDate, nextWeekFinishDate)
        }
    }
    
//    func calculateNewContentDeadlineDate(studyDeadlineDay: Int) -> Date? {
//
//        var calendar = Calendar(identifier: .iso8601)
//        calendar.firstWeekday = 2
//
//        // self -> 마감일에 1초를 더한 날짜
//        let nextStartDate = self.convertDeadlineToStartDate()
//
//        // 마감일을 기준으로 다음 마감 날짜 구하기
//        // 마감날짜에 +1초한 날짜를 기준으로 다음 마감 날짜를 구해야하는데
//        let nowDay = calendar.dateComponents([.weekday], from: nextStartDate!).weekday ?? 0
//        let calcDay = (studyDeadlineDay + 7 - nowDay) % 7
//
//        var deadlineDate = calendar.date(byAdding: .day, value: calcDay, to: nextStartDate!) ?? Date()
//
//        let year = calendar.dateComponents([.year], from: deadlineDate).year
//        let month = calendar.dateComponents([.month], from: deadlineDate).month
//        let day = calendar.dateComponents([.day], from: deadlineDate).day
//
//        let components = DateComponents(year: year, month: month, day: day, hour: 23, minute: 59, second: 59)
//        deadlineDate = calendar.date(from: components)!
//
//        print("nowDay", nowDay)
//        print("calcDay", calcDay)
//        print("currentDate", deadlineDate)
//
//        return deadlineDate
//    }
    
    func calculateNewContentFinishDate(deadlineDay: Int) -> Date? {
        // 마감 날짜를 기준으로 다음주를 구함
        var calendar = Calendar(identifier: .iso8601)
        calendar.firstWeekday = 2
        
        // 마감일을 기준으로 마감 날짜 구하기
        // self는 선택한 마감일
        var finishDate = self.getFinishDate(finishDayNum: deadlineDay, type: .currentWeek) ?? Date()

        print(self)
        print(finishDate)
        
        // 날짜 비교
        let result: ComparisonResult = finishDate.compare(self)
    
        switch result {
        case .orderedAscending: // 과거
            print("orderedAscending")
            finishDate = calendar.date(byAdding: .weekOfYear, value: 1, to: self) ?? Date()
            
            print(finishDate.getFinishDate(finishDayNum: deadlineDay, type: .currentWeek))
            return finishDate.getFinishDate(finishDayNum: deadlineDay, type: .currentWeek)
            
        case .orderedDescending: // 미래
            print("orderedDescending")
            print(finishDate)
            return finishDate
            
        case .orderedSame: // 현재
            print("orderedSame")
            // 같은 날짜일 경우
            finishDate = calendar.date(byAdding: .weekOfYear, value: 1, to: self) ?? Date()
            
            print(finishDate.getFinishDate(finishDayNum: deadlineDay, type: .currentWeek))
            return finishDate.getFinishDate(finishDayNum: deadlineDay, type: .currentWeek)
        }
    }
    
    // 해당 날짜를 기준으로 한주의 월요일과 일요일을 구하는 메소드
    func getMondayAndSunDay() -> (Date,Date) {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        
        let now = self
        
        var mondayComponent = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
        mondayComponent.weekday = 2 // 2는 월요일
   
        let monday = calendar.date(from: mondayComponent)!
        mondayComponent = calendar.dateComponents([.year, .month, .day], from: monday)
        let changeMondayTime = DateComponents(year: mondayComponent.year, month: mondayComponent.month, day: mondayComponent.day)
        let resultMonday = calendar.date(from: changeMondayTime)!
 
        let sunday = calendar.date(byAdding: .day, value: 6, to: monday)!
        let sundayComponent = calendar.dateComponents([.year, .month, .day], from: sunday)
        let changeSundayTime = DateComponents(year: sundayComponent.year, month: sundayComponent.month, day: sundayComponent.day)
        let resultSunday = calendar.date(from: changeSundayTime)!
    
        return (monday: resultMonday, sunday: resultSunday)
    }
    

    
    enum FinishDateType {
        case nextWeek
        case currentWeek
    }

//    // 현재 주에서 마감 날짜 구하기 / 한주 뒤에서 마감날짜 구하기
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
        case 2:
            resultFinishDate = startOfWeek
        case 3:
            resultFinishDate = calendar.date(byAdding: .day, value: 1, to: startOfWeek)!
        case 4:
            resultFinishDate = calendar.date(byAdding: .day, value: 2, to: startOfWeek)!
        case 5:
            resultFinishDate = calendar.date(byAdding: .day, value: 3, to: startOfWeek)!
        case 6:
            resultFinishDate = calendar.date(byAdding: .day, value: 4, to: startOfWeek)!
        case 7:
            resultFinishDate = calendar.date(byAdding: .day, value: 5, to: startOfWeek)!
        case 1:
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
    
    
    func makeContentDeadlineDate(finishDayNum: Int) -> Date? {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        
        var date = self
        
        // 월 ~ 일 구하기
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        let startOfWeek = calendar.date(from: components)!
        var resultFinishDate = Date()
        
        switch finishDayNum {
        case 2:
            resultFinishDate = startOfWeek
        case 3:
            resultFinishDate = calendar.date(byAdding: .day, value: 1, to: startOfWeek)!
        case 4:
            resultFinishDate = calendar.date(byAdding: .day, value: 2, to: startOfWeek)!
        case 5:
            resultFinishDate = calendar.date(byAdding: .day, value: 3, to: startOfWeek)!
        case 6:
            resultFinishDate = calendar.date(byAdding: .day, value: 4, to: startOfWeek)!
        case 7:
            resultFinishDate = calendar.date(byAdding: .day, value: 5, to: startOfWeek)!
        case 1:
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
    

    

}


//    // xxxx년 xx월의 x주 인지 구하는 메소드
//    func getWeekOfMonth() -> String {
//
//        var calendar = Calendar.current
//        calendar.firstWeekday = 2 //Monday
//
//        let year = calendar.component(.year, from: self)
//        let month = calendar.component(.month, from: self)
//        let weekOfYear = calendar.component(.weekOfMonth, from: self)
//
//        return "\(year)년 \(month)월 \(weekOfYear)주"
//    }
//
//
//    /// 마감 날짜를 "\(month)-\(day) \(hour):\(minute):\(second)까지"로 변환하는 메소드 입니다.
//    /// - Returns: 마감 날짜
//    func convertFinishDate() -> String {
//
//        var calendar = Calendar.current
//        calendar.firstWeekday = 2 //Monday
//
//        let month = calendar.component(.month, from: self)
//        let day = calendar.component(.day, from: self)
//        let hour = calendar.component(.hour, from: self)
//        let minute = calendar.component(.minute, from: self)
//        let second = calendar.component(.second, from: self)
//
//        return "\(month)-\(day) \(hour):\(minute):\(second)까지"
//    }
//    func calculateWeeksPassed() -> Int {
//        var currentWeekNum = 0
//
//        var calendar = Calendar(identifier: .iso8601)
//        calendar.firstWeekday = 2
//
//        // 시작 2023-06-06
//        var startYear = calendar.component(.year, from: self)
//        let weekNumberForStartWeek = calendar.component(.weekOfYear, from: self)
//        // 끝 2023-06-11
//        let endYear = calendar.component(.year, from: Date())
//        let weekNumberForEndWeek = calendar.component(.weekOfYear, from: Date())
//
//        // 년도가 같은지 비교
//        if startYear == endYear {
//            // 같은 년도면 (현재 날짜 기준 주 - 시작 날짜 기준 주)
//            currentWeekNum = weekNumberForEndWeek - weekNumberForStartWeek
//        } else {
//            // 시작 날짜 년도부터 현재 날짜 년도까지 차이
//            let subtractYear = endYear - startYear
//
//            // 1년 이상 차이날경우
//            if subtractYear >= 1 {
//                // 시작 년도부터 현재 년도까지 계산
//                for i in 0...subtractYear {
//
//                    // 이전 년도 마지막 날짜
//                    let lastDayComponents = DateComponents(year: startYear, month: 12, day: 31)
//                    let lastDay = calendar.date(from: lastDayComponents)!
//
//                    // 12월 31일이 몇주차인지
//                    let maxWeekOfYearNum = calendar.component(.weekOfYear, from: lastDay)
//
//                    // 2021/05/10(0) 2022(1) 2023(2)
//                    // 1. 2021/05/10 -> 19주 (52주에서 19주 빼기)
//                    // 2. 2022/12/31 -> 52주 (52주 전체 더하기)
//                    // 3. 2023/07/12 -> 28주 (28주 더하기
//
//                    // 1번인 경우
//                    if i == 0 {
//                        currentWeekNum += maxWeekOfYearNum - weekNumberForStartWeek
//                    } else if i == subtractYear { // 3번인 경우
//                        currentWeekNum += weekNumberForEndWeek
//                    } else { // 2번인 경우
//                        currentWeekNum += maxWeekOfYearNum
//                    }
//                    startYear += 1
//                }
//            }
//        }
//        return currentWeekNum
//    }


// 비교할 날짜를 기준으로 마감 요일의 날짜가 언제인지 구하는 메소드
//    func calculateCurrentWeekFinishDate(deadlineDay: Int) -> Date? {
//
//        // 현재 주차에서 마감일이 몇일인지 확인
//        var calendar = Calendar(identifier: .iso86∫01)
//        calendar.firstWeekday = 2
//        calendar.locale = Locale(identifier: "ko_kr")
//
//        // 현재 날짜가 무슨 요일인지 (월:2 화:3 수:4 목:5 금:6 토:7 일:1)
//        let nowDay = calendar.dateComponents([.weekday], from: self)
//
//        // 마감일이 현재 날짜랑 같을때 선택지 주기
//        // 오늘로할지 다음주로할지
//
//            if nowDay.weekday == deadlineDay {
//
//                let date = calendar.date(byAdding: .day, value: 7, to: self) ?? Date()
//
//                let year = calendar.dateComponents([.year], from: date).year
//                let month = calendar.dateComponents([.month], from: date).month
//                let day = calendar.dateComponents([.day], from: date).day
//
//                let components = DateComponents(year: year, month: month, day: day, hour: 23, minute: 59, second: 59)
//
//                print(calendar.date(from: components))
//
//                return calendar.date(from: components)
//            }
//
//
//        var resultFinishDate = Date()
//
//        switch deadlineDay {
//        case 2:
//            //월 2
//            let day = (2 + 7 - nowDay.weekday!) % 7
//            resultFinishDate = calendar.date(byAdding: .day, value: day, to: self) ?? Date()
//        case 3:
//            //화 3
//            let day = (3 + 7 - nowDay.weekday!) % 7
//            resultFinishDate = calendar.date(byAdding: .day, value: day, to: self) ?? Date()
//        case 4:
//            //수 4
//            let day = (4 + 7 - nowDay.weekday!) % 7
//            resultFinishDate = calendar.date(byAdding: .day, value: day, to: self) ?? Date()
//        case 5:
//            //목 5
//            let day = (5 + 7 - nowDay.weekday!) % 7
//            resultFinishDate = calendar.date(byAdding: .day, value: day, to: self) ?? Date()
//        case 6:
//            //금 6
//            let day = (6 + 7 - nowDay.weekday!) % 7
//            resultFinishDate = calendar.date(byAdding: .day, value: day, to: self) ?? Date()
//        case 7:
//            //토 7
//            let day = (7 + 7 - nowDay.weekday!) % 7
//            resultFinishDate = calendar.date(byAdding: .day, value: day, to: self) ?? Date()
//        case 1:
//            //일 1
//            let day = (1 + 7 - nowDay.weekday!) % 7
//            resultFinishDate = calendar.date(byAdding: .day, value: day, to: self) ?? Date()
//        default:
//            print("포함 X")
//        }
//
//        let year = calendar.dateComponents([.year], from: resultFinishDate).year
//        let month = calendar.dateComponents([.month], from: resultFinishDate).month
//        let day = calendar.dateComponents([.day], from: resultFinishDate).day
//
//        let components = DateComponents(year: year, month: month, day: day, hour: 23, minute: 59, second: 59)
//
//
//        print(calendar.date(from: components)!)
//
//        return calendar.date(from: components)
//    }





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

//    // 사용 안함
//    // XXXXX 현재 날짜에서 선택한 마감 요일의 날짜를 구하는 메소드
//    func calcCurrentFinishDate(setDay: Int) -> Date? {
//        // 현재 주차에서 마감일이 몇일인지 확인
//        var calendar = Calendar.current
//        calendar.firstWeekday = 2
//        calendar.locale = Locale(identifier: "ko_kr")
//
//        // 무슨 요일인지 (월:2 화:3 수:4 목:5 금:6 토:7 일:1)
//        let nowDay = calendar.dateComponents([.weekday], from: self)
//        var calcDay = Date()
//
//        switch setDay {
//        case 101:
//            //월 2
//            let day = (2 + 7 - nowDay.weekday!) % 7
//            calcDay = calendar.date(byAdding: .day, value: day, to: self) ?? Date()
//        case 102:
//            //화 3
//            let day = (3 + 7 - nowDay.weekday!) % 7
//            calcDay = calendar.date(byAdding: .day, value: day, to: self) ?? Date()
//        case 103:
//            //수 4
//            let day = (4 + 7 - nowDay.weekday!) % 7
//            calcDay = calendar.date(byAdding: .day, value: day, to: self) ?? Date()
//        case 104:
//            //목 5
//            let day = (5 + 7 - nowDay.weekday!) % 7
//            calcDay = calendar.date(byAdding: .day, value: day, to: self) ?? Date()
//        case 105:
//            //금 6
//            let day = (6 + 7 - nowDay.weekday!) % 7
//            calcDay = calendar.date(byAdding: .day, value: day, to: self) ?? Date()
//        case 106:
//            //토 7
//            let day = (7 + 7 - nowDay.weekday!) % 7
//            calcDay = calendar.date(byAdding: .day, value: day, to: self) ?? Date()
//        case 107:
//            //일 1
//            let day = (1 + 7 - nowDay.weekday!) % 7
//            calcDay = calendar.date(byAdding: .day, value: day, to: self) ?? Date()
//        default:
//            calcDay = Date()
//        }
//
//        let year = calendar.dateComponents([.year], from: calcDay).year
//        let month = calendar.dateComponents([.month], from: calcDay).month
//        let day = calendar.dateComponents([.day], from: calcDay).day
//
//        let components = DateComponents(year: year, month: month, day: day)
//
//        let resultDay = calendar.date(from: components)
//
//        return resultDay
//    }
