////
////  TestDetailViewModel.swift
////  BlogApp
////
////  Created by PKW on 2023/06/27.
////
//
//import Foundation
//
//class TestDetailViewModel {
//    
//    var study: Observable<Study?> = Observable(nil)
//    
//    // 블로그 게시물 데이터 가지고 온 후 멤버 데이터
//    var members: [UserModel] = []
//    
//    // 마지막 공지사항
//    var lastContent: Content?
//    
//    init(studyData: Study) {
//        self.study.value = studyData
//        self.members = CoreDataManager.shared.fetchCoreDataMembers(study: studyData)
//        self.lastContent = CoreDataManager.shared.fetchLastContent(studyEntity: studyData)
//    }
//    
//    deinit {
//        print("TestDetailViewModel - 메모리 해제")
//    }
//    
//
//    // 한주가 지났는지 체크
//    func checkIfDatePassed() -> Bool? {
//        // 마지막 공지사항 가지고오기
//        self.lastContent = CoreDataManager.shared.fetchLastContent(studyEntity: study.value!)
//        
//
//        let calendar = Calendar.current
//        let components = DateComponents(year: 2023, month: 7, day: 17)
//        let currentDate = calendar.date(from: components)!
//        
//        // 현재 날짜랑 마지막 공지의 마감 날짜 비교
//        return (self.lastContent?.finishDate)! < currentDate ? true : false
//    }
//    
//    // 스터디 데이터 가지고오기
//    func fetchStudy() {
//        
//        // 현재 날짜 기준으로 마지막 공지의 마감날짜가 지났는지 확인
//        if let isCheckDate = checkIfDatePassed(), isCheckDate == true {
//            print("지남")
//                       
//            // 저번주에 포함된 게시글 가지고오기
//            fetchPostLastWeek { membersData in
//                
//                // 벌금 계산
//                let contentMembers = self.calculateFine(members: membersData)
//                        
//                // study 데이터에 각 멤버 벌금 업데이트
////                self.study.value = CoreDataManager.shared.updateMembersFine(studyEntity: self.study.value!, contentEntity: self.lastContent!, contentMembers: contentMembers)
//            
//                print("생성완료")
//            }
//        } else {
//            print("안지남")
//            
//            // 현재 주차의 새로운 게시글 있는지 확인
//            
//        }
//    }
//    
//    // 마지막주에 작성된 게시글 가져오기
//    func fetchPostLastWeek(completion: @escaping ([ContentUserModel?]) -> ()) {
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
////                // 게시글 URL 가져오기
////                CrawlingManager.getPostURLs(url: url) { url in
////                    
////                    // 게시글 제목, 날짜 가지고오기
////                    // content에 저장된 마감날
////                    let finishDate = self.lastContent?.finishDay
////                    // 월요일
////                    let startDate = finishDate?.getStartDayAndEndDay().0
////                    // 일요일
////                    let endDate = finishDate?.getStartDayAndEndDay().1
////
////                    // content에 저장할 유저 모델
////                    CrawlingManager.getPostTitleAndDate(urls: , startDate: startDate!, endDate: endDate!) { postData in
////                        let contentUserData = ContentUserModel(name: member.name, title: postData?.title, postURL: postData?.postUrl, fine: member.fine)
////                        posts[index] = contentUserData
////                        group.leave()
////                    }
////                }
//            }
//        }
//        
//        group.notify(queue: .main) {
//            posts = [ContentUserModel(name: "1111", title: "1", postURL: "1", fine: -10000),
//                     ContentUserModel(name: "2222", title: "2", postURL: "2", fine: 30000),
//                     ContentUserModel(name: "3333", title: nil, postURL: nil, fine: -10000),
//                     ContentUserModel(name: "4444", title: "4", postURL: "4", fine: -10000)]
//            completion(posts)
//        }
//    }
//    
//    // 벌금 계산
//    func calculateFine(members: [ContentUserModel?]) -> [ContentUserModel?] {
//        
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
//        // ContentUser Entity 업데이트
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
//}
