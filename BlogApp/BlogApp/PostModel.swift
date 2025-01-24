//
//  PostModel.swift
//  BlogApp
//
//  Created by PKW on 1/23/25.
//

import Foundation

struct PostResponse {
    var name: String?
    var data: PostModel?
    var errorMessage: String?
}

struct PostModel {
    let title: String?
    let date: String?
    let postUrl: String?
}
