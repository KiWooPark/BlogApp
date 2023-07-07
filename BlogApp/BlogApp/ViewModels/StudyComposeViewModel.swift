//
//  StucyComposeViewModel.swift
//  BlogApp
//
//  Created by PKW on 2023/06/02.
//

import Foundation

enum StudyProperty {
    case title
    case announcement
    case startDate
    case setDay
    case fine
    case members
}

class StudyComposeViewModel {

    // 제목
    var title: Observable<String?> = Observable(nil)
    // 공지사항
    var announcement: Observable<String?> = Observable(nil)
    // 시작 날짜
    var startDate: Observable<Date?> = Observable(nil)
    // 설정 요일
    var finishDay: Observable<Int?> = Observable(nil)
    // 벌금
    var fine: Observable<Int?> = Observable(nil)
    // 코어데이터에 저장된 멤버
    var coreDataMembers: Observable<[User]> = Observable([])
    
    
    // 셀에 보여줄 멤버
    //var members: Observable<[UserModel]> = Observable([])
    // 수정할 유저 정보
    //var editMemberInfo: User?
    // 기존 스터디인지 신규 스터디인지
    var isNewStudy: Observable<Bool> = Observable(true)
    
    /*
     로직
     1. 코어데이터에 있는 멤버 데이터 가져옴
     2. members 배열에 UserModel 구조로 새로 저장
     3. members 배열에 있는 데이터로 셀에 보여줌
     */
    
    init(studyData: Study?) {
        if let studyData = studyData {
            self.title.value = studyData.title
            self.announcement.value = studyData.announcement
            self.startDate.value = studyData.startDate
            self.finishDay.value = Int(studyData.finishDay)
            self.fine.value = Int(studyData.fine)
            self.coreDataMembers.value = CoreDataManager.shared.fetchCoreDataMembers(study: studyData)
        }
    }
    
    // 새로운 Study 생성
    func createStudy(completion: @escaping() -> ()) {
        
        CoreDataManager.shared.createStudy(title: self.title.value ?? "",
                                           announcement: self.announcement.value ?? "",
                                           startDate: self.startDate.value ?? Date(),
                                           finishDay: self.finishDay.value ?? 0,
                                           fine: self.fine.value ?? 0,
                                           members: self.coreDataMembers.value,
                                           isNewStudy: self.isNewStudy.value) {
            completion()
        }
    }
    
    // Study Entity에 저장된 멤버 데이터 가지고와서 셀에 보여줄수 있도록 UserModel로 변경
    func fetchMembers() {
//        self.members.value.removeAll()
//
//        coreDataMembers.value.forEach { member in
//            let user = UserModel(name: member.name, blogUrl: member.blogUrl, fine: Int(member.fine))
//            members.value.append(user)
//        }
    }
    
    //MARK: U
    func updateStudyProperty(_ property: StudyProperty, value: Any, isEditMember: Bool = false) {
        switch property {
        case .title:
            self.title.value = value as? String
        case .announcement:
            self.announcement.value = value as? String
        case .startDate:
            self.startDate.value = value as? Date
        case .setDay:
            self.finishDay.value = value as? Int
        case .fine:
            self.fine.value = value as? Int
        case .members:
            
            if isEditMember {
                // 수정
                if let value = value as? (Int, String, String, Int) {
                    let target = self.coreDataMembers.value[value.0]
                    target.name = value.1
                    target.blogUrl = value.2
                    target.fine = Int64(value.3)
                    
                    self.coreDataMembers.value[value.0] = target
                }
            } else {
                // 추가
                if let value = value as? (String, String, Int) {
                    let newMember = User(context: CoreDataManager.shared.persistentContainer.viewContext)
                    newMember.name = value.0
                    newMember.blogUrl = value.1
                    newMember.fine = Int64(value.2)
                    
                    self.coreDataMembers.value.append(newMember)
                    
                }
            }
        }
    }

    // 마지막 공지사항이 있는지 확인하고
    // 있으면 변경사항 study, content 둘다 변경
    // 멤버 수정 잘해야댐
    func updateDetailStudyData(detailViewModel: StudyDetailViewModel, completion: @escaping () -> ()) {
        // study
        // 타이틀, 공지사항, 시작날짜, 요일, 벌금, 멤버
        let target = detailViewModel.study.value
        target?.title = title.value
        target?.announcement = announcement.value
        target?.startDate = startDate.value
        target?.finishDay = Int64(finishDay.value ?? 0)
        target?.fine = Int64(fine.value ?? 0)
        
        // 추가된 멤버 study 연결
        coreDataMembers.value.forEach { member in
            if member.study == nil {
                target?.addToMembers(member)
            }
        }
    
        target?.memberCount = Int64(coreDataMembers.value.count)
        
        var lastContent = CoreDataManager.shared.fetchLastContent(studyEntity: target!)
        
        let lastContentFinishDate = lastContent?.finishDate
        
        // 마감 요일 변경했을때
        // 현재 요일이 수요일이면
        // 월 화 -> 마감 기간 지난 상태
        // 수 목 금 토 일 월 -> 마감 기간 지나지 않은 상태
        let finishDate = Date().calcCurrentFinishDate(setDay: finishDay.value ?? 0)!
        
        // finishDate가 현재 주차인지 아니면 한주가 지난 상태인지 체크
        // 0이면 현재 주차, 1이면 한주가 지난 주차
        if Date().calculateWeekNumber(finishDate: finishDate) == 0 {
            print("다음주 공지 없어야함")
            
            // 마지막 공지의 마감 날짜가 다음주이면 마지막 공지 삭제
            if Date().calculateWeekNumber(finishDate: lastContentFinishDate!) == 1 {
                print("삭제")
                CoreDataManager.shared.deleteContent(content: lastContent!)
                
                // 삭제 후 마지막 공지에 수정된 마감 날짜 및 마감 요일 저장
                lastContent = CoreDataManager.shared.fetchLastContent(studyEntity: target!)
                // 마감 날짜
                lastContent?.finishDate = finishDate
                // 마감 요일(101, 102, 103 ...)
                lastContent?.finishWeekDay = Int64(finishDay.value ?? 0)
            } else {
                // 마감 날짜
                lastContent?.finishDate = finishDate
                // 마감 요일(101, 102, 103 ...)
                lastContent?.finishWeekDay = Int64(finishDay.value ?? 0)
            }
        } else {
            print("다음주 공지 있어야함")
            if Date().calculateWeekNumber(finishDate: lastContentFinishDate!) == 1 {
                print("유지")
                // 마감 날짜
                lastContent?.finishDate = finishDate
                // 마감 요일(101, 102, 103 ...)
                lastContent?.finishWeekDay = Int64(finishDay.value ?? 0)
            } else {
                print("새로운 공지 생성")
                // 마지막 공지 벌금 업데이트 하고 새로운 공지 만들어야함
                
                
                
                lastContent = CoreDataManager.shared.createContent(studyEntity: target!)
            }
        }
        
        // 여기서 만약 스터디 시작 날짜를 변경하면
        // 이전에 만들었던 content의 currentWeekNumber도 싹다 변경
        CoreDataManager.shared.updateContentCurrentWeekNumber(startDate: startDate.value!, studyEntity: target!)

        // content멤버 데이터 가지고오고
        let contentMembers = CoreDataManager.shared.fetchCoreDataContentMembers(content: lastContent!)
        
        // content멤버 다 지우고
        CoreDataManager.shared.deleteContentMembers(members: contentMembers)
        // study에 저장된 멤버들로 다시 추가
        CoreDataManager.shared.addContentMembers(members: self.coreDataMembers.value, content: lastContent!)

        CoreDataManager.shared.saveContext()

        detailViewModel.fetchStudyData() {
            completion()
        }
    }
    
    func checkPost() {
        
    }
}
