//
//  AddStudyViewController.swift
//  BlogApp
//
//  Created by PKW on 2023/05/01.
//

import UIKit
import CoreData
import SafariServices

class AddStudyViewController: UIViewController, ViewModelBindableType {
    
    typealias ViewModelType = StudyComposeViewModel

    var viewModel: ViewModelType?
    
    @IBOutlet weak var addStudyScrollView: UIScrollView!
    
    @IBOutlet weak var addStudyMainTitleLabel1: UILabel!
    @IBOutlet weak var addStudyMainTitleLabel2: UILabel!
    
    @IBOutlet weak var progressInfoBaseView: UIView!
    @IBOutlet weak var progressSubTitleLabel: UILabel!
    @IBOutlet weak var progressButtonStackView: UIStackView!
    @IBOutlet weak var newStudyButton: UIButton!
    @IBOutlet weak var progressStudyButton: UIButton!
    @IBOutlet weak var lastProgressNumberStackView: UIStackView!
    @IBOutlet weak var lastProgressNumberTextField: UITextField!
    @IBOutlet weak var lastProgressDeadlineDateBaseView: UIView!
    @IBOutlet weak var lastProgressDeadlineDateLabel: UILabel!
    @IBOutlet weak var lastProgressDeadlineDateEditButton: UIButton!
    
    @IBOutlet weak var nameInfoBaseView: UIView!
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var firstStartDateInfoBaseView: UIView!
    @IBOutlet weak var firstStartDateTitleLabel: UILabel!
    @IBOutlet weak var firstStartDateLabel: UILabel!
    @IBOutlet weak var firstStartDateEditButton: UIButton!
    
    @IBOutlet weak var deadlineInfoBaseView: UIView!
    @IBOutlet weak var deadlineDayLabel: UILabel!
    @IBOutlet weak var deadlineDaySubLabel: UILabel!
    @IBOutlet weak var deadlineEditButton: UIButton!
    
    @IBOutlet weak var fineInfoBaseView: UIView!
    @IBOutlet weak var fineLabel: UILabel!
    @IBOutlet weak var fineEditButton: UIButton!
    
    @IBOutlet weak var memberCountLabel: UILabel!
    @IBOutlet weak var addMemberButton: UIButton!
    
    @IBOutlet weak var editMemberInfoStackView: UIStackView!
    
    var isKeyboardActive: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 네비게이션바 그림자 제거
        self.navigationController?.navigationBar.standardAppearance.shadowColor = .clear
        
        addStudyScrollView.keyboardDismissMode = .onDrag
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false // 스크롤뷰의 다른 동작에 방해되지 않게 설정
        addStudyScrollView.addGestureRecognizer(tap) // scrollView는 당신의 UIScrollView 인스턴스를 가리킵니다.
        
        bindViewModel()
        configLayout()
        configData()
    }
    
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
                memberCountLabel.text = "현재 \(viewModel?.studyMembers.value.count ?? 0)명이 참여중이에요."
            case .edit:
                updateMemberInfoViewInStackView(index: viewModel?.editIndex ?? 0)
            case .delete:
                deleteMemberInfoViewInStackView(index: viewModel?.editIndex ?? 0)
                memberCountLabel.text = "현재 \(viewModel?.studyMembers.value.count ?? 0)명이 참여중이에요."
            default:
                print("")
            }
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func tapCloseButton(_ sender: Any) {
        
        makeAlertDialog(title: nil, message: "스터디 정보 변경을 취소하시겠습니까?", type: .closeComposeVC)
    }
    
    @IBAction func tapDoneButton(_ sender: Any) {

        if let checkData = viewModel?.validateStudyData() {
            makeAlertDialog(title: nil, message: checkData, type: .ok)
        } else {
            if viewModel?.isEditStudy == true {
                viewModel?.updateStudyData {
                    DispatchQueue.main.async {
                        self.dismiss(animated: true)
                    }
                }
            } else {
                viewModel?.createStudyData {
                    DispatchQueue.main.async {
                        self.dismiss(animated: true)
                    }
                }
            }
        }
    }
    
    @IBAction func tapNewStudyButton(_ sender: Any) {
        // 뷰모델 프로퍼티 업데이트
        viewModel?.updateStudyProperty(.newStudy, value: true)
        viewModel?.updateStudyProperty(.lastStudyCount, value: nil as Any?)
        viewModel?.updateStudyProperty(.lastProgressDeadlineDate, value: nil as Any?)
    }
    
    @IBAction func tapProgressStudyButton(_ sender: Any) {
        // 뷰모델 프로퍼티 업데이트
        viewModel?.updateStudyProperty(.newStudy, value: false)
    }
    
    @IBAction func taplastProgressDeadlineDateButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "BottomSheetViewController", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "BottomSheetViewController") as? BottomSheetViewController else { return }
        
        vc.option = .lastProgressDeadlineDate
        vc.composeViewModel = viewModel
    
        vc.modalPresentationStyle = .overFullScreen
        
        self.present(vc, animated: false)
    }
    
    @IBAction func tapFirstStartDateButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "BottomSheetViewController", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "BottomSheetViewController") as? BottomSheetViewController else { return }
        
        vc.option = .firstStartDate
        vc.composeViewModel = viewModel
    
        vc.modalPresentationStyle = .overFullScreen
        
        self.present(vc, animated: false)
    }
    
    @IBAction func tapDeadlineDateButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "BottomSheetViewController", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "BottomSheetViewController") as? BottomSheetViewController else { return }
        
        vc.option = .deadlineDay
        vc.composeViewModel = viewModel
        
        vc.modalPresentationStyle = .overFullScreen
        
        self.present(vc, animated: false)
    }
    
    @IBAction func tapFineButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "BottomSheetViewController", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "BottomSheetViewController") as? BottomSheetViewController else { return }
        
        vc.option = .fine
        vc.composeViewModel = viewModel
        
        vc.modalPresentationStyle = .overFullScreen
        
        self.present(vc, animated: false)
    }
    
    @IBAction func tapAddMemberButton(_ sender: Any) {
        
        if viewModel?.fine.value == nil {
            makeAlertDialog(title: nil, message: "벌금이 선택되지 않았습니다.", type: .ok)
        } else {
            let storyboard = UIStoryboard(name: "BottomSheetViewController", bundle: nil)
            guard let vc = storyboard.instantiateViewController(withIdentifier: "BottomSheetViewController") as? BottomSheetViewController else { return }
            
            vc.option = .addStudyMemeber
            vc.composeViewModel = viewModel
            
            vc.modalPresentationStyle = .overFullScreen
            
            self.present(vc, animated: false)
        }
    }
    
    
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
    
    func configData() {
        // 수정 상태인지 생성 상태인지 분기
        
        if viewModel?.isEditStudy == true {
            // 수정
            
            // 메인 타이틀
            addStudyMainTitleLabel1.text = "스터디 정보를 수정하기 위해서"
            addStudyMainTitleLabel2.text = "아래 정보들을 변경해 주세요!"
            
            // 진행 여부
            progressInfoBaseView.isHidden = true
            
            nameTextField.text = viewModel?.title.value ?? ""
            
            firstStartDateInfoBaseView.isHidden = true
            
            deadlineDayLabel.text = viewModel?.deadlineDay.value?.convertDeadlineDayToString()
            deadlineDaySubLabel.text = viewModel?.lastContentDeadlineDate.value?.toString()
            
            fineLabel.text = "\(viewModel?.fine.value?.insertComma() ?? "")원"//viewModel?.fine.value?.convertFineStr()
            
            memberCountLabel.text = "현재 \(viewModel?.studyMembers.value.count ?? 0)명이 참여중이에요."
            
            insertMemberInfoViewsInStackView()
        
        } else {
            // 메인 타이틀
            addStudyMainTitleLabel1.text = "새로운 스터디를 등록하기 위해서"
            addStudyMainTitleLabel2.text = "아래 정보들을 입력해 주세요!"
            
            // 생성
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
    
    @objc func lastProgressCountTextFieldDidChange(_ sender: Any?) {
        // 1초 뒤에 업데이트하도록?
        guard let textField = sender as? UITextField else { return }
        
        // 업데이트 메소드로 변경
        viewModel?.lastProgressNumber.value = textField.text == "" ? nil :  Int(textField.text ?? "0")
    }
    
    @objc func nameTextFieldDidChange(_ sender: Any?) {
        // 1초 뒤에 업데이트하도록?
        guard let textField = sender as? UITextField else { return }
        
        // 업데이트 메소드로 변경
        viewModel?.title.value = textField.text == "" ? nil : textField.text
    }
    
    func insertMemberInfoViewsInStackView() {
        viewModel?.studyMembers.value.forEach({ member in
            let memberInfoView = EditMemberInfoView()
            memberInfoView.nameLabel.text = member.name ?? ""
            
            if member.fine < viewModel?.fine.value ?? 0 {
                memberInfoView.fineSubTitle.text = "보증금이 부족해요! (현재 \(Int(member.fine).insertComma())원)"
            } else {
                memberInfoView.fineSubTitle.text = "\(Int(member.fine).insertComma())원"
            }
            
            memberInfoView.blogSubTitle.text = member.blogUrl ?? ""
            memberInfoView.editButton.addTarget(self, action: #selector(tapEditMemberInfoButton( _:)), for: .touchUpInside)
            editMemberInfoStackView.addArrangedSubview(memberInfoView)
        })
        
        updateMemberInfoViewInEditButtonTag()
    }
    
    // 멤버 정보 뷰 추가
    func insertMemberInfoViewInStackView(index: Int) {
        
        let memberInfoView = EditMemberInfoView()
        memberInfoView.nameLabel.text = viewModel?.studyMembers.value[index].name ?? ""
        
        if viewModel?.studyMembers.value[index].fine ?? 0 < viewModel?.fine.value ?? 0 {
            memberInfoView.fineSubTitle.text = "보증금이 부족해요! (현재 \(Int(viewModel?.studyMembers.value[index].fine ?? 0).insertComma())원)"
        } else {
            memberInfoView.fineSubTitle.text = "\(Int(viewModel?.studyMembers.value[index].fine ?? 0).insertComma())원"
        }
        
        memberInfoView.fineSubTitle.text = "\(Int(viewModel?.studyMembers.value[index].fine ?? 0).insertComma())원"
        memberInfoView.blogSubTitle.text = viewModel?.studyMembers.value[index].blogUrl ?? ""
        memberInfoView.editButton.addTarget(self, action: #selector(tapEditMemberInfoButton( _:)), for: .touchUpInside)
        editMemberInfoStackView.insertArrangedSubview(memberInfoView, at: 0)
        
        updateMemberInfoViewInEditButtonTag()
    }
    
    func updateMemberInfoViewInStackView(index: Int) {
        if let memberInfoView = editMemberInfoStackView.arrangedSubviews[index] as? EditMemberInfoView {
            memberInfoView.nameLabel.text = viewModel?.studyMembers.value[index].name ?? ""
            
            if viewModel?.studyMembers.value[index].fine ?? 0 < viewModel?.fine.value ?? 0 {
                memberInfoView.fineSubTitle.text = "보증금이 부족해요! (현재 \(Int(viewModel?.studyMembers.value[index].fine ?? 0).insertComma())원)"
            } else {
                memberInfoView.fineSubTitle.text = "\(Int(viewModel?.studyMembers.value[index].fine ?? 0).insertComma())원"
            }
            memberInfoView.blogSubTitle.text = viewModel?.studyMembers.value[index].blogUrl ?? ""
        }
    }
    
    func deleteMemberInfoViewInStackView(index: Int) {
        if let memberInfoView = editMemberInfoStackView.arrangedSubviews[index] as? EditMemberInfoView {
            editMemberInfoStackView.removeArrangedSubview(memberInfoView)
            memberInfoView.removeFromSuperview()
            
            updateMemberInfoViewInEditButtonTag()
        }
    }
    
    // 멤버 정보뷰에 수정 버튼 태그 업데이트하기
    func updateMemberInfoViewInEditButtonTag() {
        for (index, view) in editMemberInfoStackView.arrangedSubviews.enumerated() {
            if let memberInfoView = view as? EditMemberInfoView {
                memberInfoView.editButton.tag = index
            }
        }
    }
    
    @objc func tapEditMemberInfoButton(_ sender: UIButton) {
        
        let storyboard = UIStoryboard(name: "BottomSheetViewController", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "BottomSheetViewController") as? BottomSheetViewController else { return }
        
        vc.option = .editStudyMember
        vc.index = sender.tag
        vc.composeViewModel = viewModel
        
        vc.modalPresentationStyle = .overFullScreen
        
        self.present(vc, animated: false)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
}



//class AddStudyViewController: UIViewController, ViewModelBindableType {
//
//    typealias ViewModelType = StudyComposeViewModel
//
//    var viewModel: ViewModelType?
//
//    @IBOutlet var studyInfoTableView: UITableView!
//
//    var isEditStudy = false
//
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        let titleCellNib = UINib(nibName: "\(AddTitleTableViewCell.identifier)", bundle: nil)
//        studyInfoTableView.register(titleCellNib, forCellReuseIdentifier: AddTitleTableViewCell.identifier)
//
//        let typeCellNib = UINib(nibName: "\(AddStudyTypeTableViewCell.identifier)", bundle: nil)
//        studyInfoTableView.register(typeCellNib, forCellReuseIdentifier: AddStudyTypeTableViewCell.identifier)
//
//        let announcementCellNib = UINib(nibName: "\(AddAnnouncementTableViewCell.identifier)", bundle: nil)
//        studyInfoTableView.register(announcementCellNib, forCellReuseIdentifier: AddAnnouncementTableViewCell.identifier)
//
//        let commonSetInfoCellNib = UINib(nibName: "\(AddCommonSetInfoTableViewCell.identifier)", bundle: nil)
//        studyInfoTableView.register(commonSetInfoCellNib, forCellReuseIdentifier: AddCommonSetInfoTableViewCell.identifier)
//
//        let memberInfoCellNib = UINib(nibName: "\(AddMemberInfoTableViewCell.identifier)", bundle: nil)
//        studyInfoTableView.register(memberInfoCellNib, forCellReuseIdentifier: AddMemberInfoTableViewCell.identifier)
//
//        studyInfoTableView.keyboardDismissMode = .onDrag
//
//        if !isEditStudy {
//            viewModel = StudyComposeViewModel(studyData: nil)
//        }
//
//        bindViewModel()
//    }
//
//
//
//    func bindViewModel() {
//        viewModel?.startDate.bind { [weak self] _ in
//            guard let self = self else { return }
//            DispatchQueue.main.async {
//                self.studyInfoTableView.reloadSections(IndexSet(integer: 3), with: .none)
//            }
//        }
//
//        viewModel?.finishDay.bind { [weak self] _ in
//            guard let self = self else { return }
//            DispatchQueue.main.async {
//                self.studyInfoTableView.reloadSections(IndexSet(integer: 4), with: .none)
//            }
//        }
//
//        viewModel?.fine.bind { [weak self] _ in
//            guard let self = self else { return }
//            DispatchQueue.main.async {
//                self.studyInfoTableView.reloadSections(IndexSet(integer: 5), with: .none)
//            }
//        }
//
//        viewModel?.studyMembers.bind { [weak self] _ in
//            guard let self = self else { return }
//
//            DispatchQueue.main.async {
//                self.studyInfoTableView.reloadSections(IndexSet(integer: 6), with: .none)
//                //self.studyInfoTableView.scrollToRow(at: IndexPath(row: (self.viewModel?.members.value.count ?? 0), section: 6), at: .bottom, animated: true)
//            }
//        }
//    }
//
//    @IBAction func tapCloseButton(_ sender: Any) {
//        self.dismiss(animated: true)
//    }
//
//    @IBAction func tapDoneButton(_ sender: Any) {
//
//        if isEditStudy {
//            viewModel?.updateStudyData {
//                DispatchQueue.main.async {
//                    self.dismiss(animated: true)
//                }
//            }
//        } else {
//            viewModel?.createStudyData {
//                DispatchQueue.main.async {
//                    self.dismiss(animated: true)
//                }
//            }
//        }
//
//
//
////        let checkPostData = viewModel?.validatePostInputData()
////
////        if checkPostData == nil {
////            if isEdit {
////                viewModel?.updateDetailStudyData(detailViewModel: detailViewModel!, completion: {
////
////                    DispatchQueue.main.async {
////                        self.dismiss(animated: true)
////                    }
////                })
////            } else {
////                viewModel?.createStudy(completion: {
////                    DispatchQueue.main.async {
////                        self.dismiss(animated: true)
////                    }
////                })
////            }
////        } else {
////            makeAlertDialog(title: checkPostData ?? "", message: "")
////        }
//    }
//}
//
//extension AddStudyViewController: UITableViewDataSource {
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 7
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        switch section {
//        case 0,1,2,3,4,5:
//            return 1
//        case 6:
//            return 1 + (viewModel?.studyMembers.value.count ?? 0)
//        default:
//            return 0
//        }
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        switch indexPath.section {
//        case 0:
//            guard let cell = tableView.dequeueReusableCell(withIdentifier: AddStudyTypeTableViewCell.identifier, for: indexPath) as? AddStudyTypeTableViewCell else { return UITableViewCell() }
//            cell.viewModel = viewModel
//            cell.configButton(isEdit: isEditStudy)
//            return cell
//        case 1:
//            guard let cell = tableView.dequeueReusableCell(withIdentifier: AddTitleTableViewCell.identifier, for: indexPath) as? AddTitleTableViewCell else { return UITableViewCell() }
//            cell.viewModel = viewModel
//            cell.configData()
//
//            return cell
//        case 2:
//            guard let cell = tableView.dequeueReusableCell(withIdentifier: AddAnnouncementTableViewCell.identifier, for: indexPath) as? AddAnnouncementTableViewCell else { return UITableViewCell() }
//            cell.viewModel = viewModel
//            cell.delegate = self
//            cell.configData()
//
//            return cell
//        case 3:
//            guard let cell = tableView.dequeueReusableCell(withIdentifier: AddCommonSetInfoTableViewCell.identifier, for: indexPath) as? AddCommonSetInfoTableViewCell else { return UITableViewCell() }
//            cell.viewModel = viewModel
//            cell.configLayout(indexPath: indexPath)
//            cell.configData(indexPath: indexPath)
//            cell.delegate = self
//            return cell
//        case 4:
//            guard let cell = tableView.dequeueReusableCell(withIdentifier: AddCommonSetInfoTableViewCell.identifier, for: indexPath) as? AddCommonSetInfoTableViewCell else { return UITableViewCell() }
//            cell.viewModel = viewModel
//            cell.configLayout(indexPath: indexPath)
//            cell.configData(indexPath: indexPath)
//            cell.delegate = self
//            return cell
//        case 5:
//            guard let cell = tableView.dequeueReusableCell(withIdentifier: AddCommonSetInfoTableViewCell.identifier, for: indexPath) as? AddCommonSetInfoTableViewCell else { return UITableViewCell() }
//            cell.viewModel = viewModel
//            cell.configLayout(indexPath: indexPath)
//            cell.configData(indexPath: indexPath)
//            cell.delegate = self
//            return cell
//        case 6:
//            switch indexPath.row {
//            case 0:
//                guard let cell = tableView.dequeueReusableCell(withIdentifier: AddCommonSetInfoTableViewCell.identifier, for: indexPath) as? AddCommonSetInfoTableViewCell else { return UITableViewCell() }
//                cell.viewModel = viewModel
//                cell.configLayout(indexPath: indexPath)
//                cell.delegate = self
//                return cell
//            default:
//                guard let cell = tableView.dequeueReusableCell(withIdentifier: AddMemberInfoTableViewCell.identifier, for: indexPath) as? AddMemberInfoTableViewCell else { return UITableViewCell() }
//                cell.viewModel = viewModel
//                cell.configData(indexPath: indexPath)
//                cell.delegate = self
//
//                return cell
//            }
//        default:
//            return UITableViewCell()
//        }
//    }
//}
//
//extension AddStudyViewController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//        print("123123")
//        if indexPath.section == 6 && indexPath.row != 0 {
//            let storyboard = UIStoryboard(name: "BottomSheetViewController", bundle: nil)
//            guard let vc = storyboard.instantiateViewController(withIdentifier: "BottomSheetViewController") as? BottomSheetViewController else { return }
//
//            vc.option = StudyOptionType.studyMemeber
//            vc.composeViewModel = viewModel
//            vc.isEditMember = true
//            vc.editIndex = indexPath.row - 1
//
//            vc.modalPresentationStyle = .overFullScreen
//
//            self.present(vc, animated: false)
//        }
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if isEditStudy {
//            if indexPath.section == 0 {
//                return 0
//            }
//        }
//        return UITableView.automaticDimension
//    }
//}
//
//extension AddStudyViewController: AddAnnouncementTableViewCellDelegate {
//    func updateHeightOfRow(_ cell: AddAnnouncementTableViewCell, _ textView: UITextView) {
//
//        let size = textView.bounds.size
//        let newSize = studyInfoTableView.sizeThatFits(CGSize(width: size.width, height: .greatestFiniteMagnitude))
//
//        if size.height != newSize.height {
//            UIView.setAnimationsEnabled(false)
//            studyInfoTableView.beginUpdates()
//            studyInfoTableView.endUpdates()
//            UIView.setAnimationsEnabled(true)
//
//            if let thisIndexPath = studyInfoTableView.indexPath(for: cell) {
//                studyInfoTableView.scrollToRow(at: thisIndexPath, at: .bottom, animated: false)
//            }
//        }
//    }
//}
//
//extension AddStudyViewController: AddCommonSetInfoTableViewCellDelegate {
//
//    // 멤버 추가 버튼으로 호출
//    func showNextVC(option: StudyOptionType) {
//
//        // 옵션이 .addMemeber이고 벌금을 설정하지 않았을 경우
//        if option == .studyMemeber && viewModel?.fine.value == nil {
//            makeAlertDialog(title: "벌금을 설정해주세요.", message: "", vcType: .ok)
//        } else {
//            let storyboard = UIStoryboard(name: "BottomSheetViewController", bundle: nil)
//            guard let vc = storyboard.instantiateViewController(withIdentifier: "BottomSheetViewController") as? BottomSheetViewController else { return }
//
//            vc.option = option
//            vc.composeViewModel = viewModel
//
//            vc.isEditStudy = isEditStudy
//            vc.isNewMember = true
//            vc.isEditMember = false
//
//            vc.modalPresentationStyle = .overFullScreen
//
//            self.present(vc, animated: false)
//        }
//    }
//}
//
//extension AddStudyViewController: AddMemberInfoTableViewCellDelegate {
//
//    // 수정 버튼으로 호출
//    func showEditMemberVC(index: Int) {
//        let storyboard = UIStoryboard(name: "BottomSheetViewController", bundle: nil)
//        guard let vc = storyboard.instantiateViewController(withIdentifier: "BottomSheetViewController") as? BottomSheetViewController else { return }
//
//        vc.option = StudyOptionType.studyMemeber
//        vc.composeViewModel = viewModel
//
//        vc.editIndex = index
//
//        vc.isEditStudy = isEditStudy
//        vc.isNewMember = false
//        vc.isEditMember = true
//
//
//        vc.modalPresentationStyle = .overFullScreen
//
//        self.present(vc, animated: false)
//    }
//
//    func showBlogWebView(url: String) {
//        guard let url = URL(string: url) else {
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
