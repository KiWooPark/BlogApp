//
//  AddStudyViewModel.swift
//  BlogApp
//
//  Created by PKW on 2023/05/17.
//

import Foundation

class StudyDetailViewModel {
    
    var study: Observable<Study?> = Observable(nil)
<<<<<<< HEAD
    // 블로그 게시물 데이터 가지고 온 후 멤버 데이터
    var members: [User] = []
    
    var contentList = [Content]()
    
    var lastContent: Content?

    init(studyData: Study) {
        self.study.value = studyData
        self.members = CoreDataManager.shared.fetchStudyMembers(studyEntity: studyData)
        self.contentList = CoreDataManager.shared.fetchContentList(studyEntity: studyData)
        self.lastContent = self.contentList.last
=======
    
    // 블로그 게시물 데이터 가지고 온 후 멤버 데이터
    var members: [UserModel] = []
    
    // 마지막 공지사항
    var lastContent: Content?
    
    init(studyData: Study) {
        self.study.value = studyData
        self.members = CoreDataManager.shared.fetchCoreDataMembers(study: studyData)
>>>>>>> main
    }
    
    deinit {
        print("StudyDetailViewModel - 메모리 해제")
    }
    
<<<<<<< HEAD
    func fetchStudyData() {
        if let id = self.study.value?.objectID {
            self.study.value = CoreDataManager.shared.fetchStudy(id: id)
            
            if let studyEntity = self.study.value {
                self.contentList = CoreDataManager.shared.fetchContentList(studyEntity: studyEntity)
                self.lastContent = self.contentList.last
                
                self.members = CoreDataManager.shared.fetchStudyMembers(studyEntity: studyEntity)
            }
        }
    }
    
    func isDeadlinePassed() -> Bool {
        
        if let lastContent = self.lastContent {
            
            let result = lastContent.deadlineDate?.compare(Date())
                
            switch result {
            case .orderedAscending: // 과거
                print("마감 날짜가 지났습니다.")
                return true
            case .orderedDescending, .orderedSame: // 미래
                print("마감 날짜가 지나지 않았습니다.")
                return false
            case .none:
                print("")
                return false
            }
        }

        return false
    }

    /// 현재 날짜부터 마지막 공지사항의 마감일까지 몇일이 남았는지 계산하는 메소드 입니다. (D-Day)
    /// ---------------------------------------------
    /// - Parameter index: 스터디의 index 번호 입니다.
    /// - Returns: 계산된 D-Day가 리턴됩니다.
    func calculateDday() -> Int? {
        
        var result: Int?
    
        if let lastContentDeadlineDate = lastContent?.deadlineDate {
            
            let startOfDayForDate1 = Calendar.current.startOfDay(for: lastContentDeadlineDate)
            let startOfDayForDate2 = Calendar.current.startOfDay(for: Date())
            
            let daysDifference = Calendar.current.dateComponents([.day], from: startOfDayForDate2, to: startOfDayForDate1).day
            
            result = daysDifference
        }
        
        return result
    }
}

    
    
    
    
//    func fetchStudyData(completion: @escaping () -> ()) {
//
//        // 멤버 데이터 다시 가져오기
//        self.members = CoreDataManager.shared.fetchCoreDataMembers(study: study.value!)
//
//        fetchCurrentWeekPost {
//            self.study.value = CoreDataManager.shared.getStudy(id: self.study.value!.objectID)
//            completion()
//        }
//    }
//
//    func configStartDate() -> (String,NSAttributedString)? {
//        if let startDate = study.value?.startDate {
//
//            let firstStr = startDate.convertStartDate()
//            let secondStr = "진행중인 주차 : \(abs(startDate.calculateWeekNumber(finishDate: Date()))) 주차"
//
//            return (firstStr, secondStr.convertBoldString(boldString: .startDate))
//        }
//        return nil
//    }
//
//    func configSetDay() -> (String, NSAttributedString)? {
//        var firstStr = ""
//
//        switch study.value?.finishDay {
//        case 101:
//            firstStr = "매주 월요일"
//        case 102:
//            firstStr = "매주 화요일"
//        case 103:
//            firstStr = "매주 수요일"
//        case 104:
//            firstStr = "매주 목요일"
//        case 105:
//            firstStr = "매주 금요일"
//        case 106:
//            firstStr = "매주 토요일"
//        case 107:
//            firstStr = "매주 일요일"
//        default:
//            return nil
//        }
//
//        let finishDate = Date().calcCurrentFinishDate(setDay: Int(study.value?.finishDay ?? 0))
//
//        let secondStr = "마감 : \(finishDate?.convertFinishDate() ?? "")"
//
//        return (firstStr, secondStr.convertBoldString(boldString: .setDay))
//    }

    
    
    // -----------------------------------------------------------------
    
    // 날짜 지났는지 체크하고
    // 마지막 공지 마감 날짜 포함 현재 주차 마감 날짜까지 배열로 리턴 O
    
    // 디테일뷰컨에서 사용할 메서드
    // 스터디 데이터 가지고오기
//    func fetchStudy(completion: @escaping () -> ()) {
//        // 현재 날짜 기준으로 마지막 공지의 마감날짜가 지났는지 확인
//        // 만약 2주이상 지났을 경우에 중간에 작성안된 공지사항까지 만들어야함
//        let updateContentsDate = checkIfDatePassed()
//
//        if updateContentsDate.isEmpty {
//            // 날짜별로 반복 실행
//            print("최근 공지 있음")
//            fetchCurrentWeekPost {
//                completion()
//            }
//        } else {
//            print("최근 공지 없음")
//            startDateWork(date: updateContentsDate) {
//                self.fetchCurrentWeekPost {
//                    completion()
//                }
//            }
//
//        }
//    }
//
//    func fetchCurrentWeekPost(completion: @escaping () -> ()) {
//
//        let group = DispatchGroup()
//
//        for (index, member) in self.members.enumerated() {
//
//            group.enter()
//
//            if let url = CrawlingManager.addCategoryStr(blogUrl: member.blogUrl) {
//                CrawlingManager.getPostsURL(url: url) { result in
//                    switch result {
//                    case .success(let urls):
//
//                        let lastContent = CoreDataManager.shared.fetchLastContent(studyEntity: self.study.value!)
//
//                        let startDate = lastContent?.finishDate?.getStartDateAndEndDate().0
//                        let endDate = lastContent?.finishDate?.getStartDateAndEndDate().1
//
//                        CrawlingManager.getPostTitleAndDate(urls: urls, startDate: startDate, endDate: endDate) { result in
//                            switch result {
//                            case .success(let postData):
//
//                                if let postData = postData {
//                                    self.members[index].postData = postData.postUrl == nil ? PostResponse(name: member.name, data: nil, errorMessage: "작성된 게시글이 없습니다.") : PostResponse(data: postData, errorMessage: nil)
//                                }
//                                group.leave()
//                            case .failure(let error):
//                                print("3")
//                                print(error)
//                                group.leave()
//                            }
//                        }
//                    case .failure(let error):
//                        print("2", error)
//                        self.members[index].postData = PostResponse(name: member.name, data: nil, errorMessage: "블로그 URL을 확인 해주세요.")
//                        group.leave()
//                    }
//                }
//            } else {
//                print("1")
//                self.members[index].postData = PostResponse(name: member.name, data: nil, errorMessage: "블로그 URL을 확인 해주세요.")
//                group.leave()
//            }
//        }
//
//        group.notify(queue: .main) {
//            completion()
//        }
//    }
//
//
//
//    // 확인 안한 주차 구하기
//    // 708188399 // 2023-06-11 14:59:59 (일)
//    // 708793199 // 2023-06-18 14:59:59 (일)
//    // 709397999 // 2023-06-25 14:59:59 (일)
//    // 710002799 // 2023-07-02 14:59:59 (일)
//    // 710607599 // 2023-07-09 14:59:59 (일)
//    // 711212399 // 2023-07-16 14:59:59 (월)
//
//    // 708015599 // 2023-06-09 14:59:59 (금)
//    // 708620399 // 2023-06-16 14:59:59 (금)
//    // 709225199 // 2023-06-23 14:59:59 (금)
//    // 709829999 // 2023-06-30 14:59:59 (금)
//
//    // 708447599 // 2023-06-14 14:59:59 (수)
//    // 709052399 // 2023-06-21 14:59:59 (수)
//    // 709657199 // 2023-06-28 14:59:59 (수)
//
//    // 710261999 // 2023-07-05 14:59:59 (수)
//    // 710866799 // 2023-07-12 14:59:59 (수)
//    // 711471599 // 2023-07-19 14:59:59 (수)
//    // 712076399 // 2023-07-26 14:59:59 (수)
//
//    func checkIfDatePassed() -> [Date] {
//
//        // 공지사항 만들 날짜 배열
//        var result = [Date]()
//        let calendar = Calendar.current
//
//        // 마지막 공지사항 가지고오기
//        let lastContent = CoreDataManager.shared.fetchLastContent(studyEntity: study.value!)
//        let lastContentFinishDate = (lastContent?.finishDate)!
//
////        let components = DateComponents(year: 2023, month: 7, day: 14, hour: 12, minute: 12, second: 12)
////        let date = calendar.date(from: components)!
////
////        print(date.timeIntervalSinceReferenceDate)
//
//        // 현재 날짜가 마지막 공지의 마감날짜를 지났는지 체크
//        if Date() > lastContentFinishDate {
//            print("날짜 지남")
//            // 마지막 공지 날짜 추가
//            result.append(lastContentFinishDate)
//
//            var weekCount = lastContentFinishDate.calculateWeekNumber(finishDate: Date())
//
//            switch weekCount {
//            case 0, 1:
//                weekCount = 1
//            default :
//                print("")
//            }
//
//
//            var standardFinishDate = lastContentFinishDate
//            // 마지막 공지날짜부터 현재 날짜까지 생성
//            for _ in 1..<weekCount {
//                let nextFinishDate = calendar.date(byAdding: .day, value: 7, to: standardFinishDate)!
//                result.append(nextFinishDate)
//                standardFinishDate = nextFinishDate
//            }
//
//            // 마지막 마감 날짜가 지났으면 다음주 content까지 생성
//            if let lastDate = result.last,
//               let finishDate = calendar.date(byAdding: .day, value: 7, to: lastDate) {
//
//                if Date() > finishDate {
//                    result.append(finishDate)
//                }
//            }
//            return result
//        } else {
//            print("날짜 안 지남")
//            return []
//        }
//    }
//
//    // 1. 순차적으로 날짜 시작
//    // 14 21 28
//    func startDateWork(date: [Date], completion: @escaping () -> ()) {
//        // 날짜 순서
//        var currentDateCount = 0
//
//        func next() {
//
//            // 최신 study
//            let study = CoreDataManager.shared.getStudy(id: study.value!.objectID)
//            // 최신 content
//            let lastContent = CoreDataManager.shared.fetchLastContent(studyEntity: study!)
//
//            guard currentDateCount < date.count else {
//                completion()
//                return
//            }
//
//            fetchBlogPost(date: date[currentDateCount]) { result in
//                switch result {
//                case .success(let data):
//
//                    // 벌금 계산
//                    let fine = self.calculateFine(members: data)
//
//                    CoreDataManager.shared.updateMembersFine(studyEntity: study!, contentEntity: lastContent!, fine: (fine.totalFine, fine.plus), membersPost: data) {
//
//                        currentDateCount += 1
//                        next()
//                    }
//
//                case .failure(let error):
//                    print("----", error)
//                }
//            }
//        }
//
//        next()
//
//    }
//
//    // 2. 메인 기능 시작 메소드
//    func fetchBlogPost(date: Date, completion: @escaping (Result<[PostResponse],Error>) -> ()) {
//
//        // 1. 각 멤버별로 마지막 페이지넘버 가지고오기 (동시)
//        // 2. 순차적으로 페이지를 순회하면서 기준이되는 날짜에 포함되는지 확인 (순차적)
//        let group = DispatchGroup()
//        var membersPost = Array(repeating: PostResponse(), count: self.members.count)
//
//        for (index, member) in members.enumerated() {
//
//            membersPost[index].name = member.name
//
//            print("11111", membersPost[index])
//
//            group.enter()
//            CrawlingManager.getLastPageNumber(member: member) { result in
//                switch result {
//                case .success(let pages): // ## 1~마지막페이지까지 ##
//
//                    // 마지막 페이지 넘버 가지고 왔으면 순차적으로 검색
//                    self.checkPagesPost(blogURL: member.blogUrl ?? "", lastPageNum: pages.last ?? 0, date: date) { result in
//                        switch result {
//                        case .success(let data):
//                            membersPost[index].data = data.data
//                            membersPost[index].errorMessage = data.errorMessage
//                            group.leave()
//                        case .failure(let error):
//                            // 에러
//                            membersPost[index].errorMessage = "\(error)"
//                            group.leave()
//                        }
//                    }
//                case .failure(let error):
//                    // page 가지고오지 못하거나 URL이 잘못됬을때
//                    membersPost[index].errorMessage = "\(error)"
//                    group.leave()
//                }
//            }
//        }
//
//        group.notify(queue: .main) {
//            // 여기까지 해당 주차에 작성된 게시글이 있는지 체크 완료
//            completion(.success(membersPost))
//        }
//    }
//
//    func checkPagesPost(blogURL: String, lastPageNum: Int, date: Date, completion: @escaping (Result<PostResponse,CrawlingError>) -> ()) {
//
//        var currentPage = 1
//
//        let startDate = date.getStartDateAndEndDate().0
//        let endDate = date.getStartDateAndEndDate().1
//
//        func next() {
//            guard currentPage < lastPageNum else { return }
//
//            let urlStr = blogURL + "/category?page=\(currentPage)"
//
//            if let url = URL(string: urlStr) {
//                CrawlingManager.getPostsURL(url: url) { result in
//                    switch result {
//                    case .success(let urls):
//
//                        CrawlingManager.getPostTitleAndDate(urls: urls, startDate: startDate, endDate: endDate) { result in
//                            switch result {
//                            case .success(let postData):
//
//                                var result = PostResponse()
//
//                                if postData?.postUrl == nil {
//                                    result = PostResponse(data: nil, errorMessage: "작성된 게시글이 없습니다.")
//                                } else {
//                                    result = PostResponse(data: postData, errorMessage: nil)
//                                }
//
//                                completion(.success(result))
//
//                                if postData == nil {
//                                    currentPage += 1
//                                    next()
//                                }
//                            case .failure(let error):
//                                completion(.failure(error))
//                            }
//                        }
//                    case .failure(let error):
//                        completion(.failure(error))
//                    }
//                }
//            }
//        }
//        next()
//    }
//
//    func calculateFine(members: [PostResponse]) -> (totalFine: Int, plus :Int){
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
//        let totalFine = Int(study.value?.fine ?? 0).convertFineInt() * notPostCount
//
//        // 분배할 금액
//        resultFine = totalFine / postCount
//
//        return (totalFine, resultFine)
//    }
    
    // 2023/7/13 로직 변경
    
    
    
    
//}
=======
    func fetchStudyData(completion: @escaping () -> ()) {
        self.study.value = CoreDataManager.shared.getStudy(id: study.value!.objectID)
        self.members = CoreDataManager.shared.fetchCoreDataMembers(study: self.study.value!)
       
        fetchCurrentWeekPost {
            print(self.members)
            completion()
        }
    }

    func configStartDate() -> (String,NSAttributedString)? {
        if let startDate = study.value?.startDate {

            let firstStr = startDate.convertStartDate()
            let secondStr = "진행중인 주차 : \(abs(startDate.calculateWeekNumber(finishDate: Date()))) 주차"

            return (firstStr, secondStr.convertBoldString(boldString: .startDate))
        }
        return nil
    }
    
    func configSetDay() -> (String, NSAttributedString)? {
        var firstStr = ""
        
        switch study.value?.finishDay {
        case 101:
            firstStr = "매주 월요일"
        case 102:
            firstStr = "매주 화요일"
        case 103:
            firstStr = "매주 수요일"
        case 104:
            firstStr = "매주 목요일"
        case 105:
            firstStr = "매주 금요일"
        case 106:
            firstStr = "매주 토요일"
        case 107:
            firstStr = "매주 일요일"
        default:
            return nil
        }
        
        let finishDate = Date().calcCurrentFinishDate(setDay: Int(study.value?.finishDay ?? 0))
        
//        let finishDate = Date().calculateDeadline(endDay: Int(study.value?.finishDay ?? 0))
        
        let secondStr = "마감 : \(finishDate)"
        
        return (firstStr, secondStr.convertBoldString(boldString: .setDay))
    }

    
    
    // -----------------------------------------------------------------
    
    // 날짜 지났는지 체크하고
    // 마지막 공지 마감 날짜 포함 현재 주차 마감 날짜까지 배열로 리턴 O
    
    // 디테일뷰컨에서 사용할 메서드
    // 스터디 데이터 가지고오기
    func fetchStudy(completion: @escaping () -> ()) {
        // 현재 날짜 기준으로 마지막 공지의 마감날짜가 지났는지 확인
        // 만약 2주이상 지났을 경우에 중간에 작성안된 공지사항까지 만들어야함
        let updateContentsDate = checkIfDatePassed()
        
        if updateContentsDate.isEmpty {
            // 날짜별로 반복 실행
            print("최근 공지 있음")
            fetchCurrentWeekPost {
                completion()
            }
        } else {
            print("최근 공지 없음")
            startDateWork(date: updateContentsDate) {
                self.fetchCurrentWeekPost {
                    completion()
                }
            }
            
        }
    }
    
    func fetchCurrentWeekPost(completion: @escaping () -> ()) {
        
        let group = DispatchGroup()
        
        for (index, member) in self.members.enumerated() {
            
            group.enter()
            
            if let url = CrawlingManager.addCategoryStr(blogUrl: member.blogUrl) {
                CrawlingManager.getPostsURL(url: url) { result in
                    switch result {
                    case .success(let urls):
                        
                        let startDate = Date().getMondayAndSunDay().0
                        let endDate = Date().getMondayAndSunDay().1
                        
                        CrawlingManager.getPostTitleAndDate(urls: urls, startDate: startDate, endDate: endDate) { result in
                            switch result {
                            case .success(let postData):
                              
                                if let postData = postData {
                                    self.members[index].postData = postData.postUrl == nil ? PostResponse(data: nil, errorMessage: "작성된 게시글이 없습니다.") : PostResponse(data: postData, errorMessage: nil)
                                }
                                group.leave()
                            case .failure(let error):
                                print("3")
                                print(error)
                                group.leave()
                            }
                        }
                    case .failure(let error):
                        print("2", error)
                        self.members[index].postData = PostResponse(data: nil, errorMessage: "블로그 URL을 확인 해주세요.")
                        group.leave()
                    }
                }
            } else {
                print("1")
                self.members[index].postData = PostResponse(data: nil, errorMessage: "블로그 URL을 확인 해주세요.")
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion()
        }
    }
    
   
    
    // 확인 안한 주차 구하기
    // 708188399 // 2023-06-11 14:59:59 (일)
    // 708793199 // 2023-06-18 14:59:59 (일)
    // 709397999 // 2023-06-25 14:59:59 (일)
    // 710002799 // 2023-07-02 14:59:59 (일)
    // 710607599 // 2023-07-09 14:59:59 (일)
    
    // 708015599 // 2023-06-09 14:59:59 (금)
    // 708620399 // 2023-06-16 14:59:59 (금)
    // 709225199 // 2023-06-23 14:59:59 (금)
    // 709829999 // 2023-06-30 14:59:59 (금)
    
    // 708015599 // 2023-06-09 14:59:59 (수)
    // 708620399 // 2023-06-16 14:59:59 (수)
    // 709225199 // 2023-06-23 14:59:59 (수)
    // 709829999 // 2023-06-30 14:59:59 (수)
    
    
    // 708447599 // 2023-06-14 14:59:59 (수)
    // 709052399 // 2023-06-21 14:59:59 (수)
    // 709657199 // 2023-06-28 14:59:59 (수)
    
    // 710261999 // 2023-07-05 14:59:59 (수)
    // 710866799 // 2023-07-12 14:59:59 (수)
    // 711471599 // 2023-07-19 14:59:59 (수)
    // 712076399 // 2023-07-26 14:59:59 (수)
    
    func checkIfDatePassed() -> [Date] {
        
        // 공지사항 만들 날짜 배열
        var result = [Date]()
        let calendar = Calendar.current
        
        // 마지막 공지사항 가지고오기
        let lastContent = CoreDataManager.shared.fetchLastContent(studyEntity: study.value!)
        let lastContentFinishDate = (lastContent?.finishDate)!
        
//        let components = DateComponents(year: 2023, month: 7, day: 6, hour: 23, minute: 59, second: 59)
//        let date = calendar.date(from: components)!
//
//        print(date.timeIntervalSinceReferenceDate)
        
        // 현재 날짜가 마지막 공지의 마감날짜를 지났는지 체크
        if Date() > lastContentFinishDate {
            print("날짜 지남")
            // 마지막 공지 날짜 추가
            result.append(lastContentFinishDate)
            
            var weekCount = lastContentFinishDate.calculateWeekNumber(finishDate: Date())
        
            switch weekCount {
            case 0, 1:
                weekCount = 1
            default :
                print("")
            }
            
            
            var standardFinishDate = lastContentFinishDate
            // 마지막 공지날짜부터 현재 날짜까지 생성
            for _ in 1..<weekCount {
                let nextFinishDate = calendar.date(byAdding: .day, value: 7, to: standardFinishDate)!
                result.append(nextFinishDate)
                standardFinishDate = nextFinishDate
            }
            
            // 마지막 마감 날짜가 지났으면 다음주 content까지 생성
            if let lastDate = result.last,
               let finishDate = calendar.date(byAdding: .day, value: 7, to: lastDate) {
                
                if Date() > finishDate {
                    result.append(finishDate)
                }
            }
            return result
        } else {
            print("날짜 안 지남")
            let contents = CoreDataManager.shared.fetchContent(studyEntity: study.value!)
            contents.map({print($0.finishDate)})
            return []
        }
    }
    
    // 1. 순차적으로 날짜 시작
    // 14 21 28
    func startDateWork(date: [Date], completion: @escaping () -> ()) {
        // 날짜 순서
        var currentDateCount = 0
        
        func next() {
            
            // 최신 study
            let study = CoreDataManager.shared.getStudy(id: study.value!.objectID)
            // 최신 content
            let lastContent = CoreDataManager.shared.fetchLastContent(studyEntity: study!)
            
            guard currentDateCount < date.count else {
                completion()
                return
            }
            
            fetchBlogPost(date: date[currentDateCount]) { result in
                switch result {
                case .success(let data):
                    
                    // 벌금 계산
                    let fine = self.calculateFine(members: data)
                    
                    CoreDataManager.shared.updateMembersFine(studyEntity: study!, contentEntity: lastContent!, fine: (fine.totalFine, fine.plus), membersPost: data)

                    currentDateCount += 1
                    next()
                    
                case .failure(let error):
                    print("----", error)
                }
            }
        }
        
        next()

    }
    
    // 2. 메인 기능 시작 메소드
    func fetchBlogPost(date: Date, completion: @escaping (Result<[PostResponse],Error>) -> ()) {
        
        // 1. 각 멤버별로 마지막 페이지넘버 가지고오기 (동시)
        // 2. 순차적으로 페이지를 순회하면서 기준이되는 날짜에 포함되는지 확인 (순차적)
        let group = DispatchGroup()
        var membersPost = Array(repeating: PostResponse(), count: self.members.count)
        
        for (index, member) in members.enumerated() {
            
            group.enter()
            CrawlingManager.getLastPageNumber(member: member) { result in
                switch result {
                case .success(let pages): // ## 1~마지막페이지까지 ##
                    
                    // 마지막 페이지 넘버 가지고 왔으면 순차적으로 검색
                    self.checkPagesPost(blogURL: member.blogUrl ?? "", lastPageNum: pages.last ?? 0, date: date) { result in
                        switch result {
                        case .success(let data):
                            membersPost[index] = data
                            group.leave()
                        case .failure(let error):
                            // 에러
                            membersPost[index].errorMessage = "\(error)"
                            group.leave()
                        }
                    }
                case .failure(let error):
                    // page 가지고오지 못하거나 URL이 잘못됬을때
                    membersPost[index].errorMessage = "\(error)"
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            // 여기까지 해당 주차에 작성된 게시글이 있는지 체크 완료
            completion(.success(membersPost))
        }
    }
    
    func checkPagesPost(blogURL: String, lastPageNum: Int, date: Date, completion: @escaping (Result<PostResponse,CrawlingError>) -> ()) {
        
        var currentPage = 1
        
        let startDate = date.getMondayAndSunDay().0
        let endDate = date.getMondayAndSunDay().1
        
        func next() {
            guard currentPage < lastPageNum else { return }
            
            let urlStr = blogURL + "/category?page=\(currentPage)"
            
            if let url = URL(string: urlStr) {
                CrawlingManager.getPostsURL(url: url) { result in
                    switch result {
                    case .success(let urls):
                        
                        CrawlingManager.getPostTitleAndDate(urls: urls, startDate: startDate, endDate: endDate) { result in
                            switch result {
                            case .success(let data):
                                
                                var result = PostResponse()
                                
                                if data?.postUrl == nil {
                                    result = PostResponse(data: nil, errorMessage: "작성된 게시글이 없습니다.")
                                } else {
                                    result = PostResponse(data: data, errorMessage: nil)
                                }
                                
                                completion(.success(result))
                                
                                if data == nil {
                                    currentPage += 1
                                    next()
                                }
                            case .failure(let error):
                                completion(.failure(error))
                            }
                        }
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
        }
        next()
    }
    
    func calculateFine(members: [PostResponse]) -> (totalFine: Int, plus :Int){
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
        let totalFine = Int(study.value?.fine ?? 0).convertFineInt() * notPostCount
   
        // 분배할 금액
        resultFine = totalFine / postCount
        
        return (totalFine, resultFine)
    }
}
>>>>>>> main

//
//    func updateStudyData(title: String?, announcement: String?, startDate: Date?, setDay: Int?, fine: Int?, newMembers: [User], completion: @escaping () -> ()) {
//
//        if let study = study.value {
//            study.title = title
//            study.announcement = announcement
//            study.startDate = startDate
//            study.finishDay = Int64(setDay ?? 0)
//            study.fine = Int64(fine ?? 0)
//            study.memberCount = Int64(newMembers.count)
//
//            // 코어데이터에 저장된 멤버 + #### content에 저장된 멤버도 확인
//            if let coreDataMembers = self.study.value?.members?.allObjects as? [User],
//               let contentCoreDataMembers = self.lastContent?.members?.allObjects as? [ContentUser] {
//
//                // 이름 중복 체크 필요
//                // 기존 멤버 [111,222,333,444]
//                // content 멤버 [1111,2222,333,444]
//                // 새로운 멤버 [222,333,444,555]
//                let coreDataMembersNames = Set(coreDataMembers.map({$0.name}))
//                let contentCoreDataMembers = Set(contentCoreDataMembers.map({$0.name}))
//
//                let newMembersNames = Set(newMembers.map({$0.name}))
//
//                let deleteMembers = coreDataMembersNames.subtracting(newMembersNames)
//                let deleteContentMembers = contentCoreDataMembers.subtracting(newMembersNames)
//
//                let updateMembers = newMembersNames.subtracting(coreDataMembersNames)
//                let updateContentMembers = newMembersNames.subtracting(contentCoreDataMembers)
//
//                // 멤버 지우기
//                deleteMembers.forEach { name in
//                    if let index = coreDataMembers.firstIndex(where: {$0.name == name}) {
//                        CoreDataManager.shared.deleteMember(user: coreDataMembers[index])
//                    }
//                }
//
//                // 멤버 저장하기
//                updateMembers.forEach { name in
//                    if let index = newMembers.firstIndex(where: {$0.name == name}) {
//                        CoreDataManager.shared.addNewMembers(members: [newMembers[index]], study: study)
//                    }
//                }
//            }
//
//            //            CoreDataManager.shared.saveContext()
//            self.study.value = study
//
//            completion()
//        }
//    }

//    // 현재 주차에 작성된 게시글 가져오기
//    func fetchPostCurrentWeek(type: CrawlingType, completion: @escaping () -> ()) {
//
//        let group = DispatchGroup()
//
//        for (index, member) in members.enumerated() {
//            if let url = CrawlingManager.addCategoryStr(blogUrl: member.blogUrl) {
//
//                group.enter()
//
//                CrawlingManager.getPostsURL(url: url, type: type) { result in
//                    switch result {
//                    case .success(let url):
//                        CrawlingManager.getPostTitleAndDate(urls: url, startDate: nil, endDate: nil) { result in
//                            switch result {
//                            case .success(let postData):
////                                if let postData = postData {
////                                    self.members[index].postData = PostResponse(data: [postData], errorMessage: nil)
////                                }
//                                group.leave()
//                            case .failure(let error):
//                                self.members[index].postData = PostResponse(data: nil, errorMessage: "작성된 게시물이 없습니다.")
//                                group.leave()
//                            }
//                        }
//                    case .failure(let error):
//                        self.members[index].postData = PostResponse(data: nil, errorMessage: "블로그 URL을 확인 해주세요.")
//                        group.leave()
//                    }
//                }
//            }
//        }
//        group.notify(queue: .main) {
//            completion()
//        }
//    }
//
//    // 마지막주에 작성된 게시글 가져오기
//    func fetchPostLastWeek(type: CrawlingType, completion: @escaping (Result<[ContentUserModel?], Error>) -> ()) {
//
//        let group = DispatchGroup()
//
//        var posts: [ContentUserModel?] = Array(repeating: nil, count: members.count)
//
//        for (index, member) in members.enumerated() {
//
//            group.enter()
//
//            // "/category" 추가
//            if let url = CrawlingManager.addCategoryStr(blogUrl: member.blogUrl) {
//
//                // 게시글 URL 가져오기
//                CrawlingManager.getPostsURL(url: url, type: type) { result in
//                    switch result {
//                    case .success(let urls):
//                        let finishDate = self.lastContent?.finishDay
//                        // 월요일
//                        let startDate = finishDate?.getStartDayAndEndDay().0
//                        // 일요일
//                        let endDate = finishDate?.getStartDayAndEndDay().1
//
//                        // content에 저장할 유저 모델
//                        CrawlingManager.getPostTitleAndDate(urls: urls, startDate: startDate!, endDate: endDate!) { result in
//                            switch result {
//                            case .success(let postData):
//                                let contentUserData = ContentUserModel(name: member.name, title: postData?.title, postURL: postData?.postUrl, fine: member.fine)
//                                posts[index] = contentUserData
//                                group.leave()
//                            case .failure(let error):
//                                posts[index] = ContentUserModel(name: member.name, title: "게시물을 직접 확인 해주세요.", postURL: nil, fine: member.fine)
//                                group.leave()
//                                print(error)
//                            }
//                        }
//                    case .failure(let error):
//                        print("getPostURLs Error", error)
//                        posts[index] = ContentUserModel(name: member.name, title: "블로그 URL을 확인 해주세요.", postURL: nil, fine: member.fine)
//                        group.leave()
//                    }
//                }
//            }
//        }
//
//        group.notify(queue: .main) {
//            posts = [ContentUserModel(name: "1111", title: nil, postURL: nil, fine: 25000),
//                     ContentUserModel(name: "2222", title: "2", postURL: "2", fine: 10000),
//                     ContentUserModel(name: "3333", title: "3", postURL: "3", fine: -5000)]
//
//            completion(.success(posts))
//        }
//    }

//    func calculateFine(members: [ContentUserModel?]) -> [ContentUserModel?] {
//        var resultFine = 0
//        var copyMembers = members
//
//        // 작성 안한사람
//        let memberNotPostCount = members.filter({$0?.postURL == nil}).count
//
//        // 작성한 사람
//        let memberPostCount = members.filter({$0?.postURL != nil}).count
//
//        // 다 작성했거나 다 작성 안했거나 하면 벌금 0 원
//        if memberNotPostCount == members.count || memberPostCount == members.count {
//            return members
//        }
//
//        let totalFine = Int(study.value?.fine ?? 0).convertFineInt() * memberNotPostCount
//
//        resultFine = totalFine / memberPostCount
//
//        // 마지막 공지사항 벌금 업데이트
//        self.lastContent?.plusFine = Int64(resultFine)
//
//        // ContentUserModel 업데이트
//        for i in 0..<copyMembers.count {
//
//            let memberFine = copyMembers[i]?.fine ?? 0
//
//            if copyMembers[i]?.postURL != nil {
//                copyMembers[i]?.fine = memberFine + resultFine
//            } else {
//                copyMembers[i]?.fine = memberFine - Int(self.study.value?.fine ?? 0).convertFineInt()
//            }
//        }
//
//        return copyMembers
//    }

// 한주가 지났는지 체크 // 날짜 테스트중
//    func checkIfDatePassed() -> Bool? {
//        let lastContent = CoreDataManager.shared.fetchLastContent(studyEntity: study.value!)
//
//        // [테스트 날짜]
//        let calendar = Calendar.current
//        let components = DateComponents(year: 2023, month: 7, day: 24)
//        let currentDate = calendar.date(from: components)!
//
//        // 현재 날짜랑 마지막 공지의 마감 날짜 비교
//        return (lastContent?.finishDate)! < currentDate ? true : false
//
//        //        return (self.lastContent?.finishDay)! < Date() ? true : false
//    }
<<<<<<< HEAD

=======
>>>>>>> main
