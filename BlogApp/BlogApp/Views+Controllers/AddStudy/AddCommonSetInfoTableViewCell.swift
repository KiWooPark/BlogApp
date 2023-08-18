//
//  SetDateTableViewCell.swift
//  BlogApp
//
//  Created by PKW on 2023/05/16.
//

import UIKit

protocol AddCommonSetInfoTableViewCellDelegate: AnyObject {
    func showNextVC(option: StudyOptionType)
}

class AddCommonSetInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var changeButton: UIButton!
    
    var viewModel: StudyComposeViewModel?
    weak var delegate: AddCommonSetInfoTableViewCellDelegate?
    
    
    static var identifier: String { return String(describing: self)}
    
    //var indexPath: IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        subTitleLabel.isHidden = false
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configData(indexPath: IndexPath) {
        
//        switch indexPath.section {
//        case 3:
//            subTitleLabel.text = viewModel?.startDate.value == nil ? "시작 날짜를 설정해주세요." : viewModel?.startDate.value?.toString()
//        case 4:
//            subTitleLabel.text = viewModel?.finishDay.value == nil ? "마감 요일을 설정해주세요." : viewModel?.finishDay.value?.convertDeadlineDayToString() ?? ""
//        case 5:
//            subTitleLabel.text = viewModel?.fine.value == nil ? "벌금을 설정해주세요." : viewModel?.fine.value?.convertFineStr() ?? ""
//        default:
//            return
//        }
    }
    
    
    func configLayout(indexPath: IndexPath) {
//
//        let screenSize = UIScreen.main.bounds.size
//        changeButton.titleLabel?.font = UIFont.systemFont(ofSize: screenSize.width / changeButton.frame.width + 3)
//        changeButton.titleLabel?.numberOfLines = 1
//
//        changeButton.layer.borderWidth = 1
//        changeButton.layer.borderColor = UIColor.gray.cgColor
//        changeButton.layer.cornerRadius = 5
//
//        switch indexPath.section {
//        case 3:
//            titleLabel.text = "시작날짜 설정"
//            changeButton.setTitle("변경하기", for: .normal)
//        case 4:
//            titleLabel.text = "마감 요일 설정"
//            changeButton.setTitle("변경하기", for: .normal)
//        case 5:
//            titleLabel.text = "벌금 설정"
//            changeButton.setTitle("변경하기", for: .normal)
//        case 6:
//            switch indexPath.row {
//            case 0:
//                titleLabel.text = "참여인원 설정"
//                subTitleLabel.isHidden = true
//                changeButton.setTitle("추가하기", for: .normal)
//            default:
//                return
//            }
//        default:
//            return
//        }
    }
    
    @IBAction func tapSelectOptionButton(_ sender: Any) {
//        switch indexPath?.section {
//        case 3:
//            delegate?.showNextVC(option: .startDate)
//        case 4:
//            delegate?.showNextVC(option: .selectDeadlineDay)
//        case 5:
//            delegate?.showNextVC(option: .selectFine)
//        case 6:
//            switch indexPath?.row {
//            case 0:
//                delegate?.showNextVC(option: .studyMemeber)
//            default:
//                return
//            }
//        default:
//            return
//        }
    }
}



/*
 if #available(iOS 13.0, *) {
     // iOS 13 이상
     if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
        let keyWindow = windowScene.windows.first {
         keyWindow.addSubview(vc.view)
     }
 } else {
     // iOS 13 이하
     if let keyWindow = UIApplication.shared.keyWindow {
         keyWindow.addSubview(vc.view)
     }
 }
 */
