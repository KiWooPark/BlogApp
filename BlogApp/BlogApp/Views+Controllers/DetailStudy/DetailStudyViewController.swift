//
//  DetailStudyViewController.swift
//  BlogApp
//
//  Created by PKW on 2023/05/08.
//

import UIKit
import SafariServices

class DetailStudyViewController: UIViewController, ViewModelBindableType {
    
    @IBOutlet weak var studySubTitleLabel: UILabel!

    // 스터디 정보
    @IBOutlet weak var studyInfoView: UIView!
    @IBOutlet weak var studyNameLabel: UILabel!
    @IBOutlet weak var firstStudyDateLabel: UILabel!
    @IBOutlet weak var deadlineDayLabel: UILabel!
    @IBOutlet weak var fineLabel: UILabel!
    // 진행 상황
    @IBOutlet weak var durationInfoView: UIView!
    @IBOutlet weak var studyCountLabel: UILabel!
    @IBOutlet weak var dDayLabel: UILabel!
    @IBOutlet weak var durationSubTitleLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    // 참여자
    @IBOutlet weak var memberCountLabel: UILabel!
    @IBOutlet weak var memberInfoStackView: UIStackView!
    
    typealias ViewModelType = StudyDetailViewModel
    
    var viewModel: ViewModelType?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 라지 타이틀 사용 X
        navigationItem.largeTitleDisplayMode = .never
       
        // 네비게이션바 그림자 제거
        self.navigationController?.navigationBar.standardAppearance.shadowColor = .clear
       
        // 네비게이션바 RightButton 추가
        let moreButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis") , style: .plain, target: self, action: #selector(tapMoreMenuButton( _:)))
        moreButton.tintColor = .black
        navigationItem.rightBarButtonItem = moreButton
        
        // 네비게이션바 타이틀 추가
        navigationItem.title = "정보"
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        viewModel?.fetchStudyData()
        
        configLayout()
        configData()
        insertMemberInfoViewsInStackView()
        
        if viewModel?.isDeadlinePassed() == true {
            makeAlertDialog(title: "마감 날짜가 지났습니다.\n\(viewModel?.lastContent?.contentNumber ?? 0)회차 마감을 진행해 주세요.", message: nil, type: .addContent)
        }
    }
    
    func bindViewModel() {
        
    }
    
    func configLayout() {
        studyInfoView.layer.cornerRadius = .cornerRadius
        durationInfoView.layer.cornerRadius = .cornerRadius
    }
    
    func configData() {
        
        guard let target = viewModel?.study.value else { return }
        
        if target.isNewStudy == true {
            studySubTitleLabel.text = "신규로 등록된 스터디에요."
            studyNameLabel.text = target.title ?? ""
            firstStudyDateLabel.text = (target.firstStartDate ?? Date()).toString()
            deadlineDayLabel.text = "\(Int(target.deadlineDay).convertDeadlineDayToString())"
            fineLabel.text = "\(Int(target.fine).insertComma())원"
            
            studyCountLabel.text = "\(viewModel?.lastContent?.contentNumber ?? 0) 회차 진행중이에요. "
            
            let dDay = viewModel?.calculateDday() ?? 0
            
            if dDay == 0 {
                dDayLabel.text = "마감일이 오늘이에요!"
            } else if dDay < 0 {
                dDayLabel.text = "마감일이 \(abs(dDay))일 지났어요!"
            } else {
                dDayLabel.text = "마감까지 \(dDay)일 남았어요!"
            }
        
            if viewModel?.contentList.count == 1 {
                durationSubTitleLabel.text = "이번 회차는 처음 진행되는 회차에요."
                durationLabel.text = "~ \(viewModel?.lastContent?.deadlineDate?.toString() ?? "")"
            } else {
                durationSubTitleLabel.text = "\((viewModel?.lastContent?.contentNumber ?? 0) - 1) 회차 마감일 이후부터 시작되요!"
                durationLabel.text = "\(viewModel?.lastContent?.startDate?.toString() ?? "") ~ \(viewModel?.lastContent?.deadlineDate?.toString() ?? "")"
            }

            // 참여자
            memberCountLabel.text = "현재 \(viewModel?.members.count ?? 0)명이 참여중이에요."
            
        } else {
            studySubTitleLabel.text = "기존에 진행으로 등록된 스터디에요."
            studyNameLabel.text = target.title ?? ""
            firstStudyDateLabel.text = (target.firstStartDate ?? Date()).toString()
            deadlineDayLabel.text = "\(Int(target.deadlineDay).convertDeadlineDayToString())"
            fineLabel.text = "\(Int(target.fine).insertComma())원"
            
            studyCountLabel.text = "\(viewModel?.lastContent?.contentNumber ?? 0) 회차 진행중이에요. "
            
            let dDay = viewModel?.calculateDday() ?? 0
            
            if dDay == 0 {
                dDayLabel.text = "마감일이 오늘이에요!"
            } else if dDay < 0 {
                dDayLabel.text = "마감일이 \(abs(dDay))일이나 지났어요!"
            } else {
                dDayLabel.text = "마감까지 \(dDay)일 남았어요!"
            }
            
            let startDate = viewModel?.lastContent?.startDate ?? Date()
            let deadlineDate = viewModel?.lastContent?.deadlineDate ?? Date()
            
            studyCountLabel.text = "\(viewModel?.lastContent?.contentNumber ?? 0) 회차 진행중이에요. "
            
            if viewModel?.lastContent?.contentNumber ?? 0 == 1 {
                durationSubTitleLabel.text = "이번 회차는 처음 진행되는 회차에요."
            } else {
                durationSubTitleLabel.text = "\((viewModel?.lastContent?.contentNumber ?? 0) - 1) 회차 마감일 이후부터 시작되요!"
            }
            
            
            
            durationLabel.text = "\(startDate.toString()) ~ \(deadlineDate.toString())"
            
            memberCountLabel.text = "현재 \(viewModel?.members.count ?? 0)명이 참여중이에요."
        }
    }
    
    func insertMemberInfoViewsInStackView() {
        
        guard let target = viewModel?.members else { return }

        // 기존에 있던 멤버 뷰 삭제
        if !memberInfoStackView.arrangedSubviews.isEmpty {
            memberInfoStackView.arrangedSubviews.forEach { view in
                if let memberInfoView = view as? StudyMemberInfoView {
                    memberInfoStackView.removeArrangedSubview(memberInfoView)
                }
            }
        }
        
        // 새로 멤버뷰 생성
        for index in 0 ..< target.count {
            let memberInfoView = StudyMemberInfoView()
            memberInfoView.nameLabel.text = target[index].name ?? ""
            
            if target[index].fine < (viewModel?.study.value?.fine ?? 0) {
                memberInfoView.fineSubTitle.text = "보증금이 부족해요! (현재 \(Int(target[index].fine).insertComma())원)"
            } else {
                memberInfoView.fineSubTitle.text = "\(Int(target[index].fine).insertComma())원"
            }
            
            
            memberInfoView.showBlogButton.addTarget(self, action: #selector(showBlogWebView( _:)), for: .touchUpInside)
            memberInfoView.showBlogButton.tag = index
            memberInfoStackView.addArrangedSubview(memberInfoView)
        }
    }

    @objc func showBlogWebView(_ sender: UIButton) {
        guard let url = URL(string: viewModel?.members[sender.tag].blogUrl ?? "") else { return }
        
        let safariVC = SFSafariViewController(url: url)
        self.present(safariVC, animated: true)
    }
    
    @objc func tapMoreMenuButton(_ sender: Any) {
        makeAlertDialog(title: nil, message: nil, type: .deatileVC, style: .actionSheet)
    }
}

//class DetailStudyViewController: UIViewController, ViewModelBindableType {
//
//    typealias ViewModelType = StudyDetailViewModel
//
//    var viewModel: ViewModelType?
//
//    @IBOutlet weak var detailStudyTableView: UITableView!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        let titleCellNib = UINib(nibName: "\(DetailTitleTableViewCell.identifier)", bundle: nil)
//        detailStudyTableView.register(titleCellNib, forCellReuseIdentifier: DetailTitleTableViewCell.identifier)
//        let announcementCellNib = UINib(nibName: "\(DetailAnnouncementTableViewCell.identifier)", bundle: nil)
//        detailStudyTableView.register(announcementCellNib, forCellReuseIdentifier: DetailAnnouncementTableViewCell.identifier)
//        let commonSetInfoCellNib = UINib(nibName: "\(DetailCommonSetInfoTableViewCell.identifier)", bundle: nil)
//        detailStudyTableView.register(commonSetInfoCellNib, forCellReuseIdentifier: DetailCommonSetInfoTableViewCell.identifier)
//        let memberCellNib = UINib(nibName: "\(DetailMemberTableViewCell.identifier)", bundle: nil)
//        detailStudyTableView.register(memberCellNib, forCellReuseIdentifier: DetailMemberTableViewCell.identifier)
//        let memberInfoCellNib = UINib(nibName: "\(DetailMemberInfoTableViewCell.identifier)", bundle: nil)
//        detailStudyTableView.register(memberInfoCellNib, forCellReuseIdentifier: DetailMemberInfoTableViewCell.identifier)
//
//        detailStudyTableView.rowHeight = UITableView.automaticDimension
//        detailStudyTableView.estimatedRowHeight = UITableView.automaticDimension
//
//        bindViewModel()
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        viewModel?.fetchStudyData()
//
//        if viewModel?.checkDeadlinePassed() == true {
//            makeAlertDialog(title: "마감 날짜가 지났습니다.", message: "", vcType: .addContent, vc: self)
//        }
//    }
//
//    func bindViewModel() {
//        viewModel?.study.bind { [weak self] _ in
//            guard let self = self else { return }
//
//            DispatchQueue.main.async {
//                print("bindViewModel")
//                self.detailStudyTableView.reloadData()
//            }
//        }
//    }
//
//    @IBAction func tapMoreMenuButton(_ sender: Any) {
//        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//        let delete = UIAlertAction(title: "삭제", style: .destructive) { _ in
//
////            self.listViewModel?.deleteStudy(study: self.viewModel?.study.value, completion: {
////                self.navigationController?.popViewController(animated: true)
////            })
//        }
//
//        let edit = UIAlertAction(title: "수정", style: .default) { _ in
//
//            let storyboard = UIStoryboard(name: "AddStudyViewController", bundle: nil)
//            guard let nvc = storyboard.instantiateViewController(withIdentifier: "composeNVC") as? UINavigationController,
//                  let vc = nvc.viewControllers[0] as? AddStudyViewController else { return }
//
//            vc.isEditStudy = true
//            vc.viewModel = StudyComposeViewModel(studyData: self.viewModel?.study.value)
////            vc.detailViewModel = self.viewModel
//
//            let navigationVC = UINavigationController(rootViewController: vc)
//            navigationVC.modalPresentationStyle = .fullScreen
//            self.present(navigationVC, animated: true)
//        }
//
//        let share = UIAlertAction(title: "공유 내용 보기", style: .default) { _ in
//            let storyboard = UIStoryboard(name: "ShareContentViewController", bundle: nil)
//            guard let nvc = storyboard.instantiateViewController(withIdentifier: "ShareContentNVC") as? UINavigationController,
//                  let vc = nvc.viewControllers[0] as? ShareContentViewController else { return }
//
//            vc.viewModel = ShareContentViewModel(study: self.viewModel?.study.value)
//
//            let navigationVC = UINavigationController(rootViewController: vc)
//            navigationVC.modalPresentationStyle = .fullScreen
//            self.present(navigationVC, animated: true)
//        }
//
//        let cancel = UIAlertAction(title: "취소", style: .cancel)
//
//        alert.addAction(edit)
//        alert.addAction(share)
//        alert.addAction(delete)
//        alert.addAction(cancel)
//
//        self.present(alert, animated: true)
//    }
//}
//
//extension DetailStudyViewController: UITableViewDataSource {
//
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 6
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        switch section {
//        case 0,1,2,3,4:
//            return 1
//        case 5:
//            return 1 + (viewModel?.study.value?.members?.count ?? 0)
//        default:
//            return 0
//        }
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        switch indexPath.section {
//        case 0:
//            guard let cell = tableView.dequeueReusableCell(withIdentifier: DetailTitleTableViewCell.identifier, for: indexPath) as? DetailTitleTableViewCell else { return UITableViewCell() }
//            cell.viewModel = viewModel
//            cell.configData()
//
//            return cell
//        case 1:
//            guard let cell = tableView.dequeueReusableCell(withIdentifier: DetailAnnouncementTableViewCell.identifier, for: indexPath) as? DetailAnnouncementTableViewCell else { return UITableViewCell() }
//            cell.viewModel = viewModel
//            cell.configData()
//
//            return cell
//        case 2:
//            guard let cell = tableView.dequeueReusableCell(withIdentifier: DetailCommonSetInfoTableViewCell.identifier, for: indexPath) as? DetailCommonSetInfoTableViewCell else { return UITableViewCell() }
//            cell.viewModel = viewModel
//            cell.configLayout(indexPath: indexPath)
//            cell.configData(index: indexPath)
//
//            return cell
//        case 3:
//            guard let cell = tableView.dequeueReusableCell(withIdentifier: DetailCommonSetInfoTableViewCell.identifier, for: indexPath) as? DetailCommonSetInfoTableViewCell else { return UITableViewCell() }
//            cell.viewModel = viewModel
//            cell.configLayout(indexPath: indexPath)
//            cell.configData(index: indexPath)
//
//            return cell
//        case 4:
//            guard let cell = tableView.dequeueReusableCell(withIdentifier: DetailCommonSetInfoTableViewCell.identifier, for: indexPath) as? DetailCommonSetInfoTableViewCell else { return UITableViewCell() }
//            cell.viewModel = viewModel
//            cell.configLayout(indexPath: indexPath)
//            cell.configData(index: indexPath)
//
//            return cell
//        case 5:
//            switch indexPath.row {
//            case 0:
//                guard let cell = tableView.dequeueReusableCell(withIdentifier: DetailMemberTableViewCell.identifier, for: indexPath) as? DetailMemberTableViewCell else { return UITableViewCell() }
//                cell.studyViewModel = viewModel
//                cell.configData()
//                return cell
//            default:
//                guard let cell = tableView.dequeueReusableCell(withIdentifier: DetailMemberInfoTableViewCell.identifier, for: indexPath) as? DetailMemberInfoTableViewCell else { return UITableViewCell() }
//
//                cell.viewModel = viewModel
//                cell.delegate = self
//                cell.showPostButton.tag = indexPath.row
//
//                cell.configLayout(indexPath: indexPath)
//                cell.configData(indexPath: indexPath)
//
//                return cell
//            }
//        default:
//            return UITableViewCell()
//        }
//    }
//}
//
//extension DetailStudyViewController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 30
//    }
//
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        switch section {
//        case 4:
//            return 30
//        default:
//            return .leastNormalMagnitude
//        }
//    }
//}
//
//
//extension DetailStudyViewController: DetailMemberInfoTableViewCellDelegate {
//    func showBlogWebView(blogURL: String) {
//
//        guard let url = URL(string: blogURL) else {
//            makeAlertDialog(title: "URL을 확인해주세요!", message: "", vcType: .ok)
//            return
//        }
//
//        if ["http", "https"].contains(url.scheme?.lowercased() ?? "") {
//            let safariVC = SFSafariViewController(url: url)
//            self.present(safariVC, animated: true)
//        } else {
//            makeAlertDialog(title: "URL을 확인해주세요!", message: "", vcType: .ok)
//        }
//    }
//}
//
