//
//  ShareContentViewController.swift
//  BlogApp
//
//  Created by PKW on 2023/06/16.
//

import UIKit

class ShareContentViewController: UIViewController, ViewModelBindableType {
<<<<<<< HEAD

    @IBOutlet weak var contentCollectionView: UICollectionView!
    @IBOutlet weak var contentNumberLabel: UILabel!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    typealias ViewModelType = ShareContentViewModel
    var viewModel: ViewModelType?
   
    private enum Const {
        
        static let navigationBarHeight = 44.0
        static let contentNumberStackViewHeight = 50.0
        
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
        
        static let itemSize = CGSize(width: UIScreen.main.bounds.width * 0.85, height: (UIScreen.main.bounds.height - navigationBarHeight - contentNumberStackViewHeight - totalSafeArea))
        
=======
    
    typealias ViewModelType = ShareContentViewModel
    var viewModel: ViewModelType?
    
    @IBOutlet weak var contentCollectionView: UICollectionView!
    @IBOutlet weak var dateLable: UILabel!
    
    
    private enum Const {
        static let itemSize = CGSize(width: UIScreen.main.bounds.width * 0.85, height: UIScreen.main.bounds.height * 0.7)
>>>>>>> main
        static let itemSpacing = 24.0
        
        static var insetX: CGFloat {
            (UIScreen.main.bounds.width - self.itemSize.width) / 2.0
        }
        
        static var collectionViewContentInset: UIEdgeInsets {
<<<<<<< HEAD
            UIEdgeInsets(top: 0, left: self.insetX, bottom: 0, right: self.insetX)
=======
            UIEdgeInsets(top: 0, left: Self.insetX, bottom: 0, right: Self.insetX)
>>>>>>> main
        }
    }
    
    private let collectionViewFlowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = Const.itemSize
        layout.minimumLineSpacing = Const.itemSpacing
        layout.minimumInteritemSpacing = 0
        return layout
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configLayout()
<<<<<<< HEAD
        configData()
        bindViewModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if viewModel?.contentList?.count != 1 {
            let indexPath = IndexPath(row: (viewModel?.contentList?.count ?? 0) - 2, section: 0)
            viewModel?.currentIndex = indexPath.row
            contentCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
=======
        bindViewModel()
    }
    
>>>>>>> main
    
    @IBAction func tapCloseButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
<<<<<<< HEAD
    @IBAction func tapShareButton(_ sender: Any) {
        var shareList = [String]()
        
        if let cell = contentCollectionView.cellForItem(at: IndexPath(row: viewModel?.currentIndex ?? 0, section: 0)) as? ContentCollectionViewCell,
           let shareText = cell.shareContentTextView.text {
            
            shareList.append(shareText)
        }
        
        let activityVC = UIActivityViewController(activityItems: shareList, applicationActivities: nil)
        
        // 공유하기 기능 중 제외할 기능이 있을 때 사용
//        activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
        
        activityVC.popoverPresentationController?.sourceView = self.view
        self.present(activityVC, animated: true, completion: nil)
    }
    
    
    
=======
    @IBAction func tapMoreMenuButton(_ sender: Any) {
        
    }
    
>>>>>>> main
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
<<<<<<< HEAD
        
    }
    
    func configData() {
        if viewModel?.contentList?.count == 1 {
            contentNumberLabel.text = "\(viewModel?.contentList?.first?.contentNumber ?? 0) 회차"
            shareButton.isEnabled = false
        } else {
            contentNumberLabel.text = "\(viewModel?.contentList?[(viewModel?.contentList?.count ?? 0) - 2].contentNumber ?? 0) 회차"
        }
=======
>>>>>>> main
    }
    
    func bindViewModel() { }
}

extension ShareContentViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
<<<<<<< HEAD
        return viewModel?.contentList?.count ?? 0
=======
        return viewModel?.contentList.count ?? 0
>>>>>>> main
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "contentCell", for: indexPath) as? ContentCollectionViewCell else { return UICollectionViewCell() }
        cell.viewModel = viewModel
        cell.configData(index: indexPath.row)
        
        return cell
    }
}

extension ShareContentViewController: UICollectionViewDelegateFlowLayout {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let scrolledOffsetX = targetContentOffset.pointee.x + scrollView.contentInset.left
        let cellWidth = Const.itemSize.width + Const.itemSpacing
        let index = round(scrolledOffsetX / cellWidth)
<<<<<<< HEAD
    
        targetContentOffset.pointee = CGPoint(x: index * cellWidth - scrollView.contentInset.left, y: scrollView.contentInset.top)
        
        if (viewModel?.contentList?.count ?? 0) - 1 == Int(index) {
            shareButton.isEnabled = false
        } else {
            shareButton.isEnabled = true
        }
        
        viewModel?.currentIndex = Int(index)
        
        contentNumberLabel.text = "\(viewModel?.contentList?[Int(index)].contentNumber ?? 0) 회차"
=======
        targetContentOffset.pointee = CGPoint(x: index * cellWidth - scrollView.contentInset.left, y: scrollView.contentInset.top)
        dateLable.text = "\(viewModel?.contentList[Int(index)].finishDate?.getWeekOfMonth() ?? "")"

        
>>>>>>> main
    }
}
