//
//  DetailMemberInfoTableViewCell.swift
//  BlogApp
//
//  Created by PKW on 2023/05/23.
//

import UIKit

protocol DetailMemberInfoTableViewCellDelegate: AnyObject {
    func showBlogWebView(urlStr: String)
}

class DetailMemberInfoTableViewCell: UITableViewCell {

    static var identifier: String { return String(describing: self)}
    
    var viewModel: StudyDetailViewModel?
    weak var delegate: DetailMemberInfoTableViewCellDelegate?
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var blogNameLable: UILabel!
    
    @IBOutlet weak var newPostCheckLabel: UILabel!
    
    @IBOutlet weak var postTitleLabel: UILabel!
    
    @IBOutlet weak var postDateLabel: UILabel!
    
    @IBOutlet weak var fineLabel: UILabel!
    
    
    @IBOutlet weak var showPostButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        blogNameLable.isHidden = false
        newPostCheckLabel.isHidden = false
        postDateLabel.isHidden = false
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
        blogNameLable.text = target?.blogName ?? ""
        fineLabel.text = "\(target?.fine ?? 0)"

        if target?.postData?.data == nil {
            postTitleLabel.text = target?.postData?.errorMessage ?? ""
            newPostCheckLabel.text = "X"
            postDateLabel.text = ""
        } else {
            newPostCheckLabel.text = "O"
            postTitleLabel.text = target?.postData?.data?.title ?? ""
            postDateLabel.text = (target?.postData?.data?.date ?? "").convertDateFormat(type: .mmdd)
        }
    }
    
    func configLayout(indexPath: IndexPath) {

        if viewModel?.members.count ?? 0 == indexPath.row {
            contentView.layer.cornerRadius = 5
            contentView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }

        if viewModel?.members[indexPath.row - 1].postData?.data == nil {
            blogNameLable.isHidden = true
            newPostCheckLabel.isHidden = viewModel?.members[indexPath.row - 1].postData?.errorMessage == "URL을 확인해주세요." ? true : false
            postDateLabel.isHidden = true
            showPostButton.isEnabled = false
        }
    }
    
    @IBAction func tapShowButton(_ sender: Any) {
        guard let button = sender as? UIButton else { return }
        let target = viewModel?.members[button.tag - 1]
        delegate?.showBlogWebView(urlStr: target?.postData?.data?.postUrl ?? "")
    }
}
