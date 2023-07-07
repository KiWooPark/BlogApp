//
//  DetailStudyViewController.swift
//  BlogApp
//
//  Created by PKW on 2023/03/08.
//

import UIKit
import SafariServices

class DetailStudyViewController: UIViewController, ViewModelBindableType {
    
    typealias ViewModelType = StudyDetailViewModel
    //typealias ViewModelType = TestDetailViewModel
    
    var viewModel: ViewModelType?
    var listViewModel: StudyListViewModel?
   
    @IBOutlet weak var detailStudyTableView: UITableView!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 새로고침
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let titleCellNib = UINib(nibName: "\(DetailTitleTableViewCell.identifier)", bundle: nil)
        detailStudyTableView.register(titleCellNib, forCellReuseIdentifier: DetailTitleTableViewCell.identifier)
        let announcementCellNib = UINib(nibName: "\(DetailAnnouncementTableViewCell.identifier)", bundle: nil)
        detailStudyTableView.register(announcementCellNib, forCellReuseIdentifier: DetailAnnouncementTableViewCell.identifier)
        let commonSetInfoCellNib = UINib(nibName: "\(DetailCommonSetInfoTableViewCell.identifier)", bundle: nil)
        detailStudyTableView.register(commonSetInfoCellNib, forCellReuseIdentifier: DetailCommonSetInfoTableViewCell.identifier)
        let memberCellNib = UINib(nibName: "\(DetailMemberTableViewCell.identifier)", bundle: nil)
        detailStudyTableView.register(memberCellNib, forCellReuseIdentifier: DetailMemberTableViewCell.identifier)
        let memberInfoCellNib = UINib(nibName: "\(DetailMemberInfoTableViewCell.identifier)", bundle: nil)
        detailStudyTableView.register(memberInfoCellNib, forCellReuseIdentifier: DetailMemberInfoTableViewCell.identifier)
        
        detailStudyTableView.rowHeight = UITableView.automaticDimension
        detailStudyTableView.estimatedRowHeight = UITableView.automaticDimension
        
        bindViewModel()
         
        viewModel?.fetchStudy() {
            DispatchQueue.main.async {
                self.detailStudyTableView.reloadData()
            }
        }
    }
    
    func bindViewModel() {
        viewModel?.study.bind { [weak self] _ in
            guard let self = self else { return }
            
            self.listViewModel?.updateList(study: self.viewModel?.study.value)
            
            DispatchQueue.main.async {
                self.detailStudyTableView.reloadData()
            }
        }
        
//        viewModel?.study.bind { [weak self] _ in
//            guard let self = self else { return }
//
//            self.viewModel?.fetchMemberData(type: .currentWeek, completion: {
//
//                self.listViewModel?.updateList(study: self.viewModel?.study.value)
//
//                DispatchQueue.main.async {
//                    self.detailStudyTableView.reloadData()
//                }
//            })
//        }
    }
    
    @IBAction func tapMoreMenuButton(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let delete = UIAlertAction(title: "삭제", style: .destructive) { _ in
            
            self.listViewModel?.deleteStudy(study: self.viewModel?.study.value, completion: {
                self.navigationController?.popViewController(animated: true)
            })
        }
        
        let edit = UIAlertAction(title: "수정", style: .default) { _ in
            
            let storyboard = UIStoryboard(name: "AddStudyViewController", bundle: nil)
            guard let nvc = storyboard.instantiateViewController(withIdentifier: "composeNVC") as? UINavigationController,
                  let vc = nvc.viewControllers[0] as? AddStudyViewController else { return }
            
            vc.isEdit = true
            vc.viewModel = StudyComposeViewModel(studyData: self.viewModel?.study.value)
            vc.detailViewModel = self.viewModel
            
        
            let navigationVC = UINavigationController(rootViewController: vc)
            navigationVC.modalPresentationStyle = .fullScreen
            self.present(navigationVC, animated: true)
        }
        
        let share = UIAlertAction(title: "공유 내용 보기", style: .default) { _ in
            let storyboard = UIStoryboard(name: "ShareContentViewController", bundle: nil)
            guard let nvc = storyboard.instantiateViewController(withIdentifier: "ShareContentNVC") as? UINavigationController,
                  let vc = nvc.viewControllers[0] as? ShareContentViewController else { return }
            
            vc.viewModel = ShareContentViewModel(study: self.viewModel?.study.value)
            
            let navigationVC = UINavigationController(rootViewController: vc)
            navigationVC.modalPresentationStyle = .fullScreen
            self.present(navigationVC, animated: true)
        }
        
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        
        alert.addAction(edit)
        alert.addAction(share)
        alert.addAction(delete)
        alert.addAction(cancel)
        
        self.present(alert, animated: true)
    }
}

extension DetailStudyViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0,1,2,3,4:
            return 1
        case 5:
            return 1 + (viewModel?.study.value?.members?.count ?? 0)
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: DetailTitleTableViewCell.identifier, for: indexPath) as? DetailTitleTableViewCell else { return UITableViewCell() }
            cell.viewModel = viewModel
            cell.configData()
            
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: DetailAnnouncementTableViewCell.identifier, for: indexPath) as? DetailAnnouncementTableViewCell else { return UITableViewCell() }
            cell.viewModel = viewModel
            cell.configData()
            
            return cell
        case 2:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: DetailCommonSetInfoTableViewCell.identifier, for: indexPath) as? DetailCommonSetInfoTableViewCell else { return UITableViewCell() }
            cell.viewModel = viewModel
            cell.configLayout(indexPath: indexPath)
            cell.configData(index: indexPath)
            
            return cell
        case 3:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: DetailCommonSetInfoTableViewCell.identifier, for: indexPath) as? DetailCommonSetInfoTableViewCell else { return UITableViewCell() }
            cell.viewModel = viewModel
            cell.configLayout(indexPath: indexPath)
            cell.configData(index: indexPath)
            
            return cell
        case 4:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: DetailCommonSetInfoTableViewCell.identifier, for: indexPath) as? DetailCommonSetInfoTableViewCell else { return UITableViewCell() }
            cell.viewModel = viewModel
            cell.configLayout(indexPath: indexPath)
            cell.configData(index: indexPath)
            
            return cell
        case 5:
            switch indexPath.row {
            case 0:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: DetailMemberTableViewCell.identifier, for: indexPath) as? DetailMemberTableViewCell else { return UITableViewCell() }
                return cell
            default:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: DetailMemberInfoTableViewCell.identifier, for: indexPath) as? DetailMemberInfoTableViewCell else { return UITableViewCell() }

                cell.viewModel = viewModel
                cell.delegate = self
                cell.showPostButton.tag = indexPath.row
                
                cell.configLayout(indexPath: indexPath)
                cell.configData(indexPath: indexPath)
            
                return cell
            }
        default:
            return UITableViewCell()
        }
    }
}

extension DetailStudyViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case 4:
            return 30
        default:
            return .leastNormalMagnitude
        }
    }
}


extension DetailStudyViewController: DetailMemberInfoTableViewCellDelegate {
    func showBlogWebView(urlStr: String) {
        
        if let url = URL(string: urlStr) {
            let safariVC = SFSafariViewController(url: url)
            self.present(safariVC, animated: true)
        }
    }
}

