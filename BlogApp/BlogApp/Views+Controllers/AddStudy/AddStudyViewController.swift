//
//  AddStudyViewController.swift
//  BlogApp
//
//  Created by PKW on 2023/05/01.
//

import UIKit
import CoreData
import SafariServices

/// 새로운 스터디를 추가하기위한 화면을 표시하는 뷰 컨트롤러 입니다.
class AddStudyViewController: UIViewController, ViewModelBindableType {
    
    // MARK:  ===== [@IBOutlet] =====
    
    // 기본 바탕이 되는 스크롤 뷰
    @IBOutlet weak var addStudyScrollView: UIScrollView!
    
    // 메인 타이틀1 레이블
    @IBOutlet weak var addStudyMainTitleLabel1: UILabel!
    
    // 메인 타이틀2 레이블
    @IBOutlet weak var addStudyMainTitleLabel2: UILabel!
    
    
    // 기존에 진행중인 스터디 정보를 표시하기위한 뷰의 바탕 뷰
    @IBOutlet weak var progressInfoBaseView: UIView!
    
    // 신규 및 기존 버튼 선택에 따라 설정 내용을 표시할 레이블
    @IBOutlet weak var progressSubTitleLabel: UILabel!
    
    // 신규 및 기존 버튼이 포함될 스택 뷰
    @IBOutlet weak var progressButtonStackView: UIStackView!
    
    // 신규 버튼
    @IBOutlet weak var newStudyButton: UIButton!
    
    // 기존 버튼
    @IBOutlet weak var progressStudyButton: UIButton!
    
    // 마지막 마감 회차 정보를 표시할 스택 뷰
    @IBOutlet weak var lastProgressNumberStackView: UIStackView!
    
    // 마지막 마감 회차를 입력받기위한 텍스트 필드
    @IBOutlet weak var lastProgressNumberTextField: UITextField!
    
    // 마지막 마감 회차의 마감 날짜 정보를 표시하기위한 바탕 뷰
    @IBOutlet weak var lastProgressDeadlineDateBaseView: UIView!
    
    // 선택한 마감 날짜를 표시할 레이블
    @IBOutlet weak var lastProgressDeadlineDateLabel: UILabel!
    
    // 마감 날짜를 선택하기위한 버튼
    @IBOutlet weak var lastProgressDeadlineDateEditButton: UIButton!
    
    
    // 이름을 표시하기 위한 바탕 뷰
    @IBOutlet weak var nameInfoBaseView: UIView!
    
    // 이름을 입력받기 위한 텍스트 필드
    @IBOutlet weak var nameTextField: UITextField!
    
    
    // 최초 시작 날짜를 표시하기위한 바탕 뷰
    @IBOutlet weak var firstStartDateInfoBaseView: UIView!
    
    // "최초 시작 날짜"를 표시하기위한 레이블
    @IBOutlet weak var firstStartDateTitleLabel: UILabel!
    
    // 선택한 최초 시작 날짜를 표시하기위한 레이블
    @IBOutlet weak var firstStartDateLabel: UILabel!
    
    // 최초 시작 날짜를 선택하기위한 버튼
    @IBOutlet weak var firstStartDateEditButton: UIButton!
    
    // 마감 요일을 표시하기 위한 바탕 뷰
    @IBOutlet weak var deadlineInfoBaseView: UIView!
    
    // "마감 요일"을 표시하기 위한 레이블
    @IBOutlet weak var deadlineDayLabel: UILabel!
    
    // 선택한 마감날짜를 표시하기위한 서브 레이블
    @IBOutlet weak var deadlineDaySubLabel: UILabel!
    
    // 마감 날짜를 선택하기위한 버튼
    @IBOutlet weak var deadlineEditButton: UIButton!
    
    
    // 벌금을 표시할 바탕 뷰
    @IBOutlet weak var fineInfoBaseView: UIView!
    
    // 벌금을 표시할 레이블
    @IBOutlet weak var fineLabel: UILabel!
    
    // 벌금을 선택하기위한 버튼
    @IBOutlet weak var fineEditButton: UIButton!
    
    // 멤버 카운트를 표시할 레이블
    @IBOutlet weak var memberCountLabel: UILabel!
    
    // 새로운 멤버를 추가하기위한 버튼
    @IBOutlet weak var addMemberButton: UIButton!
    
    // 멤버 정보 뷰를 표시하기위한 수직 스택 뷰
    @IBOutlet weak var editMemberInfoStackView: UIStackView!
    
    typealias ViewModelType = StudyComposeViewModel

    var viewModel: ViewModelType?
    
    // 키보드가 화면에 나타나있는지 여부를 나타내는 변수
    var isKeyboardActive: Bool = false
    
    
    
    // MARK: ===== [Override] =====
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 네비게이션바 그림자 제거
        self.navigationController?.navigationBar.standardAppearance.shadowColor = .clear
        
        // 스크롤시 키보드 숨김
        addStudyScrollView.keyboardDismissMode = .onDrag
        
        // 화면 터치시 키보드 숨김
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false // 스크롤뷰의 다른 동작에 방해되지 않게 설정
        addStudyScrollView.addGestureRecognizer(tap) // 탭 추가
        
        bindViewModel()
        configLayout()
        configData()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    
    // MARK: ===== [@IBAction] =====
    
    /// 닫기 버튼을 탭했을 때의 동작을 정의합니다.
    @IBAction func tapCloseButton(_ sender: Any) {
        
        // 스터디 수정 상태인 경우
        if viewModel?.isEditStudy == true {
            // 스터디 정보 변경을 취소할 것인지에 대한 경고창을 띄웁니다.
            makeAlertDialog(title: nil, message: "스터디 정보 변경을 취소하시겠습니까?", type: .closeComposeVC)
        } else {
            // 스터디 등록을 취소할 것인지에 대한 경고창을 띄웁니다.
            makeAlertDialog(title: nil, message: "스터디 등록을 취소하시겠습니까?", type: .closeComposeVC)
        }
    }
    
    
    /// 완료 버튼을 탭했을 때의 동작을 정의합니다.
    @IBAction func tapDoneButton(_ sender: Any) {

        // 입력하지 않은 정보가 있는지 체크
        if let checkData = viewModel?.validateStudyData() {
            makeAlertDialog(title: nil, message: checkData, type: .ok)
        } else {
            // 스터디 수정 상태인 경우
            if viewModel?.isEditStudy == true {
                // 코어 데이터에 수정된 정보를 업데이트 합니다.
                viewModel?.updateStudyData {
                    DispatchQueue.main.async {
                        self.dismiss(animated: true)
                    }
                }
            } else {
                // 코어 데이터에 새로운 스터디를 등록 합니다.
                viewModel?.createStudyData {
                    DispatchQueue.main.async {
                        self.dismiss(animated: true)
                    }
                }
            }
        }
    }
    
    
    /// 신규 스터디 버튼을 탭했을 때의 동작을 정의합니다.
    @IBAction func tapNewStudyButton(_ sender: Any) {
        
        // 뷰모델의 프로퍼티 값을 업데이트 합니다.
        viewModel?.updateStudyProperty(.newStudy, value: true)
        viewModel?.updateStudyProperty(.lastStudyCount, value: nil as Any?)
        viewModel?.updateStudyProperty(.lastProgressDeadlineDate, value: nil as Any?)
    }
    
    /// 기존 스터디 버튼을 탭했을 때의 동작을 정의합니다.
    @IBAction func tapProgressStudyButton(_ sender: Any) {
        // 뷰모델의 프로퍼티 값을 업데이트 합니다.
        viewModel?.updateStudyProperty(.newStudy, value: false)
    }
    
    /// 마지막 회차 마감 날짜 버튼을 탭했을 때의 동작을 정의합니다.
    @IBAction func taplastProgressDeadlineDateButton(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "BottomSheetViewController", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "BottomSheetViewController") as? BottomSheetViewController else { return }
        
        // 옵션을 'lastProgressDeadlineDate'로 설정합니다.
        vc.option = .lastProgressDeadlineDate
        
        // 현재 뷰 모델을 'BottomSheetViewController'에 전달합니다.
        vc.composeViewModel = viewModel
    
        vc.modalPresentationStyle = .overFullScreen
        
        // 'BottomSheetViewController'를 현재 뷰 컨트롤러 위에 표시합니다.
        self.present(vc, animated: false)
    }
    
    /// 최초 시작 날짜 선택 버튼을 탭했을 때의 동작을 정의합니다.
    @IBAction func tapFirstStartDateButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "BottomSheetViewController", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "BottomSheetViewController") as? BottomSheetViewController else { return }
        
        // 옵션을 'firstStartDate'로 설정합니다.
        vc.option = .firstStartDate
        
        // 현재 뷰 모델을 'BottomSheetViewController'에 전달합니다.
        vc.composeViewModel = viewModel
    
        vc.modalPresentationStyle = .overFullScreen
        
        // 'BottomSheetViewController'를 현재 뷰 컨트롤러 위에 표시합니다.
        self.present(vc, animated: false)
    }
    
    /// 마감 요일 선택 버튼을 탭했을 때의 동작을 정의합니다.
    @IBAction func tapDeadlineDateButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "BottomSheetViewController", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "BottomSheetViewController") as? BottomSheetViewController else { return }
        
        // 옵션을 'deadlineDay'로 설정합니다.
        vc.option = .deadlineDay
        
        // 현재 뷰 모델을 'BottomSheetViewController'에 전달합니다.
        vc.composeViewModel = viewModel
        
        vc.modalPresentationStyle = .overFullScreen
        
        // 'BottomSheetViewController'를 현재 뷰 컨트롤러 위에 표시합니다.
        self.present(vc, animated: false)
    }
    
    /// 벌금 선택 버튼을 탭했을 때의 동작을 정의합니다.
    @IBAction func tapFineButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "BottomSheetViewController", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "BottomSheetViewController") as? BottomSheetViewController else { return }
        
        // 옵션을 'fine'로 설정합니다.
        vc.option = .fine
        
        // 현재 뷰 모델을 'BottomSheetViewController'에 전달합니다.
        vc.composeViewModel = viewModel
        
        vc.modalPresentationStyle = .overFullScreen
        
        // 'BottomSheetViewController'를 현재 뷰 컨트롤러 위에 표시합니다.
        self.present(vc, animated: false)
    }
    
    /// 새로운 멤버 등록 버튼을 탭했을 때의 동작을 정의하는 메소드 입니다.
    @IBAction func tapAddMemberButton(_ sender: Any) {
        
        // 벌금이 선택되지 않은 경우 경고창을 띄웁니다.
        if viewModel?.fine.value == nil {
            makeAlertDialog(title: nil, message: "벌금이 선택되지 않았습니다", type: .ok)
        } else {
            let storyboard = UIStoryboard(name: "BottomSheetViewController", bundle: nil)
            guard let vc = storyboard.instantiateViewController(withIdentifier: "BottomSheetViewController") as? BottomSheetViewController else { return }
            
            // 옵션을 'addStudyMemeber'로 설정합니다.
            vc.option = .addStudyMemeber
            
            // 현재 뷰 모델을 'BottomSheetViewController'에 전달합니다.
            vc.composeViewModel = viewModel
            
            vc.modalPresentationStyle = .overFullScreen
            
            // 'BottomSheetViewController'를 현재 뷰 컨트롤러 위에 표시합니다.
            self.present(vc, animated: false)
        }
    }
    
    
    // MARK:  ===== [Function] =====
    
    /// ViewModel의 프로퍼티와 뷰 컨트롤러의 UI 컴포넌트를 연결합니다.
    ///
    /// ViewModel의 프로퍼티의 값이 변경될때 UI가 업데이트 됩니다.
    func bindViewModel() {
        viewModel?.isNewStudy.bind({ [weak self] isNewStudy in
            guard let self = self else { return }
            
            if isNewStudy == true {
                viewModel?.lastProgressNumber.value = 1
                
                // 레이아웃 업데이트
                newStudyButton.backgroundColor = .buttonColor
                newStudyButton.tintColor = .white
                
                progressStudyButton.backgroundColor = .backgroundColor
                progressStudyButton.tintColor = .black
            
                progressSubTitleLabel.text = "신규로 생성하면 1회차 부터 시작되요!"
                
                lastProgressNumberStackView.isHidden = true
                
                lastProgressDeadlineDateBaseView.isHidden = true
            } else {
                viewModel?.lastProgressNumber.value = nil
                
                // 텍스트필드 초기화
                lastProgressNumberTextField.text = nil
                
                // 레이아웃 업데이트
                progressStudyButton.backgroundColor = .buttonColor
                progressStudyButton.tintColor = .white
                
                newStudyButton.backgroundColor = .backgroundColor
                newStudyButton.tintColor = .black
            
                progressSubTitleLabel.text = "기존에 진행하던 스터디는\n마지막으로 진행했던 회차를 입력해주세요!"
                lastProgressNumberTextField.text = ""
                lastProgressDeadlineDateLabel.text = "아직 선택하지 않았어요!"
            
                
                lastProgressNumberStackView.isHidden = false
                
                lastProgressDeadlineDateBaseView.isHidden = false
            }
        })
        
        viewModel?.lastProgressDeadlineDate.bind({ [weak self] lastProgressDeadlineDate in
            guard let self = self else { return }
            lastProgressDeadlineDateLabel.text = lastProgressDeadlineDate?.makeDeadlineDate()?.toString()
        })
        
        viewModel?.firstStudyDate.bind({ [weak self] firstStudyDate in
            guard let self = self else { return }
            firstStartDateLabel.text = firstStudyDate?.toString()
        })
        
        viewModel?.lastContentDeadlineDate.bind({ [weak self] lastContentDeadlineDate in
            guard let self = self else { return }
            firstStartDateLabel.text = lastContentDeadlineDate?.toString()
        })
        
        viewModel?.deadlineDay.bind({ [weak self] deadlineDay in
            guard let self = self else { return }
            deadlineDayLabel.text = deadlineDay?.convertDeadlineDayToString()
        })
        
        viewModel?.deadlineDate.bind({ [weak self] deadlineDate in
            guard let self = self else { return }
            deadlineDaySubLabel.isHidden = false
            deadlineDaySubLabel.text = viewModel?.deadlineDate.value?.toString()
        })
        
        viewModel?.fine.bind({ [weak self] fine in
            guard let self = self else { return }
            fineLabel.text = "\(fine?.insertComma() ?? "")원"
        })
        
        viewModel?.studyMembers.bind({ [weak self] studyMembers in
            guard let self = self else { return }
            
            switch viewModel?.memberState {
            case .add:
                insertMemberInfoViewInStackView(index: 0)
                memberCountLabel.text = "현재 \(viewModel?.studyMembers.value.count ?? 0)명이 참여중이에요"
            case .edit:
                updateMemberInfoViewInStackView(index: viewModel?.editIndex ?? 0)
            case .delete:
                deleteMemberInfoViewInStackView(index: viewModel?.editIndex ?? 0)
                memberCountLabel.text = "현재 \(viewModel?.studyMembers.value.count ?? 0)명이 참여중이에요"
            default:
                print("")
            }
        })
    }
    
    ///  레이아웃을 설정합니다.
    func configLayout() {
        progressInfoBaseView.layer.cornerRadius = .cornerRadius
        nameInfoBaseView.layer.cornerRadius = .cornerRadius
        firstStartDateInfoBaseView.layer.cornerRadius = .cornerRadius
        deadlineInfoBaseView.layer.cornerRadius = .cornerRadius
        fineInfoBaseView.layer.cornerRadius = .cornerRadius
        
        newStudyButton.layer.cornerRadius = .cornerRadius
        progressStudyButton.layer.cornerRadius = .cornerRadius
        lastProgressDeadlineDateEditButton.layer.cornerRadius = .cornerRadius
        firstStartDateEditButton.layer.cornerRadius = .cornerRadius
        deadlineEditButton.layer.cornerRadius = .cornerRadius
        fineEditButton.layer.cornerRadius = .cornerRadius
        addMemberButton.layer.cornerRadius = .cornerRadius
        
        lastProgressNumberTextField.addTarget(self, action: #selector(lastProgressCountTextFieldDidChange(_:)), for: .editingChanged)
        nameTextField.addTarget(self, action: #selector(nameTextFieldDidChange(_:)), for: .editingChanged)
    }
    
    /// 스터디 데이터를 설정합니다.
    func configData() {
        // 수정 상태인지 생성 상태인지 분기
        
        // 스터디 수정 상태인 경우
        if viewModel?.isEditStudy == true {
    
            addStudyMainTitleLabel1.text = "스터디 정보를 수정하기 위해서"
            addStudyMainTitleLabel2.text = "아래 정보들을 변경해 주세요!"
            
            // 기존 진행 여부 뷰를 보여줍니다.
            progressInfoBaseView.isHidden = true
            
            nameTextField.text = viewModel?.title.value ?? ""
            
            firstStartDateInfoBaseView.isHidden = true
            
            deadlineDayLabel.text = viewModel?.deadlineDay.value?.convertDeadlineDayToString()
            deadlineDaySubLabel.text = viewModel?.lastContentDeadlineDate.value?.toString()
            
            fineLabel.text = "\(viewModel?.fine.value?.insertComma() ?? "")원"
            
            memberCountLabel.text = "현재 \(viewModel?.studyMembers.value.count ?? 0)명이 참여중이에요"
            
            insertMemberInfoViewsInStackView()
        
        } else {
            addStudyMainTitleLabel1.text = "새로운 스터디를 등록하기 위해서"
            addStudyMainTitleLabel2.text = "아래 정보들을 입력해 주세요!"
            
            progressSubTitleLabel.text = "신규로 생성하면 1회차 부터 시작되요!"
            viewModel?.lastProgressNumber.value = 1
            
            lastProgressDeadlineDateBaseView.isHidden = true
        
            newStudyButton.backgroundColor = .buttonColor
            newStudyButton.tintColor = .white
            lastProgressNumberStackView.isHidden = true

            deadlineDaySubLabel.isHidden = true
            
            memberCountLabel.text = "스터디에 참여할 사람을 추가해주세요!"
        }
    }
    
    /// 스택뷰에 멤버 정보 뷰들을 추가합니다.
    func insertMemberInfoViewsInStackView() {
        
        // 뷰모델의 studyMembers 값들을 순회하며 처리합니다.
        viewModel?.studyMembers.value.forEach({ member in
            
            // 멤버 정보를 표시하기 위한 뷰를 생성합니다.
            let memberInfoView = EditMemberInfoView()
            
            // 이름 레이블에 멤버의 이름을 설정합니다.
            memberInfoView.nameLabel.text = member.name ?? ""
            
            // 멤버의 보증금이 뷰모델의 보증금보다 적은 경우 주의 메시지를 표시합니다.
            if member.fine < viewModel?.fine.value ?? 0 {
                memberInfoView.fineSubTitle.text = "보증금이 부족해요! (현재 \(Int(member.fine).insertComma())원)"
            } else {
                memberInfoView.fineSubTitle.text = "\(Int(member.fine).insertComma())원"
            }
            
            // 블로그 주소를 설정합니다.
            memberInfoView.blogSubTitle.text = member.blogUrl ?? ""
            
            // 멤버 정보 수정 버튼에 액션을 연결합니다.
            memberInfoView.editButton.addTarget(self, action: #selector(tapEditMemberInfoButton( _:)), for: .touchUpInside)
            
            // 스택뷰에 멤버 정보 뷰를 추가합니다.
            editMemberInfoStackView.addArrangedSubview(memberInfoView)
        })
        
        // 멤버 정보 뷰의 수정 버튼 태그를 업데이트합니다.
        updateMemberInfoViewInEditButtonTag()
    }
    
    
    /// 스택뷰에 멤버 정보 뷰를 추가합니다.
    func insertMemberInfoViewInStackView(index: Int) {
        
        // 멤버 정보를 표시하기 위한 뷰를 생성합니다.
        let memberInfoView = EditMemberInfoView()
        
        // 이름 레이블에 멤버의 이름을 설정합니다.
        memberInfoView.nameLabel.text = viewModel?.studyMembers.value[index].name ?? ""
        
        // 멤버의 보증금이 뷰모델의 보증금보다 적은 경우 주의 메시지를 표시합니다.
        if viewModel?.studyMembers.value[index].fine ?? 0 < viewModel?.fine.value ?? 0 {
            memberInfoView.fineSubTitle.text = "보증금이 부족해요! (현재 \(Int(viewModel?.studyMembers.value[index].fine ?? 0).insertComma())원)"
        } else {
            memberInfoView.fineSubTitle.text = "\(Int(viewModel?.studyMembers.value[index].fine ?? 0).insertComma())원"
        }
   
        // 블로그 주소를 설정합니다.
        memberInfoView.blogSubTitle.text = viewModel?.studyMembers.value[index].blogUrl ?? ""
        
        // 멤버 정보 수정 버튼에 액션을 연결합니다.
        memberInfoView.editButton.addTarget(self, action: #selector(tapEditMemberInfoButton( _:)), for: .touchUpInside)
        
        // 스택뷰에 멤버 정보 뷰를 추가합니다.
        editMemberInfoStackView.insertArrangedSubview(memberInfoView, at: 0)
        
        // 멤버 정보 뷰의 수정 버튼 태그를 업데이트합니다.
        updateMemberInfoViewInEditButtonTag()
    }

    /// 스택뷰의 특정 위치에 있는 멤버 정보 뷰를 업데이트합니다.
    /// - Parameter index: 수정할 뷰의 인덱스 번호
    func updateMemberInfoViewInStackView(index: Int) {
        
        // 스택뷰의 특정 위치에 있는 멤버 정보 뷰를 가져옵니다.
        if let memberInfoView = editMemberInfoStackView.arrangedSubviews[index] as? EditMemberInfoView {
            
            // 이름 레이블에 특정 멤버의 이름을 업데이트 합니다.
            memberInfoView.nameLabel.text = viewModel?.studyMembers.value[index].name ?? ""
            
            // 특정 멤버의 보증금이 뷰모델의 보증금보다 적은 경우 주의 메시지를 표시합니다.
            if viewModel?.studyMembers.value[index].fine ?? 0 < viewModel?.fine.value ?? 0 {
                memberInfoView.fineSubTitle.text = "보증금이 부족해요! (현재 \(Int(viewModel?.studyMembers.value[index].fine ?? 0).insertComma())원)"
            } else {
                memberInfoView.fineSubTitle.text = "\(Int(viewModel?.studyMembers.value[index].fine ?? 0).insertComma())원"
            }
            
            // 블로그 주소를 업데이트 합니다.
            memberInfoView.blogSubTitle.text = viewModel?.studyMembers.value[index].blogUrl ?? ""
        }
    }
    
    /// 스택뷰의 특정 위치에 있는 멤버 정보 뷰를 삭제합니다.
    /// - Parameter index: 삭제할 뷰의 인덱스 번호
    func deleteMemberInfoViewInStackView(index: Int) {
        // 스택뷰의 특정 위치에 있는 멤버의 정보 뷰를 가져옵니다.
        if let memberInfoView = editMemberInfoStackView.arrangedSubviews[index] as? EditMemberInfoView {
            
            //스택뷰에 멤버 정보 뷰를 삭제합니다.
            editMemberInfoStackView.removeArrangedSubview(memberInfoView)
            memberInfoView.removeFromSuperview()
            
            // 멤버 정보 뷰의 수정 버튼 태그를 업데이트 합니다.
            updateMemberInfoViewInEditButtonTag()
        }
    }
    
    // 멤버 정보 뷰의 수정 버튼 태그를 업데이트 합니다.
    func updateMemberInfoViewInEditButtonTag() {
        for (index, view) in editMemberInfoStackView.arrangedSubviews.enumerated() {
            if let memberInfoView = view as? EditMemberInfoView {
                memberInfoView.editButton.tag = index
            }
        }
    }
    
    
    // MARK: ===== [@objc Function] =====
    
    /// 'lastProgressCountTextField'의 텍스트가 변경될 때 호출됩니다.
    @objc func lastProgressCountTextFieldDidChange(_ sender: Any?) {
        
        guard let textField = sender as? UITextField else { return }
    
        // 텍스트 필드의 텍스트가 빈 문자열이면 viewModel의 'lastProgressNumber' 값을 nil로 설정하고, 그렇지 않으면 해당 텍스트를 정수로 변환하여 값을 설정합니다.
        viewModel?.lastProgressNumber.value = textField.text == "" ? nil :  Int(textField.text ?? "0")
    }
    
    /// 'nameTextField'의 텍스트가 변경될 때 호출됩니다.
    @objc func nameTextFieldDidChange(_ sender: Any?) {
        
        guard let textField = sender as? UITextField else { return }
        
        // 텍스트 필드의 텍스트가 빈 문자열이면 viewModel의 'title' 값을 nil로 설정하고, 그렇지 않으면 해당 텍스트 값을 설정합니다.
        viewModel?.title.value = textField.text == "" ? nil : textField.text
    }
    
    /// 'editMemberInfoButton'을 탭할 때 호출 됩니다.
    @objc func tapEditMemberInfoButton(_ sender: UIButton) {
        
        let storyboard = UIStoryboard(name: "BottomSheetViewController", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "BottomSheetViewController") as? BottomSheetViewController else { return }
        
        // 뷰컨트롤러의 옵션을 'editStudyMember'로 설정하고, 뷰모델과 인덱스를 업데이트합니다.
        vc.option = .editStudyMember
        vc.index = sender.tag
        vc.composeViewModel = viewModel
        
        vc.modalPresentationStyle = .overFullScreen
        
        self.present(vc, animated: false)
    }
    
    // 키보드를 화면에서 보이지 않도록 합니다.
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
