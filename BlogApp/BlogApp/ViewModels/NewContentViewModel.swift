//
//  AddContentViewModel.swift
//  BlogApp
//
//  Created by PKW on 2023/07/14.
//

import Foundation

class NewContentViewModel {

    enum ContentProperty {
        case startDate
        case deadlineDate
        case fine
        case addContentMember
        case editContentMember
        case deleteContentMember
    }
    
    var lastContent: Observable<Content?> = Observable(nil)
    var deadlineDay: Observable<Int?> = Observable(nil)
    var startDate: Observable<Date?> = Observable(nil)
    var deadlineDate: Observable<Date?> = Observable(nil)
    var fine: Observable<Int?> = Observable(nil)
    
    var studyMembers: Observable<[User]> = Observable([])
    
    var contentMembers: Observable<[ContentUser]> = Observable([])
    
    var postsData: Observable<[PostResponse]> = Observable([])
    
    var totalFine = 0
    var plusFine = 0
    
    var memberState = MemberState.none
    var editIndex = 0

    init(studyEntity: Study?) {
        if let studyEntity = studyEntity {

            self.lastContent.value = CoreDataManager.shared.fetchLastContent(studyEntity: studyEntity)
            self.deadlineDay.value = Int(studyEntity.deadlineDay)
            
            if lastContent.value?.startDate != nil {
                self.startDate.value = self.lastContent.value?.startDate
            }
        
            self.deadlineDate.value = self.lastContent.value?.deadlineDate
            self.fine.value = Int(studyEntity.fine)
            self.studyMembers.value = CoreDataManager.shared.fetchStudyMembers(studyEntity: studyEntity)
        }
    }
    
    func updateContentProperty(_ property: ContentProperty, value: Any) {
        
        switch property {
        case .startDate:
            self.startDate.value = (value as? Date)?.makeStartDate()
        case .deadlineDate:
            self.deadlineDate.value = (value as? Date)?.makeDeadlineDate()
            // 마감 날짜도 변경
            self.deadlineDay.value = (value as? Date)?.getDayOfCurrentDate()
        case .fine:
            self.fine.value = value as? Int
        case .addContentMember:
            memberState = .add
            
            if let value = value as? (String, String, Int),
               let studyEntity = lastContent.value?.study {
                let member = User(context: CoreDataManager.shared.persistentContainer.viewContext)
                
                member.name = value.0
                member.blogUrl = value.1
                member.fine = Int64(value.2)
                
                self.studyMembers.value.insert(member, at: 0)
                studyEntity.addToMembers(member)
            }
    
        case .editContentMember:
            memberState = .edit
           
            if let value = value as? (String, String, Int, Int) {
                
                editIndex = value.3
                
                let member = studyMembers.value[value.3]
                member.name = value.0
                member.blogUrl = value.1
                member.fine = Int64(value.2)
                
                self.studyMembers.value[value.3] = member
            }
        case .deleteContentMember:
            memberState = .delete
            
            if let index = value as? Int {
                editIndex = index
               
                contentMembers.value.remove(at: index)
                postsData.value.remove(at: index)
                
                // 코어 데이터 먼저 지워야함 
                CoreDataManager.shared.deleteStudyMember(member: studyMembers.value[index])
                studyMembers.value.remove(at: index)
                
            }
        }
    }
    
    func fetchBlogPosts(completion: @escaping () -> ()) {
        CrawlingManager.fetchMembersBlogPost(members: studyMembers.value, startDate: startDate.value?.makeStartDate(), deadlineDate: deadlineDate.value?.makeDeadlineDate()) { postsData in
            
            self.postsData.value.removeAll()
            self.postsData.value = postsData
            self.fetchContentMembers()
            
            completion()
        }
    }
    
    func fetchContentMembers() {
        
        self.calculateFine()
        
        self.contentMembers.value.removeAll()
        
        for i in 0 ..< self.studyMembers.value.count {
            
            let contentMember = ContentUser(context: CoreDataManager.shared.persistentContainer.viewContext)
            contentMember.name = self.studyMembers.value[i].name
            
            // totalfine이 0 이면 벌금 계산 안함 
            if self.postsData.value[i].data == nil {
                contentMember.title = self.postsData.value[i].errorMessage ?? ""
                contentMember.postUrl = nil
                contentMember.fine = Int64(Int(self.studyMembers.value[i].fine) - (totalFine == 0 ? 0 : Int(self.fine.value ?? 0)))
            } else {
                contentMember.title = self.postsData.value[i].data?.title ?? ""
                contentMember.postUrl = self.postsData.value[i].data?.postUrl ?? ""
                contentMember.fine = Int64(Int(self.studyMembers.value[i].fine) + self.plusFine)
            }
            
            self.contentMembers.value.append(contentMember)
        }
    }
    
    func calculateFine() {
        let notPostMemberCount = self.postsData.value.filter({$0.data == nil}).count
        
        if notPostMemberCount == 0 || notPostMemberCount == self.postsData.value.count {
            self.totalFine = 0
            self.plusFine = 0
        } else {
            self.totalFine = (fine.value ?? 0) * notPostMemberCount
            self.plusFine = totalFine / (self.postsData.value.count - notPostMemberCount)
        }
    }
    
    func createContentData(completion: @escaping () -> ()) {
        CoreDataManager.shared.createContent(lastContent: lastContent.value, deadlineDay: deadlineDay.value, startDate: startDate.value, deadlineDate: deadlineDate.value, fine: fine.value, totalFine: totalFine, plusFine: plusFine, studyMembers: studyMembers.value, contentMembers: contentMembers.value) {
            completion()
        }
    }
    
    
    
//    func addContentMember(member: User, completion: @escaping () -> ()) {
//        CrawlingManager.fetchMembersBlogPost(members: [member], startDate: startDate.value, deadlineDate: deadlineDate.value) { postsData in
//
//            let target = postsData[0]
//
//            self.postsData.value.insert(target, at: 0)
//
//            self.calculateFine()
//
//            let contentMember = ContentUser(context: CoreDataManager.shared.persistentContainer.viewContext)
//            contentMember.name = member.name
//
//            if target.data == nil {
//                contentMember.title = target.errorMessage ?? ""
//                contentMember.postUrl = nil
//                contentMember.fine = Int64(Int(member.fine) - (self.fine.value ?? 0))
//            } else {
//                contentMember.title = target.data?.title
//                contentMember.postUrl = target.data?.postUrl
//                contentMember.fine = Int64(Int(member.fine) + self.plusFine)
//            }
//
//            self.contentMembers.value.insert(contentMember, at: 0)
//
//            completion()
//        }
//    }
//
//    func editContentMember(member: User, index: Int, completion: @escaping () -> ()) {
//        CrawlingManager.fetchMembersBlogPost(members: [member], startDate: startDate.value, deadlineDate: deadlineDate.value) { postsData in
//
//            let target = postsData[0]
//
//            self.postsData.value[index] = target
//
//            self.calculateFine()
//
//            let contentMember = self.contentMembers.value[index]
//            contentMember.name = member.name
//
//            if target.data == nil {
//                contentMember.title = target.errorMessage ?? ""
//                contentMember.postUrl = nil
//                contentMember.fine = Int64(Int(member.fine) - (self.fine.value ?? 0))
//            } else {
//                contentMember.title = target.data?.title
//                contentMember.postUrl = target.data?.postUrl
//                contentMember.fine = Int64(Int(member.fine) + self.plusFine)
//            }
//
//            self.contentMembers.value[index] = contentMember
//            completion()
//        }
//    }
    
    
//    func fetchBlogPosts(completion: @escaping () -> ()) {
//        CrawlingManager.fetchMembersBlogPost(members: studyMembers.value, startDate: startDate.value, deadlineDate: deadlineDate.value) { postsData in
//
//            self.postsData.value = postsData
//            // 벌금 계산
//            self.calculateFine()
//
//            self.createContentMembers()
//
//            completion()
//        }
//    }
//
//    func calculateFine() {
//        let notPostMemberCount = postsData.value.filter({$0.data == nil}).count
//
//        if notPostMemberCount == 0 || notPostMemberCount == postsData.value.count {
//            self.totalFine = 0
//            self.plusFine = 0
//        } else {
//            //self.totalFine = (fine.value?.convertFineInt() ?? 0) * notPostMemberCount
//            self.plusFine =  totalFine / (postsData.value.count - notPostMemberCount)
//        }
//    }
//
//    func createContentMembers() {
//        for i in 0 ..< self.studyMembers.value.count {
//            let contentMember = ContentUser(context: CoreDataManager.shared.persistentContainer.viewContext)
//            contentMember.name = self.studyMembers.value[i].name
//
//            if let index = self.postsData.value.firstIndex(where: {$0.name == contentMember.name}) {
//
//                if self.postsData.value[index].data == nil {
//                    contentMember.title = self.postsData.value[index].errorMessage ?? ""
//                    contentMember.postUrl = nil
//                    contentMember.fine = Int64(Int(self.studyMembers.value[index].fine) - (self.fine.value ?? 0))
//                } else {
//                    contentMember.title = self.postsData.value[index].data?.title
//                    contentMember.postUrl = self.postsData.value[index].data?.postUrl
//                    contentMember.fine = Int64(Int(self.studyMembers.value[index].fine) + self.plusFine)
//                }
//            }
//            self.contentMembers.value.append(contentMember)
//        }
//    }
//
//    func addContentMember(member: User, completion: @escaping () -> ()) {
//        CrawlingManager.fetchMembersBlogPost(members: [member], startDate: startDate.value, deadlineDate: deadlineDate.value) { postsData in
//
//            let target = postsData[0]
//
//            self.postsData.value.insert(target, at: 0)
//
//            self.calculateFine()
//
//            let contentMember = ContentUser(context: CoreDataManager.shared.persistentContainer.viewContext)
//            contentMember.name = member.name
//
//            if target.data == nil {
//                contentMember.title = target.errorMessage ?? ""
//                contentMember.postUrl = nil
//                contentMember.fine = Int64(Int(member.fine) - (self.fine.value ?? 0))
//            } else {
//                contentMember.title = target.data?.title
//                contentMember.postUrl = target.data?.postUrl
//                contentMember.fine = Int64(Int(member.fine) + self.plusFine)
//            }
//
//            self.contentMembers.value.insert(contentMember, at: 0)
//
//            completion()
//        }
//    }
//
//    func editContentMember(member: User, index: Int, completion: @escaping () -> ()) {
//        CrawlingManager.fetchMembersBlogPost(members: [member], startDate: startDate.value, deadlineDate: deadlineDate.value) { postsData in
//
//            let target = postsData[0]
//
//            self.postsData.value[index] = target
//
//            self.calculateFine()
//
//            let contentMember = self.contentMembers.value[index]
//            contentMember.name = member.name
//
//            if target.data == nil {
//                contentMember.title = target.errorMessage ?? ""
//                contentMember.postUrl = nil
//                contentMember.fine = Int64(Int(member.fine) - (self.fine.value ?? 0))
//            } else {
//                contentMember.title = target.data?.title
//                contentMember.postUrl = target.data?.postUrl
//                contentMember.fine = Int64(Int(member.fine) + self.plusFine)
//            }
//        }
//    }
    
    
    
//    func updateContentProperty(_ property: ContentProperty, value: Any, isAddMember: Bool = true) {
//
//        switch property {
//        case .startDate:
//            editDateType = .startDate
//            if let startDate = value as? Date {
//                self.startDate.value = startDate
//            }
//        case .deadlineDate:
//            editDateType = .deadlineDate
//            if let deadlineDate = value as? Date {
//                self.deadlineDate.value = deadlineDate
//            }
//        case .fine:
//            if let fine = value as? Int {
//                self.fine.value = fine
//            }
//        case .addContentMember:
//            if let value = value as? (String, String, Int) {
//
//                self.contentMemberState = .add
//
//                let member = User(context: CoreDataManager.shared.persistentContainer.viewContext)
//
//                member.name = value.0
//                member.blogUrl = value.1
//                member.fine = Int64(value.2)
//
//                studyMembers.value.insert(member, at: 0)
//            }
//        case .updateContentMember:
//            if let value = value as? (String, String, Int, Int) {
//
//                self.contentMemberState = .update
//                self.index = value.3
//
//                let member = studyMembers.value[self.index]
//                member.name = value.0
//                member.blogUrl = value.1
//                member.fine = Int64(value.2)
//
//                studyMembers.value[self.index] = member
//            }
//        case .deleteContentMember:
//            if let index = value as? Int {
//                self.contentMemberState = .delete
//                self.index = index
//                studyMembers.value.remove(at: index)
//            }
//        }
//    }
    
    
    
//    init(study: Study?) {
//        if let study = study {
//            self.study = study
//            self.studyMembers.value = CoreDataManager.shared.fetchStudyMembers(studyEntity: study)
//            self.contents = CoreDataManager.shared.fetchContentList(studyEntity: study)
//            //self.deadlineDay.value = Int(study.finishDay)
//            self.startDate.value = contents.last?.deadlineDate?.getStartDateAndDeadlineDate().startDate
//
//            if self.contents.count == 1 {
//
//                self.lastContentStartDate.value = contents.last?.deadlineDate?.getStartDateAndDeadlineDate().startDate
//
//            } else {
//                self.lastContentStartDate.value = self.contents[self.contents.count - 2].deadlineDate?.getStartDateAndDeadlineDate().startDate
//            }
//
//            self.deadlineDate.value = contents.last?.deadlineDate
//            self.fine.value = Int(study.fine)
//
//            //print(startDate.value)
//
//        }
//    }
    
//
//
//    func checkBlogPost() {
//        CrawlingManager.fetchMembersBlogPost(members: studyMembers.value, startDate: startDate.value, deadlineDate: deadlineDate.value) { postsData in
//            self.postsData.value = postsData
//        }
//    }
//
//    func createContent(completion: @escaping () -> ()) {
//        let contentEntity = contents.last
//        contentEntity?.deadlineDay = Int64(deadlineDay.value ?? 0)
//        contentEntity?.startDate = startDate.value
//        contentEntity?.deadlineDate = deadlineDate.value
//        contentEntity?.plusFine = Int64(plusFine)
//        contentEntity?.totalFine = Int64(totalFine)
//
//        // content 멤버 생성
//        for post in postsData.value {
//            if let index = studyMembers.value.firstIndex(where: {$0.name == post.name}) {
//
//                if post.data == nil {
//                    //studyMembers.value[index].fine -= Int64(fine.value?.convertFineInt() ?? 0)
//                } else {
//                    studyMembers.value[index].fine += Int64(plusFine)
//                }
//
//                let contentMember = ContentUser(context: CoreDataManager.shared.persistentContainer.viewContext)
//                contentMember.name = post.name
//                contentMember.title = post.data?.title
//                contentMember.postUrl = post.data?.postUrl
//                contentMember.fine = Int64(studyMembers.value[index].fine)
//                contentEntity?.addToMembers(contentMember)
//            }
//        }
//
//        let nextContent = Content(context: CoreDataManager.shared.persistentContainer.viewContext)
//        nextContent.contentNumber = (contentEntity?.contentNumber ?? 0) + 1
//        //nextContent.deadlineDate = contentEntity?.deadlineDate?.calculateNewContentFinishDate(deadlineDay: Int(study?.finishDay ?? 0))
//
//        print(nextContent.deadlineDate)
//
//        study?.addToContents(nextContent)
//
//        CoreDataManager.shared.saveContext()
//        completion()
//    }
//
//    func updateContents() {
//        self.startDate.value = self.contents[self.contents.count - 2].deadlineDate?.getStartDateAndDeadlineDate().startDate
//    }
//
//    func calculateFine() {
//        let notPostMemberCount = postsData.value.filter({$0.data == nil}).count
//
//        if notPostMemberCount == 0 || notPostMemberCount == postsData.value.count {
//            self.totalFine = 0
//            self.plusFine = 0
//        } else {
//            //self.totalFine = (fine.value?.convertFineInt() ?? 0) * notPostMemberCount
//            self.plusFine =  totalFine / (postsData.value.count - notPostMemberCount)
//        }
//    }
//
//    func getStartDateSubTitleDate() -> String {
//        if let studyEntity = study {
//
//            let contents = CoreDataManager.shared.fetchContentList(studyEntity: studyEntity)
//
//            if contents.count == 1 {
//                return "처음 생성하는 공지사항 입니다.\n시작 날짜를 자유롭게 설정해주세요."
//            } else {
//                let subTitleDate = (contents[contents.count - 2].deadlineDate ?? Date()).makeStartDate()
//                return "시작일은 이전 마감일인 \(subTitleDate?.toString() ?? "")및 과거로 선택할 수 없습니다."
//            }
//        } else {
//            return ""
//        }
//    }
}

//    func addContentMember(name: String, blogUrl: String, fine: Int) {
//        let member = User(context: CoreDataManager.shared.persistentContainer.viewContext)
//
//        member.name = name
//        member.blogUrl = blogUrl
//        member.fine = Int64(fine)
//
//        contentMembers.value.insert(member, at: 0)
//    }
//
//    func updateContentMember(name: String, blogUrl: String, fine: Int, index: Int) {
//
//        self.contentMemberState = .update
//        self.index = index
//
//        let member = contentMembers.value[index]
//        member.name = name
//        member.blogUrl = blogUrl
//        member.fine = Int64(fine)
//
//        contentMembers.value[index] = member
//    }
    
//    func deleteContentMember(index: Int) {
//        self.contentMemberState = .delete
//        self.index = index
//
//        contentMembers.value.remove(at: index)
//    }
