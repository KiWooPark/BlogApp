//
//  BottomSheetViewController.swift
//  BlogApp
//
//  Created by PKW on 2023/05/25.
//

import UIKit

enum DetailOption {
    case startDate
    case selectDay
    case selectFine
    case addMemeber
}

class BottomSheetViewController: UIViewController {
    
    @IBOutlet weak var baseView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    @IBOutlet weak var baseStackView: UIStackView!
    
    @IBOutlet weak var startDateView: UIView!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    
    // tag = 101 시작
    @IBOutlet weak var selectDayView: UIView!
    @IBOutlet var dayButtons: [UIButton]!
    
    // tag = 201 시작
    @IBOutlet weak var selectFineView: UIView!
    @IBOutlet var fineButtons: [UIButton]!
    
    @IBOutlet weak var addMemberView: UIView!
    @IBOutlet weak var memberNameTextField: UITextField!
    @IBOutlet weak var blogUrlTextField: UITextField!
    @IBOutlet weak var fineTextField: UITextField!
    
    @IBOutlet weak var fineStackView: UIStackView!
    
    @IBOutlet weak var doneButton: UIButton!
    
    var detailOption: DetailOption?
    var viewModel: StudyComposeViewModel?
    
    var isEditMember: Bool = false
    var editIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configLayout()
        configData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 키보드 노티 등록
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardUp), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDown), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 키보드 노티 삭제
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardUp(notification: NSNotification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            
            UIView.animate(withDuration: 0.3) {
                self.baseView.transform = CGAffineTransform(translationX: 0, y: -keyboardRectangle.height)
            }
        }
    }
    
    @objc func keyboardDown(notification: NSNotification) {
        self.baseView.transform = .identity
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.baseView.endEditing(true)
    }
    
    func configData() {
        if isEditMember {
            let target = viewModel?.coreDataMembers.value[editIndex]
            memberNameTextField.text = target?.name ?? ""
            blogUrlTextField.text = target?.blogUrl ?? ""
            fineTextField.text = "\(target?.fine ?? 0)"
        }
    }
    
    func configLayout() {
        switch detailOption {
        case .startDate:
            titleLabel.text = "시작 날짜를 선택해 주세요."
            startDateView.isHidden = false
        case .selectDay:
            titleLabel.text = "마감 요일을 선택해 주세요."
            selectDayView.isHidden = false
        case .selectFine:
            titleLabel.text = "벌금을 선택해 주세요."
            selectFineView.isHidden = false
        case .addMemeber:
            titleLabel.text = "추가할 멤버의 정보를 입력해주세요."
            addMemberView.isHidden = false
            fineStackView.isHidden = isEditMember == true || viewModel?.isNewStudy.value == false ? false : true
        default:
            print("")
        }
    }

    @IBAction func tapCloseButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func tapDoneButton(_ sender: Any) {
        switch detailOption {
        case .startDate:
            let value = startDatePicker.date
            viewModel?.updateStudyProperty(.startDate, value: value)
        case .selectDay:
            let index = dayButtons.firstIndex(where: {$0.isSelected == true}) ?? 0
            viewModel?.updateStudyProperty(.setDay, value: dayButtons[index].tag)
        case .selectFine:
            let index = fineButtons.firstIndex(where: {$0.isSelected == true}) ?? 0
            viewModel?.updateStudyProperty(.fine, value: fineButtons[index].tag)
        case .addMemeber:
            // 셀 눌러서 수정
            if isEditMember {
                let name = memberNameTextField.text ?? ""
                let blogUrl = blogUrlTextField.text ?? ""
                let fine = Int(fineTextField.text ?? "")
                
                viewModel?.updateStudyProperty(.members, value: (editIndex, name, blogUrl, fine), isEditMember: true)
                
            } else { // 추가버튼 눌러서 추가
                if viewModel?.isNewStudy.value == true { // 신규 추가
                    let name = memberNameTextField.text ?? ""
                    let blogUrl = blogUrlTextField.text ?? ""
                    let fine = viewModel?.fine.value?.convertFineInt() ?? 0
                    
                    viewModel?.updateStudyProperty(.members, value: (name, blogUrl, fine))
                    
                } else { // 기존 추가
                    let name = memberNameTextField.text ?? ""
                    let blogUrl = blogUrlTextField.text ?? ""
                    let fine = Int(fineTextField.text ?? "")
                    
                    viewModel?.updateStudyProperty(.members, value: (name, blogUrl, fine))
                }
            }
            
            
//            if isEditMember {
//                print("111")
//                let name = memberNameTextField.text ?? ""
//                let blogUrl = blogUrlTextField.text ?? ""
//                let fine = viewModel?.fine.value?.convertFineInt()
//
//                viewModel?.updateStudyProperty(.members, value: (name, blogUrl, fine))
//            } else {
//                print("222")
//                let name = memberNameTextField.text ?? ""
//                let blogUrl = blogUrlTextField.text ?? ""
//                let fine = fineTextField.text ?? ""
//
//                viewModel?.updateStudyProperty(.members, value: (name, blogUrl, fine), isAddMember: false)
//            }
        default:
            return
        }
       
        self.dismiss(animated: true)
    }
    
    @IBAction func tapSetDayButton(_ sender: Any) {
        guard let selectButton = sender as? UIButton else { return }
        
        dayButtons.forEach { button in
            button.isSelected = button.tag == selectButton.tag ? true : false
        }
    }
    
    @IBAction func tapFineButton(_ sender: Any) {
        guard let selectButton = sender as? UIButton else { return }
        
        fineButtons.forEach { button in
            button.isSelected = button.tag == selectButton.tag ? true : false
        }
    }
}
