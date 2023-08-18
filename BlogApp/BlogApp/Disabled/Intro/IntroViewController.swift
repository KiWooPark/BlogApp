//
//  IntroViewController.swift
//  BlogApp
//
//  Created by PKW on 2023/05/01.
//

import UIKit

class IntroViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

      
    }
    
    @IBAction func tapSingUpButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "signUpVC") as? SignUpViewController else { return }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func tapSignInButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "SignIn", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "signInVC") as? SignInViewController else { return }
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
