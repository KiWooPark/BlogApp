//
//  StudyListTableViewCell.swift
//  BlogApp
//
//  Created by PKW on 2023/05/17.
//

import UIKit

class StudyListTableViewCell: UITableViewCell {

    static var identifier: String { return String(describing: self)}
    
<<<<<<< HEAD
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var progressLabel: BasePaddingLabel!
    @IBOutlet weak var studyTitleLabel: UILabel!
    @IBOutlet weak var deadlineDateLabel: UILabel!
    @IBOutlet weak var dDayLabel: UILabel!
    @IBOutlet weak var memberCountLabel: UILabel!

=======
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var memberCountLable: UILabel!
    
>>>>>>> main
    var viewModel: StudyListViewModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
<<<<<<< HEAD
        configLayout()
=======
>>>>>>> main
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
<<<<<<< HEAD
    func configLayout() {
        baseView.layer.cornerRadius = .cornerRadius
    
        progressLabel.clipsToBounds = true
        progressLabel.layer.cornerRadius = 3
    }
    
    func configData(index: Int) {
        guard let target = viewModel?.list.value[index] else { return }
       
        // 713804399 // 713890799
        if let isPassed = viewModel?.isDeadlinePassed(index: index) {
            if isPassed {
                progressLabel.text = "마감"
                progressLabel.backgroundColor = .finishColor
            } else {
                progressLabel.text = "진행중"
                progressLabel.backgroundColor = .progressColor
            }
        }
        
        // D-Day
        let dDay = viewModel?.calculateDday(index: index) ?? 0
        
        if dDay == 0 {
            dDayLabel.text = "D-오늘!"
        } else if dDay < 0 {
            dDayLabel.text = "\(abs(dDay))일 지났어요."
        } else {
            dDayLabel.text = "D-\(dDay)"
        }
        
        // 스터디 이름
        studyTitleLabel.text = target.title ?? ""
        
        // 참여 인원
        memberCountLabel.text = "\(target.memberCount) 명"
        
        // 마감 날짜
        deadlineDateLabel.text = viewModel?.getLastContentDeadlineDate(studtEntity: viewModel?.list.value[index]).toString()
=======
    func configData(indexPath: IndexPath) {
        titleLabel.text = viewModel?.list.value[indexPath.row].title
        memberCountLable.text = "참여인원 \(viewModel?.list.value[indexPath.row].members?.count ?? 0)명"
>>>>>>> main
    }
}
