//
//  TestCoreDataManager.swift
//  BlogAppTests
//
//  Created by PKW on 1/23/25.
//

@testable import BlogApp
import CoreData
import Foundation

class TestCoreDataManager {
    static let shared = TestCoreDataManager()
    private init() {}
    
    private let entityName = "CoreData"
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: self.entityName)
        
        // 메모리 타입으로 저장소 설정
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                debugPrint(error, error.userInfo)
            }
        }
        return container
    }()
    
    // MARK: CREATE

    func createStudy(isNewStudy: Bool, lastProgressNumber: Int?, lastProgressDeadlineDate: Date?, title: String, firstStudyDate: Date, deadlineDay: Int, deadlineDate: Date, fine: Int, members: [User], completion: @escaping () -> ()) {
        let studyEntity = Study(context: persistentContainer.viewContext)
        // 생성 날짜
        studyEntity.createDate = Date()
        // 신규, 기존
        studyEntity.isNewStudy = isNewStudy
        // 스터디 이름
        studyEntity.title = title
        // 최초 시작 날짜
        studyEntity.firstStartDate = firstStudyDate
        // 마감 요일
        studyEntity.deadlineDay = Int64(deadlineDay)
        // 벌금
        studyEntity.fine = Int64(fine)
        // 멤버 수
        studyEntity.memberCount = Int64(members.count)
        // 멤버
        for member in members {
            studyEntity.addToMembers(member)
        }
        
        // 회차 데이터 생성
        let contentEntity = Content(context: persistentContainer.viewContext)
        // 신규
        if isNewStudy == true {
            // 회차
            contentEntity.contentNumber = 1
            // 마감 요일 (삭제해도 됨)
            contentEntity.deadlineDay = Int64(deadlineDay)
            // 마감 날짜
            contentEntity.deadlineDate = deadlineDate
            
            studyEntity.addToContents(contentEntity)
        } else {
            // 마지막 스터디 진행 회차
            contentEntity.contentNumber = Int64(lastProgressNumber ?? 0)
            // 마감 요일
            contentEntity.deadlineDay = Int64(deadlineDay)
            // 마지막 스터디 진행 회차의 마감 날짜
            contentEntity.startDate = lastProgressDeadlineDate?.makeDeadlineDate()?.convertDeadlineToStartDate()
            // 마감 날짜
            contentEntity.deadlineDate = deadlineDate
            
            studyEntity.addToContents(contentEntity)
        }
        
        saveContext()
        
        completion()
    }
    
    func createContent(lastContent: Content?, deadlineDay: Int, startDate: Date, deadlineDate: Date, fine: Int, totalFine: Int, plusFine: Int, studyMembers: [User], contentMembers: [ContentUser], completion: @escaping () -> ()) {
        
        // 마지막 마감 데이터 정보 업데이트
        lastContent?.deadlineDay = Int64(deadlineDay)
        lastContent?.startDate = startDate
        lastContent?.deadlineDate = deadlineDate
        lastContent?.fine = Int64(fine)
        lastContent?.totalFine = Int64(totalFine)
        lastContent?.plusFine = Int64(plusFine)
        
        // 스터디에 설정된 마감요일
        let studyDeadlineDay = Int(studyMembers.first?.study?.deadlineDay ?? 0)
        
        // 새로운 공지사항 만들고
        let contentEntity = Content(context: persistentContainer.viewContext)
        contentEntity.contentNumber = (lastContent?.contentNumber ?? 0) + 1
        // 시작 날짜는 이전 마감일로부터 + 1일
        contentEntity.startDate = lastContent?.deadlineDate?.convertDeadlineToStartDate()
        // 스터디에 설정된 마감요일에 날짜로 새로 계산
        let calcDeadlineDate = contentEntity.startDate?.calculateFinishDate(deadlineDay: studyDeadlineDay)
        
        if calcDeadlineDate?.nextWeekFinishDate == nil {
            contentEntity.deadlineDate = calcDeadlineDate?.currentDate
        } else {
            contentEntity.deadlineDate = calcDeadlineDate?.nextWeekFinishDate
        }
        
        if let studyEntity = lastContent?.study {
            // 새로 생성한 content study에 연결
            studyEntity.addToContents(contentEntity)
        }
        
        for i in 0 ..< studyMembers.count {
            lastContent?.addToMembers(contentMembers[i])
            studyMembers[i].fine = contentMembers[i].fine
        }

        saveContext()
        completion()
    }
    
    // MARK: READ

    func fetchStudyList() -> [Study] {
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
    
    func fetchStudy(id: NSManagedObjectID) -> Study? {
        do {
            return try context.existingObject(with: id) as? Study
        } catch {
            print("fetchStudy - ERROR")
            return nil
        }
    }
    
    func fetchContentList(studyEntity: Study) -> [Content] {
        let request: NSFetchRequest<Content> = Content.fetchRequest()
        request.predicate = NSPredicate(format: "study = %@", studyEntity)
        request.sortDescriptors = [NSSortDescriptor(key: "deadlineDate", ascending: true)]
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
        request.sortDescriptors = [NSSortDescriptor(key: "deadlineDate", ascending: true)]
        var fetchedContents: [Content] = []
        
        do {
            fetchedContents = try persistentContainer.viewContext.fetch(request)
        } catch {
            print(error.localizedDescription)
        }
        return fetchedContents.last
    }
    
    func fetchStudyMembers(studyEntity: Study) -> [User] {
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "study = %@", studyEntity)
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        do {
            return try persistentContainer.viewContext.fetch(request)
        } catch {
            print(error.localizedDescription)
        }
        
        return []
    }
    
    func fetchContentMembers(contentEntity: Content?) -> [ContentUser] {
        let request: NSFetchRequest<ContentUser> = ContentUser.fetchRequest()
        guard let contentEntity = contentEntity else { return [] }
        request.predicate = NSPredicate(format: "content = %@", contentEntity)
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
    
        do {
            return try persistentContainer.viewContext.fetch(request)
        } catch {
            print(error.localizedDescription)
        }
        return []
    }

    // MARK: UPDATE

    func updateStudy(id: NSManagedObjectID?, title: String?, deadlineDay: Int, deadlineDate: Date, fine: Int, members: [User], completion: @escaping () -> ()) {
        if let studyID = id,
           let studyEntity = fetchStudy(id: studyID)
        {
            studyEntity.title = title
            studyEntity.deadlineDay = Int64(deadlineDay)
            studyEntity.fine = Int64(fine)
            
            for member in members {
                if member.study == nil {
                    studyEntity.addToMembers(member)
                }
            }
            
            studyEntity.memberCount = Int64(studyEntity.members?.count ?? 0)
            
            let lastContent = fetchLastContent(studyEntity: studyEntity)
            lastContent?.deadlineDay = Int64(deadlineDay)
            lastContent?.deadlineDate = deadlineDate
        }
        
        saveContext()
        
        completion()
    }
    
    // MARK: DELETE

    func deleteStudy(study: Study?) {
        let context = persistentContainer.viewContext
        
        if let studyEntity = study {
            context.delete(studyEntity)
        }
        
        saveContext()
    }
    
    func deleteStudyMember(member: User) {
        let context = persistentContainer.viewContext
        context.delete(member)
    }
    
    func deleteStudyMembers(members: [User]) {
        for member in members {
            let context = persistentContainer.viewContext
            context.delete(member)
        }
    }
    
    func deleteContentMembers(members: [ContentUser]) {
        for member in members {
            let context = persistentContainer.viewContext
            context.delete(member)
        }
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
    
    func resetPersistentStore() {
        let coordinator = persistentContainer.persistentStoreCoordinator
        for store in coordinator.persistentStores {
            do {
                try coordinator.remove(store)
                try coordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
            } catch {
                fatalError("Failed to reset persistent store: \(error)")
            }
        }
    }
}
