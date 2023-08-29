//
//  DetailStudyViewController.swift
//  BlogApp
//
//  Created by PKW on 2023/05/08.
//

import UIKit
import SafariServices

class DetailStudyViewController: UIViewController, ViewModelBindableType {
    
    // MARK:  ===== [@IBOutlet] =====
    
    // 신규 / 기존 스터디를 표시할 레이블
    @IBOutlet weak var studySubTitleLabel: UILabel!

    // 스터디 정보를 표시할 바탕 뷰
    @IBOutlet weak var studyInfoView: UIView!
    
    // 스터디 이름을 표시할 뷰
    @IBOutlet weak var studyNameLabel: UILabel!
    
    // 최초 시작 날짜를 표시할 뷰
    @IBOutlet weak var firstStudyDateLabel: UILabel!
    
    // 마감 요일을 표시할 레이블
    @IBOutlet weak var deadlineDayLabel: UILabel!
    
    // 벌금을 표시할 레이블
    @IBOutlet weak var fineLabel: UILabel!
    
    // 진행 상황을 표시할 바탕 뷰
    @IBOutlet weak var durationInfoView: UIView!
    
    // 스터디 진행 회차를 표시할 레이블
    @IBOutlet weak var studyCountLabel: UILabel!
    
    // 디데이를 표시할 레이블
    @IBOutlet weak var dDayLabel: UILabel!
    
    // 진행 기간을 시작일을 표시할 레이블
    @IBOutlet weak var durationSubTitleLabel: UILabel!
    
    // 진행 기간을 표시할 레이블
    @IBOutlet weak var durationLabel: UILabel!
    
    // 참여자 수를 표시할 레이블
    @IBOutlet weak var memberCountLabel: UILabel!
    
    // 멤버 정보를 표시하기위한 수직 스택 뷰
    @IBOutlet weak var memberInfoStackView: UIStackView!
    
    typealias ViewModelType = StudyDetailViewModel
    
    var viewModel: ViewModelType?
    
    
    
    // MARK: ===== [Override] =====
    
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

        // 멤버 정보를 가져옵니다.
        viewModel?.fetchStudyData()
        
        configLayout()
        configData()
        
        // 멤버 정보를 표시할 뷰들을 스택뷰에 추가합니다.
        insertMemberInfoViewsInStackView()
        
        // 현재 스터디의 마감 날짜가 지났으면
        if viewModel?.isDeadlinePassed() == true {
            // 마감 처리 경고창을 띄웁니다.
            makeAlertDialog(title: "마감 날짜가 지났습니다.\n\(viewModel?.lastContent?.contentNumber ?? 0)회차 마감을 진행해 주세요", message: nil, type: .addContent)
        }
    }
    
    
    // MARK:  ===== [Function] =====
    
    func bindViewModel() { }
    
    /// 레이아웃을 설정합니다.
    func configLayout() {
        studyInfoView.layer.cornerRadius = .cornerRadius
        durationInfoView.layer.cornerRadius = .cornerRadius
    }
    
    /// 스터디 정보를 설정합니다.
    func configData() {
        
        guard let target = viewModel?.study.value else { return }
        
        // 신규 스터디 등록 상태인 경우
        if target.isNewStudy == true {
            studySubTitleLabel.text = "신규로 등록된 스터디에요"
            studyNameLabel.text = target.title ?? ""
            firstStudyDateLabel.text = (target.firstStartDate ?? Date()).toString()
            deadlineDayLabel.text = "\(Int(target.deadlineDay).convertDeadlineDayToString())"
            fineLabel.text = "\(Int(target.fine).insertComma())원"
            
            studyCountLabel.text = "\(viewModel?.lastContent?.contentNumber ?? 0) 회차 진행중이에요"
            
            let dDay = viewModel?.calculateDday() ?? 0
            
            if dDay == 0 {
                dDayLabel.text = "마감일이 오늘이에요!"
            } else if dDay < 0 {
                dDayLabel.text = "마감일이 \(abs(dDay))일 지났어요!"
            } else {
                dDayLabel.text = "마감까지 \(dDay)일 남았어요!"
            }
        
            if viewModel?.contentList.count == 1 {
                durationSubTitleLabel.text = "이번 회차는 처음 진행되는 회차에요"
                durationLabel.text = "~ \(viewModel?.lastContent?.deadlineDate?.toString() ?? "")"
            } else {
                durationSubTitleLabel.text = "\((viewModel?.lastContent?.contentNumber ?? 0) - 1) 회차 마감일 이후부터 시작되요!"
                durationLabel.text = "\(viewModel?.lastContent?.startDate?.toString() ?? "") ~ \(viewModel?.lastContent?.deadlineDate?.toString() ?? "")"
            }

            // 참여자
            memberCountLabel.text = "현재 \(viewModel?.members.count ?? 0)명이 참여중이에요"
            
        } else {
            studySubTitleLabel.text = "기존에 진행으로 등록된 스터디에요"
            studyNameLabel.text = target.title ?? ""
            firstStudyDateLabel.text = (target.firstStartDate ?? Date()).toString()
            deadlineDayLabel.text = "\(Int(target.deadlineDay).convertDeadlineDayToString())"
            fineLabel.text = "\(Int(target.fine).insertComma())원"
            
            studyCountLabel.text = "\(viewModel?.lastContent?.contentNumber ?? 0) 회차 진행중이에요"
            
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
            
            studyCountLabel.text = "\(viewModel?.lastContent?.contentNumber ?? 0) 회차 진행중이에요"
            
            if viewModel?.lastContent?.contentNumber ?? 0 == 1 {
                durationSubTitleLabel.text = "이번 회차는 처음 진행되는 회차에요"
            } else {
                durationSubTitleLabel.text = "\((viewModel?.lastContent?.contentNumber ?? 0) - 1) 회차 마감일 이후부터 시작되요!"
            }
            
            
            durationLabel.text = "\(startDate.toString()) ~ \(deadlineDate.toString())"
            
            memberCountLabel.text = "현재 \(viewModel?.members.count ?? 0)명이 참여중이에요"
        }
    }
    
    /// 스택뷰에 멤버 정보 뷰를 추가합니다.
    func insertMemberInfoViewsInStackView() {
        
        // 뷰 모델의 멤버 데이터를 가져옵니다.
        guard let target = viewModel?.members else { return }

        // 스택뷰에 이미 멤버 뷰들이 있다면, 모두 제거합니다.
        if !memberInfoStackView.arrangedSubviews.isEmpty {
            memberInfoStackView.arrangedSubviews.forEach { view in
                if let memberInfoView = view as? StudyMemberInfoView {
                    memberInfoStackView.removeArrangedSubview(memberInfoView)
                }
            }
        }
        
        // 새로운 멤버 뷰를 생성하여 스택뷰에 추가합니다.
        for index in 0 ..< target.count {
            let memberInfoView = StudyMemberInfoView()
            memberInfoView.nameLabel.text = target[index].name ?? ""
            
            // 멤버의 보증금이 스터디의 보증금보다 적은 경우 알림 텍스트를 설정합니다.
            if target[index].fine < (viewModel?.study.value?.fine ?? 0) {
                memberInfoView.fineSubTitle.text = "보증금이 부족해요! (현재 \(Int(target[index].fine).insertComma())원)"
            } else {
                memberInfoView.fineSubTitle.text = "\(Int(target[index].fine).insertComma())원"
            }
            
            // 멤버의 '블로그 보러가기' 버튼 액션을 연결합니다.
            memberInfoView.showBlogButton.addTarget(self, action: #selector(showBlogWebView( _:)), for: .touchUpInside)
            
            // '블로그 보러가기' 버튼의 태그를 설정합니다.
            memberInfoView.showBlogButton.tag = index
           
            // 스택뷰에 멤버 정보 뷰를 추가합니다.
            memberInfoStackView.addArrangedSubview(memberInfoView)
        }
    }

    /// '블로그 보러가기' 버튼을 탭할 때 호출됩니다.
    @objc func showBlogWebView(_ sender: UIButton) {
       
        // 버튼의 태그를 이용하여 뷰 모델에서 해당 멤버의 블로그 URL을 가져옵니다.
        guard let url = URL(string: viewModel?.members[sender.tag].blogUrl ?? "") else { return }
        
        // Safari 뷰 컨트롤러를 이용해 해당 URL의 웹 페이지를 표시합니다.
        let safariVC = SFSafariViewController(url: url)
        self.present(safariVC, animated: true)
    }
    
    /// 메뉴 더 보기 버튼을 탭 할때 호출됩니다.
    @objc func tapMoreMenuButton(_ sender: Any) {
        
        // 액션 시트 스타일로 더 보기 메뉴를 표시합니다.
        makeAlertDialog(title: nil, message: nil, type: .deatileVC, style: .actionSheet)
    }
}
