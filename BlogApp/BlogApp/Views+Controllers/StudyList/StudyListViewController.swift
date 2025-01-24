//
//  StudyListViewController.swift
//  BlogApp
//
//  Created by PKW on 2023/05/01.
//

import Alamofire
import SwiftSoup
import UIKit

class StudyListViewController: UIViewController, ViewModelBindableType {
    @IBOutlet weak var studyListTableView: UITableView!
    @IBOutlet weak var addStudyButton: UIButton!
    
    typealias ViewModelType = StudyListViewModel
    var viewModel: ViewModelType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 테이블뷰 셀 등록
        let studyListCellNib = UINib(nibName: "\(StudyListTableViewCell.identifier)", bundle: nil)
        studyListTableView.register(studyListCellNib, forCellReuseIdentifier: StudyListTableViewCell.identifier)
        let emptyStudyListCellNib = UINib(nibName: "\(StudyListEmptyTableViewCell.identifier)", bundle: nil)
        studyListTableView.register(emptyStudyListCellNib, forCellReuseIdentifier: StudyListEmptyTableViewCell.identifier)
        
        // 네비게이션바 세팅
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        // 뷰모델 인스턴스 생성
        viewModel = StudyListViewModel(studyRepository: DefaultStudyRepository())
        bindViewModel()
        
        viewModel?.fetchStudys()
        
        addStudyButton.layer.cornerRadius = addStudyButton.frame.width * 0.5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        // VC가 나타날때마다 참여중인 스터디 패치
//        viewModel?.fetchStudys {
//            DispatchQueue.main.async {
//                self.studyListTableView.reloadData()
//            }
//        }
    }
    
    func bindViewModel() { 
        viewModel?.list.bind({ [weak self] _ in
            DispatchQueue.main.async {
                self?.studyListTableView.reloadData()
            }
        })
    }
    
    /// 새로운 스터디를 생성하기 위한 버튼 이벤트 메소드 입니다.
    /// -. AddStudyViewController로 이동 합니다.
    /// -. StudyComposeViewModel 인스턴스를 생성하여 전달 합니다.
    /// -------------------------------------
    /// - Parameter sender: UIButton
    @IBAction func tapAddStudyButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "AddStudyViewController", bundle: nil)
        guard let nvc = storyboard.instantiateViewController(withIdentifier: "composeNVC") as? UINavigationController,
              let vc = nvc.viewControllers[0] as? AddStudyViewController else { return }

        vc.viewModel = StudyComposeViewModel(studyData: nil)

        nvc.modalPresentationStyle = .fullScreen
        self.present(nvc, animated: true)
    }
}

extension StudyListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.listCount == 0 ? 1 : viewModel?.listCount ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if viewModel?.listCount == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: StudyListEmptyTableViewCell.identifier, for: indexPath) as? StudyListEmptyTableViewCell else { return UITableViewCell() }
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: StudyListTableViewCell.identifier, for: indexPath) as? StudyListTableViewCell else { return UITableViewCell() }
            cell.viewModel = viewModel
            cell.configData(index: indexPath.row)
            return cell
        }
    }
}

extension StudyListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if viewModel?.listCount != 0 {
            let storyboard = UIStoryboard(name: "DetailStudyViewController", bundle: nil)
            guard let vc = storyboard.instantiateViewController(withIdentifier: "detailStudyVC") as? DetailStudyViewController else { return }

            vc.viewModel = StudyDetailViewModel(studyData: viewModel?.list.value[indexPath.row] ?? Study())

            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
