//
//  AddContentViewController.swift
//  BlogApp
//
//  Created by PKW on 2023/07/14.
//

import UIKit

/// 마감 정보를 업데이트하고 새로운 마감 정보를 추가하기위한 화면을 표시하는 뷰 컨트롤러 입니다.
class AddContentViewController: UIViewController, ViewModelBindableType {
    
    // MARK:  ===== [@IBOutlet] =====
    
    // 현재 마감할 회차를 표시할 레이블
    @IBOutlet weak var contentNumberLabel: UILabel!
    
    // 마감 요일을 표시할 바탕 뷰
    @IBOutlet weak var deadlineDayBaseView: UIView!
    
    // 마감 요일을 표시할 레이블
    @IBOutlet weak var deadlineDayLabel: UILabel!
    
    // 마감 기간을 표시할 바탕 뷰
    @IBOutlet weak var durationBaseView: UIView!
    
    // 시작 날짜를 표시할 레이블
    @IBOutlet weak var startDateLabel: UILabel!
    
    // 시작 날짜 선택 버튼
    @IBOutlet weak var editStartDateButton: UIButton!
    
    // 마감 날짜를 표시할 레이블
    @IBOutlet weak var deadlineDateLabel: UILabel!
    
    // 마감 날짜 선택 버튼
    @IBOutlet weak var editDeadlineDateButton: UIButton!
    
    // 벌금을 표시하기 위한 바탕 뷰
    @IBOutlet weak var fineBaseView: UIView!
    
    // 벌금을 표시할 레이블
    @IBOutlet weak var fineLabel: UILabel!
    
    // 벌금 선택 버튼
    @IBOutlet weak var editFineButton: UIButton!
    
    // 멤버 수를 표시할 레이블
    @IBOutlet weak var memberCountLabel: UILabel!
    
    // 멤버 추가 버튼
    @IBOutlet weak var addMemberButton: UIButton!
    
    // 멤버 정보 뷰를 표시하기위한 수직 스택 뷰
    @IBOutlet weak var memberInfoStackView: UIStackView!

    typealias ViewModelType = NewContentViewModel
    
    var viewModel: ViewModelType?
    
    // 저장 진행중인지 여부를 나타내는 변수(버튼 중복 이벤트 방지)
    var isProcessing: Bool = false
    
    
    
    // MARK: ===== [Override] =====
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        
        configLayout()
        configData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 로딩 인디케이터를 화면에 표시합니다.
        LoadingIndicator.showLoading(type: .fetchPost)
        
        // 네트워크 연결 상태를 확인합니다.
        if NetworkCheckManager.shared.isConnected {
            
            // 네트워크 연결이 되어 있으면 블로그 게시글을 가져옵니다.
            self.viewModel?.fetchBlogPosts {
                DispatchQueue.main.async {
                    // 멤버 정보 뷰를 추가하고 로딩 인디케이터를 화면에서 숨깁니다.
                    self.insertMemberViewsInStackView()
                    LoadingIndicator.hideLoading()
                }
            }
        } else {
            
            // 네트워크 연결이 되어 있지 않으면 경고창을 띄웁니다.
            DispatchQueue.main.async {
                self.makeAlertDialog(title: nil, message: "네트워크 연결을 확인해 주세요", type: .notConnected, connectedType: .fetchMember)
            }
        }
    }
    
    
    
    // MARK: ===== [@IBAction] =====
    
    /// 완료 버튼을 탭했을 때의 동작을 정의합니다.
    @IBAction func tapDoneButton(_ sender: Any) {
        
        // 저장중인지 확인합니다.
        if isProcessing {
            return
        }
        
        // 저장중 상태로 변경합니다.
        isProcessing = true
        
        // 시작 날짜가 선택되어 있지 않다면 경고창을 띄웁니다.
        if viewModel?.startDate.value == nil {
            makeAlertDialog(title: nil, message: "시작일을 선택해 주세요", type: .ok)
            isProcessing = false
        } else {
            
            // 로딩 인디케이터를 화면에 표시합니다.
            LoadingIndicator.showLoading(type: .saveContent)
            
            // 마감 정보를 코어데이터에 저장합니다.
            viewModel?.createContentData {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    
                    // 처리 완료 상태로 변경합니다.
                    self.isProcessing = false
                    self.dismiss(animated: true) {
                        // 로딩 인디케이터를 화면에서 숨깁니다.
                        LoadingIndicator.hideLoading()
                    }
                }
            }
        }
    }
    
    /// 시작 날짜 선택 버튼을 탭했을 때의 동작을 정의합니다.
    @IBAction func tapEditStartDateButton(_ sender: Any) {
        
        if viewModel?.startDate.value == nil {
            // 시작 날짜가 nil인 경우 날짜 선택 화면으로 이동합니다.(1화차 일때)
            let storyboard = UIStoryboard(name: "BottomSheetViewController", bundle: nil)
            guard let vc = storyboard.instantiateViewController(withIdentifier: "BottomSheetViewController") as? BottomSheetViewController else { return }
            
            // 옵션을 'contentStartDate'로 설정합니다.
            vc.option = .contentStartDate
            
            // 현재 뷰 모델을 'BottomSheetViewController'에 전달합니다.
            vc.newContentViewModel = viewModel
        
            vc.modalPresentationStyle = .overFullScreen
            
            self.present(vc, animated: false)
        } else {
            // 2화차 이상인 경우 경고창을 띄웁니다.
            makeAlertDialog(title: nil, message: "시작일은 변경할 수 없습니다", type: .ok)
        }
    }
    
    /// 마감 날짜 선택 버튼을 탭했을 때의 동작을 정의합니다.
    @IBAction func tapEditDeadlineDateButton(_ sender: Any) {
        
        
        if viewModel?.startDate.value == nil {
            // 시작 날짜가 선택되어있지 않으면 경고창을 띄웁니다.
            makeAlertDialog(title: nil, message: "시작일이 선택되지 않았습니다", type: .ok)
        } else {
            let storyboard = UIStoryboard(name: "BottomSheetViewController", bundle: nil)
            guard let vc = storyboard.instantiateViewController(withIdentifier: "BottomSheetViewController") as? BottomSheetViewController else { return }
            
            // 옵션을 'contentDeadlineDate'로 설정합니다.
            vc.option = .contentDeadlineDate
            
            // 현재 뷰 모델을 'BottomSheetViewController'에 전달합니다.
            vc.newContentViewModel = viewModel
            
            vc.modalPresentationStyle = .overFullScreen
            
            self.present(vc, animated: false)
        }
    }
    
    /// 벌금 선택 버튼을 탭했을 때의 동작을 정의합니다.
    @IBAction func tapEditFineButton(_ sender: Any) {
        
        // 벌금 선택 화면으로 이동합니다.
        let storyboard = UIStoryboard(name: "BottomSheetViewController", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "BottomSheetViewController") as? BottomSheetViewController else { return }
        
        // 옵션을 'contentFine'로 설정합니다.
        vc.option = .contentFine
        
        // 현재 뷰 모델을 'BottomSheetViewController'에 전달합니다.
        vc.newContentViewModel = viewModel
        
        vc.modalPresentationStyle = .overFullScreen
        
        self.present(vc, animated: false)
    }
    
    /// 멤버 추가 버튼을 탭했을 때의 동작을 정의합니다.
    @IBAction func tapAddMemberButton(_ sender: Any) {
        
        // 멤버 선택 화면으로 이동합니다.
        let storyboard = UIStoryboard(name: "BottomSheetViewController", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "BottomSheetViewController") as? BottomSheetViewController else { return }
        
        // 옵션을 'addContentMember'로 설정합니다.
        vc.option = .addContentMember
        
        // 현재 뷰 모델을 'BottomSheetViewController'에 전달합니다.
        vc.newContentViewModel = viewModel
        
        vc.modalPresentationStyle = .overFullScreen
        
        self.present(vc, animated: false)
    }
    
    /// 멤버 정보 수정 버튼을 탭했을 때의 동작을 정의합니다.
    @objc func tapEditMemberButton(_ sender: UIButton) {
        
        // 멤버 정보 화면으로 이동합니다.
        let storyboard = UIStoryboard(name: "BottomSheetViewController", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "BottomSheetViewController") as? BottomSheetViewController else { return }
        
        // 옵션을 'editContentMember'로 설정합니다.
        vc.option = .editContentMember
        
        // 터치한 버튼의 태그값을 설정합니다.
        vc.index = sender.tag
        
        // 현재 뷰 모델을 'BottomSheetViewController'에 전달합니다.
        vc.newContentViewModel = viewModel
        
        vc.modalPresentationStyle = .overFullScreen
        
        self.present(vc, animated: false)
    }
    
    
    
    // MARK: ===== [Function] =====
    
    /// ViewModel의 프로퍼티와 뷰 컨트롤러의 UI 컴포넌트를 연결합니다.
    ///
    /// ViewModel의 프로퍼티의 값이 변경될때 UI가 업데이트 됩니다.
    func bindViewModel() {
        viewModel?.studyMembers.bind({ [weak self] members in
            guard let self = self else { return }
            
            switch viewModel?.memberState {
                
            // 추가
            case .add:
                LoadingIndicator.showLoading(type: .fetchPost)
                
                if NetworkCheckManager.shared.isConnected {
                    viewModel?.fetchBlogPosts {
                        DispatchQueue.main.async {
                            self.removeMemberInfoViewsInStackView()
                            self.insertMemberViewsInStackView()
                            self.memberCountLabel.text = "현재 \(self.viewModel?.contentMembers.value.count ?? 0)명 참여중이에요"
                            LoadingIndicator.hideLoading()
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.makeAlertDialog(title: nil, message: "네트워크 연결을 확인해 주세요", type: .notConnected, connectedType: .addMember)
                    }
                }
            
            // 수정
            case .edit:
                LoadingIndicator.showLoading(type: .fetchPost)
                
                if NetworkCheckManager.shared.isConnected {
                    viewModel?.fetchBlogPosts {
                        DispatchQueue.main.async {
                            self.removeMemberInfoViewsInStackView()
                            self.insertMemberViewsInStackView()
                            LoadingIndicator.hideLoading()
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.makeAlertDialog(title: nil, message: "네트워크 연결을 확인해 주세요", type: .notConnected, connectedType: .editMember)
                    }
                }
            
            // 삭제
            case .delete:
                viewModel?.fetchContentMembers()
                removeMemberInfoViewsInStackView()
                insertMemberViewsInStackView()
    
                memberCountLabel.text = "현재 \(viewModel?.contentMembers.value.count ?? 0)명 참여중이에요"
            default:
                print("")
            }
        })
        
        viewModel?.startDate.bind({ [weak self] startDate in

            guard let self = self else { return }
            startDateLabel.text = "시작일 : \(startDate?.toString() ?? "")"
            
            LoadingIndicator.showLoading(type: .fetchPost)
            
            if NetworkCheckManager.shared.isConnected {
                viewModel?.fetchBlogPosts {
                    DispatchQueue.main.async {
                        self.removeMemberInfoViewsInStackView()
                        self.insertMemberViewsInStackView()
                        LoadingIndicator.hideLoading()
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.makeAlertDialog(title: nil, message: "네트워크 연결을 확인해 주세요", type: .notConnected, connectedType: .startDate)
                }
            }
        })
        
        
        viewModel?.deadlineDate.bind({ [weak self] deadlineDate in
            print("3")
            guard let self = self else { return }
        
            deadlineDateLabel.text = "마감일 : \(deadlineDate?.toString() ?? "")"
           
            LoadingIndicator.showLoading(type: .fetchPost)
            
            if NetworkCheckManager.shared.isConnected {
                viewModel?.fetchBlogPosts {
                    DispatchQueue.main.async {
                        self.removeMemberInfoViewsInStackView()
                        self.insertMemberViewsInStackView()
                        LoadingIndicator.hideLoading()
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.makeAlertDialog(title: nil, message: "네트워크 연결을 확인해 주세요", type: .notConnected, connectedType: .deadlineDate)
                }
            }
        })
        
        viewModel?.deadlineDay.bind({ [weak self] deadlineDay in
            print("4")
            guard let self = self else { return }
            
            deadlineDayLabel.text = "\(deadlineDay?.convertWeekDayToString() ?? "")로 마감 됩니다"
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
    
    /// 레이아웃을 설정합니다.
    func configLayout() {
        deadlineDayBaseView.layer.cornerRadius = .cornerRadius
        durationBaseView.layer.cornerRadius = .cornerRadius
        fineBaseView.layer.cornerRadius = .cornerRadius
        
        editStartDateButton.layer.cornerRadius = .cornerRadius
        editDeadlineDateButton.layer.cornerRadius = .cornerRadius
        editFineButton.layer.cornerRadius = .cornerRadius
        
        addMemberButton.layer.cornerRadius = .cornerRadius
    }
    
    /// 마감 정보의 데이터를 설정합니다.
    func configData() {
        contentNumberLabel.text = "현재 마감할 회차는 \(viewModel?.lastContent.value?.contentNumber ?? 0)회에요!"
        deadlineDayLabel.text = "\(viewModel?.deadlineDate.value?.getDayOfCurrentDate().convertDeadlineDayToString().components(separatedBy: " ")[1] ?? "")로 마감 됩니다"
        
        startDateLabel.text = viewModel?.startDate.value == nil ? "시작일을 선택해 주세요." : "시작일 : \(viewModel?.startDate.value?.makeStartDate()?.toString() ?? "")"
        deadlineDateLabel.text = "마감일 : \(viewModel?.deadlineDate.value?.toString() ?? "")"
        
        fineLabel.text = "\(viewModel?.fine.value?.insertComma() ?? "")원"
        memberCountLabel.text = "현재 \(viewModel?.studyMembers.value.count ?? 0)명 참여중이에요"
    }
    
    /// 스택뷰에 멤버 정보 뷰들을 추가합니다.
    func insertMemberViewsInStackView() {
        
        // 뷰모델의 contentMembers 값들을 순회하며 처리합니다.
        for i in 0 ..< (viewModel?.contentMembers.value.count ?? 0) {
            let target = viewModel?.contentMembers.value[i]
            
            // 멤버 정보를 표시하기 위한 뷰를 생성합니다.
            let memberInfoView = EditMemberInfoView()
            
            // 레이블에 멤버 정보를 설정합니다.
            memberInfoView.nameLabel.text = target?.name ?? ""
            memberInfoView.blogTitleLabel.text = "게시물 제목"
            memberInfoView.blogSubTitle.text = target?.title ?? ""
            
            if target?.postUrl == nil {
                // 작성된 블로그 게시물이 없는 경우 보증금을 벌금만큼 차감 후 설정합니다.
                memberInfoView.fineSubTitle.text = "\(Int(target?.fine ?? 0).insertComma()) \(viewModel?.totalFine == 0 ? "(-0원)" : "(-\(Int(viewModel?.fine.value ?? 0).insertComma()))원")"
            } else {
                // 작성된 블로그 게시물이 있는 경우 보증금을 증액 후 설정합니다.
                memberInfoView.fineSubTitle.text = "\(Int(target?.fine ?? 0).insertComma()) (+\(Int(viewModel?.plusFine ?? 0).insertComma())원)"
            }
            
            // 멤버 정보 수정 버튼에 액션을 연결합니다.
            memberInfoView.editButton.addTarget(self, action: #selector(tapEditMemberButton(_:)), for: .touchUpInside)
            
            // 버튼 태그를 설정합니다.
            memberInfoView.editButton.tag = i
            
            // 스택뷰에 멤버 정보 뷰를 추가합니다.
            memberInfoStackView.addArrangedSubview(memberInfoView)
        }
    }
    
    /// 스택 뷰에서 모든 멤버 정보 뷰를 제거합니다.
    func removeMemberInfoViewsInStackView() {
        
        // 스택 뷰의 모든 서브뷰를 순회합니다.
        memberInfoStackView.arrangedSubviews.forEach { view in
            
            // 서브뷰가 `EditMemberInfoView` 타입인 경우
            if let memberInfoView = view as? EditMemberInfoView {
                
                // 해당 서브뷰를 스택 뷰에서 제거합니다.
                memberInfoStackView.removeArrangedSubview(memberInfoView)
                
                // 서브뷰를 뷰 계층에서 완전히 제거합니다.
                memberInfoView.removeFromSuperview()
            }
        }
    }
}
