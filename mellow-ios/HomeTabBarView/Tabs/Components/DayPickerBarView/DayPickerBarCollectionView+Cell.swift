//
//  DayPickerBarCollectionView+Cell.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 13/08/2024.
//

import UIKit

extension DayPickerBarCollectionView {
    class CollectionViewCell: UICollectionViewCell {
        private let label: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textAlignment = .center
            label.font = UIFont(name: "SF Pro Display", size: 14)
            label.textColor = .white
            return label
        }()
        
        private(set) var date: Date!
        
        override var isSelected: Bool {
            didSet {
                updateSelectionState()
            }
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupView()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupView() {
            contentView.addSubview(label)
            
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: contentView.topAnchor),
                label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
            
            contentView.layer.cornerRadius = 10
            contentView.layer.masksToBounds = true
        }
        
        private func updateSelectionState() {
            if isSelected {
                contentView.backgroundColor = UIColor(named: "softPeriwinkle")
            } else {
                contentView.backgroundColor = UIColor.clear
            }
        }
        
        func configure(with date: Date) {
            self.date = date
            label.text = formattedDate(for: date)
        }
        
        private func formattedDate(for date: Date) -> String {
            let calendar = Calendar.current
            
            if calendar.isDateInToday(date) {
                return "Today"
            } else if calendar.isDateInYesterday(date) {
                return "Yesterday"
            } else if calendar.isDateInTomorrow(date) {
                return "Tomorrow"
            } else {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "E, MMM d"
                return dateFormatter.string(from: date)
            }
        }
    }
}
