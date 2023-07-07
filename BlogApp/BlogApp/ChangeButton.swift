//
//  ChangeButton.swift
//  BlogApp
//
//  Created by PKW on 2023/05/16.
//

import UIKit

final class ChangeButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureUI()
    }

    private func configureUI() {
        if #available(iOS 15.0, *) {
            var buttonConfig = UIButton.Configuration.filled()
            var buttonTitleAttribute = AttributedString()
            buttonTitleAttribute.font = UIFont.boldSystemFont(ofSize: 8)
            buttonConfig.attributedTitle = buttonTitleAttribute
            buttonConfig.titleAlignment = .center
            buttonConfig.baseBackgroundColor = .gray
            buttonConfig.baseForegroundColor = .black
            buttonConfig.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
            configuration = buttonConfig
        } else {
            self.invalidateIntrinsicContentSize()
            self.titleLabel?.textAlignment = .center
            self.backgroundColor = .gray
            self.titleLabel?.font = UIFont.systemFont(ofSize: 8, weight: .bold)
            self.setTitleColor(.black, for: .normal)
            self.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        }
    }
}
