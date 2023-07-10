//
//  AddStudyViewController.swift
//  BlogApp
//
//  Created by PKW on 2023/02/27.
//

import UIKit
import CoreData
import SwiftUI

class AddStudyViewController: UIViewController, ViewModelBindableType {

    typealias ViewModelType = StudyComposeViewModel
    
    var viewModel: ViewModelType?

    var listViewModel: StudyListViewModel?
    var detailViewModel: StudyDetailViewModel?

    @IBOutlet var studyInfoTableView: UITableView!
    
    var isEdit = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let titleCellNib = UINib(nibName: "\(AddTitleTableViewCell.identifier)", bundle: nil)
        studyInfoTableView.register(titleCellNib, forCellReuseIdentifier: AddTitleTableViewCell.identifier)
        
        let typeCellNib = UINib(nibName: "\(AddStudyTypeTableViewCell.identifier)", bundle: nil)
        studyInfoTableView.register(typeCellNib, forCellReuseIdentifier: AddStudyTypeTableViewCell.identifier)
        
        let announcementCellNib = UINib(nibName: "\(AddAnnouncementTableViewCell.identifier)", bundle: nil)
        studyInfoTableView.register(announcementCellNib, forCellReuseIdentifier: AddAnnouncementTableViewCell.identifier)
        
        let commonSetInfoCellNib = UINib(nibName: "\(AddCommonSetInfoTableViewCell.identifier)", bundle: nil)
        studyInfoTableView.register(commonSetInfoCellNib, forCellReuseIdentifier: AddCommonSetInfoTableViewCell.identifier)
        
        let memberInfoCellNib = UINib(nibName: "\(AddMemberInfoTableViewCell.identifier)", bundle: nil)
        studyInfoTableView.register(memberInfoCellNib, forCellReuseIdentifier: AddMemberInfoTableViewCell.identifier)
        
        studyInfoTableView.keyboardDismissMode = .onDrag
        
        if !isEdit {
            viewModel = StudyComposeViewModel(studyData: nil)
        }
        
        bindViewModel()
    }
    
    
    
    func bindViewModel() {
        viewModel?.startDate.bind { [weak self] _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.studyInfoTableView.reloadSections(IndexSet(integer: 3), with: .none)
            }
        }
        
        viewModel?.finishDay.bind { [weak self] _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.studyInfoTableView.reloadSections(IndexSet(integer: 4), with: .none)
            }
        }
        
        viewModel?.fine.bind { [weak self] _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.studyInfoTableView.reloadSections(IndexSet(integer: 5), with: .none)
            }
        }
        
        viewModel?.coreDataMembers.bind { [weak self] _ in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.studyInfoTableView.reloadSections(IndexSet(integer: 6), with: .none)
                //self.studyInfoTableView.scrollToRow(at: IndexPath(row: (self.viewModel?.members.value.count ?? 0), section: 6), at: .bottom, animated: true)
            }
        }
    }
    
    @IBAction func tapCloseButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func tapDoneButton(_ sender: Any) {
        
        let checkPostData = viewModel?.validatePostInputData()
        
        if checkPostData == nil {
            if isEdit {
                viewModel?.updateDetailStudyData(detailViewModel: detailViewModel!, completion: {
                    DispatchQueue.main.async {
                        self.dismiss(animated: true)
                    }
                })
            } else {
                viewModel?.createStudy(completion: {
                    DispatchQueue.main.async {
                        self.dismiss(animated: true)
                    }
                })
            }
        } else {
            makeAlertDialog(title: checkPostData ?? "", message: "")
        }
    }
}

extension AddStudyViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0,1,2,3,4,5:
            return 1
        case 6:
            return 1 + (viewModel?.coreDataMembers.value.count ?? 0)
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AddStudyTypeTableViewCell.identifier, for: indexPath) as? AddStudyTypeTableViewCell else { return UITableViewCell() }
            cell.viewModel = viewModel
            cell.configButton(isEdit: isEdit)
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AddTitleTableViewCell.identifier, for: indexPath) as? AddTitleTableViewCell else { return UITableViewCell() }
            cell.viewModel = viewModel
            cell.configData()
            
            return cell
        case 2:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AddAnnouncementTableViewCell.identifier, for: indexPath) as? AddAnnouncementTableViewCell else { return UITableViewCell() }
            cell.viewModel = viewModel
            cell.delegate = self
            cell.configData()

            return cell
        case 3:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AddCommonSetInfoTableViewCell.identifier, for: indexPath) as? AddCommonSetInfoTableViewCell else { return UITableViewCell() }
            cell.viewModel = viewModel
            cell.configLayout(indexPath: indexPath)
            cell.configData(indexPath: indexPath)
            cell.delegate = self
            return cell
        case 4:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AddCommonSetInfoTableViewCell.identifier, for: indexPath) as? AddCommonSetInfoTableViewCell else { return UITableViewCell() }
            cell.viewModel = viewModel
            cell.configLayout(indexPath: indexPath)
            cell.configData(indexPath: indexPath)
            cell.delegate = self
            return cell
        case 5:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AddCommonSetInfoTableViewCell.identifier, for: indexPath) as? AddCommonSetInfoTableViewCell else { return UITableViewCell() }
            cell.viewModel = viewModel
            cell.configLayout(indexPath: indexPath)
            cell.configData(indexPath: indexPath)
            cell.delegate = self
            return cell
        case 6:
            switch indexPath.row {
            case 0:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: AddCommonSetInfoTableViewCell.identifier, for: indexPath) as? AddCommonSetInfoTableViewCell else { return UITableViewCell() }
                cell.viewModel = viewModel
                cell.configLayout(indexPath: indexPath)
                cell.delegate = self
                return cell
            default:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: AddMemberInfoTableViewCell.identifier, for: indexPath) as? AddMemberInfoTableViewCell else { return UITableViewCell() }
                cell.viewModel = viewModel
                cell.configData(indexPath: indexPath)
                
                return cell
            }
        default:
            return UITableViewCell()
        }
    }
}

extension AddStudyViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if indexPath.section == 6 && indexPath.row != 0 {
            let storyboard = UIStoryboard(name: "BottomSheetViewController", bundle: nil)
            guard let vc = storyboard.instantiateViewController(withIdentifier: "BottomSheetViewController") as? BottomSheetViewController else { return }
            
            vc.detailOption = DetailOption.addMemeber
            vc.viewModel = viewModel
            vc.isEditMember = true
            vc.editIndex = indexPath.row - 1
            
            vc.modalPresentationStyle = .overFullScreen
            
            self.present(vc, animated: false)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isEdit {
            if indexPath.section == 0 {
                return 0
            }
        }
        return UITableView.automaticDimension
    }
}

extension AddStudyViewController: AddAnnouncementTableViewCellDelegate {
    func updateHeightOfRow(_ cell: AddAnnouncementTableViewCell, _ textView: UITextView) {
        
        let size = textView.bounds.size
        let newSize = studyInfoTableView.sizeThatFits(CGSize(width: size.width, height: .greatestFiniteMagnitude))
        
        if size.height != newSize.height {
            UIView.setAnimationsEnabled(false)
            studyInfoTableView.beginUpdates()
            studyInfoTableView.endUpdates()
            UIView.setAnimationsEnabled(true)
            
            if let thisIndexPath = studyInfoTableView.indexPath(for: cell) {
                studyInfoTableView.scrollToRow(at: thisIndexPath, at: .bottom, animated: false)
            }
        }
    }
}

extension AddStudyViewController: AddCommonSetInfoTableViewCellDelegate {
    func showNextVC(option: DetailOption) {
        let storyboard = UIStoryboard(name: "BottomSheetViewController", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "BottomSheetViewController") as? BottomSheetViewController else { return }
        
        vc.detailOption = option
        vc.viewModel = viewModel
        vc.isEditMember = false
        
        vc.modalPresentationStyle = .overFullScreen
        
        self.present(vc, animated: false)
    }
}
