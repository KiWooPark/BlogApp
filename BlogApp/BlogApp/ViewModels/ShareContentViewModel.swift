//
//  ShareContentViewModel.swift
//  BlogApp
//
//  Created by PKW on 2023/06/16.
//

import Foundation

class ShareContentViewModel {
    
    var study: Study?
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

}
