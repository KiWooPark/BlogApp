//
//  DetailCommonSetInfoTableViewCell.swift
//  BlogApp
//
//  Created by PKW on 2023/05/23.
//

import UIKit

class DetailCommonSetInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    static var identifier: String { return String(describing: self)}
    
    var viewModel: StudyDetailViewModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // 셀사이 간격주기
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
        contentView.layer.cornerRadius = 10
    }
    
    func configData(index: IndexPath) {
//        switch index.section {
//        case 2:
//            subTitleLabel.text = viewModel?.study.value?.startDate?.toString()
//        case 3:
//            subTitleLabel.text = "\(Int(viewModel?.study.value?.finishDay ?? 0).convertDeadlineDayToString())"
//        case 4:
//            subTitleLabel.text = Int(viewModel?.study.value?.fine ?? 0).convertFineStr()
//        default:
//            return
//        }
    }
    
    func configLayout(indexPath: IndexPath) {
        switch indexPath.section {
        case 2:
            titleLabel.text = "시작 날짜"
        case 3:
            titleLabel.text = "마감 요일"
        case 4:
            titleLabel.text = "벌금"
        default:
            break
        }
    }
}
