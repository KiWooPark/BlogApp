//
//  StucyComposeViewModel.swift
//  BlogApp
//
//  Created by PKW on 2023/06/02.
//

import Foundation

enum StudyProperty {
    case newStudy
    case title
    case announcement
    case startDate
    case setDay
    case fine
    case members
    case deleteMember
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
    // 기존 스터디인지 신규 스터디인지
    var isNewStudy: Observable<Bool> = Observable(true)
    
    var oldFinishDay = 0

    init(studyData: Study?) {
        if let studyData = studyData {
            self.title.value = studyData.title
            self.announcement.value = studyData.announcement
            self.startDate.value = studyData.startDate
            self.finishDay.value = Int(studyData.finishDay)
            self.fine.value = Int(studyData.fine)
            self.coreDataMembers.value = CoreDataManager.shared.fetchCoreDataMembers(study: studyData)
            self.isNewStudy.value = studyData.isNewStudy
            self.oldFinishDay = Int(studyData.finishDay)
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
    
    //MARK: U
    func updateStudyProperty(_ property: StudyProperty, value: Any, isEditMember: Bool = false) {
        switch property {
        case .newStudy:
            self.isNewStudy.value = value as! Bool
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
        case .deleteMember:
            if let value = value as? Int {
                let member = coreDataMembers.value[value]
                coreDataMembers.value.remove(at: value)
                CoreDataManager.shared.deleteStudyMember(user: member)
            }
        }
    }
    
  
    /// Study 데이터 및 멤버 추가 삭제시 Study, Content, StudyMembers, ContentMembers 데이터를 업데이트하는 메소드 입니다.
    /// - 마감 요일이 변경 되었을경우 공지사항의 마감 요일 및 마감 날짜를 변경하며, 마감 요일이 변경되지 않으면 나머지 데이터만 업데이트 합니다.
    /// -------------------------------------------------------------------------------------------
    /// - Parameters:
    ///   - detailViewModel: <#detailViewModel description#>
    ///   - completion: <#completion description#>
    func updateDetailStudyData(detailViewModel: StudyDetailViewModel, completion: @escaping () -> ()) {
        
        let target = detailViewModel.study.value!
        
        // 공지사항 리스트
        var contentList = CoreDataManager.shared.fetchContent(studyEntity: target)
        
        // 새로운 공지 생성 체크
        var isCreateNewContent = false
        
        // 마감 요일 바꿨을때만 공지 업데이트
        if oldFinishDay == finishDay.value ?? 0 {
            target.title = title.value
            target.announcement = announcement.value
            target.startDate = startDate.value
            target.fine = Int64(fine.value ?? 0)
            target.memberCount = Int64(coreDataMembers.value.count)
        } else {
            target.title = title.value
            target.announcement = announcement.value
            target.startDate = startDate.value
            target.finishDay = Int64(finishDay.value ?? 0)
            target.fine = Int64(fine.value ?? 0)
            target.memberCount = Int64(coreDataMembers.value.count)
    
            // 변경한 마감 요일
            // 현재 날짜(수요일)를 기준으로 변경한 마감 요일에 대한 날짜를 구함
            // 현재 날짜가 수요일일 경우
            // 월, 화로 변경시 마감 날짜 지남
            // 수 목 금 토 일로 변경시 마감 날짜 아직 안지남
            let changeFinishDate = Date().calcCurrentFinishDate(setDay: finishDay.value ?? 0)!
            
            // 마지막 공지사항의 마감 날짜가 이번주인지 다음주인지 분기처리하기 위해 마감 날짜 구함
            let lastContentFinishDate = contentList.last?.finishDate ?? Date()
            
            // 변경한 마감 요일이 마감 날짜가 지나 다음주인지, 마감 날짜가 지나지 않아 이번주인지 체크
            // 현재 날짜가 [수요일]인 상태에서 마감 요일을 [월,화]로 변경하면 마감되어 다음주이므로 1
            // 현재 날짜가 [수요일]인 상태에서 마감 요일을 [수, 목, 금, 토, 일]로 변경하면 마감되지 않아 이번주이므로 0
            if Date().calculateWeekNumber(finishDate: changeFinishDate) == 0 {
                
                // 마감 요일이 이번주에 포함되어 있으므로 마지막 공지사항의 마감 날짜를 업데이트하기위해 마지막 공지사항 마감 날짜 체크
                // 마지막 공지사항의 마감 요일이 이번주이면 0 바로 업데이트
                // 마지막 공지사항의 마감 요일이 다음주이면 1 날짜 계산해서 업데이트
                if Date().calculateWeekNumber(finishDate: lastContentFinishDate) == 0 {
                    let lastContent = contentList.last
                    lastContent?.finishDate = changeFinishDate
                    lastContent?.finishWeekDay = Int64(finishDay.value ?? 0)
                    lastContent?.plusFine = 0
                    lastContent?.totalFine = 0
                
                } else if Date().calculateWeekNumber(finishDate: lastContentFinishDate) == 1 {
                    
                    isCreateNewContent = true
                    
                    // 마지막 공지사항 삭제하고 공지사항 갯수에 따라서 마감요일 분기처리
                    updateCurrentWeekLastContentFinishDate(contentList: contentList, studyEntity: target, finishDate: changeFinishDate) {

                        detailViewModel.fetchStudyData() {
                            print("AAAAAAA")
                            completion()
                        }
                    }
                }
            } else {
                // 변경한 요일이 다음주 이므로 공지사항 있어야함
                // 다음주 공지사항이 있는지 체크
                if Date().calculateWeekNumber(finishDate: lastContentFinishDate) == 1 {
                    // 다음주 공지사항이 있으면
                    
                    // 마지막 공지사항 이전 공지사항의 마감 요일이 이번주인지 체크하고
                    // 이번주면 날짜 업데이트하고
                    // 게시글 체크도 업데이트
                    let content = contentList[contentList.count - 2]
                    
                    if Date().calculateWeekNumber(finishDate: content.finishDate ?? Date()) == 0 {
                        
                        isCreateNewContent = true
                        
                        content.finishDate = Date().getFinishDate(finishDayNum: finishDay.value ?? 0, type: .currentWeek)
                        content.finishWeekDay = Int64(finishDay.value ?? 0)
                        content.plusFine = 0
                        content.totalFine = 0
                        
                        if let lastContent = contentList.last {
                            CoreDataManager.shared.deleteContent(content: lastContent)
                        }
                        
                        // 벌금 동기화
                        CoreDataManager.shared.updateLastContentMembers(lastContent: content, studyMembers: coreDataMembers.value)
                        
                        let finishDate = Date().getFinishDate(finishDayNum: finishDay.value ?? 0, type: .currentWeek)
                        let startDate = finishDate?.getStartDateAndEndDate().0 ?? Date()
                        let endDate = finishDate?.getStartDateAndEndDate().1 ?? Date()
                        
                        CrawlingManager.fetchPostData(members: coreDataMembers.value, startDate: startDate, endDate: endDate) { result in
                            
                            switch result {
                            case .success(let responseData):
                                
                                let fine = self.calculateFine(studyEntity: target, members: responseData)
                                
                                CoreDataManager.shared.updateMembersFine(studyEntity: target, contentEntity: content, fine: (fine.totalFine, fine.plus), membersPost: responseData) {
                                    CoreDataManager.shared.updateContentCurrentWeekNumber(startDate: self.startDate.value ?? Date(), studyEntity: target) {
                                    
                                        detailViewModel.fetchStudyData() {
                                            print("BBBBBBBBB")
                                            completion()
                                        }
                                    }
                                }
                                
 
                            case .failure(let error):
                                print(error)
                            }
                        }
                    } else {
                        // 그리고 마지막 공지사항 업데이트
                        let lastContent = contentList.last
                        lastContent?.finishDate = changeFinishDate
                        lastContent?.finishWeekDay = Int64(finishDay.value ?? 0)
                        lastContent?.plusFine = 0
                        lastContent?.totalFine = 0
                    }
                } else if Date().calculateWeekNumber(finishDate: lastContentFinishDate) == 0 {
                    // 다음주 공지사항이 없으면
                    // 새로운 공지사항 생성
                    isCreateNewContent = true
                    
                    updateNextWeekLastContentFinishDate(contentList: contentList, studyEntity: target, finishDate: changeFinishDate) {

                        detailViewModel.fetchStudyData() {
                            print("CCCCCCCC")
                            completion()
                        }
                    }
                }
            }
        }
    
        // 추가된 멤버 study 연결
        coreDataMembers.value.forEach { member in
            if member.study == nil {
                target.addToMembers(member)
            }
        }
    
        if !isCreateNewContent {
            
            // 시작 날짜를 변경하면 이전 공지사항들의 주 번호 전부 변경
            CoreDataManager.shared.updateContentCurrentWeekNumber(startDate: startDate.value!, studyEntity: target) {
                // content멤버 데이터 가지고오고
                let contentMembers = CoreDataManager.shared.fetchCoreDataContentMembers(content: contentList.last!)
                
                // content멤버 다 지우고
                CoreDataManager.shared.deleteContentMembers(members: contentMembers)
                // study에 저장된 멤버들로 다시 추가
                CoreDataManager.shared.addContentMembers(members: self.coreDataMembers.value, content: contentList.last!)
                
                CoreDataManager.shared.saveContext()
                
                
                detailViewModel.fetchStudyData() {
                    print("isCreateNewContent")
                    completion()
                }
            }
        }
    }
    
    func calculateFine(studyEntity: Study, members: [PostResponse]) -> (totalFine: Int, plus :Int){
        var resultFine = 0
        
        // 작성 안한사람
        let notPostCount = members.filter({$0.data == nil}).count
        // 작성한 사람
        let postCount = members.filter({$0.data != nil}).count
        
        // 다 작성했거나 다 작성 안했거나 하면 벌금 0 원
        if notPostCount == members.count || postCount == members.count {
            return (0, 0)
        }
        
        // 각 멤버별 벌금 합계
        let totalFine = Int(studyEntity.fine).convertFineInt() * notPostCount
        
        // 분배할 금액
        resultFine = totalFine / postCount
        
        return (totalFine, resultFine)
    }
    
    func validatePostInputData() -> String? {
        
        enum Check: String {
            case title = "스터디 제목"
            case announcement = "공지사항 및 소개"
            case startDate = "시작 날짜"
            case finishDay = "마감 날짜"
            case fine = "벌금"
        }
        
        var alertList = [Check]()
        
        if title.value == nil {
            alertList.append(.title)
        }
        
        if announcement.value == nil {
            alertList.append(.announcement)
        }
        
        if startDate.value == nil {
            alertList.append(.startDate)
        }
        
        if finishDay.value == nil {
            alertList.append(.finishDay)
        }
        
        if fine.value == nil {
            alertList.append(.fine)
        }
        
        if alertList.isEmpty {
            return nil
        } else {
            return "\(alertList.map({$0.rawValue}).joined(separator: "\n")) \n입력을 완료해주세요. "
        }
    }
    
    /// 변경한 마감 요일이 이번주에 포함되어있으며 마지막 공지사항의 마감 날짜가 다음주일 경우 마지막 공지사항을 삭제하고
    /// 마감 날짜가 이번주인 공지사항을 업데이트하는 메소드 입니다.
    /// ----------------------------------------------------------------------------------
    /// - Parameters:
    ///   - contentList: 공지사항 리스트
    ///   - studyEntity: <#studyEntity description#>
    ///   - finishDate: <#finishDate description#>
    ///   - completion: <#completion description#>
    func updateCurrentWeekLastContentFinishDate(contentList: [Content], studyEntity: Study?, finishDate: Date, completion: @escaping () -> ()) {
        
        var copyContentList = contentList
    
        // 마감 날짜가 다음주인 공지사항 삭제(마지막 공지사항)
        if let lastContent = copyContentList.last {
            CoreDataManager.shared.deleteContent(content: lastContent)
            copyContentList.removeLast()
        }
        
        // 그 다음 업데이트 할 마지막 공지사항
        if let updateLastContent = copyContentList.last {
        
            // 공지사항 개수에 따라 분기 처리
            // 공지사항 개수가 1이라면 바로 업데이트
            // 공지사항 개수가 2개 이상이라면 저번주 공지사항의 마감 요일로 현재 공지사항 마감 요일 업데이트
            if copyContentList.count == 1 {
                updateLastContent.finishDate = finishDate
                updateLastContent.finishWeekDay = Int64(self.finishDay.value ?? 0)
            } else {
                // 업데이트 해야할 공지사항의 저번주 마감 날짜로 업데이트해야함
                if let index = copyContentList.firstIndex(of: updateLastContent) {
                    let content = copyContentList[index - 1]
                    
                    // 현재 업데이트할 마감 요일이 이번주에 있다면 이전 공지사항의 마감 날짜로 업데이트
                    if Date().calculateWeekNumber(finishDate: updateLastContent.finishDate ?? Date()) == 0 {
                    
                        // 저번주의 마감 요일의 날짜를 구한 후 업데이트
                        let beforeWeek = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: updateLastContent.finishDate ?? Date()) ?? Date()
                        let newFinishDate = beforeWeek.getFinishDate(finishDayNum: Int(content.finishWeekDay), type: .currentWeek) ?? Date()
                        
                        updateLastContent.finishDate = newFinishDate
                        updateLastContent.finishWeekDay = content.finishWeekDay
                        updateLastContent.plusFine = 0
                        updateLastContent.totalFine = 0
                    
                        // 멤버 벌금 동기화
                        // 마지막 공지사항에 저장되어있는 벌금을 Study에 저장되어있는 멤버 벌금에 업데이트
                        CoreDataManager.shared.updateLastContentMembers(lastContent: updateLastContent, studyMembers: coreDataMembers.value)
                        
                        // 저번주의 마감 날짜가 일요일이면
                        // 현재 업데이트해야하는 공지사항의 범위는 (일 23:59:59 ~ 일 23:59:59)
                        let startDate = newFinishDate.getStartDateAndEndDate().0
                        let endDate = newFinishDate.getStartDateAndEndDate().1
                      
                        // 작성된 게시물이 있는지 체크
                        CrawlingManager.fetchPostData(members: coreDataMembers.value, startDate: startDate, endDate: endDate) { result in
                            
                            switch result {
                            case .success(let responseData):
                                
                                if let studyEntity = studyEntity {
                                    
                                    // 벌금 계산
                                    // 0 = total 벌금, 1 = 게시글 작성한 사람한테 더해주어야할 벌금
                                    let fine = self.calculateFine(studyEntity: studyEntity, members: responseData)
                                    
                                    // 벌금 업데이트
                                    CoreDataManager.shared.updateMembersFine(studyEntity: studyEntity, contentEntity: updateLastContent, fine: (fine.totalFine, fine.plus), membersPost: responseData) {
                                        CoreDataManager.shared.updateContentCurrentWeekNumber(startDate: studyEntity.startDate ?? Date(), studyEntity: studyEntity) {
                                            completion()
                                        }
                                    }
                                }
                            case .failure(let error):
                                print(error)
                            }
                        }
                    } else {
                        updateLastContent.finishDate = finishDate
                        updateLastContent.finishWeekDay = Int64(self.finishDay.value ?? 0)
                        updateLastContent.plusFine = 0
                        updateLastContent.totalFine = 0
                        
                        // 멤버 벌금 동기화
                        CoreDataManager.shared.updateLastContentMembers(lastContent: updateLastContent, studyMembers: coreDataMembers.value)
                    }
                }
            }
        }
    }
    
    /// 변경한 마감 요일이 다음주에 포함되어 있으며 마지막 공지사항의 마감 날짜가 다음주에 포함되어 있지 않으면 새로운 공지사항을 생성하는 메소드 입니다.
    /// ----------------------------------------------------------------
    /// - Parameters:
    ///   - contentList: <#contentList description#>
    ///   - studyEntity: <#studyEntity description#>
    ///   - finishDate: <#finishDate description#>
    ///   - completion: <#completion description#>
    func updateNextWeekLastContentFinishDate(contentList: [Content], studyEntity: Study?, finishDate: Date, completion: @escaping () -> ()) {
        
        // 현재 날짜를 기준으로 변경한 마감 요일에 대한 이번주 날짜 구하기
        let finishDate = Date().getFinishDate(finishDayNum: self.finishDay.value ?? 0, type: .currentWeek)
        
        // 공지사항 개수에 따라 분기 처리
        // 공지사항 개수가 1개라면 바로 업데이트 해주고 게시글을 작성했는지 체크
        // 공지사항 개수가 2개 이상이라면 저번주 마감 날짜부터 변경된 마감 날짜까지 범위 확대(중간에 마감 요일 변경으로 인한 공백이 생기지 않도록)
        if contentList.count == 1 {
            if let lastContent = contentList.last {
                lastContent.finishDate = finishDate
                lastContent.finishWeekDay = Int64(self.finishDay.value ?? 0)
                
                let startDate = finishDate?.getStartDateAndEndDate().0 ?? Date()
                let endDate = finishDate?.getStartDateAndEndDate().1 ?? Date()
                
                CrawlingManager.fetchPostData(members: coreDataMembers.value, startDate: startDate, endDate: endDate) { result in
                    switch result {
                    case .success(let responseData):
                        
                        if let studyEntity = studyEntity {
                            let fine = self.calculateFine(studyEntity: studyEntity, members: responseData)
                            
                            // 이름으로 인덱스 검색해서 업데이트하게 바꿔야함
                            CoreDataManager.shared.updateMembersFine(studyEntity: studyEntity, contentEntity: lastContent, fine: (fine.totalFine, fine.plus), membersPost: responseData) {
                                CoreDataManager.shared.updateContentCurrentWeekNumber(startDate: studyEntity.startDate ?? Date(), studyEntity: studyEntity) {
                                    completion()
                                }
                            }
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        } else {
            // 공지사항이 2개 이상인경우
            // 이전주 시작날짜부터 변경한 날짜까지 체크
            // 현재 날짜 = 11일 , 원래 마감 날짜 = 16일, 변경 날짜 = 11일 (월요일)
            // 이전주 시작 날짜 2일 ~ 10일까지 체크
            let content = contentList[contentList.count - 2]
            let startDate = content.finishDate?.getStartDateAndEndDate().0 ?? Date()
            let endDate = finishDate ?? Date()
            
            CrawlingManager.fetchPostData(members: coreDataMembers.value, startDate: startDate, endDate: endDate) { result
                in
                switch result {
                case .success(let responseData):
                    
                    if let studyEntity = studyEntity {
                        
                        let fine = self.calculateFine(studyEntity: studyEntity, members: responseData)
                    
                        // 저번주 공지사항의 마감 날짜 업데이트(변경된 마감 요일의 날짜로)
                        content.finishDate = endDate
                        content.finishWeekDay = Int64(self.finishDay.value ?? 0)
                        
                        // 마지막 공지사항 삭제
                        if let lastContent = contentList.last {
                            CoreDataManager.shared.deleteContent(content: lastContent)
                        }
                        
                        // 멤버 벌금 동기화
                        CoreDataManager.shared.updateLastContentMembers(lastContent: content, studyMembers: self.coreDataMembers.value)
                        
                        // 벌금 업데이트
                        CoreDataManager.shared.updateMembersFine(studyEntity: studyEntity, contentEntity: content, fine: (fine.totalFine, fine.plus), membersPost: responseData) {
                            CoreDataManager.shared.updateContentCurrentWeekNumber(startDate: studyEntity.startDate ?? Date(), studyEntity: studyEntity) {
                                completion()
                            }
                        }

                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    // 백업
//    func updateDetailStudyData11(detailViewModel: StudyDetailViewModel, completion: @escaping () -> ()) {
//
//        // Study 데이터 업데이트
//        let target = detailViewModel.study.value
//        target?.title = title.value
//        target?.announcement = announcement.value
//        target?.startDate = startDate.value
//        target?.finishDay = Int64(finishDay.value ?? 0)
//        target?.fine = Int64(fine.value ?? 0)
//        target?.memberCount = Int64(coreDataMembers.value.count)
//
//        // 추가된 멤버 study 연결
//        coreDataMembers.value.forEach { member in
//            if member.study == nil {
//                target?.addToMembers(member)
//            }
//        }
//
//        // ===========================
//
//        // 새로운 공지 생성 체크
//        var isCreateNewContent = false
//
//        // 공지사항 리스트
//        var contentList = CoreDataManager.shared.fetchContent(studyEntity: target!)
//
//        // 변경한 요일에 대한 날짜
//        // 현재 날짜 11일(화요일) -> 마감일 월요일이면 10일이 지났으므로 -> 마감일은 다음주인 17일(월요일)
//        let changeFinishDate = Date().calcCurrentFinishDate(setDay: finishDay.value ?? 0)!
//
//        // 마감일을 기준으로 현재주에 있는지 아니면 다음주에 있는지
//        if Date().calculateWeekNumber(finishDate: changeFinishDate) == 0 {
//            // 현재 주차이므로 다음주차 공지사항 없어야함
//
//            // 마지막 공지사항 마감 날짜
//            let lastContentFinishDate = contentList.last?.finishDate!
//
//            // 마지막 공지사항 마감 날짜가 다음 주차이면 삭제
//            if Date().calculateWeekNumber(finishDate: lastContentFinishDate!) == 1 {
//
//                // 마지막 공지 삭제하고
//                if let lastContent = contentList.last {
//                    CoreDataManager.shared.deleteContent(content: lastContent)
//                    contentList.removeLast()
//                }
//
//                let newLastContent = contentList.last
//
//                if contentList.count == 1 {
//                    newLastContent?.finishDate = changeFinishDate
//                    newLastContent?.finishWeekDay = Int64(finishDay.value ?? 0)
//                } else {
//                    let index = contentList.firstIndex(of: newLastContent!)!
//                    let content11 = contentList[index - 1]
//
//                    if Date().calculateWeekNumber(finishDate: (newLastContent?.finishDate)!) == 0 {
//                        let afterWeek = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: (newLastContent?.finishDate)!)
//                        let new = afterWeek!.getFinishDate(finishDayNum: Int(content11.finishWeekDay), type: .currentWeek)
//
//                        newLastContent?.finishDate = new
//                        newLastContent?.finishWeekDay = Int64(content11.finishWeekDay)
//                        newLastContent?.plusFine = 0
//                        newLastContent?.totalFine = 0
//
//                        let lastContentMembers = CoreDataManager.shared.fetchCoreDataContentMembers(content: newLastContent!)
//
//                        // 만약 멤버가 추가된 상태라면 추가한 멤버 빼고 나머지 공지에 있는 멤버들은 업데이트시켜줘야함
//                        for member in lastContentMembers {
//                            if let index = coreDataMembers.value.firstIndex(where: {$0.name == member.name}) {
//                                coreDataMembers.value[index].fine = member.fine
//                            }
//                        }
//
//                        let startDate = new?.getStartDateAndEndDate().0
//                        let endDate = new?.getStartDateAndEndDate().1
//
//                        CrawlingManager.fetchPostData(members: coreDataMembers.value, startDate: startDate!, endDate: endDate!) { result in
//
//                            switch result {
//                            case .success(let responseData):
//                                let fine = self.calculateFine(studyEntity: target!, members: responseData)
//
//                                CoreDataManager.shared.updateMembersFine(studyEntity: target!, contentEntity: newLastContent!, fine: (fine.totalFine, fine.plus), membersPost: responseData)
//                                CoreDataManager.shared.updateContentCurrentWeekNumber(startDate: self.startDate.value!, studyEntity: target!)
//
//                                detailViewModel.fetchStudyData() {
//                                    completion()
//                                }
//                            case .failure(let error):
//                                print(error)
//                            }
//                        }
//                    } else {
//                        if let newLastContent = contentList.last {
//                            newLastContent.finishDate = changeFinishDate
//                            newLastContent.finishWeekDay = Int64(finishDay.value ?? 0)
//                            newLastContent.plusFine = 0
//                            newLastContent.totalFine = 0
//
//                            let lastContentMembers = CoreDataManager.shared.fetchCoreDataContentMembers(content: newLastContent)
//
//                            // 만약 멤버가 추가된 상태라면 추가한 멤버 빼고 나머지 공지에 있는 멤버들은 업데이트시켜줘야함
//                            for member in lastContentMembers {
//                                if let index = coreDataMembers.value.firstIndex(where: {$0.name == member.name}) {
//                                    coreDataMembers.value[index].fine = member.fine
//                                }
//                            }
//                        }
//                    }
//                }
//            } else if Date().calculateWeekNumber(finishDate: lastContentFinishDate!) == 0 { // changeFinishDate
//
//                // 마지막 공지사항 업데이트
//                if let lastContent = contentList.last {
//                    lastContent.finishDate = changeFinishDate
//                    lastContent.finishWeekDay = Int64(finishDay.value ?? 0)
//                    lastContent.plusFine = 0
//                    lastContent.totalFine = 0
//                }
//            }
//        } else {
//            // 다음 주차이므로 다음주차 공지사항 있어야함
//            let lastContentFinishDate = contentList.last?.finishDate!
//
//            // 다음주 공지사항이 있으므로
//            if Date().calculateWeekNumber(finishDate: lastContentFinishDate!) == 1 {
//
//                // 마지막 공지사항 업데이트
//                if let lastContent = contentList.last {
//                    lastContent.finishDate = changeFinishDate
//                    lastContent.finishWeekDay = Int64(finishDay.value ?? 0)
//                    lastContent.plusFine = 0
//                    lastContent.totalFine = 0
//                }
//                // 다음주 공지사항이 없으므로
//            } else if Date().calculateWeekNumber(finishDate: lastContentFinishDate!) == 0 {
//
//                isCreateNewContent = true
//
//                let finishDate = Date().getFinishDate(finishDayNum: finishDay.value ?? 0, type: .currentWeek)
//
//                // 공지사항이 한개일경우
//                if contentList.count == 1 {
//
//                    // 변경된 마감날짜
//                    if let lastContent = contentList.last {
//                        lastContent.finishDate = finishDate
//                        lastContent.finishWeekDay = Int64(finishDay.value ?? 0)
//
//                        let startDate = finishDate?.getStartDateAndEndDate().0
//                        let endDate = finishDate?.getStartDateAndEndDate().1
//                        // 벌금 업데이트
//                        CrawlingManager.fetchPostData(members: coreDataMembers.value, startDate: startDate!, endDate: endDate!) { result in
//                            switch result {
//                            case .success(let responseData):
//
//                                let fine = self.calculateFine(studyEntity: target!, members: responseData)
//
//                                // 이름으로 인덱스 검색해서 업데이트하게 바꿔야함
//                                CoreDataManager.shared.updateMembersFine(studyEntity: target!, contentEntity: lastContent, fine: (fine.totalFine, fine.plus), membersPost: responseData)
//
//                                CoreDataManager.shared.updateContentCurrentWeekNumber(startDate: self.startDate.value!, studyEntity: target!)
//
//                                detailViewModel.fetchStudyData() {
//                                    completion()
//                                }
//
//                            case .failure(let error):
//                                print(error)
//                            }
//                        }
//                    }
//                } else {
//                    // 공지사항이 2개 이상인경우
//                    // 이전주 시작날짜부터 변경한 날짜까지 체크
//                    // 현재 날짜 = 11일 , 원래 마감 날짜 = 16일, 변경 날짜 = 11일 (월요일)
//                    // 이전주 시작 날짜 2일 ~ 10일까지 체크
//                    let startDate = contentList[contentList.count - 2].finishDate?.getStartDateAndEndDate().0
//                    let endDate = finishDate
//
//                    CrawlingManager.fetchPostData(members: coreDataMembers.value, startDate: startDate!, endDate: endDate!) { result
//                        in
//                        switch result {
//                        case .success(let responseData):
//                            let fine = self.calculateFine(studyEntity: target!, members: responseData)
//
//                            let lastContent = contentList[contentList.count - 2]
//
//                            lastContent.finishDate = endDate
//                            lastContent.finishWeekDay = Int64(self.finishDay.value ?? 0)
//
//                            CoreDataManager.shared.deleteContent(content: contentList.last!)
//                            contentList.removeLast()
//
//
//                            let members : [User] = CoreDataManager.shared.fetchCoreDataMembers(study: target!)
//                            let contentMembers = CoreDataManager.shared.fetchCoreDataContentMembers(content: lastContent)
//
//                            for contentMember in contentMembers {
//                                let index = members.firstIndex(where: {$0.name == contentMember.name})
//                                members[index!].fine = contentMember.fine
//                            }
//
//                            // 새로운 공지 생성
//                            CoreDataManager.shared.updateMembersFine(studyEntity: target!, contentEntity: lastContent, fine: (fine.totalFine, fine.plus), membersPost: responseData)
//
//                            CoreDataManager.shared.updateContentCurrentWeekNumber(startDate: self.startDate.value!, studyEntity: target!)
//
//                            detailViewModel.fetchStudyData() {
//                                completion()
//                            }
//
//                        case .failure(let error):
//                            print(error)
//                        }
//                    }
//                }
//            }
//        }
//
//        if !isCreateNewContent {
//
//            // 시작 날짜를 변경하면 이전 공지사항들의 주 번호 전부 변경
//            CoreDataManager.shared.updateContentCurrentWeekNumber(startDate: startDate.value!, studyEntity: target!)
//            
//            // content멤버 데이터 가지고오고
//            let contentMembers = CoreDataManager.shared.fetchCoreDataContentMembers(content: contentList.last!)
//
//            // content멤버 다 지우고
//            CoreDataManager.shared.deleteContentMembers(members: contentMembers)
//            // study에 저장된 멤버들로 다시 추가
//            CoreDataManager.shared.addContentMembers(members: self.coreDataMembers.value, content: contentList.last!)
//
//            CoreDataManager.shared.saveContext()
//
//            detailViewModel.fetchStudyData() {
//                completion()
//            }
//        }
//    }
}
