//
//  ShareContentViewController.swift
//  BlogApp
//
//  Created by PKW on 2023/06/16.
//

import UIKit

// 마감 정보를 공유하기 위한 화면을 표시하는 뷰 컨트롤러 입니다.
class ShareContentViewController: UIViewController, ViewModelBindableType {
    
    // MARK: ===== [Enum] =====
    
    // 'ShareContentViewController'에서 사용될 상수 열거형
    private enum Const {
        
        // 네비게이션바의 높이
        static let navigationBarHeight = 44.0
        
        // 마감 회차 정보를 표시할 스택뷰의 높이
        static let contentNumberStackViewHeight = 50.0
        
        // 탑, 바텀 세이프 에어리어 합계
        // 노치 유뮤에 따라 분기 처리
        static var totalSafeArea: CGFloat {
            if #available(iOS 13.0, *) {
                let window = UIApplication.shared.windows.first
                let top = window?.safeAreaInsets.top ?? 0.0
                let bottom = window?.safeAreaInsets.bottom ?? 0.0
                return top + bottom
                
            } else if #available(iOS 11.0, *) {
                let window = UIApplication.shared.keyWindow
                let top = window?.safeAreaInsets.top ?? 0.0
                let bottom = window?.safeAreaInsets.bottom ?? 0.0
                return top + bottom
            }
        }
        
        // 컬렉션뷰의 아이템 사이즈
        static let itemSize = CGSize(width: UIScreen.main.bounds.width * 0.85, height: (UIScreen.main.bounds.height - navigationBarHeight - contentNumberStackViewHeight - totalSafeArea))
        
        // 아이템간 간격
        static let itemSpacing = 24.0
        
        // 아이템을 중앙에 위치시키기 위한 X inset
        static var insetX: CGFloat {
            (UIScreen.main.bounds.width - self.itemSize.width) / 2.0
        }
        
        // 컬렉션뷰의 인셋
        static var collectionViewContentInset: UIEdgeInsets {
            UIEdgeInsets(top: 0, left: self.insetX, bottom: 0, right: self.insetX)
        }
    }

    
    
    // MARK:  ===== [@IBOutlet] =====
    
    // 마감된 회차의 정보를 표시할 컬렉선 뷰
    @IBOutlet weak var contentCollectionView: UICollectionView!
    
    // 회차를 표시하기위한 레이블
    @IBOutlet weak var contentNumberLabel: UILabel!
    
    // 마감 정보 공유 버튼
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    typealias ViewModelType = ShareContentViewModel
    
    var viewModel: ViewModelType?
   
    
    
    // MARK: ===== [Property] =====
    
    // 컬렉션 뷰의 플로우 레이아웃 설정
    private let collectionViewFlowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = Const.itemSize
        layout.minimumLineSpacing = Const.itemSpacing
        layout.minimumInteritemSpacing = 0
        return layout
    }()
    
    
    
    // MARK: ===== [Override] =====
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configLayout()
        configData()
        bindViewModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 마감 정보가 2개 이상인 경우 (마감된 마지막 마감 정보로 이동)
        if viewModel?.contentList?.count != 1 {
            // 마지막 회차의 이전 회차 인덱스를 설정합니다.
            let indexPath = IndexPath(row: (viewModel?.contentList?.count ?? 0) - 2, section: 0)
            
            // 뷰 모델의 인덱스를 설정합니다.
            viewModel?.currentIndex = indexPath.row
            
            // 인덱스 위치로 컬렉션 뷰를 이동시킵니다.
            contentCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    // MARK: ===== [@IBAction] =====
    
    /// 취소 버튼을 탭했을 떄의 동작을 정의합니다.
    @IBAction func tapCloseButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    /// 공유 버튼을 탭했을 때의 동작을 정의합니다.
    @IBAction func tapShareButton(_ sender: Any) {
        
        // 공유할 내용을 담을 배열
        var shareList = [String]()
        
        // 현재 선택된 컬렉션뷰의 셀을 가져와 공유할 내용을 'shareList'에 추가
        if let cell = contentCollectionView.cellForItem(at: IndexPath(row: viewModel?.currentIndex ?? 0, section: 0)) as? ContentCollectionViewCell,
           let shareText = cell.shareContentTextView.text {
            
            shareList.append(shareText)
        }
        
        // 공유 액티비티 뷰 컨트롤러를 생성
        let activityVC = UIActivityViewController(activityItems: shareList, applicationActivities: nil)
        
        // 공유하기 기능 중 제외할 기능이 있을 때 사용
        // activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
        
        activityVC.popoverPresentationController?.sourceView = self.view
        self.present(activityVC, animated: true, completion: nil)
    }
    
    
    
    // MARK:  ===== [Function] =====
    
    /// 레이아웃을 설정합니다.
    func configLayout() {
        contentCollectionView.collectionViewLayout = self.collectionViewFlowLayout
        contentCollectionView.isScrollEnabled = true
        contentCollectionView.showsHorizontalScrollIndicator = false
        contentCollectionView.showsVerticalScrollIndicator = true
        contentCollectionView.backgroundColor = .clear
        contentCollectionView.clipsToBounds = true
        contentCollectionView.isPagingEnabled = false
        contentCollectionView.contentInsetAdjustmentBehavior = .never
        contentCollectionView.contentInset = Const.collectionViewContentInset
        contentCollectionView.decelerationRate = .fast
        contentCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    /// 공유할 마감 정보를 설정합니다.
    func configData() {
        
        // 마감된 정보가 1개일 경우
        if viewModel?.contentList?.count == 1 {
            
            contentNumberLabel.text = "\(viewModel?.contentList?.first?.contentNumber ?? 0) 회차"
            
            // 공유 버튼을 사용안함으로 설정합니다.
            shareButton.isEnabled = false
        } else {
            contentNumberLabel.text = "\(viewModel?.contentList?[(viewModel?.contentList?.count ?? 0) - 2].contentNumber ?? 0) 회차"
        }
    }
    
    func bindViewModel() { }
}

extension ShareContentViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.contentList?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "contentCell", for: indexPath) as? ContentCollectionViewCell else { return UICollectionViewCell() }
        cell.viewModel = viewModel
        cell.configData(index: indexPath.row)
        
        return cell
    }
}

extension ShareContentViewController: UICollectionViewDelegateFlowLayout {
    
    // 스크롤이 멈췄을 때 호출됩니다.
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        // 타겟 위치를 계산합니다.
        let scrolledOffsetX = targetContentOffset.pointee.x + scrollView.contentInset.left
        let cellWidth = Const.itemSize.width + Const.itemSpacing
        let index = round(scrolledOffsetX / cellWidth)
    
        // 스크롤 뷰의 타겟 위치를 설정합니다.
        targetContentOffset.pointee = CGPoint(x: index * cellWidth - scrollView.contentInset.left, y: scrollView.contentInset.top)
        
        
        if (viewModel?.contentList?.count ?? 0) - 1 == Int(index) {
            shareButton.isEnabled = false
        } else {
            shareButton.isEnabled = true
        }
        
        // 현재 인덱스를 업데이트 합니다.
        viewModel?.currentIndex = Int(index)
        
        // 레이블을 업데이트 합니다.
        contentNumberLabel.text = "\(viewModel?.contentList?[Int(index)].contentNumber ?? 0) 회차"
    }
}
