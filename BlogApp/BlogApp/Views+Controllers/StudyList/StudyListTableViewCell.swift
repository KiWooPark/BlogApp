//
//  StudyListTableViewCell.swift
//  BlogApp
//
//  Created by PKW on 2023/05/17.
//

import UIKit

/// 스터디 정보를 표시하는 UITableViewCell 클래스 입니다.
class StudyListTableViewCell: UITableViewCell {

    // MARK:  ===== [@IBOutlet] =====
    
    // 스터디 정보를 보여줄 바탕 뷰
    @IBOutlet weak var baseView: UIView!
    
    // 진행중, 마감 표시 레이블
    @IBOutlet weak var progressLabel: BasePaddingLabel!
    
    // 스터디 제목 레이블
    @IBOutlet weak var studyTitleLabel: UILabel!
    
    // 마감 날짜 레이블
    @IBOutlet weak var deadlineDateLabel: UILabel!
    
    // 디데이 레이블
    @IBOutlet weak var dDayLabel: UILabel!

    // 참여중인 멤버 카운트 레이블
    @IBOutlet weak var memberCountLabel: UILabel!
    
    static var identifier: String { return String(describing: self)}

    var viewModel: StudyListViewModel?
    
    
    
    // MARK: ===== [Override] =====
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configLayout()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    
    
    // MARK:  ===== [Function] =====
    
    /// 레이아웃 설정
    func configLayout() {
        baseView.layer.cornerRadius = .cornerRadius
    
        progressLabel.clipsToBounds = true
        progressLabel.layer.cornerRadius = 3
    }
    
    /// 데이터 설정
    func configData(index: Int) {
        
        // 인덱스에 해당하는 스터디 데이터를 가져옵니다.
        guard let target = viewModel?.list.value[index] else { return }
       
        // 마감일이 지났는지 확인 후 레이블의 텍스트와 색상을 설정합니다.
        if let isPassed = viewModel?.isDeadlinePassed(index: index) {
            if isPassed {
                progressLabel.text = "마감"
                progressLabel.backgroundColor = .finishColor
            } else {
                progressLabel.text = "진행중"
                progressLabel.backgroundColor = .progressColor
            }
        }
        
        // D-Day를 계산하여 레이블에 텍스트를 설정합니다.
        let dDay = viewModel?.calculateDday(index: index) ?? 0
        
        if dDay == 0 {
            dDayLabel.text = "D-오늘!"
        } else if dDay < 0 {
            dDayLabel.text = "\(abs(dDay))일 지났어요"
        } else {
            dDayLabel.text = "D-\(dDay)"
        }
        
        // 스터디 이름을 레이블에 설정합니다.
        studyTitleLabel.text = target.title ?? ""
        
        // 참여 인원 카운트를 레이블에 설정합니다.
        memberCountLabel.text = "\(target.memberCount) 명"
        
        // 마감 날짜를 레이블에 설정합니다.
        deadlineDateLabel.text = viewModel?.getLastContentDeadlineDate(studtEntity: viewModel?.list.value[index]).toString()
    }
}
