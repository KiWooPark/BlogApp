//
//  CoreDataManager.swift
//  BlogApp
//
//  Created by PKW on 2023/05/18.
//

import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    private init() {}
    
    private let entityName = "CoreData"
    
    var context: NSManagedObjectContext {
        return self.persistentContainer.viewContext
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: self.entityName)
        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                debugPrint(error, error.userInfo)
            }
        }
        return container
    }()
    
    // MARK: CREATE
    func createStudy(title: String, announcement: String, startDate: Date, finishDay: Int, fine: Int, members: [User], isNewStudy: Bool, completion: @escaping () -> ()) {
        
        let studyEntity = Study(context: persistentContainer.viewContext)
        studyEntity.createDate = Date()
        studyEntity.title = title
        studyEntity.announcement = announcement
        studyEntity.startDate = startDate
        studyEntity.finishDay = Int64(finishDay)
        studyEntity.fine = Int64(fine)
        studyEntity.memberCount = Int64(members.count)
        studyEntity.isNewStudy = isNewStudy
        
        addNewMembers(members: members, study: studyEntity)
        
        let contentEntity = Content(context: persistentContainer.viewContext)
        
        // 현재 날짜를 기준으로 선택한 마감일의 날짜를 구함
        let finishDate = Date().calcCurrentFinishDate(setDay: finishDay)
        
        contentEntity.currentWeekNumber = Int64(startDate.calculateWeekNumber(finishDate: finishDate!))
        contentEntity.finishDate = finishDate
        contentEntity.plusFine = 0
        contentEntity.totalFine = 0
        contentEntity.finishWeekDay = Int64(Int(finishDay))
        studyEntity.addToContents(contentEntity)
        
        addContentMembers(members: members, content: contentEntity)
        
        saveContext()
        completion()
    }
    
    func createContent(studyEntity: Study) -> Content {
        let contentEntity = Content(context: persistentContainer.viewContext)
        
        let finishDate = Date().calcCurrentFinishDate(setDay: Int(studyEntity.finishDay))!
        
        contentEntity.currentWeekNumber = Int64(studyEntity.startDate?.calculateWeekNumber(finishDate: finishDate) ?? 0)
        contentEntity.finishDate = finishDate
        contentEntity.plusFine = 0
        contentEntity.totalFine = 0
        contentEntity.finishWeekDay = studyEntity.finishDay
        studyEntity.addToContents(contentEntity)
        
        let members: [User] = fetchCoreDataMembers(study: studyEntity)

        addContentMembers(members: members, content: contentEntity)
        
        return contentEntity
    }
 
    
    // 새로 생성할때 스터디엔티티에 멤버 연결
    func addNewMembers(members: [User], study: Study) {
        for member in members {
            study.addToMembers(member)
        }
    }
    
    // 공지사항 생성할때 콘텐트 엔티티에 연결
    func addContentMembers(members: [User], content: Content) {
        for member in members {
            let contentMember = ContentUser(context: persistentContainer.viewContext)
            contentMember.name = member.name
            contentMember.postUrl = nil
            contentMember.fine = member.fine
            
            content.addToMembers(contentMember)
        }
    }
    
    // MARK: READ
    // 스터디 가져오기
    func fetchStudys() -> [Study] {
        let request: NSFetchRequest<Study> = Study.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createDate", ascending: true)]
        var fetchedStudys: [Study] = []
        
        do {
            fetchedStudys = try persistentContainer.viewContext.fetch(request)
        } catch {
            print(error.localizedDescription)
        }
        return fetchedStudys
    }
    
    // 해당 id의 스터디 가지고오기
    func getStudy(id: NSManagedObjectID) -> Study? {
        do {
            return try context.existingObject(with: id) as? Study
        } catch {
            print("error")
            return nil
        }
    }
    
    // content 가져오기
    func fetchContent(studyEntity: Study) -> [Content] {
        let request: NSFetchRequest<Content> = Content.fetchRequest()
        request.predicate = NSPredicate(format: "study = %@", studyEntity)
        request.sortDescriptors = [NSSortDescriptor(key: "finishDate", ascending: true)]
        var fetchedContents: [Content] = []

        do {
            fetchedContents = try persistentContainer.viewContext.fetch(request)
        } catch {
            print(error.localizedDescription)
        }
        return fetchedContents
    }
    
    func fetchLastContent(studyEntity: Study) -> Content? {
        let request: NSFetchRequest<Content> = Content.fetchRequest()
        request.predicate = NSPredicate(format: "study = %@", studyEntity)
        request.sortDescriptors = [NSSortDescriptor(key: "finishDate", ascending: true)]
        
        do {
            let contents = try persistentContainer.viewContext.fetch(request)
            return contents.last
        } catch {
            print("error")
            return nil
        }
    }
    
    
    // MARK: UPDATE
    func updateMembersFine(studyEntity: Study, contentEntity: Content, fine: (total: Int,plus: Int), membersPost: [PostResponse], completion: @escaping () -> ()) {
    
        // study에 저장된 멤버 데이터 가지고오기
        let studyMembers: [User] = fetchCoreDataMembers(study: studyEntity)

        // 마지막 content에 저장된 멤버 데이터 가지고오기
        var lastContentMembers = fetchCoreDataContentMembers(content: contentEntity)

        // content에 벌금 업데이트
        contentEntity.totalFine = Int64(fine.total)
        contentEntity.plusFine = Int64(fine.plus)
        
        // 게시글 작성하지 않은 멤버 카운트
        let notPostMemberCount = membersPost.filter({$0.data == nil}).count
        
        // 이름 비교를 위해
        let lastContentMembersName = lastContentMembers.map({$0.name})
        let membersPostName = membersPost.map({$0.name})
        
        // 이름만 따로 가져오고
        let names = lastContentMembersName.filter({ !membersPostName.contains($0) })
        
        // 스터디 멤버에 속하지 않는 멤버 삭제
        if !names.isEmpty {
            for name in names {
                let deleteMember = lastContentMembers.filter({$0.name == name})
                deleteContentMember(user: deleteMember[0])
            }
        }
        
        // 벌금 업데이트하는데
        // content에 있는 멤버는 업데이트하고
        // 없는 멤버는 추가
        for post in membersPost {
            // content에 해당 멤버가 있으면
            if let index = lastContentMembers.firstIndex(where: {$0.name == post.name}) {
                
                // 작성한 게시글이 있으면
                if post.data != nil {
                    if let index = studyMembers.firstIndex(where: {$0.name == post.name}) {
                        studyMembers[index].fine += Int64(fine.plus)
                    }
                    
                    lastContentMembers[index].postUrl = post.data?.postUrl
                    lastContentMembers[index].title = post.data?.title
                } else {
                    if let index = studyMembers.firstIndex(where: {$0.name == post.name}) {
                        studyMembers[index].fine -= Int64(fine.total) / Int64(notPostMemberCount)
                    }
                }
            } else {
                
                if let index = studyMembers.firstIndex(where: {$0.name == post.name}) {
                    // 새로 추가된 멤버 추가하기
                    if post.data != nil {
                        studyMembers[index].fine += Int64(fine.plus)
                        let contentMember = ContentUser(context: persistentContainer.viewContext)
                        contentMember.name = post.name
                        contentMember.postUrl = post.data?.postUrl
                        contentMember.title = post.data?.title
                        contentMember.fine = Int64(Int(studyEntity.fine).convertFineInt())
                        contentEntity.addToMembers(contentMember)
                        lastContentMembers.append(contentMember)
                    } else {
                        studyMembers[index].fine -= Int64(fine.total) / Int64(notPostMemberCount)
                        let contentMember = ContentUser(context: persistentContainer.viewContext)
                        contentMember.name = post.name
                        contentMember.postUrl = nil
                        contentMember.title = nil
                        contentMember.fine = Int64(Int(studyEntity.fine).convertFineInt())
                        contentEntity.addToMembers(contentMember)
                        lastContentMembers.append(contentMember)
                    }
                }
            }
        }
  
        let nextContentEntity = Content(context: persistentContainer.viewContext)
        // 현재 공지의 마감일을 기준으로 한주 뒤에 마감일 언제인지
        let setDay = Int(studyEntity.finishDay) //Int(contentEntity.finishWeekDay)
        let nextWeekFinishDate = contentEntity.finishDate?.getFinishDate(finishDayNum: setDay, type: .nextWeek)
    
        nextContentEntity.currentWeekNumber = Int64((studyEntity.startDate?.calculateWeekNumber(finishDate: nextWeekFinishDate!))!)
        nextContentEntity.finishDate = nextWeekFinishDate
        nextContentEntity.plusFine = 0
        nextContentEntity.finishWeekDay = studyEntity.finishDay
        

        // Content 멤버에 study member에 저장한 데이터 그대로 업데이트 해야함
        for member in studyMembers {
            let contentMember = ContentUser(context: persistentContainer.viewContext)
            contentMember.name = member.name
            contentMember.fine = member.fine
            
            nextContentEntity.addToMembers(contentMember)
        }
        
        studyEntity.addToContents(nextContentEntity)
        
        saveContext()
        
        completion()
    }
    
    // 시작 날짜 변경시 content의 CurrentWeekNumber 다시 계산해서 업데이트
    func updateContentCurrentWeekNumber(startDate: Date, studyEntity: Study, completion: @escaping () -> ()) {
    
        let contents = fetchContent(studyEntity: studyEntity)
        
        for i in contents {
            let calcWeekNumber = startDate.calculateWeekNumber(finishDate: i.finishDate!)
            i.currentWeekNumber = Int64(calcWeekNumber)
        }
        
        completion()
    }
    
    func updateLastContentMembers(lastContent: Content, studyMembers: [User]) {
        let lastContentMembers = fetchCoreDataContentMembers(content: lastContent)
        
        // 공지사항에 있는 멤버들의 벌금을 Study에 속한 멤버 데이터에 업데이트 (벌금 상태 동기화)
        for member in lastContentMembers {
            if let index = studyMembers.firstIndex(where: {$0.name == member.name}) {
                studyMembers[index].fine = member.fine
            }
        }
    }
    
    
    
    
    // 멤버 가져오기
    // 데이터 변경시
    func fetchCoreDataMembers(study: Study) -> [User] {
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "study = %@", study)
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        var result = [User]()
    
        do {
            result = try persistentContainer.viewContext.fetch(request)
        } catch {
            print(error.localizedDescription)
        }
        return result
    }
    
    // 멤버 가져오기
    // 블로그 데이터 가져올때
    func fetchCoreDataMembers(study: Study) -> [UserModel] {
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "study = %@", study)
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        var result = [UserModel]()

        do {
            let members = try persistentContainer.viewContext.fetch(request)

            members.forEach { member in
                let userModel = UserModel(name: member.name, blogUrl: member.blogUrl, fine: Int(member.fine))
                result.append(userModel)
            }

        } catch {
            print(error.localizedDescription)
        }
        return result
    }
    
    func fetchCoreDataContentMembers(content: Content) -> [ContentUser] {
        let request: NSFetchRequest<ContentUser> = ContentUser.fetchRequest()
        request.predicate = NSPredicate(format: "content = %@", content)
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        var result: [ContentUser] = []
        
        do {
            result = try persistentContainer.viewContext.fetch(request)
        } catch {
            print(error.localizedDescription)
        }
        return result
    }
    
    
    // MARK: DELETE
    func deleteStudy(study: Study) {
        let context = persistentContainer.viewContext
        context.delete(study)
        saveContext()
    }
    
    func deleteContent(content: Content) {
        let context = persistentContainer.viewContext
        context.delete(content)
        saveContext()
    }
    
    func deleteStudyMember(user: User) {
        let context = persistentContainer.viewContext
        context.delete(user)
        saveContext()
    }
    
    func deleteStudyMemberTest(user: User) {
        let context = persistentContainer.viewContext
        context.delete(user)
    }
    
    func deleteContentMember(user: ContentUser) {
        let context = persistentContainer.viewContext
        context.delete(user)
        saveContext()
    }
    
    func deleteContentMembers(members: [ContentUser]) {
        
        let context = persistentContainer.viewContext
        members.forEach { member in
            context.delete(member)
        }
    }
    
    func deletaAll() {
        let readRequest = NSFetchRequest<NSManagedObject>(entityName: "Study")
        let readRequest2 = NSFetchRequest<NSManagedObject>(entityName: "User")
        let studyDatas = try! context.fetch(readRequest)
        let userDatas = try! context.fetch(readRequest2)
        
        for data in studyDatas {
            context.delete(data)
        }
        
        for data in userDatas {
            context.delete(data)
        }
        
        saveContext()
    }
    
    // MARK: SAVE
    func saveContext() {
        
        guard context.hasChanges else { return }
        
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            debugPrint(nsError.localizedDescription)
        }
    }
    
    
    
    
    
//    // ========================================
//    // StudyComposeViewModel에서 사용할 메서드
//    func updateCurrentWeekLastContentFinishDate(contentList: [Content], studyEntity: Study?, studyMembers: [User], finishDate: Date, finishDay: Int, completion: @escaping () -> ()) {
//
//        var copyContentList = contentList
//
//        // 마지막 공지사항 삭제
//        if let lastContent = copyContentList.last {
//            deleteContent(content: lastContent)
//            copyContentList.removeLast()
//        }
//
//        // 그 다음 업데이트 할 마지막 공지사항
//        if let updateLastContent = copyContentList.last {
//
//            // 공지사항 갯수에 따라서 분기처리
//            // 이전 공지사항의 마감일에 맞춰 마감요일을 업데이트해줘야함
//            // count == 1 >>> 공지사항이 한개라면 변경한 요일로 업데이트
//            // count가 2개 이상이라면 업데이트할 공지사항 이전 공지사항의 마감 날짜로 업데이트
//            if copyContentList.count == 1 {
//                updateLastContent.finishDate = finishDate
//                updateLastContent.finishWeekDay = Int64(finishDay)
//            } else {
//                if let index = copyContentList.firstIndex(of: updateLastContent) {
//                    let content = copyContentList[index - 1]
//
//                    // 현재 업데이트할 마감 요일이 이번주에 있다면 이전 공지사항의 마감 날짜로 업데이트
//                    if Date().calculateWeekNumber(finishDate: updateLastContent.finishDate ?? Date()) == 0 {
//
//                        // 저번주의 마감 요일의 날짜를 구한 후 업데이트
//                        let beforeWeek = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: updateLastContent.finishDate ?? Date())
//                        let newFinishDate = beforeWeek?.getFinishDate(finishDayNum: Int(content.finishWeekDay), type: .currentWeek)
//
//                        updateLastContent.finishDate = newFinishDate
//                        updateLastContent.finishWeekDay = content.finishWeekDay
//                        updateLastContent.plusFine = 0
//                        updateLastContent.totalFine = 0
//
//                        // 멤버 벌금 동기화
//                        updateLastContentMembers(lastContent: updateLastContent, studyMembers: studyMembers)
//
//                        let startDate = newFinishDate?.getStartDateAndEndDate().0 ?? Date()
//                        let endDate = newFinishDate?.getStartDateAndEndDate().1 ?? Date()
//
//                        CrawlingManager.fetchPostData(members: studyMembers, startDate: startDate, endDate: endDate) { result in
//
//                            switch result {
//                            case .success(let responseData):
//
//                                if let studyEntity = studyEntity {
//                                    let fine = self.calculateFine(studyEntity: studyEntity, members: responseData)
//
//                                    CoreDataManager.shared.updateMembersFine(studyEntity: studyEntity, contentEntity: updateLastContent, fine: (fine.totalFine, fine.plus), membersPost: responseData)
//
//                                    CoreDataManager.shared.updateContentCurrentWeekNumber(startDate: studyEntity.startDate ?? Date(), studyEntity: studyEntity)
//
//                                    completion()
//                                }
//                            case .failure(let error):
//                                print(error)
//                            }
//                        }
//                    } else {
//                        updateLastContent.finishDate = finishDate
//                        updateLastContent.finishWeekDay = Int64(finishDay)
//                        updateLastContent.plusFine = 0
//                        updateLastContent.totalFine = 0
//
//                        // 멤버 벌금 동기화
//                        updateLastContentMembers(lastContent: updateLastContent, studyMembers: studyMembers)
//                    }
//                }
//            }
//        }
//    }
//
//    func updateNextWeekLastContentFinishDate(contentList: [Content], studyEntity: Study?, studyMembers: [User], finishDate: Date, finishDay: Int, completion: @escaping () -> ()) {
//
//        let finishDate = Date().getFinishDate(finishDayNum: finishDay, type: .currentWeek)
//
//        if contentList.count == 1 {
//            if let lastContent = contentList.last {
//                lastContent.finishDate = finishDate
//                lastContent.finishWeekDay = Int64(finishDay)
//
//                let startDate = finishDate?.getStartDateAndEndDate().0 ?? Date()
//                let endDate = finishDate?.getStartDateAndEndDate().1 ?? Date()
//
//                CrawlingManager.fetchPostData(members: studyMembers, startDate: startDate, endDate: endDate) { result in
//                    switch result {
//                    case .success(let responseData):
//
//                        if let studyEntity = studyEntity {
//                            let fine = self.calculateFine(studyEntity: studyEntity, members: responseData)
//
//                            // 이름으로 인덱스 검색해서 업데이트하게 바꿔야함
//                            CoreDataManager.shared.updateMembersFine(studyEntity: studyEntity, contentEntity: lastContent, fine: (fine.totalFine, fine.plus), membersPost: responseData)
//
//                            CoreDataManager.shared.updateContentCurrentWeekNumber(startDate: studyEntity.startDate ?? Date(), studyEntity: studyEntity)
//
//                            completion()
//                        }
//                    case .failure(let error):
//                        print(error)
//                    }
//                }
//            }
//        } else {
//            // 공지사항이 2개 이상인경우
//            // 이전주 시작날짜부터 변경한 날짜까지 체크
//            // 현재 날짜 = 11일 , 원래 마감 날짜 = 16일, 변경 날짜 = 11일 (월요일)
//            // 이전주 시작 날짜 2일 ~ 10일까지 체크
//            let content = contentList[contentList.count - 2]
//            let startDate = content.finishDate?.getStartDateAndEndDate().0 ?? Date()
//            let endDate = finishDate ?? Date()
//
//            CrawlingManager.fetchPostData(members: studyMembers, startDate: startDate, endDate: endDate) { result
//                in
//                switch result {
//                case .success(let responseData):
//
//                    if let studyEntity = studyEntity {
//                        let fine = self.calculateFine(studyEntity: studyEntity, members: responseData)
//
//                        content.finishDate = endDate
//                        content.finishWeekDay = Int64(finishDay)
//
//                        if let lastContent = contentList.last {
//                            CoreDataManager.shared.deleteContent(content: lastContent)
//                        }
//
//                        let members: [User] = CoreDataManager.shared.fetchCoreDataMembers(study: studyEntity)
//                        let contentMembers = CoreDataManager.shared.fetchCoreDataContentMembers(content: content)
//
//                        for contentMember in contentMembers {
//                            let index = members.firstIndex(where: {$0.name == contentMember.name})
//                            members[index!].fine = contentMember.fine
//                        }
//
//                        // 새로운 공지 생성
//                        CoreDataManager.shared.updateMembersFine(studyEntity: studyEntity, contentEntity: content, fine: (fine.totalFine, fine.plus), membersPost: responseData)
//
//                        CoreDataManager.shared.updateContentCurrentWeekNumber(startDate: studyEntity.startDate ?? Date(), studyEntity: studyEntity)
//
//                        completion()
//                    }
//                case .failure(let error):
//                    print(error)
//                }
//            }
//        }
//
//    }
//
//    func calculateFine(studyEntity: Study, members: [PostResponse]) -> (totalFine: Int, plus :Int){
//        var resultFine = 0
//
//        // 작성 안한사람
//        let notPostCount = members.filter({$0.data == nil}).count
//        // 작성한 사람
//        let postCount = members.filter({$0.data != nil}).count
//
//        // 다 작성했거나 다 작성 안했거나 하면 벌금 0 원
//        if notPostCount == members.count || postCount == members.count {
//            return (0, 0)
//        }
//
//        // 각 멤버별 벌금 합계
//        let totalFine = Int(studyEntity.fine ?? 0).convertFineInt() * notPostCount
//
//        // 분배할 금액
//        resultFine = totalFine / postCount
//
//        return (totalFine, resultFine)
//    }
    
   
    
    
    
    
    
    
    
    
    
    
    
//    func StudySettingModel() -> Study? {
//        do {
//            guard let studyList = try persistentContainer.viewContext.fetch(Study.fetchRequest()) as? [Study] else { return nil }
//
//            guard let studyModel = studyList.first else {
//                guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: persistentContainer.viewContext) else {
//                    return nil
//                }
//
//                let initiaModel = NSManagedObject(entity: entity, insertInto: persistentContainer.viewContext) as? Study
//
//                return initiaModel
//            }
//            return studyModel
//        } catch {
//            print(error.localizedDescription)
//        }
//        return nil
//    }
    
}



//    // MARK: CREATE
//    func create<T>(_ model: T) {
//
//        switch model {
//
//        case is UserModel:
//            guard let userModel = model as? UserModel else { return }
//
//            if let entity = userEntity {
//                let userObject = NSManagedObject(entity: entity, insertInto: context)
//                userObject.setValue(userModel.name, forKey: "name")
//                userObject.setValue(userModel.blogUrl, forKey: "blogUrl")
//
//                saveContext()
//            }
//        case is StudyModel:
//            guard let studyModel = model as? StudyModel else { return }
//
//            if let entity = studyEntity {
//                let studyObject = NSManagedObject(entity: entity, insertInto: context)
//                studyObject.setValue(UUID().uuidString, forKey: "id")
//                studyObject.setValue(studyModel.title, forKey: "title")
//                studyObject.setValue(studyModel.announcement, forKey: "announcement")
//                studyObject.setValue(studyModel.setDate, forKey: "setDate")
//                studyObject.setValue(studyModel.fine, forKey: "fine")
//                studyObject.setValue(studyModel.createDate, forKey: "createDate")
//                studyObject.setValue(studyModel.endDate, forKey: "endDate")
//
//                saveContext()
//            }
//        default:
//            print("")
//        }

    
    
//        let entity = NSEntityDescription.entity(forEntityName: "Study", in: self.container.viewContext)!
//
//        let studyRoom = NSManagedObject(entity: entity, insertInto: self.container.viewContext)
//
//        studyRoom.setValue("공지사항", forKey: "announcement")
//        studyRoom.setValue(Date(), forKey: "createDate")
//        studyRoom.setValue(Date(), forKey: "endDate")
//        studyRoom.setValue(5000, forKey: "fine")
//        studyRoom.setValue(7, forKey: "setDate")
//        studyRoom.setValue("스터디 이름", forKey: "title")
//
//        do {
//            try self.container.viewContext.save()
//        } catch {
//            print(error)
//        }
//    }

//    // MARK: READ
//    func read() -> [StudyModel] {
//
//        let readRequest = NSFetchRequest<NSManagedObject>(entityName: "Study")
//
//        let studyDatas = try! context.fetch(readRequest)
//
//        var studyList = [StudyModel]()
//
//        for data in studyDatas {
//            let id = data.value(forKey: "id") as! String
//            let title = data.value(forKey: "title") as! String
//            let announcement = data.value(forKey: "announcement") as! String
//            let fine = data.value(forKey: "fine") as! Int
//            let setDate = data.value(forKey: "setDate") as! Int
//            let createDate = data.value(forKey: "createDate") as! Date
//            let endDate = data.value(forKey: "endDate") as! Date
//
//            studyList.append(StudyModel(id: id, title: title, announcement: announcement, setDate: setDate, fine: fine, createDate: createDate, endDate: endDate, members: nil))
//        }
//        return studyList
//    }
//


//    var studyEntity: NSEntityDescription? {
//        return  NSEntityDescription.entity(forEntityName: "Study", in: context)
//    }
//
//    var userEntity: NSEntityDescription? {
//        return  NSEntityDescription.entity(forEntityName: "User", in: context)
//    }

//    func updateStudy(study: Study) {
//        let request: NSFetchRequest<Study> = Study.fetchRequest()
//        request.predicate = NSPredicate(format: "study = %@", study)
//
//        var fetchedStudys: [Study] = []
//
//        do {
//            fetchedStudys = try persistentContainer.viewContext.fetch(request)
//
//        } catch {
//            print(error.localizedDescription)
//        }
//    }

//    // 스터디 생성
//    func study(_ model: StudyModel) -> Study {
//        let study = Study(context: persistentContainer.viewContext)
//        study.title = model.title
//        study.announcement = model.announcement
//        study.setDate = Int64(model.setDate)
//        study.fine = Int64(model.fine)
//        study.createDate = model.createDate
//        study.endDate = model.endDate
//        study.memberCount = Int64(model.memberCount)
//
//        return study
//    }

//    // 멤버 생성
//    func member(_ members: [UserModel], study: Study) {
//
//        var result = [User]()
//
//        for member in members {
//            let user = User(context: persistentContainer.viewContext)
//            user.name = member.name
//            user.blogUrl = member.blogUrl
//            study.addToMembers(user)
//
//            result.append(user)
//        }
//    }



//    func createContent(studyEntity: Study, members: [User]) {
//        let contentEntity = Content(context: persistentContainer.viewContext)
//
//        // [테스트 날짜]
//        let calendar = Calendar.current
//        let components = DateComponents(year: 2023, month: 7, day: 24)
//        let currentDate = calendar.date(from: components)!
//
////        contentEntity.currentWeekNumber = Int64(studyEntity.startDate?.testCalculateWeekNum() ?? 0)
////        contentEntity.finishDay = currentDate.testCalcFinishDay(setDay: Int(studyEntity.setDay))
////        contentEntity.plusFine = 0
//
//        //contentEntity.weekNumber = Int64(studyEntity.startDate?.calcNextWeekNum(nextWeek: <#T##Date#>, ) ?? 0)
//        contentEntity.finishDate = Date().calcFinishDay(setDay: Int(studyEntity.finishDay))
//        contentEntity.plusFine = 0
//
//        print(Date().timeIntervalSinceReferenceDate)
//
//        studyEntity.addToContents(contentEntity)
//
//        addContentMembers(members: members, content: contentEntity)
//    }
