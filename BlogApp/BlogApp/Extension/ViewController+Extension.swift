//
//  ViewController+Extension.swift
//  BlogApp
//
//  Created by PKW on 2023/07/10.
//

import Foundation
import UIKit

// MARK: ===== [Extention] =====
extension UIViewController {
    
    // MARK: ===== [Enum] =====
    /// Alert의 유형을 나타내는 열거형 입니다.
    enum AlertType {
        // 현재 스터디를 마감할 때 사용
        case addContent
        // 스터디 정보VC에서 부가 기능에 사용
        case deatileVC
        // 확인 버튼만 사용
        case ok
        // 네트워크 연결 실패에 사용
        case notConnected
        // 스터디를 삭제할때 사용
        case deleteStudy
        // 스터디 정보 수정을 취소할 때 사용
        case closeComposeVC
        // 참여중인 멤버를 삭제할때 사용
        case deleteMember
        
        /// 네트워크가 연결되지 않았을때의 유형을 나타내는 열거형 입니다.
        enum notConnetedType {
            // 참여중인 멤버 정보를 불러오는 경우
            case fetchMember
            // 새로운 멤버를 등록하는 경우
            case addMember
            // 멤버 정보를 수정하는 경우
            case editMember
            // 시작 날짜를 변경한 경우
            case startDate
            // 마감 날짜를 변경한 경우
            case deadlineDate
            // none
            case none
        }
    }
    
    /// 각 VC마다 사용할 Alert를 생성합니다.
    ///
    /// - Parameters:
    ///   - title: `Alert` 타이틀
    ///   - message: `Alert` 메시지
    ///   - type: `Alert` 유형
    ///   - connectedType: 네트워크 연결 실패시 사용할 유형, 기본값은 `.none`
    ///   - style: `Alert` 스타일, 기본값은 `alert`
    func makeAlertDialog(title: String?, message: String?, type: AlertType, connectedType: AlertType.notConnetedType = .none,  style: UIAlertController.Style = .alert) {
        
        // alert은 공용
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
       
        // 배경색 변경하기
        if let firstSubview = alert.view.subviews.first, let alertContentView = firstSubview.subviews.first {
            for view in alertContentView.subviews {
                view.backgroundColor = .cellColor
            }
        }
        
        switch type {
            
        // 마감날짜가 지난 스터디를 마감처리할 때
        case .addContent:
            let ok = UIAlertAction(title: "마감하기", style: .default) { _ in
                let storyboard = UIStoryboard(name: "AddContentViewController", bundle: nil)
                guard let vc = storyboard.instantiateViewController(identifier: "addContentVC") as? AddContentViewController else { return }
                guard let currentVC = self as? DetailStudyViewController else { return }
                
                vc.viewModel = NewContentViewModel(studyEntity: currentVC.viewModel?.study.value)
                vc.modalPresentationStyle = .fullScreen
                
                currentVC.present(vc, animated: true)
            }
            alert.addAction(ok)
            ok.setTextColor(type: .ok)
            
            self.present(alert, animated: true)
            
        // 스터디 정보의 마감 내역을 보거나, 수정 및 삭제할 때
        case .deatileVC:
            let edit = UIAlertAction(title: "수정", style: .default) { _ in
                
                let storyboard = UIStoryboard(name: "AddStudyViewController", bundle: nil)
                
                guard let nvc = storyboard.instantiateViewController(withIdentifier: "composeNVC") as? UINavigationController,
                      let addStudyVC = nvc.viewControllers[0] as? AddStudyViewController,
                      let currentVC = self as? DetailStudyViewController else { return }
                
                addStudyVC.viewModel = StudyComposeViewModel(studyData: currentVC.viewModel?.study.value)
                addStudyVC.viewModel?.isEditStudy = true
                
                            
                let navigationVC = UINavigationController(rootViewController: addStudyVC)
                navigationVC.modalPresentationStyle = .fullScreen
                            
                currentVC.present(navigationVC, animated: true)
            }
            
            let history = UIAlertAction(title: "마감 내역 보기", style: .default) { _ in
                let storyboard = UIStoryboard(name: "ShareContentViewController", bundle: nil)
                guard let nvc = storyboard.instantiateViewController(withIdentifier: "ShareContentNVC") as? UINavigationController,
                      let vc = nvc.viewControllers[0] as? ShareContentViewController,
                      let currentVC = self as? DetailStudyViewController else { return }
                
                vc.viewModel = ShareContentViewModel(study: currentVC.viewModel?.study.value)
                
                let navigationVC = UINavigationController(rootViewController: vc)
                navigationVC.modalPresentationStyle = .fullScreen
                self.present(navigationVC, animated: true)
            }
            
            let delete = UIAlertAction(title: "삭제", style: .destructive) { _ in
                self.makeAlertDialog(title: nil, message: "정말 삭제하시겠습니까?", type: .deleteStudy)
            }

            let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            
            edit.setTextColor(type: .edit)
            history.setTextColor(type: .history)
            delete.setTextColor(type: .delete)
            cancel.setTextColor(type: .cancel)
    
            alert.addAction(edit)
            alert.addAction(history)
            alert.addAction(delete)
            alert.addAction(cancel)
            
            self.present(alert, animated: true)
            
        // ok 버튼만 사용할 때
        case .ok:
            let ok = UIAlertAction(title: "확인", style: .default)
            alert.addAction(ok)

            ok.setTextColor(type: .ok)
            
            self.present(alert, animated: true)
            
        // 네트워크가 연결되지 않았을 때
        case .notConnected:
            let ok = UIAlertAction(title: "확인", style: .default) { _ in
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    
                    if NetworkCheckManager.shared.isConnected {
                        guard let currentVC = self as? AddContentViewController else { return }
                        
                        currentVC.viewModel?.fetchBlogPosts {
                            
                            switch connectedType {
                            case .fetchMember:
                                DispatchQueue.main.async {
                                    currentVC.insertMemberViewsInStackView()
                                    LoadingIndicator.hideLoading()
                                }
                            case .addMember:
                                DispatchQueue.main.async {
                                    currentVC.removeMemberInfoViewsInStackView()
                                    currentVC.insertMemberViewsInStackView()
                                    currentVC.memberCountLabel.text = "현재 \(currentVC.viewModel?.contentMembers.value.count ?? 0)명 참여중이에요."
                                    LoadingIndicator.hideLoading()
                                }
                            case .editMember:
                                DispatchQueue.main.async {
                                    currentVC.removeMemberInfoViewsInStackView()
                                    currentVC.insertMemberViewsInStackView()
                                    LoadingIndicator.hideLoading()
                                }
                            case .startDate:
                                DispatchQueue.main.async {
                                    currentVC.removeMemberInfoViewsInStackView()
                                    currentVC.insertMemberViewsInStackView()
                                    LoadingIndicator.hideLoading()
                                }
                            case .deadlineDate:
                                DispatchQueue.main.async {
                                    currentVC.removeMemberInfoViewsInStackView()
                                    currentVC.insertMemberViewsInStackView()
                                    LoadingIndicator.hideLoading()
                                }
                            default:
                                print("none")
                            }
                        }
                    } else {
                        switch connectedType {
                        case .fetchMember:
                            self.makeAlertDialog(title: nil, message: "네트워크 연결을 확인해 주세요.", type: .notConnected, connectedType: .fetchMember)
                        case .addMember:
                            self.makeAlertDialog(title: nil, message: "네트워크 연결을 확인해 주세요.", type: .notConnected, connectedType: .addMember)
                        case .editMember:
                            self.makeAlertDialog(title: nil, message: "네트워크 연결을 확인해 주세요.", type: .notConnected, connectedType: .editMember)
                        case .startDate:
                            self.makeAlertDialog(title: nil, message: "네트워크 연결을 확인해 주세요.", type: .notConnected, connectedType: .startDate)
                        case .deadlineDate:
                            self.makeAlertDialog(title: nil, message: "네트워크 연결을 확인해 주세요.", type: .notConnected, connectedType: .deadlineDate)
                        default:
                            print("none")
                        }
                        
                    }
                }
            }
            
            alert.addAction(ok)
            
            ok.setTextColor(type: .ok)
            
            self.present(alert, animated: true)
            
        // 스터디 정보를 삭제할 때
        case .deleteStudy:
            let ok = UIAlertAction(title: "확인", style: .default) { _ in
                guard let currentVC = self as? DetailStudyViewController else { return }
                CoreDataManager.shared.deleteStudy(study: currentVC.viewModel?.study.value)
                currentVC.navigationController?.popViewController(animated: true)
            }
            
            let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            
            alert.addAction(cancel)
            alert.addAction(ok)
            
            cancel.setTextColor(type: .cancel)
            ok.setTextColor(type: .ok)
           
            self.present(alert, animated: true)
        
        // 스터디 정보 수정을 취소할 때
        case .closeComposeVC:
            let ok = UIAlertAction(title: "확인", style: .default) { _ in
                guard let currentVC = self as? AddStudyViewController else { return }
                
                CoreDataManager.shared.context.rollback()
                currentVC.dismiss(animated: true)
            }
            
            let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            
            alert.addAction(cancel)
            alert.addAction(ok)
            
            cancel.setTextColor(type: .cancel)
            ok.setTextColor(type: .ok)
           
            self.present(alert, animated: true)
        
        // 멤버를 삭제할 때
        case .deleteMember:
            let ok = UIAlertAction(title: "확인", style: .default) { _ in
                guard let currentVC = self as? BottomSheetViewController else { return }
                
                switch currentVC.option {
                case .editStudyMember:
                    currentVC.composeViewModel?.updateStudyProperty(.deleteMember, value: currentVC.index)
                case .editContentMember:
                    currentVC.newContentViewModel?.updateContentProperty(.deleteContentMember, value: currentVC.index)
                default:
                    print("none")
                }
                
                currentVC.dismissBottomSheetView()
            }
            
            let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            
            alert.addAction(cancel)
            alert.addAction(ok)
            
            cancel.setTextColor(type: .cancel)
            ok.setTextColor(type: .ok)
           
            self.present(alert, animated: true)
        }
    }
}
