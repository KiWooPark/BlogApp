//
//  StucyComposeViewModel.swift
//  BlogApp
//
//  Created by PKW on 2023/06/02.
//

import Foundation
import CoreData

// MARK:  ===== [Class or Struct] =====

/// 스터디 생성 및 수정을 관리하는 ViewModel 입니다.
class StudyComposeViewModel {
    
    // MARK:  ===== [Enum] =====
    
    /// 업데이트할 스터디 프로퍼티 타입 열거형
    enum StudyProperty {
        
        // 신규 / 기존 스터디
        case newStudy
        
        // 스터디 제목
        case studyTitle
        
        // 기존에 진행하던 스터디의 마지막 마감 회차
        case lastStudyCount
        
        // 기존에 진행하던 스터디의 마지막 마감 날짜
        case lastProgressDeadlineDate
        
        // 스터디 최초 시작 날짜
        case firstStudyDate
        
        // 마감일
        case deadlineDay
        
        // 벌금
        case fine
        
        // 멤버 추가
        case addMember
        
        // 멤버 수정
        case editMember
        
        // 멤버 삭제
        case deleteMember
    }

    /// 멤버 정보 상태 타입 열거형
    enum MemberState {
        
        // 기본값
        case none
        
        // 추가
        case add
        
        // 수정
        case edit
        
        // 삭제
        case delete
    }
    
    // MARK:  ===== [Property] =====
    
    // 스터디 ID 객체를 나타내는 변수
    var id: NSManagedObjectID? = nil
    
    // 신규 스터디 또는 기존 스터디를 나타내는 변수
    var isNewStudy: Observable<Bool?> = Observable(true)
    
    // 제목을 나타내는 변수
    var title: Observable<String?> = Observable(nil)
    
    // 기존 진행중인 스터디의 마지막 진행 회차를 나타내는 변수
    var lastProgressNumber: Observable<Int?> = Observable(nil)
    
    // 기존 진행중인 스터디의 마지막 회차 마감 날짜를 나타내는 변수
    var lastProgressDeadlineDate: Observable<Date?> = Observable(nil)
    
    // 마지막 마감 정보의 마감 날짜를 나타내는 변수
    var lastContentDeadlineDate: Observable<Date?> = Observable(nil)
    
    // 최초 시작 날짜를 나타내는 변수
    var firstStudyDate: Observable<Date?> = Observable(nil)
    
    // 마감일을 나타내는 변수
    var deadlineDay: Observable<Int?> = Observable(nil)
    
    // 벌금을 나타내는 변수
    var fine: Observable<Int?> = Observable(nil)
    
    // 스터디 정보에 저장된 멤버 목록을 나타내는 배열
    var studyMembers: Observable<[User]> = Observable([])
    
    // 마감 날짜를 나타내는 변수(선택 시)
    var deadlineDate: Observable<Date?> = Observable(nil)
    
    // 수정 상태인지 나타내는 변수
    var isEditStudy = false
    
    // 멤버 정보 업데이트 상태를 나타내는 변수
    var memberState = MemberState.none
    
    // 수정할 멤버의 인덱스를 나타내는 변수
    var editIndex = 0
    
    // MARK:  ===== [Init] =====

    // Study 객체를 사용하여 StudyViewModel을 초기화합니다.
    init(studyData: Study?) {
        if let studyEntity = studyData {
            // ViewModel의 프로퍼티들을 초기화 합니다.
            self.id = studyEntity.objectID
            self.isNewStudy.value = studyEntity.isNewStudy
            self.title.value = studyEntity.title
            self.firstStudyDate.value = studyEntity.firstStartDate
            self.deadlineDay.value = Int(studyEntity.deadlineDay)
            self.fine.value = Int(studyEntity.fine)
            
            // 마지막 마감 정보의 마감 날짜를 가져옵니다.
            self.lastContentDeadlineDate.value = CoreDataManager.shared.fetchContentList(studyEntity: studyEntity).last?.deadlineDate
            self.deadlineDate.value = self.lastContentDeadlineDate.value
            
            // 스터디의 멤버 목록을 가져옵니다.
            self.studyMembers.value = CoreDataManager.shared.fetchStudyMembers(studyEntity: studyEntity)
        }
    }
    
    // MARK:  ===== [Function] =====
    
    /// 스터디 정보를 생성하여 CoreData에 저장합니다.
    ///
    /// 이 메소드는 신규 스터디 생성시(isNewStudy, title, firstStudyDate, deadlineDate, fine, members)를 저장하고, 기존 진행중이던 스터디 생성시(isNewStudy, lastCount, title, firstDate, deadlineDate, fine, members)를 CoreData에 저장합니다.
    ///
    /// - Parameter completion: 데이터가 저장된 후 호출할 콜백 함수입니다.
    func createStudyData(completion: @escaping () -> ()) {
       
        // CoreData에 저장합니다.
        CoreDataManager.shared.createStudy(isNewStudy: isNewStudy.value, lastProgressNumber: lastProgressNumber.value, lastProgressDeadlineDate: lastProgressDeadlineDate.value, title: title.value, firstStudyDate: firstStudyDate.value, deadlineDay: deadlineDay.value, deadlineDate: deadlineDate.value, fine: fine.value, members: studyMembers.value) {
            
            completion()
        }
    }
    
    /// 스터디 정보를 CoreData에 업데이트합니다.
    ///
    /// - Parameter completion: 데이터가 업데이트 된 후 호출할 콜백 함수 입니다.
    func updateStudyData(completion: @escaping () -> ()) {
        
        // CoreData에 저장합니다.
        CoreDataManager.shared.updateStudy(id: id, title: title.value, deadlineDay: deadlineDay.value, deadlineDate: deadlineDate.value, fine: fine.value, members: studyMembers.value) {
            
            completion()
        }
    }
    
    /// 스터디의 프로퍼티를 업데이트 합니다.
    ///
    /// 스터디의 여러 프로퍼티(newStudy, studyTitle, lastStudyCount, lastProgressDeadlineDate, firstStudyDate, deadlineDay, fine)중 하나를 선택하여 업데이트 합니다.
    /// 멤버에 관한 프로퍼티(추가, 삭제, 수정)도 업데이트 합니다.
    ///
    /// - Parameters:
    ///   - property:  업데이트할 스터디의 프로퍼티
    ///   - value: 업데이트할 새로운 값
    ///   - isEditMember: 멤버 정보 수정 상태인지 여부, 수정중이면 `true`, 아니면 `false`
    func updateStudyProperty(_ property: StudyProperty, value: Any, isEditMember: Bool = false) {
       
        switch property {
        case .newStudy:
            self.isNewStudy.value = value as? Bool
        case .studyTitle:
            self.title.value = value as? String
        case .lastStudyCount:
            self.lastProgressNumber.value = value as? Int
        case .lastProgressDeadlineDate:
            self.lastProgressDeadlineDate.value = value as? Date
        case .firstStudyDate:
            self.firstStudyDate.value = value as? Date
        case .deadlineDay:
            let data = value as? (Int, Date?)
            self.deadlineDay.value = data?.0
            self.deadlineDate.value = data?.1
        case .fine:
            self.fine.value = value as? Int
        case .addMember:
            
            // 멤버 정보 업데이트 상태값 변경
            memberState = .add
            
            let data = value as? (String?, String?, Int?)
            let newMember = User(context: CoreDataManager.shared.persistentContainer.viewContext)
            newMember.name = data?.0
            newMember.blogUrl = data?.1
            newMember.fine = Int64(data?.2 ?? 0)
            
            // studyMembers 배열 첫번째에 추가
            self.studyMembers.value.insert(newMember, at: 0)
            
        case .editMember:
            
            // 멤버 정보 업데이트 상태값 변경
            memberState = .edit
            
            let data = value as? (String?, String?, Int?, Int)
            
            editIndex = data?.3 ?? 0
            
            let member = studyMembers.value[editIndex]
            member.name = data?.0
            member.blogUrl = data?.1
            member.fine = Int64(data?.2 ?? 0)
            
            // studyMembers 배열의 editIndex 위치에 member 정보 변경
            self.studyMembers.value[editIndex] = member
        
        case .deleteMember:
            
            // 멤버 정보 업데이트 상태값 변경
            memberState = .delete
            
            let index = value as? Int
            
            // editIndex에 index값 변경
            editIndex = index ?? 0
            
            // 코어데이터에서 해당 멤버 정보 삭제
            CoreDataManager.shared.deleteStudyMember(member: self.studyMembers.value[editIndex])
            // studyMembers 배열에서 삭제
            self.studyMembers.value.remove(at: editIndex)
        }
    }
    
    /// 스터디 생성에 필요한 정보를 입력했는지 확인합니다.
    ///
    /// 입력한 정보는 문자열에 포함되지 않으며 입력하지 않은 정보만 문자열에 추가됩니다.
    ///
    /// - Returns: 입력하지 않은 정보는 문자열로 반환되며, 모든 정보를 입력한 경우 nil이 반환됩니다.
    func validateStudyData() -> String? {
        
        // 확인할 정보의 타입 열거형
        enum CheckStudyData: String {
            case lastProgressNumber = "마지막 진행 회차"
            case lastProgressDeadlineDate = "마지막 진행 회차 마감 날짜"
            case title = "스터디 제목"
            case firstStudyDate = "최초 시작 날짜"
            case deadlineDate = "마감 요일"
            case fine = "벌금"
            case member = "참여자"
        }
        
        // alert으로 보여질 CheckStudyData 타입의 배열
        var alertList = [CheckStudyData]()
        
        // 신규 스터디이거나 기존 스터디인 경우
        if isNewStudy.value == true {
            title.value == nil ? alertList.append(.title) : ()
            firstStudyDate.value == nil ? alertList.append(.firstStudyDate) : ()
            deadlineDay.value == nil ? alertList.append(.deadlineDate) : ()
            fine.value == nil ? alertList.append(.fine) : ()
            studyMembers.value.isEmpty ? alertList.append(.member) : ()
        } else {
            
            if isEditStudy {
                title.value == nil ? alertList.append(.title) : ()
                firstStudyDate.value == nil ? alertList.append(.firstStudyDate) : ()
                deadlineDay.value == nil ? alertList.append(.deadlineDate) : ()
                fine.value == nil ? alertList.append(.fine) : ()
                studyMembers.value.isEmpty ? alertList.append(.member) : ()
            } else {
                lastProgressNumber.value == nil ? alertList.append(.lastProgressNumber) : ()
                lastProgressDeadlineDate.value == nil ? alertList.append(.lastProgressDeadlineDate) : ()
                title.value == nil ? alertList.append(.title) : ()
                firstStudyDate.value == nil ? alertList.append(.firstStudyDate) : ()
                deadlineDay.value == nil ? alertList.append(.deadlineDate) : ()
                fine.value == nil ? alertList.append(.fine) : ()
                studyMembers.value.isEmpty ? alertList.append(.member) : ()
            }
        }
       
        if alertList.isEmpty {
            // 모든 정보를 입력한 경우 nil 반환
            return nil
        } else {
            // 입력하지 않은 정보에 대한 문자열을 하나의 문자열로 만든 후 반환
            return "\(alertList.map({$0.rawValue}).joined(separator: "\n")) \n입력을 완료해주세요. "
        }
    }
}
