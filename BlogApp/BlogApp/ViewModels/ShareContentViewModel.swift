//
//  ShareContentViewModel.swift
//  BlogApp
//
//  Created by PKW on 2023/06/16.
//

import Foundation

class ShareContentViewModel {
    
    var study: Study?
<<<<<<< HEAD
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
=======
    var contentList: [Content]
    
    init(study: Study?) {
        self.study = study
        self.contentList = CoreDataManager.shared.fetchContent(studyEntity: study!)
    }
 
    func fetchContent(index: Int) -> String {

        let announcementStr = fetchAnnouncementStr()

        let startDateStr = fetchStartDateStr(index: index)

        let setDayStr = fetchSetDayStr(index: index)

        let fineStr = fetchFineStr(index: index)

        let resultStr = fetchMembers(index: index)

        return announcementStr + startDateStr + setDayStr + fineStr + resultStr
    }

    private func fetchAnnouncementStr() -> String {
        return (study?.announcement ?? "") + "\n\n"
    }

    private func fetchStartDateStr(index: Int) -> String {
        
        // 시작 날짜 ~ 마감 날짜
        let startDate = contentList[index].finishDate?.getStartDateAndEndDate().0
        let endDate = contentList[index].finishDate?.getStartDateAndEndDate().1
        
        let weekDate = " - \(startDate?.convertStartDate() ?? "") ~ \(endDate?.convertStartDate() ?? "")\n"
        // 진행중인 주차
        let currentWeek = " - 진행 주차 : \(contentList[index].currentWeekNumber) 주차\n\n"

        return "스터디 진행 기간\n" + weekDate + currentWeek
    }

    private func fetchSetDayStr(index: Int) -> String {
        // 마감 요일
        let finishDay = " - 마감 요일 : \(Int(contentList[index].finishWeekDay).convertSetDayStr())\n"
        // 마감 기한
        let finishTime = " - \(contentList[index].currentWeekNumber)주차 마감 기한 : \(contentList[index].finishDate?.getStartDateAndEndDate().1.convertStartDate() ?? "") \(Int(contentList[index].finishWeekDay).convertSetDayStr().components(separatedBy: " ")[1]) 자정(23:59)까지\n\n"

        return "마감\n" + finishDay + finishTime
    }

    private func fetchFineStr(index: Int) -> String {
        // 벌금
        let fine = " - 벌금 : \(Int(study?.fine ?? 0).convertFineStr())\n"
        // 보증금 설명
        let explanationFine =  " - 보증금이 \(Int(study?.fine ?? 0).convertFineStr()) 미만으로 떨어지면, 본인이 가지고있는 보증금의 차액만큼 입금하셔야 합니다.\n\n"

        return "벌금\n" + fine + explanationFine
    }

    private func fetchMembers(index: Int) -> String {
        var resultStr = "\(contentList[index].currentWeekNumber) 주차 참여자 및 벌금 현황 (0/0)\n"
        
        let members = CoreDataManager.shared.fetchCoreDataContentMembers(content: contentList[index])
        
        members.forEach { member in

            // 이름
            let nameStr = "\(member.name ?? "")\n"
            // 보증금 잔액
            let fineStr = " - 보증금 잔액 : \(member.fine ?? 0)\n"
            // 제목,URL
            var titleStr = ""
            var URLStr = ""
            
            if member.postUrl == nil {
                titleStr = " - 작성된 게시글이 없습니다."
                URLStr = "\n\n"
            } else {
                titleStr = " - 제목 : \(member.title ?? "")\n"
                URLStr = " - URL : \(member.postUrl ?? "")\n\n"
            }
    
            resultStr.append(nameStr + fineStr + titleStr + URLStr)
        }

        return resultStr
    }

>>>>>>> main
}
