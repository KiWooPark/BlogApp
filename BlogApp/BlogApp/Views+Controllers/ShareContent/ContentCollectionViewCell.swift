//
//  ContentCollectionViewCell.swift
//  BlogApp
//
//  Created by PKW on 2023/07/01.
//

import UIKit

class ContentCollectionViewCell: UICollectionViewCell {
    
    var viewModel: ShareContentViewModel?
    
    @IBOutlet weak var testTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configData(index: Int) {
        testTextView.text = viewModel?.fetchContent(index: index)
    }
}
