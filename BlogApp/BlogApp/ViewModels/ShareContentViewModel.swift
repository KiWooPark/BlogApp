//
//  ShareContentViewModel.swift
//  BlogApp
//
//  Created by PKW on 2023/06/16.
//

import Foundation

// MARK:  ===== [Class or Struct] =====
/// 마감 정보 공유를 관리하는 ViewModel 입니다.
class ShareContentViewModel {
    
    // MARK:  ===== [Property] =====
    
    // 스터디 객체를 나타내는 변수
    var study: Study?

    // 마감 정보 목록을 나타내는 변수
    var contentList: [Content]?

    // 현재 마감 정보의 인덱스를 나타내는 변수
    var currentIndex = 0
    
    // MARK:  ===== [Init] =====
    
    // Study 객체를 사용하여 ShareContentViewModel을 초기화합니다.
    init(study: Study?) {
        if let studyEntity = study {
            self.study = studyEntity
            // 마감 정보 목록을 가져옵니다.
            self.contentList = CoreDataManager.shared.fetchContentList(studyEntity: studyEntity)
        }
    }
    
    /// 해당 인덱스에 해당하는 스터디 정보와 멤버 정보를 문자열로 반환합니다.
    ///
    /// 이 메소드는 공유를 위한 문자열 입니다.
    ///
    /// - Parameter index: 정보를 가져올 인덱스
    /// - Returns: 스터디 정보와 멤버 정보를 결합한 문자열을 반환합니다.
    func fetchContent(index: Int) -> String {
        
        // 스터디 정보를 문자열로 가져옵니다.
        let studyInfo = fetchStudyInfoStr(index: index)

        // 멤버 정보를 문자열로 가져옵니다.
        let contentMembers = fetchMembers(index: index)

        // 위 두 문자열을 더해 반환합니다.
        return studyInfo + contentMembers
    }
    
    /// 스터디 정보중 공유 포멧에 맞춰 가져옵니다.
    ///
    /// - Parameter index: 정보를 가져올 인덱스
    /// - Returns: 스터디 정보중 공유할 내용을 새로운 문자열로 반환합니다.
    private func fetchStudyInfoStr(index: Int) -> String {
        let target = contentList?[index]
        
        let studyInfoStr = """
        \(contentList?[index].contentNumber ?? 0) 회차 마감 결과
        
        진행 기간
        • 시작일 : \(target?.startDate?.toString() ?? "")
        • 마감일 : \(target?.deadlineDate?.toString() ?? "") 자정(23:59)
        
        마감 요일
        • \(Int(target?.deadlineDay ?? 0).convertDeadlineDayToString().components(separatedBy: " ").count == 2 ? Int(target?.deadlineDay ?? 0).convertDeadlineDayToString().components(separatedBy: " ")[1] : "")
        
        벌금
        • \(Int(target?.fine ?? 0).insertComma())원
        • 보증금이 \(Int(study?.fine ?? 0).insertComma())원 밑으로 떨어지면 본인이 현재 가지고있는 보증금의 차액만큼 입금해야합니다.\n\n
        """
        
       return studyInfoStr
    }

    /// 멤버 정보중 공유 포맷애 맞춰 가져옵니다.
    ///
    /// - Parameter index: 정보를 가져올 인덱스
    /// - Returns: 멤버 정보중 공유할 내용을 새로운 문자열로 반환합니다.
    private func fetchMembers(index: Int) -> String {
        if let contentEntity = contentList?[index] {
            let contentMembers = CoreDataManager.shared.fetchContentMembers(contentEntity: contentEntity)
            
            var title = "참여자 (작성: \(contentMembers.filter({$0.postUrl != nil}).count) ∣ 미작성: \(contentMembers.filter({$0.postUrl == nil}).count))\n"
            
            contentMembers.forEach { member in
                if member.postUrl == nil {
                    let name =  "▪︎ \(member.name ?? "") ❌\n"
                    let fine = "  • 보증금 잔액 : \(Int(member.fine).insertComma())원\n"
                    let postTitle = "  • 작성된 게시글이 없습니다."
                    let url = "\n\n"
                    title.append(name + fine + postTitle + url)
                } else {
                    let name =  "▪︎ \(member.name ?? "") ✅\n"
                    let fine = "  • 보증금 잔액 : \(Int(member.fine).insertComma())원\n"
                    let postTitle = "  [제목]\n  • \(member.title ?? "")\n"
                    let url = "  [URL]\n  • \(member.postUrl ?? "")\n\n"
                    title.append(name + fine + postTitle + url)
                }
            }
            return title
        }
        
        return ""
    }
}
