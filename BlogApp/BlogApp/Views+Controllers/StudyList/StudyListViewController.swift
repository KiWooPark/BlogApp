//
//  StudyListViewController.swift
//  BlogApp
//
//  Created by PKW on 2023/02/27.
//

import UIKit
import SwiftSoup
import Alamofire

class StudyListViewController: UIViewController, ViewModelBindableType {
    
    @IBOutlet weak var studyListTableView: UITableView!

    typealias ViewModelType = StudyListViewModel
    var viewModel: ViewModelType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let studyListCellNib = UINib(nibName: "\(StudyListTableViewCell.identifier)", bundle: nil)
        studyListTableView.register(studyListCellNib, forCellReuseIdentifier: StudyListTableViewCell.identifier)
        
        viewModel = StudyListViewModel()
        
        //bindViewModel()
        
        viewModel?.fetchStudys()
        
        // 확인 안한 주차 구하기
        // 707729864 // 2023-06-6
        
        // 708188399 // 2023-06-11 14:59:59
        // 708793199 // 2023-06-18 14:59:59
        // 709397999 // 2023-06-25 14:59:59
        // 710002799 // 2023-07-02 14:59:59
        let startDate = Date(timeIntervalSinceReferenceDate: 707729864)
        
        let date = Date(timeIntervalSinceReferenceDate: 710002799)
        
        startDate.calculateWeekNumber(finishDate: date)
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel?.fetchStudys()
        
        DispatchQueue.main.async {
            self.studyListTableView.reloadData()
        }
    }
    
    func bindViewModel() {
        // 사용 X
        viewModel?.list.bind { [weak self] data in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.studyListTableView.reloadData()
            }
        }
    }

    @IBAction func tapAddStudyButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "AddStudyViewController", bundle: nil)
        guard let nvc = storyboard.instantiateViewController(withIdentifier: "composeNVC") as? UINavigationController,
              let vc = nvc.viewControllers[0] as? AddStudyViewController else { return }
        
        vc.viewModel = StudyComposeViewModel(studyData: nil)
        vc.listViewModel = viewModel
        
        nvc.modalPresentationStyle = .fullScreen
        self.present(nvc, animated: true)
    }
}

extension StudyListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.listCount == 0 ? 0 : viewModel?.listCount ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StudyListTableViewCell.identifier, for: indexPath) as? StudyListTableViewCell else{ return UITableViewCell() }
        cell.viewModel = viewModel
        cell.configData(indexPath: indexPath)
        return cell
    }
}

extension StudyListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "DetailStudyViewController", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "detailStudyVC") as? DetailStudyViewController else { return }
    
        vc.listViewModel = viewModel
        vc.viewModel = StudyDetailViewModel(studyData: viewModel?.list.value[indexPath.row] ?? Study())

        self.navigationController?.pushViewController(vc, animated: true)
    }
}
