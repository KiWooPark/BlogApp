//
//  ViewModelBindableType.swift
//  BlogApp
//
//  Created by PKW on 2023/06/01.
//

import Foundation
import UIKit

protocol ViewModelBindableType {
    associatedtype ViewModelType
    
    var viewModel: ViewModelType? { get set }
    func bindViewModel()
}
