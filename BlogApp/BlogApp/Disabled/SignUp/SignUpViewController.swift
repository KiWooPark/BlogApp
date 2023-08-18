//
//  SignUpViewController.swift
//  BlogApp
//
//  Created by PKW on 2023/05/01.
//

import UIKit

class SignUpViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

      
    }
    
    @IBAction func tapCompleteSignUpButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "StudyList", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "studyListVC") as? StudyListViewController else { return }
        self.navigationController?.setViewControllers([vc], animated: true)
    }
}
