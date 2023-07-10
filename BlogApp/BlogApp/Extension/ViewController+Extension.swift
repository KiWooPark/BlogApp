//
//  ViewController+Extension.swift
//  BlogApp
//
//  Created by PKW on 2023/07/10.
//

import Foundation
import UIKit

extension UIViewController {
    func makeAlertDialog(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "확인", style: .default)
        
        alert.addAction(ok)
        
        self.present(alert, animated: true)
    }
}

