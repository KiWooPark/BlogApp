//
//  BottomSheetViewController.swift
//  BlogApp
//
//  Created by PKW on 2023/05/25.
//

import UIKit

/// 스터디에 필요한 세부 정보를 설정하는 클래스 입니다.
class BottomSheetViewController: UIViewController {
    
    // MARK: ===== [Enum] =====
    
    /// 설정할 정보의 타입 열거형
    enum StudyOptionType {
        // 마지막 진행 마감 날짜
        case lastProgressDeadlineDate
        
        // 최초 시작 날짜
        case firstStartDate
        
        // 마감 요일
        case deadlineDay
        
        // 벌금
        case fine
        
        // 스터디 멤버 추가
        case addStudyMemeber
        
        // 스터디 멤버 수정
        case editStudyMember
        
        // 마감 정보 시작 날짜
        case contentStartDate
        
        // 마감 정보 마감 날짜
        case contentDeadlineDate
        
        // 마감 정보 벌금
        case contentFine
        
        // 마감 정보 멤버 추가
        case addContentMember
        
        // 마감 정보 멤버 수정
        case editContentMember
    }
    

    
    // MARK:  ===== [@IBOutlet] =====

    // 바텀 시트의 바탕이 되는 뷰
    @IBOutlet weak var bottomSheetView: UIView!
    
    // 바텀 시트 타이틀을 표시할 레이블
    @IBOutlet weak var titleLabel: UILabel!

    // 바텀 시트 서브 타이틀을 표시할 레이블
    @IBOutlet weak var subTitleLabel: UILabel!

    // 날짜 선택 정보를 표시할 바탕 뷰
    @IBOutlet weak var baseDatePickerView: UIView!
    
    // 날짜 선택 데이트 피커
    @IBOutlet weak var studyDatePicker: UIDatePicker!

    // 마감요일 정보를 표시할 바탕 뷰
    @IBOutlet weak var baseDeadlineDayView: UIView!
    
    // 요일 선택 버튼
    @IBOutlet var dayButtons: [UIButton]!
    
    // 선택한 요일을 표시할 레이블
    @IBOutlet weak var selectedDayLabel: UILabel!
    
    // 선택한 요일을 표시하기 위한 스택 뷰
    @IBOutlet weak var baseSelectedDayStackView: UIStackView!
    
    // 이번주 날짜를 선택할 버튼
    @IBOutlet weak var currentDayButton: UIButton!
    
    // 다음부 날짜를 선택할 버튼
    @IBOutlet weak var nextWeekDayButton: UIButton!
    
    // 벌금 정보를 표시할 바탕 뷰
    @IBOutlet weak var baseFineView: UIView!
    
    // 벌금 선택 버튼
    @IBOutlet var fineButtons: [UIButton]!
    
    // 멤버 정보를 입력할 뷰의 바탕 뷰
    @IBOutlet weak var baseMemberInfoView: UIView!
    
    // 이름을 입력할 텍스트 필드
    @IBOutlet weak var nameTextField: UITextField!
    
    // 블로그 주소를 입력할 텍스트 필드
    @IBOutlet weak var blogUrlTextField: UITextField!
    
    // 벌금 정보를 표시하기위한 스택 뷰
    @IBOutlet weak var fineInfoStackView: UIStackView!
    
    // 벌금 정보를 입력할 텍스트 필드
    @IBOutlet weak var fineTextField: UITextField!
    
    // 멤버 추가 완료 버튼
    @IBOutlet weak var doneButton: UIButton!
     
    // 멤버 삭제 버튼
    @IBOutlet weak var deleteButton: UIButton!
    
    // 스터디 정보를 수정 및 삭제하기 위한 뷰 모델
    var composeViewModel: StudyComposeViewModel?
    
    // 마감 정보를 생성하기 위한 뷰 모델
    var newContentViewModel: NewContentViewModel?
    
    // 선택된 스터디 옵션 타입
    var option: StudyOptionType?
    
    // 선택된 멤버 인덱스
    var index: Int = 0
    
    // 스터디 수정 여부
    var isEditStudy: Bool = false
    
    // 키보드 활성화 여부
    var isKeyboardActive: Bool = false
    
    // 바텀 시트의 높이
    var bottomSheetViewHeight: CGFloat?
    
    deinit {
        print("----- 해제")
        // 키보드 노티 삭제
        removeKeyboard()
    }
    
    // MARK: ===== [Override] =====
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configLayout()
        configData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 키보드 노티 등록
        addKeyboard()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // 바텀 시트 높이가 nil인 경우 높이값 설정
        if bottomSheetViewHeight == nil {
            bottomSheetViewHeight = bottomSheetView.frame.height
            
            // 높이만큼 y값 변경(하단으로 내려 안보이도록 함)
            bottomSheetView.transform = CGAffineTransform(translationX: 0, y: bottomSheetViewHeight ?? 0.0)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // 원래 위치로 변경
        UIView.animate(withDuration: 0.3, animations: {
            self.bottomSheetView.transform = .identity
        })
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    
    // MARK:  ===== [@IBOutlet] =====
    
    /// 닫기 버튼을 탭했을 때의 동작을 정의합니다.
    @IBAction func tapCloseButton(_ sender: Any) {
        
        // 키보드가 활성화 되어있는 경우
        if isKeyboardActive {
            
            // 키보드를 비활성화 합니다.
            view.endEditing(true)
            
            // 바텀 시트를 화면에서 사라지도록 합니다.
            dismissBottomSheetView()
        } else {
            dismissBottomSheetView()
        }
    }
    
    /// 완료 버튼을 탭했을 때의 동작을 정의합니다.
    @IBAction func tapDoneButton(_ sender: Any) {
        
        // 설정중인 정보 타입
        switch option {
            
        // 마지막 진행 마감 날짜
        case .lastProgressDeadlineDate:
            // 뷰 모델의 마지막 마감 날짜를 업데이트 합니다.
            composeViewModel?.updateStudyProperty(.lastProgressDeadlineDate, value: studyDatePicker.date)
            dismissBottomSheetView()
            
        // 최초 시작 날짜
        case .firstStartDate:
            
            // 뷰 모델의 최초 시작 날짜를 업데이트 합니다.
            composeViewModel?.updateStudyProperty(.firstStudyDate, value: studyDatePicker.date)
            dismissBottomSheetView()
            
        // 마감 요일
        case .deadlineDay:
            
            // 선택한 마감 요일 버튼이 있는 경우
            if dayButtons.filter({$0.isSelected == true}).count != 0 {
                
                // 선택한 마감 요일 버튼을 가져옵니다.
                let selectedButton = dayButtons.filter({$0.isSelected == true})[0]
                
                // 오늘을 기준으로 마감 날짜를 계산 합니다.
                let deadlineDate = Date().calculateDeadlineDate(deadlineDay: selectedButton.tag)
                
                // 계산된 마감 날짜중 다음주 날짜가 nil인 경우
                if deadlineDate.nextWeekFinishDate == nil {
                    
                    // 뷰 모델의 마감 요일에 선택된 버튼 태그와 이번주 마감 날짜를 업데이트 합니다.
                    composeViewModel?.updateStudyProperty(.deadlineDay, value: (selectedButton.tag, deadlineDate.currentDate))
                } else {
                    // 다음주 날짜가 nil이 아닌 경우 이번주 날짜와 다음주 날짜를 선택하도록 경고장의 띄웁니다.
                    if currentDayButton.isSelected == false && nextWeekDayButton.isSelected == false {
                        makeAlertDialog(title: "이번주의 마감 날짜 또는 다음주의 마감날짜중 하나를 선택해 주세요", message: nil, type: .ok)
                        return
                    } else {
                        // 이번주 마감 날짜 버튼이 선택되어있다면 이번주 날짜를, 아니라면 다음주 날짜를 가져옵니다.
                        let selectedDeadlineDate = currentDayButton.isSelected == true ? deadlineDate.currentDate : deadlineDate.nextWeekFinishDate
                        // 뷰 모델의 마감 요일에 선택된 버튼의 태그와 가져온 마감 날짜를 업데이트 합니다.
                        composeViewModel?.updateStudyProperty(.deadlineDay, value: (selectedButton.tag, selectedDeadlineDate))
                    }
                }
                dismissBottomSheetView()
            }
        
        // 벌금
        case .fine:
            
            // 선택된 벌금 버튼이 있는 경우
            if fineButtons.filter({$0.isSelected == true}).count != 0 {
                
                // 선택한 벌금 버튼을 가져옵니다.
                let selectedButton = fineButtons.filter({$0.isSelected == true})[0]
                
                // 뷰 모델의 벌금을 업데이트 합니다.
                composeViewModel?.updateStudyProperty(.fine, value: selectedButton.tag)
                dismissBottomSheetView()
            }
            
        // 스터디 멤버 추가
        case .addStudyMemeber:
            
            // 신규 스터디인 경우
            if composeViewModel?.isNewStudy.value == true {
                
                // 양쪽 끝 공백이 제거된 텍스트를 가져옵니다.
                let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                let blogUrl = blogUrlTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                
                // 벌금은 스터디 정보에서 선택한 벌금
                let fine: Int? = composeViewModel?.fine.value
                
                // 이름이 빈 문자열인지 확인합니다.
                if name == "" {
                    
                    // 빈 문자열일 경우 경고창을 띄웁니다.
                    makeAlertDialog(title: nil, message: "이름을 입력해 주세요", type: .ok)
                    return
                }
                
                // 중복된 이름인지 확인합니다.
                if name.validateName(members: composeViewModel?.studyMembers.value ?? []) {
                    
                    // 중복된 이름일 경우 경고창을 띄웁니다.
                    makeAlertDialog(title: nil, message: "중복된 이름 입니다", type: .ok)
                    return
                }
                
                // 블로그 URL이 빈 문자열인지 확인합니다.
                if blogUrl == "" {
                    
                    // 빈 문자열일 경우 경고창을 띄웁니다.
                    makeAlertDialog(title: nil, message: "블로그 주소를 입력해 주세요", type: .ok)
                    return
                }
                
                // 네트워크 연결상태를 확인합니다.
                if NetworkCheckManager.shared.isConnected == false {
                    
                    // 네트워크가 연결되어 있지 않으면 경고창을 띄웁니다.
                    self.makeAlertDialog(title: nil, message: "네트워크 연결이 되지 않아 블로그 주소를 확인할 수 없습니다.\n네트워크 연결상태를 확인해 주세요", type: .ok)
                    return
                } else {
                    
                    // 네트워크가 정상적으로 연결되어있다면 유효한 URL인지 확인합니다.
                    CrawlingManager.validateBlogURL(url: blogUrl) { result in
                        switch result {
                        case .success:
                            
                            // 성공한 경우 뷰 모델에 이름, 블로그 URL, 벌금을 업데이트 합니다.
                            self.composeViewModel?.updateStudyProperty(.addMember, value: (name, blogUrl, fine))
                            self.dismissBottomSheetView()
                        case .failure(let error):
                            
                            // 실패한 경우 에러에 따라 경고창을 띄웁니다.
                            switch error {
                            case .invalidURL, .requestFailed:
                                self.makeAlertDialog(title: nil, message: "블로그 URL을 확인해 주세요", type: .ok)
                                return
                            case .notTistoryURL:
                                self.makeAlertDialog(title: nil, message: "티스토리 URL만 가능합니다", type: .ok)
                                return
                            }
                        }
                    }
                }
            } else {
                
                // 멤버 정보를 수정중이라면
                let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                let blogUrl = blogUrlTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                
                // 벌금은 텍스트필드에 입력된 벌금
                let fine = fineTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "0"
                
                if name == "" {
                    makeAlertDialog(title: nil, message: "이름을 입력해 주세요", type: .ok)
                    return
                }
                
                if name.validateName(members: composeViewModel?.studyMembers.value ?? []) {
                    makeAlertDialog(title: nil, message: "중복된 이름 입니다", type: .ok)
                    return
                }
                
                if blogUrl == "" {
                    makeAlertDialog(title: nil, message: "블로그 주소를 입력해 주세요", type: .ok)
                    return
                }
                
                if fine == "" {
                    makeAlertDialog(title: nil, message: "보증금을 입력해 주세요", type: .ok)
                    return
                }
                
                if NetworkCheckManager.shared.isConnected == false {
                    self.makeAlertDialog(title: nil, message: "네트워크 연결이 되지 않아 블로그 주소를 확인할 수 없습니다.\n네트워크 연결상태를 확인해 주세요", type: .ok)
                    return
                } else {
                    CrawlingManager.validateBlogURL(url: blogUrl) { result in
                        switch result {
                        case .success:
                            self.composeViewModel?.updateStudyProperty(.addMember, value: (name, blogUrl, Int(fine)))
                            self.dismissBottomSheetView()
                        case .failure(let error):
                            switch error {
                            case .invalidURL, .requestFailed:
                                self.makeAlertDialog(title: nil, message: "블로그 URL을 확인해 주세요", type: .ok)
                                return
                            case .notTistoryURL:
                                self.makeAlertDialog(title: nil, message: "티스토리 URL만 가능합니다", type: .ok)
                                return
                            }
                        }
                    }
                }
            }
            
        // 스터디 멤버 수정
        case .editStudyMember:
            let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let blogUrl = blogUrlTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let fine = fineTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "0"
            
            if name == "" {
                makeAlertDialog(title: nil, message: "이름을 입력해 주세요", type: .ok)
                return
            }
            
            if name.validateName(members: composeViewModel?.studyMembers.value ?? [], isEdit: true, index: index) {
                makeAlertDialog(title: nil, message: "중복된 이름 입니다", type: .ok)
                return
            }
            
            if blogUrl == "" {
                makeAlertDialog(title: nil, message: "블로그 주소를 입력해 주세요", type: .ok)
                return
            }
            
            if fine == "" {
                makeAlertDialog(title: nil, message: "보증금을 입력해 주세요", type: .ok)
                return
            }
            
            if NetworkCheckManager.shared.isConnected == false {
                self.makeAlertDialog(title: nil, message: "네트워크 연결이 되지 않아 블로그 주소를 확인할 수 없습니다.\n네트워크 연결상태를 확인해 주세요", type: .ok)
                return
            } else {
                CrawlingManager.validateBlogURL(url: blogUrl) { result in
                    switch result {
                    case .success:
                        self.composeViewModel?.updateStudyProperty(.editMember, value: (name, blogUrl, Int(fine), self.index))
                        self.dismissBottomSheetView()
                    case .failure(let error):
                        switch error {
                        case .invalidURL, .requestFailed:
                            self.makeAlertDialog(title: nil, message: "블로그 URL을 확인해 주세요", type: .ok)
                            return
                        case .notTistoryURL:
                            self.makeAlertDialog(title: nil, message: "티스토리 URL만 가능합니다", type: .ok)
                            return
                        }
                    }
                }
            }
            
        // 마감 정보의 시작 날짜
        case .contentStartDate:
            
            // 마지막 마감 정보에 시작 날짜가 없는 경우(1회차인 경우만)
            if newContentViewModel?.lastContent.value?.startDate == nil {
                
                // 데이트 피커에서 선택한 날짜를 가져옵니다.
                let targetDate = studyDatePicker.date
                
                // 마지막 마감 정보의 마감 날짜를 가져옵니다.
                let deadlineDate = newContentViewModel?.deadlineDate.value
                
                // 위 두 날짜를 비교합니다.
                let result = targetDate.dateCompare(fromDate: deadlineDate, editType: .startDate)
                
                switch result {
                case .pastStartDate:
                    // 선택한 날짜가 마감일보다 과거인 경우 뷰 모델의 시작 날짜를 업데이트 합니다.
                    newContentViewModel?.updateContentProperty(.startDate, value: studyDatePicker.date)
                    dismissBottomSheetView()
                case .futureStartDate:
                    // 선택한 날짜가 마감일보다 미래인 경우 경고창을 띄웁니다.
                    makeAlertDialog(title: nil, message: "마감일보다 미래로 선택할 수 없습니다", type: .ok)
                case .sameStartDate:
                    // 선택한 날짜가 마감일과 같은 경우 경고창을 띄웁니다.
                    makeAlertDialog(title: nil, message: "마감일과 같은 날짜로 선택할 수 없습니다", type: .ok)
                default:
                    print("none")
                }
            }
            
        // 마감 정보의 마감 날짜
        case .contentDeadlineDate:
            
            // 데이트 피커에서 선택한 날짜를 가져옵니다.
            let targetDate = studyDatePicker.date
            
            // 마지막 마감 정보에서 시작 날짜를 가져옵니다.
            let startDate = newContentViewModel?.startDate.value

            // 선택한 날짜와 시작 날짜를 비교합니다. (마감 날짜 선택시)
            let compareStartDate = targetDate.dateCompare(fromDate: startDate, editType: .deadlineDate)
            
            // 선택한 날짜와 현재 날짜를 비교합니다. (마감 날짜 선택시)
            let compareTodayDate = targetDate.dateCompare(fromDate: Date(), editType: .deadlineDate)
            
            switch (compareStartDate, compareTodayDate) {
            case (.pastDeadlineDate, .pastDeadlineDate):
                
                // 시작 날짜보다 과거이거나, 현재 날짜보다 과거인 경우 경고창을 띄웁니다.
                makeAlertDialog(title: nil, message: "시작일보다 과거로 선택할 수 없습니다", type: .ok)
            case (.sameDeadlineDate, .pastDeadlineDate):
                
                // 시작 날짜와 같거나, 현재 날짜보다 과거인 경우 경고창을 띄웁니다.
                makeAlertDialog(title: nil, message: "시작일과 같은 날짜로 선택할 수 없습니다", type: .ok)
            case (.futureDeadlineDate, .pastDeadlineDate):
                
                // 시작 날짜보다 미래이거나, 현재 날짜보다 과거인 경우 뷰 모델의 마감 날짜를 업데이트 합니다.
                newContentViewModel?.updateContentProperty(.deadlineDate, value: studyDatePicker.date)
                dismissBottomSheetView()
            case (.futureDeadlineDate, .sameDeadlineDate):
                
                // 시작 날짜보다 미래이거나, 현재 날짜와 같은 경우 경고창을 띄웁니다.
                makeAlertDialog(title: nil, message: "오늘과 같은날로 선택할 수 없습니다", type: .ok)
            default:
                
                // 나머지 경우 경고창을 띄웁니다.
                makeAlertDialog(title: nil, message: "오늘보다 미래로 선택할 수 없습니다", type: .ok)
            }
            
        // 마감 정보의 벌금
        case .contentFine:
            
            // 선택한 벌금 버튼을 가져옵니다.
            let selectedButton = fineButtons.filter({$0.isSelected == true})[0]
            
            // 뷰 모델의 벌금을 업데이트 합니다.
            newContentViewModel?.updateContentProperty(.fine, value: selectedButton.tag)
            dismissBottomSheetView()
            
        // 마감 정보에 멤버 추가
        case .addContentMember:
            let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let blogUrl = blogUrlTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let fine = fineTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "0"
            
            if name == "" {
                makeAlertDialog(title: nil, message: "이름을 입력해 주세요", type: .ok)
                return
            }
            
            if name.validateName(members: newContentViewModel?.studyMembers.value ?? []) {
                makeAlertDialog(title: nil, message: "중복된 이름 입니다", type: .ok)
                return
            }
            
            if blogUrl == "" {
                makeAlertDialog(title: nil, message: "블로그 주소를 입력해 주세요", type: .ok)
                return
            }
            
            if fine == "" {
                makeAlertDialog(title: nil, message: "보증금을 입력해 주세요", type: .ok)
                return
            }
            
            if NetworkCheckManager.shared.isConnected == false {
                self.makeAlertDialog(title: nil, message: "네트워크 연결이 되지 않아 블로그 주소를 확인할 수 없습니다.\n네트워크 연결상태를 확인해 주세요", type: .ok)
                return
            } else {
                CrawlingManager.validateBlogURL(url: blogUrl) { result in
                    switch result {
                    case .success:
                        self.newContentViewModel?.updateContentProperty(.addContentMember, value: (name, blogUrl, Int(fine)))
                        self.dismissBottomSheetView()
                    case .failure(let error):
                        switch error {
                        case .invalidURL, .requestFailed:
                            self.makeAlertDialog(title: nil, message: "블로그 URL을 확인해 주세요", type: .ok)
                            return
                        case .notTistoryURL:
                            self.makeAlertDialog(title: nil, message: "티스토리 URL만 가능합니다", type: .ok)
                            return
                        }
                    }
                }
            }
            
        // 마감 정보에 멤버 정보 수정
        case .editContentMember:
            let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let blogUrl = blogUrlTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let fine = fineTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "0"
            
            if name == "" {
                makeAlertDialog(title: nil, message: "이름을 입력해 주세요", type: .ok)
                return
            }
            
            if name.validateName(members: newContentViewModel?.studyMembers.value ?? []) {
                makeAlertDialog(title: nil, message: "중복된 이름 입니다", type: .ok)
                return
            }
            
            if blogUrl == "" {
                makeAlertDialog(title: nil, message: "블로그 주소를 입력해 주세요", type: .ok)
                return
            }
            
            if fine == "" {
                makeAlertDialog(title: nil, message: "보증금을 입력해 주세요", type: .ok)
                return
            }
            
            if NetworkCheckManager.shared.isConnected == false {
                self.makeAlertDialog(title: nil, message: "네트워크 연결이 되지 않아 블로그 주소를 확인할 수 없습니다.\n네트워크 연결상태를 확인해 주세요", type: .ok)
                return
            } else {
                CrawlingManager.validateBlogURL(url: blogUrl) { result in
                    switch result {
                    case .success:
                        self.newContentViewModel?.updateContentProperty(.editContentMember, value: (name, blogUrl, Int(fine), self.index))
                        self.dismissBottomSheetView()
                    case .failure(let error):
                        switch error {
                        case .invalidURL, .requestFailed:
                            self.makeAlertDialog(title: nil, message: "블로그 URL을 확인해 주세요", type: .ok)
                            return
                        case .notTistoryURL:
                            self.makeAlertDialog(title: nil, message: "티스토리 URL만 가능합니다", type: .ok)
                            return
                        }
                    }
                }
            }
        default:
            print("none")
        }
    }
    
    /// 멤버 정보 삭제 버튼을 탭했을 때의 동작을 정의합니다.
    @IBAction func tapDeleteButton(_ sender: Any) {
        
        // 삭제하기 전 경고창을 띄웁니다.
        makeAlertDialog(title: nil, message: "해당 멤버를 삭제 하시겠습니까?", type: .deleteMember)
    }
    
    /// 마감 요일 선택 버튼을 탭했을 때의 동작을 정의합니다.
    @IBAction func tapDeadlineDayButton(_ sender: Any) {
        
        guard let selectedButton = sender as? UIButton else { return }
        
        // 모든 버튼을 검사하여 현재 선택된 버튼만 선택 상태로 만들고 나머지는 비선택 상태로 만듭니다.
        dayButtons.forEach { button in
            button.isSelected = button.tag == selectedButton.tag ? true : false
        }
        
        // 선택된 버튼의 태그값을 기준으로 마감일을 계산합니다.
        let deadlineDate = Date().calculateDeadlineDate(deadlineDay: selectedButton.tag)
        
        // 다음 주 마감일이 없으면 'selectedDayLabel'을 보이게 하고, 있으면 'baseSelectedDayStackView'를 보이게 합니다.
        if deadlineDate.nextWeekFinishDate == nil {
            selectedDayLabel.isHidden = false
            baseSelectedDayStackView.isHidden = true
            selectedDayLabel.text = "\(deadlineDate.currentDate?.toString() ?? "")에 마감되요"
        } else {
            selectedDayLabel.isHidden = true
            baseSelectedDayStackView.isHidden = false
            currentDayButton.setTitle(deadlineDate.currentDate?.toString(), for: .normal)
            nextWeekDayButton.setTitle(deadlineDate.nextWeekFinishDate?.toString(), for: .normal)
        }
    }

    /// 이번주 마감 날짜와 다음주 마감 날짜 버튼을 탭했을 때의 동작을 정의합니다.
    @IBAction func tapCurrentDateAndNextWeekDateButton(_ sender: Any) {
        guard let selectedButton = sender as? UIButton else { return }
        
        // 현재 날짜 버튼이 선택되었는지 확인하고, 상태를 업데이트합니다.
        currentDayButton.isSelected = selectedButton.tag == currentDayButton.tag ? true : false
        
        // 다음 주 날짜 버튼이 선택되었는지 확인하고, 상태를 업데이트합니다.
        nextWeekDayButton.isSelected = selectedButton.tag == nextWeekDayButton.tag ? true : false
    }
    
    /// 벌금 버튼을 탭했을 때의 동작을 정의합니다.
    @IBAction func tapFineButton(_ sender: Any) {
        guard let selectedButton = sender as? UIButton else { return }
        
        // 모든 '벌금' 버튼의 선택 상태를 업데이트합니다. 선택된 버튼만 활성 상태로 설정됩니다.
        fineButtons.forEach { button in
            button.isSelected = button.tag == selectedButton.tag ? true : false
        }
    }
    
    
    
    // MARK:  ===== [Function] =====
    
    /// 수정 상태일 경우 멤버 정보를 설정합니다.
    func configData() {
        switch option {
        case .editStudyMember:
            nameTextField.text = composeViewModel?.studyMembers.value[index].name ?? ""
            blogUrlTextField.text = composeViewModel?.studyMembers.value[index].blogUrl ?? ""
            fineTextField.text = "\(composeViewModel?.studyMembers.value[index].fine ?? 0)"
        case .editContentMember:
            nameTextField.text = newContentViewModel?.studyMembers.value[index].name ?? ""
            blogUrlTextField.text = newContentViewModel?.studyMembers.value[index].blogUrl ?? ""
            fineTextField.text = "\(newContentViewModel?.studyMembers.value[index].fine ?? 0)"
        default:
            print("none")
        }
    }
        
    /// 레이아웃을 설정합니다.
    func configLayout() {
        bottomSheetView.layer.cornerRadius = .cornerRadius
        bottomSheetView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        doneButton.layer.cornerRadius = .cornerRadius
        deleteButton.layer.cornerRadius = .cornerRadius
        baseDatePickerView.layer.cornerRadius = .cornerRadius
        baseDeadlineDayView.layer.cornerRadius = .cornerRadius
        baseFineView.layer.cornerRadius = .cornerRadius
        baseMemberInfoView.layer.cornerRadius = .cornerRadius
    
        switch option {
        case .lastProgressDeadlineDate:
            titleLabel.text = "마지막 진행 회차의\n마감 날짜를 선택해 주세요"
            subTitleLabel.text = "마지막으로 진행한 회차의 마감 날짜에요!"
            baseDatePickerView.isHidden = false
            deleteButton.isHidden = true
            
        case .firstStartDate:
            titleLabel.text = "최초 시작 날짜를 선택해 주세요"
            subTitleLabel.text = "처음으로 시작하는 날짜에요!"
            baseDatePickerView.isHidden = false
            deleteButton.isHidden = true
            
            if composeViewModel?.firstStudyDate.value != nil {
                studyDatePicker.date = composeViewModel?.firstStudyDate.value ?? Date()
            }
        
        case .deadlineDay:
            titleLabel.text = "마감 요일을 선택해 주세요"
            subTitleLabel.text = "스터디가 마감되는 요일이에요!"
            baseDeadlineDayView.isHidden = false
            deleteButton.isHidden = true
            
            var deadlineDate: (currentDate: Date?, nextWeekFinishDate: Date?)?
            
            if composeViewModel?.deadlineDay.value != nil {
                switch composeViewModel?.deadlineDay.value {
                case 2:
                    dayButtons[0].isSelected = true
                    deadlineDate = Date().calculateDeadlineDate(deadlineDay: 2)
                case 3:
                    dayButtons[1].isSelected = true
                    deadlineDate = Date().calculateDeadlineDate(deadlineDay: 3)
                case 4:
                    dayButtons[2].isSelected = true
                    deadlineDate = Date().calculateDeadlineDate(deadlineDay: 4)
                case 5:
                    dayButtons[3].isSelected = true
                    deadlineDate = Date().calculateDeadlineDate(deadlineDay: 5)
                case 6:
                    dayButtons[4].isSelected = true
                    deadlineDate = Date().calculateDeadlineDate(deadlineDay: 6)
                case 7:
                    dayButtons[5].isSelected = true
                    deadlineDate = Date().calculateDeadlineDate(deadlineDay: 7)
                case 1:
                    dayButtons[6].isSelected = true
                    deadlineDate = Date().calculateDeadlineDate(deadlineDay: 1)
                default:
                    print("")
                }
                
                if deadlineDate?.nextWeekFinishDate == nil {
                    selectedDayLabel.isHidden = false
                    baseSelectedDayStackView.isHidden = true
                    selectedDayLabel.text = "\(deadlineDate?.currentDate?.toString() ?? "")에 마감되요"
                } else {
                    selectedDayLabel.isHidden = true
                    baseSelectedDayStackView.isHidden = false
                    currentDayButton.setTitle(deadlineDate?.currentDate?.toString(), for: .normal)
                    nextWeekDayButton.setTitle(deadlineDate?.nextWeekFinishDate?.toString(), for: .normal)
                }
            } else {
                selectedDayLabel.text = "아직 선택하지 않았어요!"
                baseSelectedDayStackView.isHidden = true
            }
    
        case .fine:
            titleLabel.text = "벌금을 선택해 주세요"
            subTitleLabel.text = "게시물을 작성하지 않았을 경우 차감될 금액이에요!"
            baseFineView.isHidden = false
            deleteButton.isHidden = true
            
            if composeViewModel?.fine.value != nil {
                switch composeViewModel?.fine.value {
                case 1000:
                    fineButtons[0].isSelected = true
                case 3000:
                    fineButtons[1].isSelected = true
                case 5000:
                    fineButtons[2].isSelected = true
                case 7000:
                    fineButtons[3].isSelected = true
                case 10000:
                    fineButtons[4].isSelected = true
                default:
                    print("")
                }
            }
            
        case .addStudyMemeber:
            
            titleLabel.text = "참여할 멤버를 추가해 주세요"
            deleteButton.isHidden = true
           
            if composeViewModel?.isNewStudy.value == true {
                baseMemberInfoView.isHidden = false
                fineInfoStackView.isHidden = true
                subTitleLabel.text = "보증금은 선택한 벌금으로 추가되요!"
            } else {
                baseMemberInfoView.isHidden = false
                fineInfoStackView.isHidden = false
                subTitleLabel.text = "보증금은 마지막 회차까지\n계산된 금액을 입력해 주세요!"
            }
        
        case .editStudyMember:
            titleLabel.text = "해당 멤버의 정보를 수정해 주세요"
            subTitleLabel.text = ""
            baseMemberInfoView.isHidden = false

        case .contentStartDate:
            titleLabel.text = "스터디를 시작 할 날짜를 선택해 주세요"
            subTitleLabel.text = "현재 회차가 시작되는 날짜에요!"
            baseDatePickerView.isHidden = false
            deleteButton.isHidden = true
            studyDatePicker.date = newContentViewModel?.startDate.value ?? Date()
            
        case .contentDeadlineDate:
            titleLabel.text = "스터디를 마감 할 날짜를 선택해 주세요"
            subTitleLabel.text = "현재 회차가 마감되는 날짜에요!"
            baseDatePickerView.isHidden = false
            deleteButton.isHidden = true
            studyDatePicker.date = newContentViewModel?.deadlineDate.value ?? Date()
        case .contentFine:
            titleLabel.text = "벌금을 선택해 주세요"
            subTitleLabel.text = "게시물을 작성하지 않았을 경우 차감될 금액이에요!"
            baseFineView.isHidden = false
            deleteButton.isHidden = true
            
            switch newContentViewModel?.fine.value {
            case 1000:
                fineButtons[0].isSelected = true
            case 3000:
                fineButtons[1].isSelected = true
            case 5000:
                fineButtons[2].isSelected = true
            case 7000:
                fineButtons[3].isSelected = true
            case 10000:
                fineButtons[4].isSelected = true
            default:
                print("")
            }
            
        case .addContentMember:
            titleLabel.text = "참여할 멤버를 추가해 주세요"
            subTitleLabel.text = "새로 추가된 인원이 있다면 추가해 주세요!"
            baseMemberInfoView.isHidden = false
            deleteButton.isHidden = true
        case .editContentMember:
            titleLabel.text = "해당 멤버의 정보를 수정해 주세요"
            subTitleLabel.text = ""
            baseMemberInfoView.isHidden = false
        default:
            print("")
        }
    }

    /// BottomSheetView를 아래로 움직여서 화면에서 사라지게합니다.
    func dismissBottomSheetView() {
        
        // 애니메이션을 사용하여 bottomSheetView를 아래로 움직입니다.
        UIView.animate(withDuration: 0.3, animations: {
            
            // bottomSheetView의 위치를 변경하여 화면 아래로 이동시킵니다.
            self.bottomSheetView.transform = CGAffineTransform(translationX: 0, y: self.bottomSheetView.frame.height)
        }, completion: { finished in
            
            // 애니메이션이 완료된 경우 뷰 컨트롤러를 닫습니다.
            if finished {
                self.dismiss(animated: false, completion: nil)
            }
        })
    }
    
    /// 키보드 노티를 등록합니다.
    func addKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardUp), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDown), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    /// 키보드 노티를 제거합니다.
    func removeKeyboard() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    
    // MARK: ===== [@objc Function] =====
    
    /// 키보드를 활성화합니다.
    @objc func keyboardUp(_ notification: NSNotification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            
            isKeyboardActive = true
            
            UIView.animate(withDuration: 0.3) {
                self.bottomSheetView.transform = CGAffineTransform(translationX: 0, y: -keyboardRectangle.height)
            }
        }
    }
    
    /// 키보드를 비활성화 합니다.
    @objc func keyboardDown(notification: NSNotification) {
        isKeyboardActive = false
        self.bottomSheetView.transform = .identity
    }
}
