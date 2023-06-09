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
            let contentUser = ContentUser(context: persistentContainer.viewContext)
            contentUser.name = member.name
            contentUser.postUrl = nil
            contentUser.fine = member.fine
            
            content.addToMembers(contentUser)
        }
    }
    
    // 공지사항 생성할때 콘텐트 엔티티에 연결
//    func addContentMember(members: [ContentUserModel?], content: Content) {
//        for member in members {
//            let contentUser = ContentUser(context: persistentContainer.viewContext)
//            contentUser.name = member?.name
//            contentUser.postUrl = member?.postURL
//            contentUser.fine = Int64(member?.fine ?? 0)
//
//            content.addToMembers(contentUser)
//        }
//    }
    
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
    
    func updateMembersFine(studyEntity: Study, contentEntity: Content, fine: (total: Int,plus: Int), membersPost: [PostResponse]) {
        
        // study에 저장된 멤버 데이터 가지고오기
        let studyMembers: [User] = fetchCoreDataMembers(study: studyEntity)
        
        // 마지막 content에 저장된 멤버 데이터 가지고오기
        let lastContentMembers = fetchCoreDataContentMembers(content: contentEntity)
        
        // content에 벌금 업데이트
        contentEntity.totalFine = Int64(fine.total)
        contentEntity.plusFine = Int64(fine.plus)
        
        let notPostMemberCount = membersPost.filter({$0.data == nil}).count

        // study에 저장된 멤버 벌금 업데이트
        for i in 0..<membersPost.count {
            
            if membersPost[i].data != nil {
                studyMembers[i].fine += Int64(fine.plus)
                lastContentMembers[i].postUrl = membersPost[i].data?.postUrl
                lastContentMembers[i].title = membersPost[i].data?.title
            } else {
                studyMembers[i].fine -= Int64(fine.total) / Int64(notPostMemberCount)
            }
        }
        
        let nextContentEntity = Content(context: persistentContainer.viewContext)
        // 현재 공지의 마감일을 기준으로 한주 뒤에 마감일 언제인지
        let setDay = Int(contentEntity.finishWeekDay)
        let nextWeekFinishDate = contentEntity.finishDate?.getFinishDate(finishDayNum: setDay, type: .nextWeek)
    
        nextContentEntity.currentWeekNumber = Int64((studyEntity.startDate?.calculateWeekNumber(finishDate: nextWeekFinishDate!))!)
        nextContentEntity.finishDate = nextWeekFinishDate
        nextContentEntity.plusFine = 0
        nextContentEntity.finishWeekDay = contentEntity.finishWeekDay

        // Content 멤버에 study member에 저장한 데이터 그대로 업데이트 해야함
        for member in studyMembers {
            let contentMember = ContentUser(context: persistentContainer.viewContext)
            contentMember.name = member.name
            contentMember.fine = member.fine
            
            nextContentEntity.addToMembers(contentMember)
        }
        
        studyEntity.addToContents(nextContentEntity)
        
        saveContext()
    }
    
    // 시작 날짜 변경시 content의 CurrentWeekNumber 다시 계산해서 업데이트
    func updateContentCurrentWeekNumber(startDate: Date, studyEntity: Study) {
    
        let contents = fetchContent(studyEntity: studyEntity)
        
        for i in contents {
            let calcWeekNumber = startDate.calculateWeekNumber(finishDate: i.finishDate!)
            i.currentWeekNumber = Int64(calcWeekNumber)
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
