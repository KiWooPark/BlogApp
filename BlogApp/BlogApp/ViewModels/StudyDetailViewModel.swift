//
//  AddStudyViewModel.swift
//  BlogApp
//
//  Created by PKW on 2023/05/17.
//

import Foundation

// MARK:  ===== [Class or Struct] =====

/// 스터디 상세화면을 관리하는 ViewModel 입니다.
class StudyDetailViewModel {
    
    // 스터디 Entitiy를 나타내는 변수
    var study: Observable<Study?> = Observable(nil)
    
    // 스터디 정보에 저장된 멤버 배열을 나타내는 변수
    var members: [User] = []
    
    // 스터디 정보에 저장된 마감 배열을 나타내는 변수
    var contentList = [Content]()
    
    // 마지막 마감 정보를 나타내는 변수
    var lastContent: Content?
    
    // MARK:  ===== [Init] =====
     
    // Study 객체를 사용하여 StudyDetailViewModel을 초기화 합니다.
    init(studyData: Study) {
        self.study.value = studyData
        
        // 스터디 정보에 저장된 멤버 목록을 가져옵니다.
        self.members = CoreDataManager.shared.fetchStudyMembers(studyEntity: studyData)
        
        // 마감 정보 목록을 가져옵니다.
        self.contentList = CoreDataManager.shared.fetchContentList(studyEntity: studyData)
        
        // 마감 정보 목록에서 마지막 마감정보를 나타내는 변수
        self.lastContent = self.contentList.last
    }
    
    // 메모리 해제를 확인합니다.
    deinit {
        print("StudyDetailViewModel - 메모리 해제")
    }
    
    // MARK:  ===== [Function] =====
    
    /// 스터디 정보를 가져옵니다.
    ///
    /// `Study` 객체의 ID로 스터디 정보를 가져온 뒤 contentList, lastContent, members 프로퍼티를 초기화 합니다.
    func fetchStudyData() {
        if let id = self.study.value?.objectID {
            self.study.value = CoreDataManager.shared.fetchStudy(id: id)
            
            if let studyEntity = self.study.value {
                self.contentList = CoreDataManager.shared.fetchContentList(studyEntity: studyEntity)
                self.lastContent = self.contentList.last
                
                self.members = CoreDataManager.shared.fetchStudyMembers(studyEntity: studyEntity)
            }
        }
    }
    
    /// 현재 스터디가 진행중인지 마감되었는지 확인합니다.
    ///
    /// 마지막 마감 정보의 마감 날짜를 기준으로 현재날짜와 비교합니다.
    ///
    /// - Returns: 마감 날짜가 현재 날짜보다 과거이면 `true`, 미래거나 현재이면 `false`가 반환됩니다.
    func isDeadlinePassed() -> Bool {
        
        // 마지막 마감 정보
        if let lastContent = self.lastContent {
            
            // 마감 날짜와 현재 날짜 비교
            let result = lastContent.deadlineDate?.compare(Date())
            
            switch result {
            case .orderedAscending: // 과거
                return true
            case .orderedDescending, .orderedSame: // 미래
                return false
            case .none:
                return false
            }
        }
        
        return false
    }
    
    /// 마지막 마감 정보의 마감 날짜부터 현재까지 몇일이 남았는지 계산합니다.
    ///
    /// 캘린더 일로 변환되어 계산됩니다.  캘린더 일로 변경하지 않으면 시간으로 차이가 발생하기 때문에 날짜 차이로 계산되지 않고 시간 차이로 계산 됩니다.
    ///
    /// - Returns: 계산된 D-Day를 반환합니다. 계산에 실패할 경우 nil이 반환 됩니다.
    func calculateDday() -> Int? {
        
        var result: Int?
        
        // 마지막 마감 정도의 마감 날짜
        if let lastContentDeadlineDate = lastContent?.deadlineDate {
            
            // 마지막 마감 정보의 마감날짜와 현재 날짜를 캘린더 일로 변환 합니다.
            let startOfDayForDate1 = Calendar.current.startOfDay(for: lastContentDeadlineDate)
            let startOfDayForDate2 = Calendar.current.startOfDay(for: Date())
            
            let daysDifference = Calendar.current.dateComponents([.day], from: startOfDayForDate2, to: startOfDayForDate1).day
            
            result = daysDifference
        }
        
        return result
    }
}
