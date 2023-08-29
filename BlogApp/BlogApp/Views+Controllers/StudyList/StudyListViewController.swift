//
//  StudyListViewController.swift
//  BlogApp
//
//  Created by PKW on 2023/05/01.
//

import UIKit
import SwiftSoup
import Alamofire

/// 스터디 목록을 표시하는 뷰 컨트롤러 입니다.
class StudyListViewController: UIViewController, ViewModelBindableType {
    
    // MARK:  ===== [@IBOutlet] =====
    
    // 스터디 목록을 표시하기 위한 테이블뷰
    @IBOutlet weak var studyListTableView: UITableView!
    
    // 새로운 스터디 추가 버튼
    @IBOutlet weak var addStudyButton: UIButton!
    
    
    
    // MARK: ===== [Property] =====
    
    // 뷰모델 타입을 typealias로 정의
    typealias ViewModelType = StudyListViewModel
    
    var viewModel: ViewModelType?
    
    
    
    // MARK: ===== [Override] =====
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 스터디 정보를 보여줄 셀 등록
        let studyListCellNib = UINib(nibName: "\(StudyListTableViewCell.identifier)", bundle: nil)
        studyListTableView.register(studyListCellNib, forCellReuseIdentifier: StudyListTableViewCell.identifier)
        
        // 스터디 목록이 비어있을 경우 보여줄 셀 등록
        let emptyStudyListCellNib = UINib(nibName: "\(StudyListEmptyTableViewCell.identifier)", bundle: nil)
        studyListTableView.register(emptyStudyListCellNib, forCellReuseIdentifier: StudyListEmptyTableViewCell.identifier)
        
        // 네비게이션바 배경 언더라인 제거
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()

        // 뷰모델 인스턴스 생성
        viewModel = StudyListViewModel()
        
        // 새로운 스터디 추가 버튼 테두리 원형으로 설정
        addStudyButton.layer.cornerRadius = addStudyButton.frame.width * 0.5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 뷰가 나타날때마다 스터디 정보 패치
        viewModel?.fetchStudys() {
            DispatchQueue.main.async {
                self.studyListTableView.reloadData()
            }
        }
    }
    
    
    
    // MARK: ===== [@IBAction] =====
    
    /// ADD 버튼을 탭 했을 때의 동작을 정의하는 메소드 입니다.
    ///
    /// AddStudyViewController로 이동 합니다.
    /// StudyComposeViewModel 인스턴스를 생성하여 전달 합니다.
    @IBAction func tapAddStudyButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "AddStudyViewController", bundle: nil)
        guard let nvc = storyboard.instantiateViewController(withIdentifier: "composeNVC") as? UINavigationController,
              let vc = nvc.viewControllers[0] as? AddStudyViewController else { return }
        
        vc.viewModel = StudyComposeViewModel(studyData: nil)
        
        nvc.modalPresentationStyle = .fullScreen
        self.present(nvc, animated: true)
    }
    
    
    
    // MARK:  ===== [Function] =====
    
    func bindViewModel() { }
}



// MARK: ===== [TableView - DataSource] =====

extension StudyListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 스터디 데이터가 없는 경우 1을 반환하고, 비어있지 않은 경우 스터디 목록의 수만큼 반환합니다.
        return viewModel?.listCount == 0 ? 1 : viewModel?.listCount ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 스터디 데이터가 없는 경우
        if viewModel?.listCount == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: StudyListEmptyTableViewCell.identifier, for: indexPath) as? StudyListEmptyTableViewCell else{ return UITableViewCell() }
            // StudyListEmptyTableViewCell 반환
            return cell
        } else {
            // 스터디 데이터가 있는 경우
            guard let cell = tableView.dequeueReusableCell(withIdentifier: StudyListTableViewCell.identifier, for: indexPath) as? StudyListTableViewCell else{ return UITableViewCell() }
            cell.viewModel = viewModel
            cell.configData(index: indexPath.row)
            
            // 스터디 정보를 표시하는 셀 반환
            return cell
        }
       
    }
}



// MARK: ===== [TableView - Delegate] =====

extension StudyListViewController: UITableViewDelegate {
    
    /// 테이블 뷰의 특정 행이 선택되었을 때 호출됩니다.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // 스터디 목록이 있는 경우 DetailStudyViewController로 이동합니다.
        if viewModel?.listCount != 0 {
            let storyboard = UIStoryboard(name: "DetailStudyViewController", bundle: nil)
            guard let vc = storyboard.instantiateViewController(withIdentifier: "detailStudyVC") as? DetailStudyViewController else { return }
            
            // 해당 인덱스의 스터디 Entity
            vc.viewModel = StudyDetailViewModel(studyData: viewModel?.list.value[indexPath.row] ?? Study())

            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
