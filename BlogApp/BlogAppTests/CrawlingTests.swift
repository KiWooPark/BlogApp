//
//  CrawlingTests.swift
//  BlogAppTests
//
//  Created by PKW on 1/24/25.
//

@testable import BlogApp
import XCTest

final class CrawlingTests: XCTestCase {
    
    var testCoreDataManager: TestCoreDataManager!
    var users: [User] = []
    
    override func setUpWithError() throws {
        
        testCoreDataManager = TestCoreDataManager.shared
        
        let user1 = createUser(name: "1번", fine: 10000, blogUrl: "https://green1229.tistory.com")
        let user2 = createUser(name: "2번", fine: 20000, blogUrl: "https://jeong9216.tistory.com")
        let user3 = createUser(name: "3번", fine: 15000, blogUrl: "https://hooni99918.tistory.com")
        let user4 = createUser(name: "4번", fine: 5000, blogUrl: "https://nsios.tistory.com")
        let user5 = createUser(name: "5번", fine: 30000, blogUrl: "https://0urtrees.tistory.com")
        
        users = [user1, user2, user3, user4, user5]
    }

    override func tearDownWithError() throws {
        users = []
        testCoreDataManager.resetPersistentStore()
        testCoreDataManager = nil
    }
    
    func test_CrawlingManager_fetchMembersBlogPost() {
        let expectation = self.expectation(description: "CrawlingManager fetchMembersBlogPost completion")
        
        let startTime = Date() // 작업 시작 시간 기록
        
        CrawlingManager.fetchMembersBlogPost(members: users,
                                             startDate: createDate(year: 2024, month: 12, day: 1),
                                             deadlineDate: createDate(year: 2024, month: 12, day: 31))
        { result in
            let endTime = Date() // 작업 종료 시간 기록
            
            let elapsedTime = endTime.timeIntervalSince(startTime) // 경과 시간 계산
            print("종료 시간 : \(elapsedTime) seconds")
            
            XCTAssertNotNil(result, "Result should not be nil")
            XCTAssertGreaterThan(result.count, 0, "Result should contain items")
            
            expectation.fulfill() // 비동기 작업 완료
        }
        
        waitForExpectations(timeout: 10.0, handler: nil)
    }

    func testPerformanceExample() throws {
        self.measure {}
    }
}

extension CrawlingTests {
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
}
