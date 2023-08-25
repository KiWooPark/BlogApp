//
//  UITableViewCell+Extention.swift
//  BlogApp
//
//  Created by PKW on 2023/06/12.
//

import Foundation
import UIKit

// MARK: ===== [Extention] =====
extension UITableViewCell {
    
    // MARK:  ===== [Property] =====
    
    /// 현재 셀이 속한 테이블 뷰를 반환합니다.
    ///
    /// - Returns: 현재 셀의 상위 뷰로서의 `UITableView` 인스턴스 또는 `nil` (셀이 테이블 뷰에 속하지 않은 경우).
    var tableView: UITableView? {
        return superview as? UITableView
    }
    
    /// 현재 셀의 인덱스 패스를 반환합니다.
    ///
    /// - Returns: 현재 셀에 대한 `IndexPath` 인스턴스 또는 `nil` (셀이 테이블 뷰에 속하지 않거나 인덱스 패스를 찾을 수 없는 경우).
    var indexPath: IndexPath? {
        return tableView?.indexPath(for: self)
    }
}
