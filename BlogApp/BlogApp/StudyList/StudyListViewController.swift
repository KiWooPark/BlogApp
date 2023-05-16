//
//  StudyListViewController.swift
//  BlogApp
//
//  Created by PKW on 2023/02/27.
//

import UIKit

class StudyListViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

     
    }
    
    @IBAction func tapAddStudyButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "AddStudy", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "addStudyVC") as? AddStudyViewController else { return }
        
        let navigationVC = UINavigationController(rootViewController: vc)
        navigationVC.modalPresentationStyle = .fullScreen
        self.present(navigationVC, animated: true)
    }
}

extension StudyListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "studyCell", for: indexPath)
        return cell
    }
}

extension StudyListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "DetailStudy", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "detailStudyVC") as? DetailStudyViewController else { return }
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
