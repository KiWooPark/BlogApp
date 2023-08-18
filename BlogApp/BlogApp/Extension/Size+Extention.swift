//
//  Size+Extention.swift
//  BlogApp
//
//  Created by PKW on 2023/07/25.
//

import Foundation
import UIKit

extension CGFloat {
    static let cornerRadius = 10.0
}

extension UIAlertAction {
    enum ActionType {
        case ok
        case edit
        case history
        case delete
        case cancel
    }
    
    func setTextColor(type: ActionType) {
        switch type {
        case .ok, .edit, .history:
            self.setValue(UIColor.buttonColor, forKey: "titleTextColor")
        case .delete:
            self.setValue(UIColor.finishColor, forKey: "titleTextColor")
        case .cancel:
            self.setValue(UIColor.finishColor, forKey: "titleTextColor")
        }
    }
}
