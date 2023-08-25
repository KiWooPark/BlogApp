//
//  StudyListViewModel.swift
//  BlogApp
//
//  Created by PKW on 2023/05/17.
//

import Foundation

// MARK:  ===== [Class or Struct] =====

/// 스터디 목록을 관리하는 ViewModel 클래스 입니다.
class StudyListViewModel {
    
    // MARK:  ===== [Property] =====
    
    // 스터디 정보를 담을 배열을 나타내는 변수
    var list: Observable<[Study]> = Observable([])
    
    // 스터디 데이터 배열의 카운트를 나타내는 변수
    var listCount: Int {
        return list.value.count
    }
        
    // MARK:  ===== [Function] =====
    
    /// CoreData에 저장되어 있는 스터디 정보를 가져옵니다.
    ///
    /// - Parameter completion: 모든 스터디 정보를 가지고 온 후 호출할 콜백 함수입니다.
    func fetchStudys(completion: @escaping () -> ()) {
        list.value = CoreDataManager.shared.fetchStudyList()

        // 코어데이터 경로
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        print(paths)
        
        completion()
    }
    
    /// 마지막 마감 정보의 마감 날짜를 가지고 옵니다.
    ///
    /// - Parameter studtEntity: 마감 날짜를 확인할 `Study` 객체
    /// - Returns: 마감 날짜를 반환합니다. 마지막 마감 정보가 없거나 `studtEntity`가 nil인 경우 현재 날짜를 반환 합니다.
    func getLastContentDeadlineDate(studtEntity: Study?) -> Date {
        var result = Date()
        
        if let study = studtEntity,
           let lastContent = CoreDataManager.shared.fetchLastContent(studyEntity: study) {
            result = lastContent.deadlineDate ?? Date()
        }
        
        return result
    }
  
    /// 마지막 마감 정보의 마감 날짜부터 현재까지 몇일이 남았는지 계산합니다.
    ///
    /// 캘린더 일로 변환되어 계산됩니다.  캘린더 일로 변경하지 않으면 시간으로 차이가 발생하기 때문에 날짜 차이로 계산되지 않고 시간 차이로 계산 됩니다.
    ///
    /// - Parameter index: 스터디 인덱스 번호
    /// - Returns: 계산된 D-Day를 반환합니다. 계산에 실패할 경우 nil이 반환 됩니다.
    func calculateDday(index: Int) -> Int? {
        
        var result: Int?
     
        // 마지막 마감 정도의 마감 날짜
        if let lastContentDeadlineDate = CoreDataManager.shared.fetchLastContent(studyEntity: list.value[index])?.deadlineDate {
            
            // 마지막 마감 정보의 마감날짜와 현재 날짜를 캘린더 일로 변환 합니다.
            let startOfDayForDate1 = Calendar.current.startOfDay(for: lastContentDeadlineDate)
            let startOfDayForDate2 = Calendar.current.startOfDay(for: Date())
            
            let daysDifference = Calendar.current.dateComponents([.day], from: startOfDayForDate2, to: startOfDayForDate1).day
            
            result = daysDifference
        }
        
        return result
    }
    
    /// 현재 스터디가 진행중인지 마감되었는지 확인합니다.
    ///
    /// 마지막 마감 정보의 마감 날짜를 기준으로 현재날짜와 비교합니다.
    ///
    /// - Parameter index: 스터디 인덱스 번호
    /// - Returns: 마감 날짜가 현재 날짜보다 과거이면 `true`, 미래거나 현재이면 `false`가 반환됩니다.
    func isDeadlinePassed(index: Int) -> Bool {

        // 마지막 마감 정보의 마감 날짜
        if let lastContentDeadlineDate = CoreDataManager.shared.fetchLastContent(studyEntity: list.value[index])?.deadlineDate {
        
            // 마감 날짜와 현재 날짜 비교
            let result = lastContentDeadlineDate.compare(Date())
            
            switch result {
            case .orderedAscending: // 과거
                return true
            case .orderedDescending, .orderedSame: // 미래, 현재
                return false
            }
        }
        return false
    }
}



