//
//  BottomSheetViewController.swift
//  BlogApp
//
//  Created by PKW on 2023/05/25.
//

import UIKit

enum StudyOptionType {
    case lastProgressDeadlineDate // o
    case firstStartDate // o
    case deadlineDay // o
    case fine // o
    case addStudyMemeber // o
    case editStudyMember // o
    
    case contentStartDate
    case contentDeadlineDate
    case contentFine
    case addContentMember
    case editContentMember
}

class BottomSheetViewController: UIViewController {
    
    @IBOutlet weak var bottomSheetView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!

    @IBOutlet weak var baseDatePickerView: UIView!
    @IBOutlet weak var studyDatePicker: UIDatePicker!

    @IBOutlet weak var baseDeadlineDayView: UIView!
    @IBOutlet var dayButtons: [UIButton]!
    @IBOutlet weak var selectedDayLabel: UILabel!
    
    @IBOutlet weak var baseSelectedDayStackView: UIStackView!
    @IBOutlet weak var currentDayButton: UIButton!
    @IBOutlet weak var nextWeekDayButton: UIButton!
    
    @IBOutlet weak var baseFineView: UIView!
    @IBOutlet var fineButtons: [UIButton]!
    
    @IBOutlet weak var baseMemberInfoView: UIView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var blogUrlTextField: UITextField!
    
    @IBOutlet weak var fineInfoStackView: UIStackView!
    @IBOutlet weak var fineTextField: UITextField!
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    var composeViewModel: StudyComposeViewModel?
    var newContentViewModel: NewContentViewModel?
    
    var option: StudyOptionType?
    var index: Int = 0
    var isEditStudy: Bool = false
    
    var isKeyboardActive: Bool = false
    var bottomSheetViewHeight: CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configLayout()
        configData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addKeyboard()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if bottomSheetViewHeight == nil {
            bottomSheetViewHeight = bottomSheetView.frame.height
            bottomSheetView.transform = CGAffineTransform(translationX: 0, y: bottomSheetViewHeight ?? 0.0)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        UIView.animate(withDuration: 0.3, animations: {
            self.bottomSheetView.transform = .identity
        })
    }

    deinit {
        print("----- 해제")
        removeKeyboard()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func dismissBottomSheetView() {
        
        view.endEditing(true)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.bottomSheetView.transform = CGAffineTransform(translationX: 0, y: self.bottomSheetView.frame.height)
        }, completion: { finished in
            // 애니메이션이 완료되면 뷰 컨트롤러를 닫음
            if finished {
                self.dismiss(animated: false, completion: nil)
            }
        })
    }
    
    @IBAction func tapCloseButton(_ sender: Any) {
        if isKeyboardActive {
            dismissBottomSheetView()
        } else {
            dismissBottomSheetView()
        }
    }
    
    @IBAction func tapDoneButton(_ sender: Any) {
        switch option {
        case .lastProgressDeadlineDate:
            composeViewModel?.updateStudyProperty(.lastProgressDeadlineDate, value: studyDatePicker.date)
            dismissBottomSheetView()
        case .firstStartDate:
            composeViewModel?.updateStudyProperty(.firstStudyDate, value: studyDatePicker.date)
            dismissBottomSheetView()
        case .deadlineDay:
            if dayButtons.filter({$0.isSelected == true}).count != 0 {
                let selectedButton = dayButtons.filter({$0.isSelected == true})[0]
                
                let deadlineDate = Date().calculateDeadlineDate(deadlineDay: selectedButton.tag)
                
                if deadlineDate.nextWeekFinishDate == nil {
                    composeViewModel?.updateStudyProperty(.deadlineDay, value: (selectedButton.tag, deadlineDate.currentDate))
                } else {
                    if currentDayButton.isSelected == false && nextWeekDayButton.isSelected == false {
                        makeAlertDialog(title: "이번주의 마감 날짜 또는 다음주의 마감날짜중 하나를 선택해 주세요", message: nil, type: .ok)
                        return
                    } else {
                        let selectedDeadlineDate = currentDayButton.isSelected == true ? deadlineDate.currentDate : deadlineDate.nextWeekFinishDate
                        composeViewModel?.updateStudyProperty(.deadlineDay, value: (selectedButton.tag, selectedDeadlineDate))
                    }
                }
                dismissBottomSheetView()
            }
        case .fine:
            if fineButtons.filter({$0.isSelected == true}).count != 0 {
                let selectedButton = fineButtons.filter({$0.isSelected == true})[0]
                composeViewModel?.updateStudyProperty(.fine, value: selectedButton.tag)
                dismissBottomSheetView()
            }
        case .addStudyMemeber:
            
            if composeViewModel?.isNewStudy.value == true {
                let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                let blogUrl = blogUrlTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                let fine: Int? = composeViewModel?.fine.value
                
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
                
                if NetworkCheck.shared.isConnected == false {
                    self.makeAlertDialog(title: nil, message: "네트워크 연결이 되지 않아 블로그 주소를 확인할 수 없습니다.\n네트워크 연결상태를 확인해 주세요", type: .ok)
                    return
                } else {
                    CrawlingManager.validateBlogURL(url: blogUrl) { result in
                        switch result {
                        case .success:
                            self.composeViewModel?.updateStudyProperty(.addMember, value: (name, blogUrl, fine))
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
            } else {
                let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                let blogUrl = blogUrlTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
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
                
                if NetworkCheck.shared.isConnected == false {
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
            
            if NetworkCheck.shared.isConnected == false {
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
        case .contentStartDate:
            if newContentViewModel?.lastContent.value?.startDate == nil {
                let targetDate = studyDatePicker.date
                let deadlineDate = newContentViewModel?.deadlineDate.value
                
                // 선택한 날짜를 마감날짜랑 현재 날짜 두개 비교해야함
                let result = targetDate.dateCompare(fromDate: deadlineDate, editType: .startDate)
                
                switch result {
                case .pastStartDate:
                    newContentViewModel?.updateContentProperty(.startDate, value: studyDatePicker.date)
                    dismissBottomSheetView()
                case .futureStartDate:
                    makeAlertDialog(title: nil, message: "마감일보다 미래로 선택할 수 없습니다", type: .ok)
                case .sameStartDate:
                    makeAlertDialog(title: nil, message: "마감일과 같은 날짜로 선택할 수 없습니다", type: .ok)
                default:
                    print("none")
                }
            }
        case .contentDeadlineDate:
            
            let targetDate = studyDatePicker.date
            let startDate = newContentViewModel?.startDate.value

            let compareStartDate = targetDate.dateCompare(fromDate: startDate, editType: .deadlineDate)
            let compareTodayDate = targetDate.dateCompare(fromDate: Date(), editType: .deadlineDate)
    
            print(compareStartDate, compareTodayDate)
            
            switch (compareStartDate, compareTodayDate) {
            case (.pastDeadlineDate, .pastDeadlineDate):
                makeAlertDialog(title: nil, message: "시작일보다 과거로 선택할 수 없습니다", type: .ok)
            case (.sameDeadlineDate, .pastDeadlineDate):
                makeAlertDialog(title: nil, message: "시작일과 같은 날짜로 선택할 수 없습니다", type: .ok)
            case (.futureDeadlineDate, .pastDeadlineDate):
                newContentViewModel?.updateContentProperty(.deadlineDate, value: studyDatePicker.date)
                dismissBottomSheetView()
            case (.futureDeadlineDate, .sameDeadlineDate):
                makeAlertDialog(title: nil, message: "오늘과 같은날로 선택할 수 없습니다", type: .ok)
            default:
                makeAlertDialog(title: nil, message: "오늘보다 미래로 선택할 수 없습니다", type: .ok)
            }
        case .contentFine:
            let selectedButton = fineButtons.filter({$0.isSelected == true})[0]
            newContentViewModel?.updateContentProperty(.fine, value: selectedButton.tag)
            dismissBottomSheetView()
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
            
            if NetworkCheck.shared.isConnected == false {
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
            
            if NetworkCheck.shared.isConnected == false {
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
    
    @IBAction func tapDeleteButton(_ sender: Any) {
        makeAlertDialog(title: nil, message: "해당 멤버를 삭제 하시겠습니까?", type: .deleteMember)
    }
    
    
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
    
    @IBAction func tapDeadlineDayButton(_ sender: Any) {
        guard let selectedButton = sender as? UIButton else { return }
        
        dayButtons.forEach { button in
            button.isSelected = button.tag == selectedButton.tag ? true : false
        }
        
        let deadlineDate = Date().calculateDeadlineDate(deadlineDay: selectedButton.tag)
        
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
    
    @IBAction func tapCurrentDateAndNextWeekDateButton(_ sender: Any) {
        guard let selectedButton = sender as? UIButton else { return }
        
        currentDayButton.isSelected = selectedButton.tag == currentDayButton.tag ? true : false
        nextWeekDayButton.isSelected = selectedButton.tag == nextWeekDayButton.tag ? true : false
    }
    
        
    @IBAction func tapFineButton(_ sender: Any) {
        guard let selectedButton = sender as? UIButton else { return }
        
        fineButtons.forEach { button in
            button.isSelected = button.tag == selectedButton.tag ? true : false
        }
    }
    
    func addKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardUp), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDown), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func removeKeyboard() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardUp(_ notification: NSNotification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            
            isKeyboardActive = true
            
            UIView.animate(withDuration: 0.3) {
                self.bottomSheetView.transform = CGAffineTransform(translationX: 0, y: -keyboardRectangle.height)
            }
        }
    }
    
    @objc func keyboardDown(notification: NSNotification) {
        isKeyboardActive = false
        self.bottomSheetView.transform = .identity
    }
}



//class BottomSheetViewController: UIViewController {
//
//    @IBOutlet weak var baseView: UIView!
//
//    @IBOutlet weak var titleLabel: UILabel!
//    @IBOutlet weak var subTitleLabel: UILabel!
//
//    @IBOutlet weak var baseStackView: UIStackView!
//
//    @IBOutlet weak var startDateView: UIView!
//    @IBOutlet weak var startDatePicker: UIDatePicker!
//
//    // tag = 101 시작
//    @IBOutlet weak var selectDayView: UIView!
//    @IBOutlet var dayButtons: [UIButton]!
//
//    // tag = 201 시작
//    @IBOutlet weak var selectFineView: UIView!
//    @IBOutlet var fineButtons: [UIButton]!
//
//    @IBOutlet weak var addMemberView: UIView!
//    @IBOutlet weak var memberNameTextField: UITextField!
//    @IBOutlet weak var blogUrlTextField: UITextField!
//    @IBOutlet weak var fineTextField: UITextField!
//
//    @IBOutlet weak var fineStackView: UIStackView!
//
//    @IBOutlet weak var currentDateButton: UIButton!
//    @IBOutlet weak var nextWeekDateButton: UIButton!
//    @IBOutlet weak var selectDateLabel: UILabel!
//
//    @IBOutlet var finishDateButtons: [UIButton]!
//
//    @IBOutlet weak var doneButton: UIButton!
//    @IBOutlet weak var deleteMemberButton: UIButton!
//
//    var option: StudyOptionType?
//
//    var composeViewModel: StudyComposeViewModel?
//
//    var newContentViewModel: NewContentViewModel?
//
//    var isEditStudy: Bool = false
//    var isEditMember: Bool = false
//    var isNewMember: Bool = true
//
//    var isSameFinishDate: Bool = false
//
//    var editIndex: Int = 999999
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        configLayout()
//        configData()
//        configDatePicker()
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        // 키보드 노티 등록
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardUp), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDown), name: UIResponder.keyboardWillHideNotification, object: nil)
//    }
//
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//
//        // 키보드 노티 삭제
//        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
//    }
//
//    @objc func keyboardUp(notification: NSNotification) {
//        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
//            let keyboardRectangle = keyboardFrame.cgRectValue
//
//            UIView.animate(withDuration: 0.3) {
//                self.baseView.transform = CGAffineTransform(translationX: 0, y: -keyboardRectangle.height)
//            }
//        }
//    }
//
//    @objc func keyboardDown(notification: NSNotification) {
//        self.baseView.transform = .identity
//    }
//
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        self.baseView.endEditing(true)
//    }
//
//    func configData() {
//
//        switch option {
//        case .studyMemeber:
//            if isEditMember {
//                let target = composeViewModel?.studyMembers.value[editIndex]
//                memberNameTextField.text = target?.name ?? ""
//                blogUrlTextField.text = target?.blogUrl ?? ""
//                fineTextField.text = "\(target?.fine ?? 0)"
//            }
//        case .contentMember:
//            if isNewMember {
//                let target = newContentViewModel?.study
//                memberNameTextField.placeholder = "이름을 입력해주세요."
//                blogUrlTextField.placeholder = "블로그 주소를 입력해주세요."
//                fineTextField.text = "\(Int(target?.fine ?? 0).convertFineInt())"
//            } else {
//                let target = newContentViewModel?.studyMembers.value[editIndex]
//                memberNameTextField.text = target?.name ?? ""
//                blogUrlTextField.text = target?.blogUrl ?? ""
//                fineTextField.text = "\(target?.fine ?? 0)"
//            }
//        default:
//            print("")
//        }
//    }
//
//    func configLayout() {
//        switch option {
//        case .startDate:
//
//            titleLabel.text = "시작 날짜를 선택해 주세요."
//            subTitleLabel.text = composeViewModel?.isNewStudy.value == true ? "신규 스터디의 시작 날짜는 이번주에서만 선택 가능합니다." : "기존 스터디의 시작 날짜는 이번주 일요일까지 선택 가능합니다."
//            startDateView.isHidden = false
//            deleteMemberButton.isHidden = true
//        case .selectDeadlineDay:
//            titleLabel.text = "마감 요일을 선택해 주세요."
//            subTitleLabel.isHidden = true
//            selectDayView.isHidden = false
//            deleteMemberButton.isHidden = true
//        case .selectFine:
//            titleLabel.text = "벌금을 선택해 주세요."
//            subTitleLabel.isHidden = true
//            selectFineView.isHidden = false
//            deleteMemberButton.isHidden = true
//        case .studyMemeber:
//            if isEditStudy {
//                // 수정
//                fineStackView.isHidden = isNewMember == true ? true : false
//                titleLabel.text = "수정 할 멤버의 정보를 입력해주세요."
//                subTitleLabel.text = ""
//            } else {
//                titleLabel.text = "추가 할 멤버의 정보를 입력해주세요."
//                // 새로등록
//                if composeViewModel?.isNewStudy.value == true {
//                    // 신규 스터디
//                    fineStackView.isHidden = isEditMember == true ? false : true
//                    subTitleLabel.text = "신규 스터디에 추가되는 멤버의 보증금은 설정한 벌금으로 자동 등록 됩니다."
//                } else {
//                    // 기존 스터디
//                    fineStackView.isHidden = isEditMember == true || isNewMember == true ? false : true
//                    subTitleLabel.text = "기존 스터디에 추가되는 멤버의 보증금을 꼭 입력해 주세요. "
//                }
//            }
//
//            addMemberView.isHidden = false
//            // 멤버 수정일 경우만
//            deleteMemberButton.isHidden = isEditMember == true ? false : true
//        case .contentStartDate:
//            titleLabel.text = "시작 날짜를 선택해 주세요."
//            subTitleLabel.text = newContentViewModel?.getStartDateSubTitleDate()
//            startDateView.isHidden = false
//            deleteMemberButton.isHidden = true
//        case .contentDeadlineDate:
//            titleLabel.text = "마감 날짜를 선택해 주세요."
//            subTitleLabel.text = "마감 날짜는 시작 날짜 +1 일부터 오늘 날짜 -1 내에서 선택 가능합니다."
//            startDateView.isHidden = false
//            deleteMemberButton.isHidden = true
//        case .contentFine:
//            titleLabel.text = "벌금을 선택해 주세요."
//            subTitleLabel.text = "선택한 벌금을 기준으로 보증금이 계산 됩니다."
//            selectFineView.isHidden = false
//            deleteMemberButton.isHidden = true
//        case .contentMember:
//
//            switch newContentViewModel?.contentMemberState {
//            case .add:
//                titleLabel.text = "추가할 멤버의 정보를 입력해주세요."
//                subTitleLabel.text = "보증금은 설정한 벌금으로 추가됩니다."
//            case .update:
//                titleLabel.text = "수정 할 멤버의 정보를 입력해주세요."
//                subTitleLabel.text = "해당 멤버의 보증금이 다르다면 수정해주세요."
//            default:
//                print("")
//            }
//
//            addMemberView.isHidden = false
//            fineStackView.isHidden = false
//
//            deleteMemberButton.isHidden = isNewMember == true ? true : false
//        default:
//            print("")
//        }
//    }
//
//    func configDatePicker() {
//
//        // 새로 등록할때
//        // 수정할때
//        // 새로운 공지사항 만들때
//
//        if composeViewModel != nil {
//            let startDate = Date().getMondayAndSunDay().0
//            let endDate = Date().getMondayAndSunDay().1
//
//            if composeViewModel?.isNewStudy.value == true {
//                // 신규 스터디
//                startDatePicker.minimumDate = startDate
//                startDatePicker.maximumDate = endDate
//            } else {
//                // 기존 스터디
//                startDatePicker.maximumDate = endDate
//            }
//        } else {
//            if newContentViewModel?.editDateType == .startDate {
//
//            } else {
//
//            }
//        }
//    }
//
//    @IBAction func tapCloseButton(_ sender: Any) {
//        self.dismiss(animated: true)
//    }
//
//    @IBAction func tapDoneButton(_ sender: Any) {
//        switch option {
//        case .startDate:
//            let value = startDatePicker.date
//            composeViewModel?.updateStudyProperty(.startDate, value: value)
//            self.dismiss(animated: true)
//        case .selectDeadlineDay:
//            let index = dayButtons.firstIndex(where: {$0.isSelected == true}) ?? 0
//            let dateIndex = finishDateButtons.firstIndex(where: {$0.isSelected == true}) ?? 0
//
//            if isSameFinishDate {
//                composeViewModel?.updateStudyProperty(.setDay, value: (dayButtons[index].tag, finishDateButtons[dateIndex].tag))
//            } else {
//                composeViewModel?.updateStudyProperty(.setDay, value: (dayButtons[index].tag, 0))
//            }
//
//            self.dismiss(animated: true)
//        case .selectFine:
//            let index = fineButtons.firstIndex(where: {$0.isSelected == true}) ?? 0
//            composeViewModel?.updateStudyProperty(.fine, value: fineButtons[index].tag)
//            self.dismiss(animated: true)
//        case .studyMemeber:
//            if fineStackView.isHidden {
//                let name = self.memberNameTextField.text ?? ""
//                let blogURL = self.blogUrlTextField.text ?? ""
//                let fine = composeViewModel?.fine.value?.convertFineInt()
//
//                self.composeViewModel?.updateStudyProperty(.members, value: (name, blogURL, fine, editIndex))
//
//            } else {
//                let name = self.memberNameTextField.text ?? ""
//                let blogURL = self.blogUrlTextField.text ?? ""
//                let fine = Int(self.fineTextField.text ?? "") ?? 0
//
//                self.composeViewModel?.updateStudyProperty(.members, value: (name, blogURL, fine, editIndex))
//            }
//
//            self.dismiss(animated: true)
//        case .contentStartDate:
//
//            if newContentViewModel?.contents.count == 1 {
//                let targetDate = startDatePicker.date.makeStartDate()
//
//                let deadlineDate = (self.newContentViewModel?.deadlineDate.value ?? Date()).makeStartDate()
//
//                let dateCompare = targetDate?.dateCompare(fromDate: deadlineDate, editType: .startDate, compareType: .deadline)
//
//                switch dateCompare {
//                case .deadlinePast:
//                    self.newContentViewModel?.updateContentProperty(.startDate, value: targetDate)
//                    self.dismiss(animated: true)
//                case .deadlineFuture:
//                    makeAlertDialog(title: "시작일은 마감일보다 미래로 선택할 수 없습니다.", message: "", vcType: .ok)
//                case .deadlineSame:
//                    makeAlertDialog(title: "시작일은 마감일과 같은 날짜로 선택할 수 없습니다.", message: "", vcType: .ok)
//                default:
//                    print("BottomSheetViewController tapDoneButton Default")
//                }
//            } else {
//
//                // 선택한 날짜
//                let targetDate = startDatePicker.date.makeStartDate()
//
//                // 마감 날짜
//                let deadlineDate = (self.newContentViewModel?.deadlineDate.value ?? Date()).makeStartDate()
//
//                // 마지막 공지 마감 날짜
//                let contentDeadlineDate = (self.newContentViewModel?.contents[(self.newContentViewModel?.contents.count ?? 0) - 2].deadlineDate ?? Date()).makeStartDate()
//
//                let checkDeadlineDate = targetDate?.dateCompare(fromDate: deadlineDate, editType: .startDate, compareType: .deadline)
//                let checkContentDeadlineDate = targetDate?.dateCompare(fromDate: contentDeadlineDate, editType: .startDate, compareType: .contentLastDeadline)
//
//                // Alert 분기 처리
//                if checkDeadlineDate == .deadlinePast && checkContentDeadlineDate == .contentLastDateSame {  // 마감일 과거 / 마지막 마감 같음
//                    makeAlertDialog(title: "마지막 공지의 마감일과 같은 날짜 선택 불가", message: "", vcType: .ok)
//                } else if checkDeadlineDate == .deadlinePast && checkContentDeadlineDate == .contentLastDateFuture {  // 마감일 과거 / 마지막 마감 미래
//                    self.newContentViewModel?.updateContentProperty(.startDate, value: targetDate)
//                    self.dismiss(animated: true)
//                } else if checkDeadlineDate == .deadlineSame && checkContentDeadlineDate == .contentLastDateFuture { // 마감일 같음 / 마지막 마감 미래
//                    makeAlertDialog(title: "마감일과 같은 날짜 선택 불가", message: "", vcType: .ok)
//                } else if checkDeadlineDate == .deadlinePast && checkContentDeadlineDate == .contentLastDatePast { // 마감일 과거 / 마지막 마감 과거
//                    makeAlertDialog(title: "시작일은 마지막 공지의 마감일보다 과거로 선택 불가", message: "", vcType: .ok)
//                } else {  // 마감일 미래 / 마지막 마감 미래
//                    makeAlertDialog(title: "시작일은 마감일보다 미래로 선택 불가", message: "", vcType: .ok)
//                }
//            }
//        case .contentDeadlineDate:
//
//            // 시작일보다 더 이전 날짜면 경고
//            // 시작날짜와 같으면 안되고, 현재 날짜와 같거나 미래이면 안됨
//            let targetDate = startDatePicker.date.makeDeadlineDate()
//            let startDate = (self.newContentViewModel?.startDate.value ?? Date()).makeDeadlineDate()
//            let currentDate = Date().makeDeadlineDate()
//
//            let checkStartDate = targetDate?.dateCompare(fromDate: startDate, editType: .deadlineDate, compareType: .start)
//            let checkCurrentDate = targetDate?.dateCompare(fromDate: currentDate, editType: .deadlineDate, compareType: .currentDate)
//
//            // 시작일 과거 / 현재 날짜 과거
//            // 시작일 같음 / 현재 날짜 과거
//            // 시작일 미래 / 현재 날짜 과거
//            // 시작일 미래 / 현재 날짜 같음
//            // 시작일 미래 / 현재 날짜 미래
//            if checkStartDate == .startPast && checkCurrentDate == .currentDatePast {
//                makeAlertDialog(title: "마감일은 시작일보다 과거로 선택 불가", message: "", vcType: .ok)
//            } else if checkStartDate == .startSame && checkCurrentDate == .currentDatePast {
//                makeAlertDialog(title: "마감일은 시작일과 같은날로 선택 불가", message: "", vcType: .ok)
//            } else if checkStartDate == .startFuture && checkCurrentDate == .currentDatePast {
//                self.newContentViewModel?.updateContentProperty(.deadlineDate, value: targetDate)
//                self.dismiss(animated: true)
//            } else if checkStartDate == .startFuture && checkCurrentDate == .currentDateSame {
//                makeAlertDialog(title: "마감일은 오늘 날짜로 선택 불가", message: "", vcType: .ok)
//            } else {
//                makeAlertDialog(title: "마감일은 오늘 날짜보다 미래로 선택 불가", message: "", vcType: .ok)
//            }
//        case .contentFine:
//            let index = fineButtons.firstIndex(where: {$0.isSelected == true}) ?? 0
//            self.newContentViewModel?.updateContentProperty(.fine, value: fineButtons[index].tag)
//            self.dismiss(animated: true)
//        case .contentMember:
//            let name = self.memberNameTextField.text ?? ""
//            let blogURL = self.blogUrlTextField.text ?? ""
//            let fine = Int(self.fineTextField.text ?? "") ?? 0
//
//            if isNewMember {
//                self.newContentViewModel?.updateContentProperty(.addContentMember, value: (name, blogURL, fine))
//            } else {
//                self.newContentViewModel?.updateContentProperty(.updateContentMember, value: (name, blogURL, fine, editIndex))
//            }
//
//            self.dismiss(animated: true)
//        default:
//            return
//        }
//    }
//
//    @IBAction func tapDeleteMemberButton(_ sender: Any) {
//
//        switch option {
//        case .studyMemeber:
//            composeViewModel?.updateStudyProperty(.deleteMember, value: editIndex)
//        case .contentMember:
//            newContentViewModel?.updateContentProperty(.deleteContentMember, value: editIndex)
//        default:
//            print("")
//        }
//
//        DispatchQueue.main.async {
//            self.dismiss(animated: true)
//        }
//    }
//
//
//    @IBAction func tapSetDayButton(_ sender: Any) {
//        guard let selectButton = sender as? UIButton else { return }
//
//        dayButtons.forEach { button in
//            button.isSelected = button.tag == selectButton.tag ? true : false
//        }
//
//        if composeViewModel?.fetchFinishDate(day: selectButton.tag).1 == nil {
//
//            isSameFinishDate = false
//
//            currentDateButton.isHidden = true
//            nextWeekDateButton.isHidden = true
//            selectDateLabel.text = "\(composeViewModel?.currentDate ?? Date())"
//        } else {
//            isSameFinishDate = true
//
//            currentDateButton.isHidden = false
//            nextWeekDateButton.isHidden = false
//            currentDateButton.setTitle("\(composeViewModel?.currentDate ?? Date())", for: .normal)
//            nextWeekDateButton.setTitle("\(composeViewModel?.nextWeekDate ?? Date())", for: .normal)
//            selectDateLabel.text = "\(composeViewModel?.currentDate ?? Date())와 \(composeViewModel?.nextWeekDate ?? Date())중 하나를 선택해 주세요."
//        }
//    }
//
//    @IBAction func tapFinishDateButtons(_ sender: Any) {
//        guard let selectButton = sender as? UIButton else { return }
//
//        finishDateButtons.forEach { button in
//            button.isSelected = button.tag == selectButton.tag ? true : false
//        }
//    }
//
//
//    @IBAction func tapFineButton(_ sender: Any) {
//        guard let selectButton = sender as? UIButton else { return }
//
//        fineButtons.forEach { button in
//            button.isSelected = button.tag == selectButton.tag ? true : false
//        }
//    }
//}
