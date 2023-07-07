//
//  ShareContentViewController.swift
//  BlogApp
//
//  Created by PKW on 2023/06/16.
//

import UIKit

class ShareContentViewController: UIViewController, ViewModelBindableType {
    
    typealias ViewModelType = ShareContentViewModel
    var viewModel: ViewModelType?
    
    @IBOutlet weak var contentCollectionView: UICollectionView!
    @IBOutlet weak var dateLable: UILabel!
    
    
    private enum Const {
        static let itemSize = CGSize(width: UIScreen.main.bounds.width * 0.85, height: UIScreen.main.bounds.height * 0.7)
        static let itemSpacing = 24.0
        
        static var insetX: CGFloat {
            (UIScreen.main.bounds.width - self.itemSize.width) / 2.0
        }
        
        static var collectionViewContentInset: UIEdgeInsets {
            UIEdgeInsets(top: 0, left: Self.insetX, bottom: 0, right: Self.insetX)
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
        bindViewModel()
    }
    
    
    @IBAction func tapCloseButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func tapMoreMenuButton(_ sender: Any) {
        
    }
    
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
    
    func bindViewModel() { }
}

extension ShareContentViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.contentList.count ?? 0
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
        targetContentOffset.pointee = CGPoint(x: index * cellWidth - scrollView.contentInset.left, y: scrollView.contentInset.top)
        dateLable.text = "\(viewModel?.contentList[Int(index)].finishDate?.getWeekOfMonth() ?? "")"

        
    }
}
