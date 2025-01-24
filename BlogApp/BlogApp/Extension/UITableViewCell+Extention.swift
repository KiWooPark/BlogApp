//
//  UITableViewCell+Extention.swift
//  BlogApp
//
//  Created by PKW on 2023/06/12.
//

import Foundation
import UIKit

extension UITableViewCell {
    var tableView: UITableView? {
        return superview as? UITableView
    }
    
    var indexPath: IndexPath? {
        return tableView?.indexPath(for: self)
    }
}
