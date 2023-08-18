//
//  StudyListViewController.swift
//  BlogApp
//
<<<<<<< HEAD
//  Created by PKW on 2023/05/01.
=======
//  Created by PKW on 2023/02/27.
>>>>>>> main
//

import UIKit
import SwiftSoup
import Alamofire

class StudyListViewController: UIViewController, ViewModelBindableType {
    
    @IBOutlet weak var studyListTableView: UITableView!
<<<<<<< HEAD
    @IBOutlet weak var addStudyButton: UIButton!
    
    typealias ViewModelType = StudyListViewModel
    
=======

    typealias ViewModelType = StudyListViewModel
>>>>>>> main
    var viewModel: ViewModelType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
<<<<<<< HEAD
    
        // 테이블뷰 셀 등록
        let studyListCellNib = UINib(nibName: "\(StudyListTableViewCell.identifier)", bundle: nil)
        studyListTableView.register(studyListCellNib, forCellReuseIdentifier: StudyListTableViewCell.identifier)
        let emptyStudyListCellNib = UINib(nibName: "\(StudyListEmptyTableViewCell.identifier)", bundle: nil)
        studyListTableView.register(emptyStudyListCellNib, forCellReuseIdentifier: StudyListEmptyTableViewCell.identifier)
        
        // 네비게이션바 세팅
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()

        // 뷰모델 인스턴스 생성
        viewModel = StudyListViewModel()
        
        addStudyButton.layer.cornerRadius = addStudyButton.frame.width * 0.5
=======
        
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
        
        
        
>>>>>>> main
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
<<<<<<< HEAD
        // VC가 나타날때마다 참여중인 스터디 패치
        viewModel?.fetchStudys() {
=======
        viewModel?.fetchStudys()
        
        DispatchQueue.main.async {
            self.studyListTableView.reloadData()
        }
    }
    
    func bindViewModel() {
        // 사용 X
        viewModel?.list.bind { [weak self] data in
            guard let self = self else { return }
>>>>>>> main
            DispatchQueue.main.async {
                self.studyListTableView.reloadData()
            }
        }
    }
<<<<<<< HEAD
    
    func bindViewModel() { }
    
    /// 새로운 스터디를 생성하기 위한 버튼 이벤트 메소드 입니다.
    /// -. AddStudyViewController로 이동 합니다.
    /// -. StudyComposeViewModel 인스턴스를 생성하여 전달 합니다.
    /// -------------------------------------
    /// - Parameter sender: UIButton
=======

>>>>>>> main
    @IBAction func tapAddStudyButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "AddStudyViewController", bundle: nil)
        guard let nvc = storyboard.instantiateViewController(withIdentifier: "composeNVC") as? UINavigationController,
              let vc = nvc.viewControllers[0] as? AddStudyViewController else { return }
        
        vc.viewModel = StudyComposeViewModel(studyData: nil)
<<<<<<< HEAD
=======
        vc.listViewModel = viewModel
>>>>>>> main
        
        nvc.modalPresentationStyle = .fullScreen
        self.present(nvc, animated: true)
    }
}

extension StudyListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
<<<<<<< HEAD
        return viewModel?.listCount == 0 ? 1 : viewModel?.listCount ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if viewModel?.listCount == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: StudyListEmptyTableViewCell.identifier, for: indexPath) as? StudyListEmptyTableViewCell else{ return UITableViewCell() }
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: StudyListTableViewCell.identifier, for: indexPath) as? StudyListTableViewCell else{ return UITableViewCell() }
            cell.viewModel = viewModel
            cell.configData(index: indexPath.row)
            return cell
        }
       
=======
        return viewModel?.listCount == 0 ? 0 : viewModel?.listCount ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StudyListTableViewCell.identifier, for: indexPath) as? StudyListTableViewCell else{ return UITableViewCell() }
        cell.viewModel = viewModel
        cell.configData(indexPath: indexPath)
        return cell
>>>>>>> main
    }
}

extension StudyListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
<<<<<<< HEAD
        
        if viewModel?.listCount != 0 {
            let storyboard = UIStoryboard(name: "DetailStudyViewController", bundle: nil)
            guard let vc = storyboard.instantiateViewController(withIdentifier: "detailStudyVC") as? DetailStudyViewController else { return }

            vc.viewModel = StudyDetailViewModel(studyData: viewModel?.list.value[indexPath.row] ?? Study())

            self.navigationController?.pushViewController(vc, animated: true)
        }
=======
        let storyboard = UIStoryboard(name: "DetailStudyViewController", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "detailStudyVC") as? DetailStudyViewController else { return }
    
        vc.listViewModel = viewModel
        vc.viewModel = StudyDetailViewModel(studyData: viewModel?.list.value[indexPath.row] ?? Study())

        self.navigationController?.pushViewController(vc, animated: true)
>>>>>>> main
    }
}
