//
//  UserModel.swift
//  BlogApp
//
//  Created by PKW on 2023/05/16.
//

import Foundation

struct UserModel {
    // 이름
    let name: String?
    // 블로그주소
    let blogUrl: String?
    // 벌금도 가지고 있어야함
    var fine: Int?
    
    // --------- 코어 데이터에 저장 안해도되는 프로퍼티
    // 블로그 이름
    var blogName: String?
    // 게시글 데이터
    var postData: PostResponse?
}

struct ContentModel {
    let content: Content?
    let contentMembers: [ContentUserModel]
    
}

struct ContentUserModel {
    var name: String?
    var title: String?
    var postURL: String?
    var fine: Int?
}

struct PostResponse {
    var data: PostModel?
    var errorMessage: String?
}

struct PostModel {
    let title: String?
    let date: String?
    let postUrl: String?
}


