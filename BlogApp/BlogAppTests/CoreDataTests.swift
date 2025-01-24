//
//  CoreDataTests.swift
//  BlogAppTests
//
//  Created by PKW on 1/23/25.
//

@testable import BlogApp
import XCTest

final class CoreDataTests: XCTestCase {
    var testCoreDataManager: TestCoreDataManager!
    
    override func setUpWithError() throws {
        testCoreDataManager = TestCoreDataManager.shared
        
        let deadlineDate = createDate(year: 2025, month: 1, day: 30)
        let firstDate = createDate(year: 2025, month: 1, day: 1)
        
        let users = [createUser(name: "1번", fine: 1111, blogUrl: "url1"),
                     createUser(name: "2번", fine: 2222, blogUrl: "url2")
        ]
        
        // when 테스트 할 코드
        testCoreDataManager.createStudy(isNewStudy: true,
                                        lastProgressNumber: nil,
                                        lastProgressDeadlineDate: nil,
                                        title: "1번 스터디",
                                        firstStudyDate: firstDate,
                                        deadlineDay: 7,
                                        deadlineDate: deadlineDate,
                                        fine: 10000,
                                        members: users) {}
    }

    override func tearDownWithError() throws {
        testCoreDataManager.resetPersistentStore()
        testCoreDataManager = nil
    }
    
    // 스터디 등록 검증(신규)
    func test_CoreDataManager_CreateNewStudy_createStudyFunc() {
        let studyList = testCoreDataManager.fetchStudyList()
        
        XCTAssertEqual(studyList.count, 1, "스터디는 1개만 저장되야 합니다.")
    }
    
    // 등록된 신규 스터디 데이터 검증
    func test_CoreDataManager_StoredNewStudyData_ShouldValid() {
        let study = testCoreDataManager.fetchStudyList()[0]
       
        XCTAssertEqual(study.isNewStudy, true)
        XCTAssertEqual(study.title, "1번 스터디")
        XCTAssertEqual(study.firstStartDate, createDate(year: 2025, month: 1, day: 1))
        XCTAssertEqual(study.deadlineDay, 7)
        XCTAssertEqual(study.fine, 10000)
        XCTAssertEqual(study.memberCount, 2)
    }
    
    // 신규 스터디에 포함된 멤버 데이터 검증
    func test_CoreDataManager_StoredStudyMemberData_ShouldValid() {
        let study = testCoreDataManager.fetchStudyList()[0]
        let studyMembers = testCoreDataManager.fetchStudyMembers(studyEntity: study)

        XCTAssertEqual(studyMembers.count, 2)
        XCTAssertEqual(studyMembers[0].name, "1번")
        XCTAssertEqual(studyMembers[1].name, "2번")
        XCTAssertEqual(studyMembers[0].fine, 1111)
        XCTAssertEqual(studyMembers[1].fine, 2222)
        XCTAssertEqual(studyMembers[0].blogUrl, "url1")
        XCTAssertEqual(studyMembers[1].blogUrl, "url2")
    }
    
    // 신규 스터디와 멤버가 연결되어 있는지 검증
    func test_CoreDataManager_StudyMemberConnection_ShouldValid() {
        let study = testCoreDataManager.fetchStudyList()[0]
        let studyMembers = testCoreDataManager.fetchStudyMembers(studyEntity: study)
        
        XCTAssertEqual(studyMembers[0].study, study)
        XCTAssertEqual(studyMembers[1].study, study)
    }
    
    // 스터디 등록 검증(기존)
    func test_CoreDataManager_CreateOldStudy_createStudyFunc() {
        createOldStudyData()
        
        let studyList = testCoreDataManager.fetchStudyList()
        XCTAssertEqual(studyList.count, 2)
    }
    
    //등록된 기존 스터디 데이터 검증
    func test_CoreDataManager_StoredOldStudyData_ShouldValid() {
        createOldStudyData()
        
        let study = testCoreDataManager.fetchStudyList()[1]
       
        XCTAssertEqual(study.isNewStudy, false)
        XCTAssertEqual(study.title, "2번 스터디")
        XCTAssertEqual(study.firstStartDate, createDate(year: 2025, month: 1, day: 30))
        XCTAssertEqual(study.deadlineDay, 7)
        XCTAssertEqual(study.fine, 5000)
        XCTAssertEqual(study.memberCount, 3)
    }
    
    
    // 기존 스터디에 포함된 멤버 데이터 검증
    func test_CoreDataManager_StoredOldStudyMemberData_ShouldValid() {
        createOldStudyData()
        
        let study = testCoreDataManager.fetchStudyList()[1]
        let studyMembers = testCoreDataManager.fetchStudyMembers(studyEntity: study)

        XCTAssertEqual(studyMembers.count, 3)
        XCTAssertEqual(studyMembers[0].name, "1번")
        XCTAssertEqual(studyMembers[1].name, "2번")
        XCTAssertEqual(studyMembers[2].name, "3번")
        XCTAssertEqual(studyMembers[0].fine, 1111)
        XCTAssertEqual(studyMembers[1].fine, 2222)
        XCTAssertEqual(studyMembers[2].fine, 3333)
        XCTAssertEqual(studyMembers[0].blogUrl, "url1")
        XCTAssertEqual(studyMembers[1].blogUrl, "url2")
        XCTAssertEqual(studyMembers[2].blogUrl, "url3")
    }
    
    // 기존 스터디와 멤버가 연결되어 있는지 검증
    func test_CoreDataManager_OldStudyMemberConnection_ShouldValid() {
        createOldStudyData()
        
        let study = testCoreDataManager.fetchStudyList()[1]
        let studyMembers = testCoreDataManager.fetchStudyMembers(studyEntity: study)
        
        XCTAssertEqual(studyMembers[0].study, study)
        XCTAssertEqual(studyMembers[1].study, study)
        XCTAssertEqual(studyMembers[2].study, study)
    }

    // 스터디 생성시 공지사항도 생성되었는지 검증
    func test_CoreDataManager_CreateContent_fetchContentList() {
        let study = testCoreDataManager.fetchStudyList()[0]
        let contents = testCoreDataManager.fetchContentList(studyEntity: study)
        
        XCTAssertEqual(contents.count, 1)
    }
    
    // 공지사항 데이터 검증
    func test_CoreDataManager_StoredContentData_ShouldValid() {
        let study = testCoreDataManager.fetchStudyList()[0]
        let content = testCoreDataManager.fetchContentList(studyEntity: study)[0]
    
        XCTAssertEqual(content.study, study)
        XCTAssertEqual(content.contentNumber, 1)
        XCTAssertEqual(content.deadlineDate, createDate(year: 2025, month: 1, day: 30))
        XCTAssertEqual(content.deadlineDay, 7)
        XCTAssertEqual(content.fine, 0)
        XCTAssertEqual(content.startDate, nil)
        XCTAssertEqual(content.totalFine, 0)
    }
    
    // 스터디 정보 업데이트 검증
    func test_CoreDataManager_UpdateStudyData_ShouldValid() {
        let study = testCoreDataManager.fetchStudyList()[0]
        let studyMembers = testCoreDataManager.fetchStudyMembers(studyEntity: study)
        
        var users = [createUser(name: "3번", fine: 3333, blogUrl: "url3"),
                     createUser(name: "4번", fine: 4444, blogUrl: "url4")]
    
        
        testCoreDataManager.updateStudy(id: study.objectID,
                                        title: "1번 스터디 변경!",
                                        deadlineDay: 5,
                                        deadlineDate: createDate(year: 2025, month: 1, day: 30),
                                        fine: 1000,
                                        members: users + studyMembers) {}
        
        let updateStudy = testCoreDataManager.fetchStudyList()[0]
    
        XCTAssertEqual(updateStudy.title, "1번 스터디 변경!")
        XCTAssertEqual(updateStudy.deadlineDay, 5)
        XCTAssertEqual(updateStudy.fine, 1000)
        XCTAssertEqual(updateStudy.memberCount, 4, "기존 멤버 + 새로운 멤버가 추가된 수")
    }
    
    // 스터디 삭제 검증
    func test_CoreDataManager_DeleteStudyData_ShouldValid() {
        let study = testCoreDataManager.fetchStudyList()[0]
        
        testCoreDataManager.deleteStudy(study: study)
        
        let studylist = testCoreDataManager.fetchStudyList()
        
        XCTAssertEqual(studylist.count, 0)
    }
    
    // 스터디 멤버 삭제 검증
    func test_CoreDataManager_DeleteStudyMember_ShouldValid() {
        let study = testCoreDataManager.fetchStudyList()[0]
        let studyMembers = testCoreDataManager.fetchStudyMembers(studyEntity: study)
        
        testCoreDataManager.deleteStudyMember(member: studyMembers[0])
        
        let fetchStudyMembers = testCoreDataManager.fetchStudyMembers(studyEntity: study)
        
        XCTAssertEqual(fetchStudyMembers.count, 1)
        XCTAssertFalse(fetchStudyMembers.contains(studyMembers[0]))
        XCTAssertEqual(fetchStudyMembers[0].name, "2번")
    }
    
    // 스터디 멤버 전체 삭제 검증
    func test_CoreDataManager_DeleteAllStudyMembers_ShouldValid() {
        let study = testCoreDataManager.fetchStudyList()[0]
        let studyMembers = testCoreDataManager.fetchStudyMembers(studyEntity: study)
        
        testCoreDataManager.deleteStudyMembers(members: studyMembers)
        
        let fetchStudyMembers = testCoreDataManager.fetchStudyMembers(studyEntity: study)
        
        XCTAssertEqual(fetchStudyMembers.count, 0)
    }
    
    // 공지사항에 포함된 멤버 전체 삭제 검증
    func test_CoreDataManager_DeleteAllContentMembers_ShouldValid() {
        let study = testCoreDataManager.fetchStudyList()[0]
        let content = testCoreDataManager.fetchContentList(studyEntity: study)[0]
        let contentMembers = testCoreDataManager.fetchContentMembers(contentEntity: content)
        
        testCoreDataManager.deleteContentMembers(members: contentMembers)
        
        let fetchContentMembers = testCoreDataManager.fetchContentMembers(contentEntity: content)
        
        XCTAssertEqual(fetchContentMembers.count, 0)
    }
}

extension CoreDataTests {
    func createDate(year: Int, month: Int, day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        
        return Calendar.current.date(from: components)!
    }
    
    func createUser(name: String, fine: Int, blogUrl: String) -> User {
        let context = testCoreDataManager.context
        let user = User(context: context)
        user.name = name
        user.fine = Int64(fine)
        user.blogUrl = blogUrl
        return user
    }
    
    func createOldStudyData() {
        let deadlineDate = createDate(year: 2025, month: 2, day: 10)
        let firstDate = createDate(year: 2025, month: 1, day: 30)
        
        let users = [createUser(name: "1번", fine: 1111, blogUrl: "url1"),
                     createUser(name: "2번", fine: 2222, blogUrl: "url2"),
                     createUser(name: "3번", fine: 3333, blogUrl: "url3")
        ]
    
        testCoreDataManager.createStudy(isNewStudy: false,
                                        lastProgressNumber: nil,
                                        lastProgressDeadlineDate: nil,
                                        title: "2번 스터디",
                                        firstStudyDate: firstDate,
                                        deadlineDay: 7,
                                        deadlineDate: deadlineDate,
                                        fine: 5000,
                                        members: users) {}
    }
    
    // 성능 테스트용
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
//            for i in 0..<100 {
//                let user = createUser(name: "User \(i)", fine: i * 100, blogUrl: "url\(i)")
//                testCoreDataManager.createStudy(isNewStudy: true,
//                                                lastProgressNumber: i,
//                                                lastProgressDeadlineDate: Date(),
//                                                title: "Study \(i)",
//                                                firstStudyDate: Date(),
//                                                deadlineDay: i % 7,
//                                                deadlineDate: Date(),
//                                                fine: i * 500,
//                                                members: [user]) {}
//            }
        }
    }
}
