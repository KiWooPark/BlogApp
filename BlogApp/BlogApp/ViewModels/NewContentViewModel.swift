//
//  AddContentViewModel.swift
//  BlogApp
//
//  Created by PKW on 2023/07/14.
//

import Foundation

// MARK:  ===== [Class or Struct] =====

/// 새로운 마감 정보 생성을 관리하는 ViewModel 입니다.
class NewContentViewModel {
    
    // MARK:  ===== [Enum] =====
    
    // 업데이트할 마감 정보의 프로퍼티 타입 열거형
    enum ContentProperty {
        // 시작 날짜
        case startDate
        
        // 마감 날짜
        case deadlineDate
        
        // 벌금
        case fine
        
        // 멤버 추가
        case addContentMember
        
        // 멤버 수정
        case editContentMember
        
        // 멤버 삭제
        case deleteContentMember
    }
    
    // MARK:  ===== [Property] =====
    
    // 마지막 마감 정보를 나타내는 변수
    var lastContent: Observable<Content?> = Observable(nil)
    
    // 마감일을 나타내는 변수
    var deadlineDay: Observable<Int?> = Observable(nil)
    
    // 시작 날짜를 나타내는 변수
    var startDate: Observable<Date?> = Observable(nil)
    
    // 마감 날짜를 나타내는 변수
    var deadlineDate: Observable<Date?> = Observable(nil)
    
    // 벌금을 나타내는 변수
    var fine: Observable<Int?> = Observable(nil)
    
    // 스터디 정보에 저장된 멤버 배열을 나타내는 변수
    var studyMembers: Observable<[User]> = Observable([])
    
    // 마감 정보에 저장된 멤버 배열을 나타내는 변수
    var contentMembers: Observable<[ContentUser]> = Observable([])
    
    // 작성한 게시물 배열을 나타내는 변수
    var postsData: Observable<[PostResponse]> = Observable([])
    
    // 벌금의 총 합을 나타내는 변수
    var totalFine = 0
    
    // 증액해야할 벌금을 나타내는 변수
    var plusFine = 0
    
    // 멤버 정보 상태를 나타내는 변수
    var memberState = StudyComposeViewModel.MemberState.none
    
    // 수정중인 인덱스 번호를 나타내는 변수
    var editIndex = 0
    
    // MARK:  ===== [Init] =====
    
    // Study 객체를 사용하여 NewContentViewModel을 초기화 합니다.
    init(studyEntity: Study?) {
        if let studyEntity = studyEntity {
            
            // 마지막 마감 정보를 가져옵니다.
            self.lastContent.value = CoreDataManager.shared.fetchLastContent(studyEntity: studyEntity)
            
            // 스터디 정보에 저장된 마감일을 가져옵니다.
            self.deadlineDay.value = Int(studyEntity.deadlineDay)
            
            if lastContent.value?.startDate != nil {
                // 마지막 마감 정보의 시작일을 가져옵니다.
                self.startDate.value = self.lastContent.value?.startDate
            }
            
            // 마지막 마감 정보의 마감일을 가져옵니다.
            self.deadlineDate.value = self.lastContent.value?.deadlineDate
            
            // 스터디 정보에 저장된 벌금을 가져옵니다.
            self.fine.value = Int(studyEntity.fine)
            
            // 스터디 정보에 저장된 멤버 목록을 가져옵니다.
            self.studyMembers.value = CoreDataManager.shared.fetchStudyMembers(studyEntity: studyEntity)
        }
    }
    
    // MARK:  ===== [Function] =====
    
    /// 마감 정보의 프로퍼티를 업데이트합니다.
    ///
    /// 마감 정보의 여러 프로퍼티(startDate, deadlineDate, fine)중 하나를 선택하여 업데이트 합니다.
    /// 멤버에 관한 프로퍼티(추가, 삭제, 수정)도 업데이트 합니다.
    ///
    /// - Parameters:
    ///   - property: 업데이트할 마감 정보의 프로퍼티
    ///   - value: 업데이트할 새로운 값
    func updateContentProperty(_ property: ContentProperty, value: Any) {
        
        switch property {
        case .startDate:
            self.startDate.value = (value as? Date)?.makeStartDate()
        case .deadlineDate:
            self.deadlineDay.value = (value as? Date)?.getDayOfCurrentDate()
            self.deadlineDate.value = (value as? Date)?.makeDeadlineDate()
        case .fine:
            self.fine.value = value as? Int
        case .addContentMember:
            
            // 멤버 정보 업데이트 상태값 변경
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
            
            // 멤버 정보 업데이트 상태값 변경
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
            
            // 멤버 정보 업데이트 상태값 변경
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
    
    /// 시작 날짜와 마감 날짜 범위에 포함된 게시물을 가져옵니다.
    ///
    /// 작성된 게시물이 없을 경우 PostResponse.data의 값은 nil이며, errorMessage에 에러 메시지가 포함됩니다.
    ///
    /// - Parameter completion: 모든 멤버들의 게시물을 가져온 후 호출할 콜백 함수 입니다.
    func fetchBlogPosts(completion: @escaping () -> ()) {
        
        CrawlingManager.fetchMembersBlogPost(members: studyMembers.value, startDate: startDate.value?.makeStartDate(), deadlineDate: deadlineDate.value?.makeDeadlineDate()) { postsData in
            
            self.postsData.value.removeAll()
            self.postsData.value = postsData
            self.fetchContentMembers()
            
            completion()
        }
    }
    
    /// 마감 정보에 저장할 멤버 정보를 가져옵니다.
    ///
    /// 이 메소드는 각 멤버별 작성한 게시물을 확인하고
    /// 게시물 작성 유무에 따라 게시물 제목, 게시물 URL, 게산된 보증금 정보를 contentMembers 배열에 추가합니다.
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
    
    
    /// 게시물 작성 유무에따라 보증금을 계산합니다.
    ///
    /// 이 메소드는 모든 멤버가 게시물을 작성하거나, 작성하지 않은 경우에는
    /// totalFine과 plusFine이 0원이며, 게시물 작성 유무에따라 보증금을 계산합니다.
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
    
    
    /// 마감 정보를 CoreData에 저장합니다.
    ///
    /// 이 메소드는 마감 정보를 저장하며, 새로운 멤버가 추가되거나 기존 멤버를 삭제할 경우
    /// 스터디 정보에도 멤버 데이터를 업데이트합니다.
    /// 스터디 정보에 업데이트 될 경우 게시물 작성 유무에 따라 보증금이 계산되어 업데이트 됩니다.
    ///
    /// - Parameter completion: 데이터가 저장된 후 호출할 콜백 함수 입니다.
    func createContentData(completion: @escaping () -> ()) {
        CoreDataManager.shared.createContent(lastContent: lastContent.value, deadlineDay: deadlineDay.value, startDate: startDate.value, deadlineDate: deadlineDate.value, fine: fine.value, totalFine: totalFine, plusFine: plusFine, studyMembers: studyMembers.value, contentMembers: contentMembers.value) {
            completion()
        }
    }
}
