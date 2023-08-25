//
//  CoreDataManager.swift
//  BlogApp
//
//  Created by PKW on 2023/05/18.
//

import Foundation
import CoreData

/// `CoreDataManager`는 CoreData 작업을 관리 합니다.
class CoreDataManager {
    
    // MARK:  ===== [CoreData Setting] =====
    // 싱글톤 인스턴스
    static let shared = CoreDataManager()
    
    // 초기화
    private init() {}
    
    // CoreDataEntity 이름
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
    
    
    // MARK:  ===== [Function] =====
    
    
    
    // MARK: CREATE
    
    /// 새로운 스터디를 생성합니다.
    ///
    /// 신규로 진행하거나 기존에 진행중이던 스터디를 구분하여 생성하며,
    /// 해당 회차의 마감 정보도 같이 생성합니다.
    ///
    /// - Parameters:
    ///   - isNewStudy: 새로운 스터디인지 기존 스터디인지 여부, 새로운 스터디이면 `true`, 아니면 `false`
    ///   - lastProgressNumber: 기존 스터디일 경우 마지막 회차 번호
    ///   - lastProgressDeadlineDate: 기존 스터디일 경우 마지막 회차 마감 날짜
    ///   - title: 스터디 제목
    ///   - firstStudyDate: 최초 시작 날짜
    ///   - deadlineDay: 마감일
    ///   - deadlineDate: 마감 날짜
    ///   - fine: 벌금
    ///   - members: 현재 등록된 멤버 목록
    ///   - completion: 스터디가 생성 완료된 후 호출할 콜백 함수입니다.
    func createStudy(isNewStudy: Bool?, lastProgressNumber: Int?, lastProgressDeadlineDate: Date?, title: String?, firstStudyDate: Date?, deadlineDay: Int?, deadlineDate: Date?, fine: Int?, members: [User], completion: @escaping () -> ()) {
        
        let studyEntity = Study(context: persistentContainer.viewContext)
        // 스터디 생성 날짜(현재)
        studyEntity.createDate = Date()
        // 신규, 기존
        studyEntity.isNewStudy = isNewStudy ?? true
        // 스터디 이름
        studyEntity.title = title
        // 최초 시작 날짜
        studyEntity.firstStartDate = firstStudyDate
        // 마감 요일
        studyEntity.deadlineDay = Int64(deadlineDay ?? 0)
        // 벌금
        studyEntity.fine = Int64(fine ?? 0)
        // 멤버 수
        studyEntity.memberCount = Int64(members.count)
        // 스터디 엔티티에 멤버 연결합니다.
        for member in members {
            studyEntity.addToMembers(member)
        }
        
        // 회차 데이터 생성
        let contentEntity = Content(context: persistentContainer.viewContext)
        
        // 신규 스터디이거나 진행중이던 스터디인 경우
        if isNewStudy == true {
            // 회차
            contentEntity.contentNumber = 1
            // 마감 요일 (삭제해도 됨)
            contentEntity.deadlineDay = Int64(deadlineDay ?? 0)
            // 마감 날짜
            contentEntity.deadlineDate = deadlineDate
            
            studyEntity.addToContents(contentEntity)
        } else {
            // 마지막 스터디 진행 회차
            contentEntity.contentNumber = Int64(lastProgressNumber ?? 0)
            // 마감 요일
            contentEntity.deadlineDay = Int64(deadlineDay ?? 0)
            // 마지막 스터디 진행 회차의 마감 날짜
            contentEntity.startDate = lastProgressDeadlineDate?.makeDeadlineDate()?.convertDeadlineToStartDate()
            // 마감 날짜
            contentEntity.deadlineDate = deadlineDate
            // 스터디 데이터에 연결 합니다.
            studyEntity.addToContents(contentEntity)
        }
        
        // 변경사항 저장
        saveContext()
        
        completion()
    }
    
    /// 마감 정보를 생성합니다.
    ///
    /// 해당 메소드는 마감 날짜가 지난 경우 기존 회차의 마감 데이터에 마감 정보를 업데이트하고, 다음 회차의 마감 정보를 생성합니다.
    ///
    /// - Parameters:
    ///   - lastContent: 마지막 마감 정보
    ///   - deadlineDay: 스터디에 등록된 마감일
    ///   - startDate: 마감할 회차의 시작 날짜
    ///   - deadlineDate: 마감할 회차의 마감 날짜
    ///   - fine: 스터디에 등록된 벌금
    ///   - totalFine: 총 벌금
    ///   - plusFine: 증액 해야하는 금액
    ///   - studyMembers: 스터디에 등록된 멤버 목록
    ///   - contentMembers: 마감 정보에 등록할 멤버 목록
    ///   - completion: 마감 정보가 생성 완료된 후 호출할 콜백 함수입니다.
    func createContent(lastContent: Content?, deadlineDay: Int?, startDate: Date?, deadlineDate: Date?, fine: Int?, totalFine: Int?, plusFine: Int?, studyMembers: [User], contentMembers: [ContentUser], completion: @escaping () -> ()) {
    
        // 마지막 마감 데이터 정보 업데이트
        lastContent?.deadlineDay = Int64(deadlineDay ?? 0)
        lastContent?.startDate = startDate
        lastContent?.deadlineDate = deadlineDate
        lastContent?.fine = Int64(fine ?? 0)
        lastContent?.totalFine = Int64(totalFine ?? 0)
        lastContent?.plusFine = Int64(plusFine ?? 0)
        
        // 스터디에 설정된 마감요일
        let studyDeadlineDay = Int(studyMembers.first?.study?.deadlineDay ?? 0)
        
        // 새로운 마감 정보를 생성합니다.
        let contentEntity = Content(context: persistentContainer.viewContext)
        // 새로운 마감 번호(이전 마감 정보 번호에 +1)
        contentEntity.contentNumber = (lastContent?.contentNumber ?? 0) + 1
        // 새로운 마감 시작 날짜
        contentEntity.startDate = lastContent?.deadlineDate?.convertDeadlineToStartDate()
        // 스터디에 설정된 마감일을 기준으로 마감날짜 계산
        let calcDeadlineDate = contentEntity.startDate?.calculateDeadlineDate(deadlineDay: studyDeadlineDay)
        
        // 마감 날짜가 다음주인지 이번주인지
        if calcDeadlineDate?.nextWeekFinishDate == nil {
            contentEntity.deadlineDate = calcDeadlineDate?.currentDate
        } else {
            contentEntity.deadlineDate = calcDeadlineDate?.nextWeekFinishDate
        }
        
        if let studyEntity = lastContent?.study {
            // 새로 생성한 content study에 연결
            studyEntity.addToContents(contentEntity)
        }
        
        // 마지막 마감 정보에 저장할 멤버 연결
        for i in 0 ..< studyMembers.count {
            lastContent?.addToMembers(contentMembers[i])
            studyMembers[i].fine = contentMembers[i].fine
        }

        // 변경사항 저장
        saveContext()
        
        completion()
    }
    
    // MARK: READ
    
    /// 저장된 모든 스터디 목록을 가져옵니다.
    /// - Returns: `Study` 객체의 배열로,  생성 날짜를 기준으로 오름차순 정렬되어 반환됩니다.
    func fetchStudyList() -> [Study] {
        
        let request: NSFetchRequest<Study> = Study.fetchRequest()
        // 가져올 스터디의 정렬 순서를 설정합니다. (생성 날짜를 기준으로 오름차순)
        request.sortDescriptors = [NSSortDescriptor(key: "createDate", ascending: true)]
        
        var fetchedStudys: [Study] = []
        
        do {
            // 결과를 fetchedStudys 배열에 저장합니다.
            fetchedStudys = try persistentContainer.viewContext.fetch(request)
        } catch {
            // 요청 수행 중 오류가 발생할 경우 오류 메시지를 출력합니다.
            print(error.localizedDescription)
        }
        
        // 스터디 목록을 반환합니다.
        return fetchedStudys
    }
    
    /// ID에 해당하는 스터디를 가져옵니다.
    ///
    /// - Parameter id: 가져올 스터디의 `NSManagedObjectID`
    /// - Returns: `NSManagedObjectID`에 해당하는 `Study` 객체가 반환되며, 해당하는 객체가 없거나 오류 발생 시 nil을 반환합니다.
    func fetchStudy(id: NSManagedObjectID) -> Study? {
        do {
            return try context.existingObject(with: id) as? Study
        } catch {
            print("fetchStudy - ERROR")
            return nil
        }
    }
    
    /// 해당 스터디에 저장된 모든 마감 정보를 가져옵니다.
    ///
    /// - Parameter studyEntity: 마감 정보를 가지고올 `Study` 객체
    /// - Returns: `studyEntity`에 해당하는 모든 `Content` 객체의 배열이 반환되며, 해당하는 객체가 없거나 오류 발생 시 빈 배열을 반환합니다.
    func fetchContentList(studyEntity: Study) -> [Content] {
        let request: NSFetchRequest<Content> = Content.fetchRequest()
        
        // studyEntity와 연결된 컨텐츠만 필터링합니다.
        request.predicate = NSPredicate(format: "study = %@", studyEntity)
        // 결과를 deadlineDate 기준으로 오름차순 정렬합니다.
        request.sortDescriptors = [NSSortDescriptor(key: "deadlineDate", ascending: true)]
        
        var fetchedContents: [Content] = []
        
        do {
            // 결과를 fetchedContents에 저장합니다.
            fetchedContents = try persistentContainer.viewContext.fetch(request)
        } catch {
            // 요청 수행 중 오류가 발생할 경우 오류 메시지를 출력합니다.
            print(error.localizedDescription)
        }
        
        // 마감 정보 목록을 반환합니다.
        return fetchedContents
    }
    
    /// 해당 스터디에 저장된 마지막 마감 정보를 가져옵니다.
    ///
    /// - Parameter studyEntity: 마감 정보를 가지고올 `Study` 객체
    /// - Returns: `studyEntity`에 해당하는 마지막 `Content` 객체가 반환되며, 해당하는 객체가 없거나 오류 발생 시 빈 배열을 반환합니다.
    func fetchLastContent(studyEntity: Study) -> Content? {
        let request: NSFetchRequest<Content> = Content.fetchRequest()
        
        // studyEntity와 연결된 컨텐츠만 필터링합니다.
        request.predicate = NSPredicate(format: "study = %@", studyEntity)
        // 결과를 deadlineDate 기준으로 오름차순 정렬합니다.
        request.sortDescriptors = [NSSortDescriptor(key: "deadlineDate", ascending: true)]
        
        var fetchedContents: [Content] = []
        
        do {
            // 결과를 fetchedContents에 저장합니다.
            fetchedContents = try persistentContainer.viewContext.fetch(request)
        } catch {
            // 요청 수행 중 오류가 발생할 경우 오류 메시지를 출력합니다.
            print(error.localizedDescription)
        }
        // 마지막 마감 정보를 반환합니다.
        return fetchedContents.last
    }
    
    /// 해당 스터디에 저장된 멤버 목록을 가져옵니다.
    ///
    /// - Parameter studyEntity: 멤버 목록을 가지고올 `Study` 객체
    /// - Returns: `studyEntity`에 해당하는 모든 `User` 객체의 배열이 반환되며, 해당하는 객체가 없거나 오류 발생 시 빈 배열을 반환합니다.
    func fetchStudyMembers(studyEntity: Study) -> [User] {
        let request: NSFetchRequest<User> = User.fetchRequest()
        
        // studyEntity와 연결된 멤버만 필터링합니다.
        request.predicate = NSPredicate(format: "study = %@", studyEntity)
        // 결과를 name 기준으로 오름차순 정렬합니다.
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        do {
            // 멤버 목록을 반환합니다.
            return try persistentContainer.viewContext.fetch(request)
        } catch {
            print(error.localizedDescription)
        }
        
        return []
    }
    
    /// 해당 마감 정보에 저장된 멤버 목록을 가져옵니다.
    ///
    /// - Parameter contentEntity: 멤버 목록을 가지고올 `Content` 객체
    /// - Returns: `contentEntity`에 해당하는 모든 `ContentUser` 객체의 배열이 반환되며, 해당하는 객체가 없거나 오류 발생 시 빈 배열을 반환합니다.
    func fetchContentMembers(contentEntity: Content?) -> [ContentUser] {
        let request: NSFetchRequest<ContentUser> = ContentUser.fetchRequest()
        
        // contentEntity가 nil이면 빈배열을 반환합니다.
        guard let contentEntity = contentEntity else { return [] }
        
        // contentEntity와 연결된 멤버만 필터링합니다.
        request.predicate = NSPredicate(format: "content = %@", contentEntity)
        // 결과를 name 기준으로 오름차순 정렬합니다.
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
    
        do {
            // 멤버 목록을 반환합니다.
            return try persistentContainer.viewContext.fetch(request)
        } catch {
            print(error.localizedDescription)
        }
        return []
    }

    
    // MARK: UPDATE
    
    
    /// 스터디 정보를 업데이트 합니다.
    ///
    /// 스터디 정보가 업데이트되면 해당 회차의 마감 정보도 업데이트 됩니다.
    ///
    /// - Parameters:
    ///   - id: 업데이트할 스터디의 `NSManagedObjectID`
    ///   - title: 변경할 스터디 제목
    ///   - deadlineDay: 변경할 마감일
    ///   - deadlineDate: 변경할 마감 날짜
    ///   - fine: 변경할 벌금
    ///   - members: 변경할 멤버 목록
    ///   - completion: 스터디 정보가 업데이트 완료된 후 호출할 콜백 함수입니다.
    func updateStudy(id: NSManagedObjectID?, title: String?, deadlineDay: Int?, deadlineDate: Date?, fine: Int?, members: [User], completion: @escaping () -> ()) {
        
        // 업데이트할 studyEntity를 ID로 가져옵니다.
        if let studyID = id,
           let studyEntity = fetchStudy(id: studyID) {
            
            // 스터디 정보 업데이트
            studyEntity.title = title
            studyEntity.deadlineDay = Int64(deadlineDay ?? 0)
            studyEntity.fine = Int64(fine ?? 0)
            
            // studyEntity에 연결되지 않은 멤버 연결
            for member in members {
                if member.study == nil {
                    studyEntity.addToMembers(member)
                }
            }
            
            // 마감 정보 업데이트
            let lastContent = fetchLastContent(studyEntity: studyEntity)
            lastContent?.deadlineDay = Int64(deadlineDay ?? 0)
            lastContent?.deadlineDate = deadlineDate
        
        }
        
        // 변경사항 저장
        saveContext()
        
        completion()
    }
    
    // MARK: DELETE
    
    /// 스터디를 삭제합니다.
    /// - Parameter study: 삭제할 `Study` 객체. nil 일 경우 함수는 아무 동작도 하지 않습니다.
    func deleteStudy(study: Study?) {
        let context = persistentContainer.viewContext
        
        // study 객체가 nil이 아닐 경우 삭제 합니다.
        if let studyEntity = study {
            context.delete(studyEntity)
        }
        
        // 변경사항 저장
        saveContext()
    }
    
    /// 스터디 정보에 저장되어있는 멤버를 삭제합니다.
    ///
    /// - Parameter member: 삭제할 `User` 객체
    func deleteStudyMember(member: User) {
        let context = persistentContainer.viewContext
        context.delete(member)
    }
    
    /// 스터디 정보에 저장되어 있는 모든 멤버를 삭제합니다.
    ///
    /// - Parameter members: 삭제할 `User` 객체 배열
    func deleteStudyMembers(members: [User]) {
        for member in members {
            let context = persistentContainer.viewContext
            context.delete(member)
        }
    }
    
    /// 마감 정보에 저장되어 있는 모든 멤버를 삭제합니다.
    ///
    /// - Parameter members: 삭제할 `ContentUser` 객체 배열
    func deleteContentMembers(members: [ContentUser]) {
            
        for member in members {
            let context = persistentContainer.viewContext
            context.delete(member)
        }
    }
    
    // MARK: SAVE
    
    /// CoreData에 저장합니다.
    func saveContext() {
        guard context.hasChanges else { return }
        
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            debugPrint(nsError.localizedDescription)
        }
    }
}
