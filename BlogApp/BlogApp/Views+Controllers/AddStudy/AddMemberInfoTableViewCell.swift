//
//  AddMemberInfoTableViewCell.swift
//  BlogApp
//
//  Created by PKW on 2023/05/25.
//

import UIKit

class AddMemberInfoTableViewCell: UITableViewCell {

    static var identifier: String { return String(describing: self)}
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var blogUrlLabel: UILabel!
    @IBOutlet weak var fineLabel: UILabel!
    
    var viewModel: StudyComposeViewModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configData(indexPath: IndexPath) {
        
        let target = viewModel?.coreDataMembers.value[indexPath.row - 1]
        
        nameLabel.text = target?.name
        blogUrlLabel.text = target?.blogUrl
        fineLabel.text = "\(target?.fine ?? 0)"
    }
    
    @IBAction func tapDeleteButton(_ sender: Any) {
        guard let button = sender as? UIButton else { return }
       
        let contentView = button.superview
        let cell = contentView?.superview as! UITableViewCell
        let tableView = cell.superview as! UITableView
        
        if let indexPath = tableView.indexPath(for: cell) {
            let member = viewModel?.coreDataMembers.value[indexPath.row - 1]
            viewModel?.coreDataMembers.value.remove(at: indexPath.row - 1)
            CoreDataManager.shared.deleteStudyMemberTest(user: member!)
            
        }
    }
}
