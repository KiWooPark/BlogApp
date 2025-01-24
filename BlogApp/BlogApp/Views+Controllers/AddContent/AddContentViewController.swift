//
//  AddContentViewController.swift
//  BlogApp
//
//  Created by PKW on 2023/07/14.
//

import UIKit

class AddContentViewController: UIViewController, ViewModelBindableType {
    
    typealias ViewModelType = NewContentViewModel
    
    @IBOutlet weak var contentNumberLabel: UILabel!
    
    @IBOutlet weak var deadlineDayBaseView: UIView!
    @IBOutlet weak var deadlineDayLabel: UILabel!
    
    @IBOutlet weak var durationBaseView: UIView!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var editStartDateButton: UIButton!
    @IBOutlet weak var deadlineDateLabel: UILabel!
    @IBOutlet weak var editDeadlineDateButton: UIButton!
    
    @IBOutlet weak var fineBaseView: UIView!
    @IBOutlet weak var fineLabel: UILabel!
    @IBOutlet weak var editFineButton: UIButton!
    
    @IBOutlet weak var memberCountLabel: UILabel!
    @IBOutlet weak var addMemberButton: UIButton!
    
    @IBOutlet weak var memberInfoStackView: UIStackView!

    var viewModel: ViewModelType?
    
    var isProcessing: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        
        configLayout()
        configData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        LoadingIndicator.showLoading(type: .fetchPost)
        
        if NetworkCheck.shared.isConnected {
            self.viewModel?.fetchBlogPosts {
                DispatchQueue.main.async {
                    self.insertMemberViewsInStackView()
                    LoadingIndicator.hideLoading()
                }
            }
        } else {
            DispatchQueue.main.async {
                self.makeAlertDialog(title: nil, message: "네트워크 연결을 확인해 주세요.", type: .notConnected, connectedType: .fetchMember)
            }
        }
    }
    
    func bindViewModel() {
        viewModel?.studyMembers.bind({ [weak self] members in
            guard let self = self else { return }
            
            switch viewModel?.memberState {
            case .add:
                LoadingIndicator.showLoading(type: .fetchPost)
                
                if NetworkCheck.shared.isConnected {
                    viewModel?.fetchBlogPosts {
                        DispatchQueue.main.async {
                            self.removeMemberInfoViewsInStackView()
                            self.insertMemberViewsInStackView()
                            self.memberCountLabel.text = "현재 \(self.viewModel?.contentMembers.value.count ?? 0)명 참여중이에요."
                            LoadingIndicator.hideLoading()
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.makeAlertDialog(title: nil, message: "네트워크 연결을 확인해 주세요.", type: .notConnected, connectedType: .addMember)
                    }
                }
            case .edit:
                LoadingIndicator.showLoading(type: .fetchPost)
                
                if NetworkCheck.shared.isConnected {
                    viewModel?.fetchBlogPosts {
                        DispatchQueue.main.async {
                            self.removeMemberInfoViewsInStackView()
                            self.insertMemberViewsInStackView()
                            LoadingIndicator.hideLoading()
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.makeAlertDialog(title: nil, message: "네트워크 연결을 확인해 주세요.", type: .notConnected, connectedType: .editMember)
                    }
                }
                
            case .delete:
                viewModel?.fetchContentMembers()
                removeMemberInfoViewsInStackView()
                insertMemberViewsInStackView()
    
                memberCountLabel.text = "현재 \(viewModel?.contentMembers.value.count ?? 0)명 참여중이에요."
            default:
                print("")
            }
        })
        
        viewModel?.startDate.bind({ [weak self] startDate in

            guard let self = self else { return }
            startDateLabel.text = "시작일 : \(startDate?.toString() ?? "")"
            
            LoadingIndicator.showLoading(type: .fetchPost)
            
            if NetworkCheck.shared.isConnected {
                viewModel?.fetchBlogPosts {
                    DispatchQueue.main.async {
                        self.removeMemberInfoViewsInStackView()
                        self.insertMemberViewsInStackView()
                        LoadingIndicator.hideLoading()
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.makeAlertDialog(title: nil, message: "네트워크 연결을 확인해 주세요.", type: .notConnected, connectedType: .startDate)
                }
            }
        })
        
        
        viewModel?.deadlineDate.bind({ [weak self] deadlineDate in
            print("3")
            guard let self = self else { return }
        
            deadlineDateLabel.text = "마감일 : \(deadlineDate?.toString() ?? "")"
           
            LoadingIndicator.showLoading(type: .fetchPost)
            
            if NetworkCheck.shared.isConnected {
                viewModel?.fetchBlogPosts {
                    DispatchQueue.main.async {
                        self.removeMemberInfoViewsInStackView()
                        self.insertMemberViewsInStackView()
                        LoadingIndicator.hideLoading()
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.makeAlertDialog(title: nil, message: "네트워크 연결을 확인해 주세요.", type: .notConnected, connectedType: .deadlineDate)
                }
            }
        })
        
        viewModel?.deadlineDay.bind({ [weak self] deadlineDay in
            print("4")
            guard let self = self else { return }
            
            deadlineDayLabel.text = "\(deadlineDay?.convertWeekDayToString() ?? "")로 마감 됩니다."
        })
        
        viewModel?.fine.bind({ [weak self] fine in
            print("5")
            guard let self = self else { return }
            
            fineLabel.text = "\(Int(fine ?? 0).insertComma())원"
            
            viewModel?.fetchContentMembers()
            self.removeMemberInfoViewsInStackView()
            self.insertMemberViewsInStackView()
        })
    }
    
    func configLayout() {
        deadlineDayBaseView.layer.cornerRadius = .cornerRadius
        durationBaseView.layer.cornerRadius = .cornerRadius
        fineBaseView.layer.cornerRadius = .cornerRadius
        
        editStartDateButton.layer.cornerRadius = .cornerRadius
        editDeadlineDateButton.layer.cornerRadius = .cornerRadius
        editFineButton.layer.cornerRadius = .cornerRadius
        
        addMemberButton.layer.cornerRadius = .cornerRadius
    }
    
    func configData() {
        contentNumberLabel.text = "현재 마감할 회차는 \(viewModel?.lastContent.value?.contentNumber ?? 0)회에요!"
        deadlineDayLabel.text = "\(viewModel?.deadlineDate.value?.getDayOfCurrentDate().convertDeadlineDayToString().components(separatedBy: " ")[1] ?? "")로 마감 됩니다."
        
        startDateLabel.text = viewModel?.startDate.value == nil ? "시작일을 선택해 주세요." : "시작일 : \(viewModel?.startDate.value?.makeStartDate()?.toString() ?? "")"
        deadlineDateLabel.text = "마감일 : \(viewModel?.deadlineDate.value?.toString() ?? "")"
        
        fineLabel.text = "\(viewModel?.fine.value?.insertComma() ?? "")원"
        memberCountLabel.text = "현재 \(viewModel?.studyMembers.value.count ?? 0)명 참여중이에요."
    }

    func insertMemberViewsInStackView() {
        for i in 0 ..< (viewModel?.contentMembers.value.count ?? 0) {
            let target = viewModel?.contentMembers.value[i]
            
            let memberInfoView = EditMemberInfoView()
            
            memberInfoView.nameLabel.text = target?.name ?? ""
            memberInfoView.blogTitleLabel.text = "게시물 제목"
            memberInfoView.blogSubTitle.text = target?.title ?? ""
            
            if target?.postUrl == nil {
                memberInfoView.fineSubTitle.text = "\(Int(target?.fine ?? 0).insertComma()) \(viewModel?.totalFine == 0 ? "(-0원)" : "(-\(Int(viewModel?.fine.value ?? 0).insertComma()))원")"
            } else {
                memberInfoView.fineSubTitle.text = "\(Int(target?.fine ?? 0).insertComma()) (+\(Int(viewModel?.plusFine ?? 0).insertComma())원)"
            }
            
            memberInfoView.editButton.addTarget(self, action: #selector(tapEditMemberButton(_:)), for: .touchUpInside)
            memberInfoView.editButton.tag = i
            memberInfoStackView.addArrangedSubview(memberInfoView)
        }
    }
    
    func removeMemberInfoViewsInStackView() {
        memberInfoStackView.arrangedSubviews.forEach { view in
            if let memberInfoView = view as? EditMemberInfoView {
                memberInfoStackView.removeArrangedSubview(memberInfoView)
                memberInfoView.removeFromSuperview()
            }
        }
    }
   
    @IBAction func tapDoneButton(_ sender: Any) {
        
        if isProcessing {
            return
        }
        
        isProcessing = true
        
        if viewModel?.startDate.value == nil {
            makeAlertDialog(title: nil, message: "시작일을 선택해 주세요.", type: .ok)
            isProcessing = false
        } else {
            LoadingIndicator.showLoading(type: .saveContent)
            
            viewModel?.createContentData {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.isProcessing = false
                    self.dismiss(animated: true) {
                        LoadingIndicator.hideLoading()
                    }
                }
            }
        }
    }
    
    @IBAction func tapEditStartDateButton(_ sender: Any) {
        
        if viewModel?.startDate.value == nil {
            let storyboard = UIStoryboard(name: "BottomSheetViewController", bundle: nil)
            guard let vc = storyboard.instantiateViewController(withIdentifier: "BottomSheetViewController") as? BottomSheetViewController else { return }
            
            vc.option = .contentStartDate
            vc.newContentViewModel = viewModel
        
            vc.modalPresentationStyle = .overFullScreen
            
            self.present(vc, animated: false)
        } else {
            makeAlertDialog(title: nil, message: "시작일은 변경할 수 없습니다.", type: .ok)
        }
        
       
    }
    
    @IBAction func tapEditDeadlineDateButton(_ sender: Any) {
        
        if viewModel?.startDate.value == nil {
            makeAlertDialog(title: nil, message: "시작일이 선택되지 않았습니다.", type: .ok)
        } else {
            let storyboard = UIStoryboard(name: "BottomSheetViewController", bundle: nil)
            guard let vc = storyboard.instantiateViewController(withIdentifier: "BottomSheetViewController") as? BottomSheetViewController else { return }
            
            vc.option = .contentDeadlineDate
            vc.newContentViewModel = viewModel
            
            vc.modalPresentationStyle = .overFullScreen
            
            self.present(vc, animated: false)
        }
    }
    
    @IBAction func tapEditFineButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "BottomSheetViewController", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "BottomSheetViewController") as? BottomSheetViewController else { return }
        
        vc.option = .contentFine
        vc.newContentViewModel = viewModel
        
        vc.modalPresentationStyle = .overFullScreen
        
        self.present(vc, animated: false)
    }
    
    @IBAction func tapAddMemberButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "BottomSheetViewController", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "BottomSheetViewController") as? BottomSheetViewController else { return }
        
        vc.option = .addContentMember
        vc.newContentViewModel = viewModel
        
        vc.modalPresentationStyle = .overFullScreen
        
        self.present(vc, animated: false)
    }
    
    
    
    @objc func tapEditMemberButton(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "BottomSheetViewController", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "BottomSheetViewController") as? BottomSheetViewController else { return }
        
        vc.option = .editContentMember
        vc.index = sender.tag
        vc.newContentViewModel = viewModel
        
        vc.modalPresentationStyle = .overFullScreen
        
        self.present(vc, animated: false)
    }
}





//
//    func bindViewModel() {
//        viewModel?.studyMembers.bind({ [weak self] members in
//            guard let self = self else { return }
//            guard let index = viewModel?.index else { return }
//
//            switch viewModel?.contentMemberState {
//            case .add:
//                insertMemberViewInStackView()
//            case .update:
//                if let memberInfoView = memberInfoStackView.arrangedSubviews[index + 1] as? MemberInfoView {
//                    memberInfoView.nameLabel.text = members[index].name
//                    memberInfoView.fineLabel.text = "\(members[index].fine)"
//                    memberInfoView.blogPostTitleLabel.text = members[index].blogUrl
//                }
//            case .delete:
//                memberInfoStackView.arrangedSubviews[index + 1].removeFromSuperview()
//                updateEditButtonTag()
//            default:
//                print("")
//            }
//
//            viewModel?.checkBlogPost()
//        })
//
//        viewModel?.startDate.bind({ [weak self] startDate in
//            guard let self = self else { return }
//            startDateLabel.text = "시작일 : \(startDate?.toString(type: .startDate) ?? "")"
//            viewModel?.checkBlogPost()
//        })
//
//
//        viewModel?.deadlineDate.bind({ [weak self] deadlineDate in
//            guard let self = self else { return }
//
//            deadlineDayLabel.text = "마감 요일은 \(deadlineDate?.getDayOfCurrentDate().convertWeekDayToString() ?? "") 입니다."
//            deadlineDateLabel.text = "마감일 : \(deadlineDate?.toString(type: .deadlineDate) ?? "")"
//            viewModel?.checkBlogPost()
//        })
//
//        viewModel?.fine.bind({ [weak self] fine in
//            guard let self = self else { return }
//            fineLabel.text = "\(Int(fine ?? 0).convertFineStr())"
//            updateMemberInfoViews()
//        })
//
//        viewModel?.postsData.bind({ [weak self] _ in
//            guard let self = self else { return }
//            updateMemberInfoViews()
//        })
//    }
//
//    func fetchNewContentData() {
//        if let studyEntity = viewModel?.study {
//            let contents = viewModel?.contents//CoreDataManager.shared.fetchContentList(studyEntity: studyEntity)
//
//            contentNumberLabel.text = "현재 마감 할 회차는 \(contents?.last?.contentNumber ?? 0)회차 입니다."
//
//            deadlineDayLabel.text = "마감 요일은 \(Int(studyEntity.finishDay).convertDeadlineDayToString().components(separatedBy: " ")[1]) 입니다."
//
//            if contents?.count == 1 {
//                let startDate = contents?.last?.deadlineDate?.getStartDateAndDeadlineDate().startDate
//                startDateLabel.text = "시작일 : \(startDate?.toString(type: .startDate) ?? "")"
//                deadlineDateLabel.text = "마감일 : \(contents?.last?.deadlineDate?.toString(type: .deadlineDate) ?? "")"
//            } else {
//                let startDate = (contents?[(contents?.count ?? 0) - 2].deadlineDate ?? Date()).addOneSecondToStartDate()
//                startDateLabel.text = "시작일 : \(startDate?.toString(type: .startDate) ?? "")"
//                deadlineDateLabel.text = "마감일 : \(contents?.last?.deadlineDate?.toString(type: .deadlineDate) ?? "")"
//            }
//
//            fineLabel.text = "\(Int(viewModel?.study?.fine ?? 0).convertFineStr())"
//        }
//
//        viewModel?.checkBlogPost()
//    }
//
//    @IBAction func tapEditStartDateButton(_ sender: Any) {
//        let storyboard = UIStoryboard(name: "BottomSheetViewController", bundle: nil)
//        guard let vc = storyboard.instantiateViewController(withIdentifier: "BottomSheetViewController") as? BottomSheetViewController else { return }
//        vc.option = .contentStartDate
//        vc.newContentViewModel = viewModel
//        vc.modalPresentationStyle = .overFullScreen
//
//        self.present(vc, animated: false)
//    }
//
//
//    @IBAction func tapEditDeadlineDateButton(_ sender: Any) {
//        let storyboard = UIStoryboard(name: "BottomSheetViewController", bundle: nil)
//        guard let vc = storyboard.instantiateViewController(withIdentifier: "BottomSheetViewController") as? BottomSheetViewController else { return }
//        vc.option = .contentDeadlineDate
//        vc.newContentViewModel = viewModel
//        vc.modalPresentationStyle = .overFullScreen
//
//        self.present(vc, animated: false)
//    }
//
//    @IBAction func tapFineButton(_ sender: Any) {
//        let storyboard = UIStoryboard(name: "BottomSheetViewController", bundle: nil)
//        guard let vc = storyboard.instantiateViewController(withIdentifier: "BottomSheetViewController") as? BottomSheetViewController else { return }
//        vc.option = .contentFine
//        vc.newContentViewModel = viewModel
//        vc.modalPresentationStyle = .overFullScreen
//
//        self.present(vc, animated: false)
//    }
//
//
//    @IBAction func tapDoneButton(_ sender: Any) {
//        viewModel?.createContent() {
//            self.dismiss(animated: true)
//        }
//    }
//
//
//    @IBAction func tapAddMemberButton(_ sender: Any) {
//        let storyboard = UIStoryboard(name: "BottomSheetViewController", bundle: nil)
//        guard let vc = storyboard.instantiateViewController(withIdentifier: "BottomSheetViewController") as? BottomSheetViewController else { return }
//
//        vc.option = .contentMember
//        vc.newContentViewModel = viewModel
//        vc.newContentViewModel?.contentMemberState = .add
//        vc.isEditStudy = false
//        vc.isEditMember = false
//        vc.isNewMember = true
//
//        vc.modalPresentationStyle = .overFullScreen
//
//        self.present(vc, animated: false)
//    }
//
//    func insertMemberViewsInStackView() {
//        for i in 0 ..< (viewModel?.studyMembers.value.count ?? 0) {
//            let view = MemberInfoView()
//            view.nameLabel.text = viewModel?.studyMembers.value[i].name ?? ""
//            view.fineLabel.text = "보증금 : \(viewModel?.studyMembers.value[i].fine ?? 0)"
//            view.blogPostTitleLabel.text = viewModel?.studyMembers.value[i].blogUrl ?? ""
//            view.editButton.addTarget(self, action: #selector(tapEditMemberButton(_:)), for: .touchUpInside)
//            view.editButton.tag = i
//            memberInfoStackView.addArrangedSubview(view)
//        }
//    }
//
//    func insertMemberViewInStackView() {
//        let view = MemberInfoView()
//        view.nameLabel.text = viewModel?.studyMembers.value.first?.name ?? ""
//        view.fineLabel.text = "보증금 : \(viewModel?.studyMembers.value.first?.fine ?? 0)"
//        view.blogPostTitleLabel.text = viewModel?.studyMembers.value.first?.blogUrl ?? ""
//        view.editButton.addTarget(self, action: #selector(tapEditMemberButton(_:)), for: .touchUpInside)
//        memberInfoStackView.insertArrangedSubview(view, at: 1)
//
//        updateEditButtonTag()
//    }
//
//    // 버튼 태그 업데이트해야함
//    func updateEditButtonTag() {
//        for i in 1 ..< memberInfoStackView.arrangedSubviews.count {
//            if let memberInfoView = memberInfoStackView.arrangedSubviews[i] as? MemberInfoView {
//                memberInfoView.editButton.tag = i - 1
//            }
//        }
//    }
//
//    func updateMemberInfoViews() {
//
//        if let postsData = viewModel?.postsData.value {
//
//            // 벌금 계산
//            viewModel?.calculateFine()
//
//            for post in postsData {
//                if let index = viewModel?.studyMembers.value.firstIndex(where: {$0.name == post.name}),
//                   let infoView = memberInfoStackView.arrangedSubviews[index + 1] as? MemberInfoView {
//
//                    if post.data == nil {
//                        infoView.blogPostTitleLabel.text = post.errorMessage ?? ""
//
//                        infoView.fineLabel.text = "보증금 : \(viewModel?.studyMembers.value[index].fine ?? 0) - \(viewModel?.plusFine == 0 ? 0 : viewModel?.fine.value?.convertFineInt() ?? 0)"
//                    } else {
//                        infoView.blogPostTitleLabel.text = post.data?.title ?? ""
//                        infoView.fineLabel.text = "보증금 : \(viewModel?.studyMembers.value[index].fine ?? 0) + \(viewModel?.plusFine ?? 0)"
//                    }
//                }
//            }
//        }
//    }
//
//    @objc func tapEditMemberButton(_ sender: UIButton) {
//        let storyboard = UIStoryboard(name: "BottomSheetViewController", bundle: nil)
//        guard let vc = storyboard.instantiateViewController(withIdentifier: "BottomSheetViewController") as? BottomSheetViewController else { return }
//
//        vc.option = .contentMember
//        vc.newContentViewModel = viewModel
//        vc.newContentViewModel?.contentMemberState = .update
//
//        vc.isEditStudy = false
//        vc.isEditMember = true
//        vc.isNewMember = false
//
//        vc.editIndex = sender.tag
//
//        vc.modalPresentationStyle = .overFullScreen
//
//        self.present(vc, animated: false)
//    }

