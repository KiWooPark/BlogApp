//
//  ContentCollectionViewCell.swift
//  BlogApp
//
//  Created by PKW on 2023/07/01.
//

import UIKit

class ContentCollectionViewCell: UICollectionViewCell {
    
    var viewModel: ShareContentViewModel?
    
    @IBOutlet weak var shareContentTextView: UITextView!
    @IBOutlet weak var currentStudyView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = .cornerRadius
    }
    
    func configData(index: Int) {
        if ((viewModel?.contentList?.count ?? 0) - 1) == index {
            currentStudyView.isHidden = false
        } else {
            shareContentTextView.text = viewModel?.fetchContent(index: index) ?? ""
            currentStudyView.isHidden = true
        }
    }
}
