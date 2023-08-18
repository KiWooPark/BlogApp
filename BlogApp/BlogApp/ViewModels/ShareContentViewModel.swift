//
//  ShareContentViewModel.swift
//  BlogApp
//
//  Created by PKW on 2023/06/16.
//

import Foundation

class ShareContentViewModel {
    
    var study: Study?
    var contentList: [Content]?
    
    var currentIndex = 0
    
    init(study: Study?) {
        if let studyEntity = study {
            self.study = studyEntity
            self.contentList = CoreDataManager.shared.fetchContentList(studyEntity: studyEntity)
        }
    }
 
    func fetchContent(index: Int) -> String {
        
        let studyInfo = fetchStudyInfoStr(index: index)
        let contentMembers = fetchMembers(index: index)

        return studyInfo + contentMembers
    }

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
