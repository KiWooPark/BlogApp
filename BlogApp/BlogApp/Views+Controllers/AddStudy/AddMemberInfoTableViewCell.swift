//
//  AddMemberInfoTableViewCell.swift
//  BlogApp
//
//  Created by PKW on 2023/05/25.
//

import UIKit

<<<<<<< HEAD
protocol AddMemberInfoTableViewCellDelegate: AnyObject {
    func showEditMemberVC(index: Int)
    func showBlogWebView(url: String)
}

=======
>>>>>>> main
class AddMemberInfoTableViewCell: UITableViewCell {

    static var identifier: String { return String(describing: self)}
    
    @IBOutlet weak var nameLabel: UILabel!
<<<<<<< HEAD
    @IBOutlet weak var fineLabel: UILabel!
    @IBOutlet weak var blogUrlLabel: UILabel!
    
    var viewModel: StudyComposeViewModel?
    weak var delegate: AddMemberInfoTableViewCellDelegate?
=======
    @IBOutlet weak var blogUrlLabel: UILabel!
    @IBOutlet weak var fineLabel: UILabel!
    
    var viewModel: StudyComposeViewModel?
>>>>>>> main
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
<<<<<<< HEAD
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(tapBlogURLLable(_:)))
        blogUrlLabel.isUserInteractionEnabled = true
        blogUrlLabel.addGestureRecognizer(recognizer)
=======
>>>>>>> main
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configData(indexPath: IndexPath) {
        
<<<<<<< HEAD
        let target = viewModel?.studyMembers.value[indexPath.row - 1]
        
        nameLabel.text = target?.name ?? ""
        fineLabel.text = "보증금 ∣ \(target?.fine ?? 0)"
        blogUrlLabel.text = target?.blogUrl ?? ""
    }
    
    @IBAction func tapEditButton(_ sender: Any) {
        guard let button = sender as? UIButton else { return }
        
        let contentView = button.superview
        let cell = contentView?.superview as! UITableViewCell
        let tableView = cell.superview as! UITableView
        
        if let indexPath = tableView.indexPath(for: cell) {
            delegate?.showEditMemberVC(index: indexPath.row - 1)
        }
    }
    
    
=======
        let target = viewModel?.coreDataMembers.value[indexPath.row - 1]
        
        nameLabel.text = target?.name
        blogUrlLabel.text = target?.blogUrl
        fineLabel.text = "\(target?.fine ?? 0)"
        
//        nameLabel.text = viewModel?.members.value[indexPath.row - 1].name
//        blogUrlLabel.text = viewModel?.members.value[indexPath.row - 1].blogUrl
//        fineLabel.text = "\(viewModel?.members.value[indexPath.row - 1].fine ?? 0)"
    }
    
>>>>>>> main
    @IBAction func tapDeleteButton(_ sender: Any) {
        guard let button = sender as? UIButton else { return }
       
        let contentView = button.superview
        let cell = contentView?.superview as! UITableViewCell
        let tableView = cell.superview as! UITableView
        
        if let indexPath = tableView.indexPath(for: cell) {
<<<<<<< HEAD
            let member = viewModel?.studyMembers.value[indexPath.row - 1]
            viewModel?.studyMembers.value.remove(at: indexPath.row - 1)
            //CoreDataManager.shared.deleteStudyMember(user: member!)
            
        }
    }
    
    @objc func tapBlogURLLable(_ sender: UITapGestureRecognizer) {
        delegate?.showBlogWebView(url: blogUrlLabel.text ?? "")
    }
=======
            viewModel?.coreDataMembers.value.remove(at: indexPath.row - 1)
        }
    }
>>>>>>> main
}
