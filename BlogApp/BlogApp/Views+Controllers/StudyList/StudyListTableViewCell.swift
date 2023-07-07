//
//  StudyListTableViewCell.swift
//  BlogApp
//
//  Created by PKW on 2023/05/17.
//

import UIKit

class StudyListTableViewCell: UITableViewCell {

    static var identifier: String { return String(describing: self)}
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var memberCountLable: UILabel!
    
    var viewModel: StudyListViewModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func configData(indexPath: IndexPath) {
        titleLabel.text = viewModel?.list.value[indexPath.row].title
        memberCountLable.text = "참여인원 \(viewModel?.list.value[indexPath.row].members?.count ?? 0)명"
    }
}
