//
//  DayPickerBarTableView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 13/08/2024.
//

import UIKit

class DayPickerBarCollectionView: UIView, UICollectionViewDataSource, UICollectionViewDelegate {
    weak var delegate: DayPickerBarDelegate?
    private let maxNumberOfItems = 7*52
    private let collectionView: UICollectionView
    private let startDate: Date
    private var selectedIndexPath: IndexPath?
    var selectedDate: Date?
    private let cellIdentifier = "CollectionViewCell"
    
    init(startDate: Date) {
        self.startDate = startDate.adjustToMidday()
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 0
        layout.itemSize = .init(width: 100, height: 44)
        
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.collectionView.showsHorizontalScrollIndicator = false
        super.init(frame: .zero)
        self.selectedDate = startDate.adjustToMidday()
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: self.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.backgroundColor = .clear
    }
    
    // MARK: - UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return maxNumberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? CollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let date = calculateDate(for: indexPath, base: startDate)
        cell.configure(with: date)
        if selectedIndexPath == nil {
            selectedIndexPath = findTodayIndexPath()
            collectionView.selectItem(at: findTodayIndexPath(), animated: false, scrollPosition: .centeredHorizontally)
        }
        
        cell.isSelected = if let selectedIndexPath { (indexPath == selectedIndexPath) } else { false }
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 200, height: 100) // Adjust width as needed
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedIndexPath = indexPath
        if let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewCell {
            self.selectedDate = cell.date
            delegate?.didSelectDate(cell.date)
        }
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    func calculateDate(for indexPath: IndexPath, base: Date) -> Date {
        let middlePoint = maxNumberOfItems/2 * -1
        let offset = indexPath.item
        
        let dateToDisplay = Calendar.current.date(byAdding: .day, value: middlePoint + offset, to: base) ?? base
        return dateToDisplay.adjustToMidday()
    }
    
    func findTodayIndexPath() -> IndexPath {
        let middlePoint = maxNumberOfItems/2
        return .init(item: middlePoint, section: 0)
    }
    
    func selectDate(_ date: Date, animated: Bool = true) {
        let daysDifference = Calendar.current.dateComponents([.day], from: startDate, to: date).day ?? 0
        let middlePoint = maxNumberOfItems / 2
        let targetItem = middlePoint + daysDifference
        
        guard targetItem >= 0 && targetItem < maxNumberOfItems else {
            print("Date is out of range for this collection view.")
            return
        }
        
        let targetIndexPath = IndexPath(item: targetItem, section: 0)
        collectionView.selectItem(at: targetIndexPath, animated: animated, scrollPosition: .centeredHorizontally)
        self.selectedDate = date.adjustToMidday()
    }
}
