//
//  DetailMemberInfoTableViewCell.swift
//  BlogApp
//
//  Created by PKW on 2023/05/23.
//

import UIKit

protocol DetailMemberInfoTableViewCellDelegate: AnyObject {
    func showBlogWebView(blogURL: String)
}

class DetailMemberInfoTableViewCell: UITableViewCell {

    static var identifier: String { return String(describing: self)}
    
    var viewModel: StudyDetailViewModel?
    weak var delegate: DetailMemberInfoTableViewCellDelegate?
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var blogNameLabel: UILabel!
    
    @IBOutlet weak var fineLabel: UILabel!
    
    
    @IBOutlet weak var showPostButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        blogNameLabel.isHidden = false
        showPostButton.isEnabled = true
    }
    
    // 셀사이 간격주기
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configData(indexPath: IndexPath) {
        
        let target = viewModel?.members[indexPath.row - 1]
        
        nameLabel.text = target?.name ?? ""
        blogNameLabel.text = target?.blogUrl ?? ""
        fineLabel.text = "보증금 | \(target?.fine ?? 0)"
    }
    
    func configLayout(indexPath: IndexPath) {

        if viewModel?.members.count ?? 0 == indexPath.row {
            contentView.layer.cornerRadius = 5
            contentView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }

//        if viewModel?.members[indexPath.row - 1].postData?.data == nil {
//            blogNameLable.isHidden = true
//            newPostCheckLabel.isHidden = viewModel?.members[indexPath.row - 1].postData?.errorMessage == "URL을 확인해주세요." ? true : false
//            postDateLabel.isHidden = true
//            showPostButton.isEnabled = false
//        }
    }
    
    @IBAction func tapShowButton(_ sender: Any) {
        guard let button = sender as? UIButton else { return }
    
        let blogUrl = viewModel?.members[button.tag - 1].blogUrl ?? ""
        delegate?.showBlogWebView(blogURL: blogUrl)
    }
}
