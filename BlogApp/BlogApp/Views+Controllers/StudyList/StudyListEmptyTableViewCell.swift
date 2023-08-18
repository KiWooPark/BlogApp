//
//  StudyListEmptyTableViewCell.swift
//  BlogApp
//
//  Created by PKW on 2023/08/15.
//

import UIKit

class StudyListEmptyTableViewCell: UITableViewCell {

    static var identifier: String { return String(describing: self)}
    
    @IBOutlet weak var emptyView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        emptyView.layer.cornerRadius = .cornerRadius
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
