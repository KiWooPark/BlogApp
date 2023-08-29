//
//  ContentCollectionViewCell.swift
//  BlogApp
//
//  Created by PKW on 2023/07/01.
//

import UIKit

class ContentCollectionViewCell: UICollectionViewCell {
    
    var viewModel: ShareContentViewModel?
    
    // 마감 정보를 표시할 텍스트 뷰
    @IBOutlet weak var shareContentTextView: UITextView!
    
    // 현재 진행중인 회차를 표시하기위한 뷰
    @IBOutlet weak var currentStudyView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = .cornerRadius
    }
    
    /// 해당 인덱스의 마감 정보를 설정합니다.
    /// - Parameter index: 표시할 위치 인덱스 번호
    func configData(index: Int) {
        if ((viewModel?.contentList?.count ?? 0) - 1) == index {
            currentStudyView.isHidden = false
        } else {
            shareContentTextView.text = viewModel?.fetchContent(index: index) ?? ""
            currentStudyView.isHidden = true
        }
    }
}
