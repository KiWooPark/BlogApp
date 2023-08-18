//
//  StudyListViewModel.swift
//  BlogApp
//
//  Created by PKW on 2023/05/17.
//

import Foundation

class StudyListViewModel {
    
    // 스터디 데이터를 담을 배열
    var list: Observable<[Study]> = Observable([])
    
    // 스터디 데이터 배열의 카운트
    var listCount: Int {
        return list.value.count
    }
    
    // 코어데이터에 저장되어있는 스터디 데이터 가져오기
<<<<<<< HEAD
    func fetchStudys(completion: @escaping () -> ()) {
        list.value = CoreDataManager.shared.fetchStudyList()

        // 코어데이터 경로
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        print(paths)
        completion()
    }
    
    // 마지막 공지의 마감 날짜를 가지고옴
    func getLastContentDeadlineDate(studtEntity: Study?) -> Date {
        var result = Date()
        
        if let study = studtEntity,
           let lastContent = CoreDataManager.shared.fetchLastContent(studyEntity: study) {
            result = lastContent.deadlineDate ?? Date()
        }
        
        return result
    }
  
    /// 현재 날짜부터 마지막 공지사항의 마감일까지 몇일이 남았는지 계산하는 메소드 입니다. (D-Day)
    /// ---------------------------------------------
    /// - Parameter index: 스터디의 index 번호 입니다.
    /// - Returns: 계산된 D-Day가 리턴됩니다.
    func calculateDday(index: Int) -> Int? {
        
        var result: Int?
     
        // 마지막 공지사항의 마감 날짜
        if let lastContentDeadlineDate = CoreDataManager.shared.fetchLastContent(studyEntity: list.value[index])?.deadlineDate {
            
            // 날짜 차이를 구할때 켈린더 일로 변경하고 해야함
            // 변경하지 않으면 시간 차이로 계산되기때문
            let startOfDayForDate1 = Calendar.current.startOfDay(for: lastContentDeadlineDate)
            let startOfDayForDate2 = Calendar.current.startOfDay(for: Date())
            
            let daysDifference = Calendar.current.dateComponents([.day], from: startOfDayForDate2, to: startOfDayForDate1).day
            
            result = daysDifference
        }
        
        return result
    }
    
    
    /// 현재 스터디가 진행중인지 마감되었는지 체크하는 메소드 입니다.
    /// 마지막 공지사항을 기준으로 현재 날짜보다 과거이면 마감으로 반환되고
    /// 현재 날짜와 같거나 미래이면 진행중으로 반환됩니다.
    /// ---------------------------------------------
    /// - Parameter index: 스터디의 index 번호 입니다.
    /// - Returns: 진행중이면 true 마감되었으면 false가 리턴됩니다.
    func isDeadlinePassed(index: Int) -> Bool {

        if let lastContentDeadlineDate = CoreDataManager.shared.fetchLastContent(studyEntity: list.value[index])?.deadlineDate {
        
            let result = lastContentDeadlineDate.compare(Date())
            
            switch result {
            case .orderedAscending: // 과거
                return true
            case .orderedDescending, .orderedSame: // 미래, 현재
                return false
            }
        }

        return false
=======
    func fetchStudys() {
        list.value = CoreDataManager.shared.fetchStudys()
        
        // 코어데이터 경로
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        print(paths)
    }
    
    // 기존 list에 스터디 데이터 추가
    func addStudy(_ study: Study?, completion: @escaping () -> ()) {
        // 전달받은 데이터 list 배열에 추가
        list.value.append(study!)
        // 코어데이터에 study 데이터 저장
        
        //CoreDataManager.shared.saveContext()
        completion()
    }
    
    func updateList(study: Study?) {
        if let index = list.value.firstIndex(where: {$0.id == study?.id}), let study = study {
            list.value[index] = study
        }
    }
    
    func deleteStudy(study: Study?, completion: @escaping () -> ()) {
        if let index = list.value.firstIndex(where: {$0.id == study?.id}), let study = study {
            list.value.remove(at: index)
            CoreDataManager.shared.deleteStudy(study: study)
            
            completion()
        }
>>>>>>> main
    }
}



