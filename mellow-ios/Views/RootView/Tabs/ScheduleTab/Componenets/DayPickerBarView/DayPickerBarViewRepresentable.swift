//
//  DayPickerBarViewRepresentable.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 13/08/2024.
//

import SwiftUI

protocol DayPickerBarDelegate: AnyObject {
    func didSelectDate(_ date: Date)
}

struct DayPickerBarViewRepresentable: UIViewRepresentable {
    @Binding var date: Date

    class Coordinator: NSObject, DayPickerBarDelegate {
        var parent: DayPickerBarViewRepresentable
        
        init(parent: DayPickerBarViewRepresentable) {
            self.parent = parent
        }
        
        func didSelectDate(_ date: Date) {
            parent.date = date
        }
    }
        
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> UIView {
        let view = DayPickerBarCollectionView(startDate: .now)
        view.delegate = context.coordinator // Set the delegate
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        guard let view = uiView as? DayPickerBarCollectionView else {
            fatalError()
        }
        guard view.selectedDate != date else { return }
        view.selectDate(date, animated: true)
    }
}
