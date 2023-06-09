//
//  CrawlingManager.swift
//  BlogApp
//
//  Created by PKW on 2023/05/16.
//

import Foundation
import Alamofire
import SwiftSoup

enum CrawlingError: Error {
    case error
    case htmlError
    case rangeError
    case urlError
    case getPostURLError
    case tryError
    case latestPostURLError
    case notFoundItemListElement
    case notFoundItem
    case notFoundId
    case notFoundTitleAndDate
    
}

//enum CrawlingType {
//    case currentWeek
//    case lastContentWeek
//}

struct CrawlingManager {
    
    
    // 카테고리 경로 붙이기
    static func addCategoryStr(blogUrl: String?) -> URL? {
        guard let url = blogUrl else { return nil }
        return URL(string: url + "/category")
    }
    
    // html에서 head 부분만 가지고 오기
    static func getHtmlHead(html: String) -> String? {
        let pattern = "<head>([\\s\\S]*?)</head>"

        guard let range = html.range(of: pattern, options: .regularExpression) else { return nil }

        let headContent = html[range]
        
        return String(headContent)
    }
    
    // 페이지 마지막 번호 가지고오기2
    static func getLastPageNumber(member: UserModel, completion: @escaping (Result<[Int], CrawlingError>) -> ()) {

        let url = addCategoryStr(blogUrl: member.blogUrl ?? "")

        // URL에 공백있으면 에러 
        if let url = url {
            AF.request(url).responseString { result in
                switch result.result {
                case .success(let data):
                    guard let html = result.value else {
                        completion(.failure(.urlError))
                        return
                    }
                    
                    do {
                        let pattern = #"(/category\?page=\d+)""#
                        let regex = try NSRegularExpression(pattern: pattern, options: [])

                        let range = NSRange(html.startIndex..<html.endIndex, in: html)
                        let matches = regex.matches(in: html, options: [], range: range)

                        let matchedStrings = matches.compactMap { match -> Int? in
                            guard let range = Range(match.range(at: 1), in: html) else {
                                return nil
                            }

                            let pageNumber = Int(String(html[range]).components(separatedBy: "=")[1])

                            return pageNumber
                        }

                        let pagesNumber = matchedStrings.sorted()
                        completion(.success(pagesNumber))

                    } catch {
                        print("getLastPageNumber error")
                    }
                case .failure(let error):
                    print("category 번호 못가져옴")
                    completion(.failure(.error))
                }
            }
        } else {
            completion(.failure(.urlError))
        }
    }
    
    // 작성한 게시글들 url 가지고오기2
    static func getPostsURL(url: URL, completion: @escaping (Result<[String], CrawlingError>) -> ()) {
    
        AF.request(url).responseString { result in
            switch result.result {
            case .success(let html):
                guard let headContent = getHtmlHead(html: html) else {
                    completion(.failure(.htmlError))
                    return
                }
                
                do {
                    let doc = try SwiftSoup.parse(headContent)
                    let scriptElements = try doc.select("script[type=application/ld+json]")
                    let jsonData = try scriptElements.first()?.html()
                    
                    guard let data = jsonData?.data(using: .utf8),
                          let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                          let itemList = json["itemListElement"] as? [[String: Any]] else {
                        completion(.failure(.notFoundItemListElement))
                        return
                    }
                    
                    var urls = [String]()
                
                    itemList.forEach { item in
                        if let item = item["item"] as? [String: String],
                           let url = item["@id"] {
                            urls.append(url)
                        }
                    }
                    completion(.success(urls))
                } catch {
                    completion(.failure(.tryError))
                }

            case .failure(_):
                completion(.failure(.getPostURLError))
            }
        }
    }
 
    static func getPostTitleAndDate(urls: [String], startDate: Date?, endDate: Date?, completion: @escaping (Result<PostModel?, CrawlingError>) -> ()) {
    
        var currentIndex = 0
        let calendar = Calendar.current

        func next() {

            guard currentIndex < urls.count else {
                print("없음 - \(urls)")
                completion(.success(nil))
                return
            }
            
            let currentUrl = urls[currentIndex]

            if let url = URL(string: currentUrl) {
                AF.request(url).responseString { result in
                    switch result.result {
                    case .success(let html):

                        let headContent = getHtmlHead(html: html)

                        do {
                            let doc = try SwiftSoup.parse(headContent ?? "")
                            let title = try doc.select("meta[property=og:title]").first()?.attr("content")
                            let date = try doc.select("meta[property=article:published_time]").first()?.attr("content")

                            // 날짜 비교
                            let dateRange = DateInterval(start: startDate!, end: endDate!)
                            
                            if dateRange.contains((date?.convertToDate())!) {
                                let postModel = PostModel(title: title, date: date, postUrl: currentUrl)
                                completion(.success(postModel))
                            } else {
                                
                                let result = calendar.compare((date?.convertToDate())!, to: startDate!, toGranularity: .day)
                                
                                switch result {
                                case .orderedAscending:
                                    let postModel = PostModel(title: nil, date: nil, postUrl: nil)
                                    completion(.success(postModel))
                                case .orderedDescending:
                                    currentIndex += 1
                                    next()
                                default:
                                    print("")
                                }
                            }
                        } catch {
                            completion(.failure(.tryError))
                        }
                    case .failure(_):
                        completion(.failure(.urlError))
                    }
                }
            }
        }
        next()
    }
}

//enum CrawlingManager {
//
//    //case getNewPost(url: String)
//    case testPost(data: [StudyModel])
//
//    func request<T>(completion: @escaping (Result<T,CrawlingError>) -> ()) {
//        switch self {
//        case .testPost(let data):
//            if let data = data as? T {
//                completion(.success(data))
//            }
//        }
//        case .getNewPost(let url):
//            if let url = url as? T {
//                completion(.success(url))
//            }
//        }
//    }
//}

//    static func fetchPostData(url: String, completion: @escaping (Result<PostResponse,CrawlingError>) -> ()) {
//
//        // 티스토리는 뒤에 category 추가
//        let tistoryUrl = url + "/category"
//
//        if let url = URL(string: tistoryUrl) {
//            getLatestPostURL(url: url) { result in
//                switch result {
//                case .success(let url):
//                    getPostTitleAndDate(url: url) { result in
//                        switch result {
//                        case .success(let model):
//                            let result = PostResponse(data: nil, errorMessage: nil)
//                            completion(.success(result))
//                        case .failure(let error):
//                            completion(.failure(error))
//                        }
//                    }
//                case .failure(let error):
//                    // html, try, 게시물 url, itemListElement, item, id를 가지고오지 못하면 (switch로 에러 분기 처리 해야함)
//                    completion(.failure(error))
//                }
//            }
//        } else {
//            // 기본 url이 잘못된경우
//            completion(.failure(.urlError))
//        }
//    }
//
//    // 1. 최신 게시글 데이터 가지고오기 (URL 주소 가지고오기)
//    // - 날짜 정보가 없기때문에 URL 주소 가지고와서 날짜 데이터를 다시 가져와야함
//    static func getLatestPostURL(url: URL, completion: @escaping (Result<String, CrawlingError>) -> ()) {
//
//        AF.request(url).responseString { result in
//            switch result.result {
//            case .success(_):
//
//                guard let html = result.value else {
//                    completion(.failure(.htmlError))
//                    return
//                }
//
//                do {
//                    let doc: Document = try SwiftSoup.parse(html)
//                    let scriptElements = try doc.select("script[type=application/ld+json]")
//
//                    // 요소들을 반복하면서 데이터 추출
//                    for scriptElement in scriptElements {
//                        // 스크립트 요소의 내용을 가져옴
//                        let jsonData = try scriptElement.html()
//
//                        // JSON 데이터로 파싱
//                        if let data = jsonData.data(using: .utf8),
//                           let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
//
//                            guard let itemList = json["itemListElement"] as? [[String: Any]] else {
//                                completion(.failure(.notFoundItemListElement))
//                                return
//                            }
//
//                            guard let item = itemList.first?["item"] as? [String: String] else {
//                                completion(.failure(.notFoundItem))
//                                return
//                            }
//
//                            guard let id = item.filter({$0.key == "@id"}).values.first else {
//                                completion(.failure(.notFoundId))
//                                return
//                            }
//
//                            completion(.success(id))
//                        }
//                    }
//                } catch {
//                    completion(.failure(.tryError))
//                }
//            case .failure(let error):
//                completion(.failure(.latestPostURLError))
//            }
//        }
//    }
//
//    // 2. URL로 날짜 및 게시글 제목 가지고 오기
//    static func getPostTitleAndDate(url: String, completion: @escaping (Result<PostModel?,CrawlingError>) -> ()) {
//        if let postUrl = URL(string: url) {
//            AF.request(postUrl).responseString { result in
//                switch result.result {
//                case .success(_):
//                    guard let html = result.value else {
//                        completion(.failure(.htmlError))
//                        return
//                    }
//
//                    do {
//                        let doc: Document = try SwiftSoup.parse(html)
//                        if let titleElement = try doc.select("meta[property=og:title]").first(),
//                           let dateElement = try doc.select("meta[property=article:published_time]").first() {
//                            let title = try titleElement.attr("content")
//                            let date = try dateElement.attr("content")
//
//                            let result = PostModel(title: title, date: date, postUrl: url)
//                            completion(.success(result))
//                        }
//                    } catch {
//                        completion(.failure(.tryError))
//                    }
//                case .failure(_):
//                    completion(.failure(.notFoundTitleAndDate))
//                }
//            }
//        }
//    }




// ---------------------------------------------------------------
// ---------------------------------------------------------------
// ---------------------------------------------------------------
// ---------------------------------------------------------------
// ---------------------------------------------------------------
/*
 - 코어데이터에 저장된 멤버 데이터 가지고온 후 URL 정보 파라미터로 전달
 1. 멤버 블로그 URL
 2. 작성한 게시글 URL
 
 3. 작성한 게시글 title, date 정보 가지고오기
 */

//    static func fetchPost(members: [UserModel], type: CrawlingType, completion: @escaping ([[PostResponse]]) -> ()) {
//
//        let group = DispatchGroup()
//
//        var postModels = Array(repeating: [PostResponse](), count: members.count)
//
//        for (index, member) in members.enumerated() {
//            let blogUrl = (member.blogUrl ?? "") + "/category"
//
//            if let url = URL(string: blogUrl) {
//                group.enter()
//                getPostURL(url: url, type: type) { result in
//                    switch result {
//                    case .success(let urls):
//                        getPostTitleAndDate11(urls: urls) { result in
//                            switch result {
//                            case .success(let postModel):
//                                // PostModelResponse를 리턴해야함 (게시물 데이터)
//                                let sortPost = postModel.sorted(by: {$0.date! > $1.date!})
//                                postModels[index] = [PostResponse(data: sortPost, errorMessage: nil)]
//                                group.leave()
//                            case .failure(_):
//                                // PostModelResponse를 리턴해야함 (게시물 없음)
//                                postModels[index] = [PostResponse(data: nil, errorMessage: "작성된 게시물이 없습니다.")]
//                                group.leave()
//                            }
//                        }
//                    case .failure(_):
//                        // PostModelResponse를 리턴해야함 (URL 확인)
//                        postModels[index] = [PostResponse(data: nil, errorMessage: "URL을 확인해주세요.")]
//                        group.leave()
//                    }
//                }
//            }
//        }
//
//        group.notify(queue: .main) {
//            completion(postModels)
//        }
//    }
//
//    static func getPostURL(url: URL, type: CrawlingType, completion: @escaping (Result<[String],CrawlingError>) -> ()) {
//
//        // 블로그 메인 페이지 HTML 가지고오기
//        AF.request(url).responseString { result in
//            guard let html = result.value else {
//                completion(.failure(.htmlError))
//                return
//            }
//
//            let pattern = "<head>([\\s\\S]*?)</head>"
//
//            guard let range = html.range(of: pattern, options: .regularExpression) else {
//                completion(.failure(.rangeError))
//                return
//            }
//
//            let headContent = html[range]
//
//            do {
//                let doc = try SwiftSoup.parse(String(headContent))
//                let scriptElements = try doc.select("script[type=application/ld+json]")
//                let scriptElement = scriptElements.first()
//
//                let jsonData = try scriptElement?.html() ?? ""
//
//                guard let data = jsonData.data(using: .utf8),
//                      let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
//                      let itemList = json["itemListElement"] as? [[String: Any]]
//                else {
//                    completion(.failure(.notFoundItemListElement))
//                    return
//                }
//
//                if type == .currentWeek {
//                    // 최신 = type이 currentWeek인지 lastContentWeek인지 분기처리
//                    if let item = itemList.first?["item"] as? [String: String],
//                       let url = item["@id"] {
//                        completion(.success([url]))
//                    }
//                } else {
//                    // 전체 = 여기서는 마지막 공지 날짜가 포함된 주에 포함하는 게시물이 있는지만 체크
//                    var urls = [String]()
//                    itemList.forEach { item in
//                        if let item = item["item"] as? [String: String],
//                           let url = item["@id"] {
//                            urls.append(url)
//                        }
//                    }
//                    completion(.success(urls))
//                }
//            } catch {
//                completion(.failure(.tryError))
//            }
//        }
//    }
//
//    static func getPostTitleAndDate11(urls: [String], completion: @escaping (Result<[PostModel],CrawlingError>) -> ()) {
//        // 반복문 돌면서 제목과 날짜 가지고오기
//
//        let group = DispatchGroup()
//
//        var postModels = [PostModel]()
//
//        for url in urls {
//            if let postURL = URL(string: url) {
//
//                group.enter()
//
//                AF.request(postURL).responseString { result in
//                    switch result.result {
//                    case .success(_):
//                        guard let html = result.value else { completion(.failure(.htmlError))
//                            return
//                        }
//
//                        let pattern = "<head>([\\s\\S]*?)</head>"
//
//                        guard let range = html.range(of: pattern, options: .regularExpression) else {
//                            completion(.failure(.rangeError))
//                            return
//                        }
//
//                        let headContent = html[range]
//
//                        do {
//                            let doc = try SwiftSoup.parse(String(headContent))
//                            let title = try doc.select("meta[property=og:title]").first()?.attr("content")
//                            let date = try doc.select("meta[property=article:published_time]").first()?.attr("content")
//
//                            postModels.append(PostModel(title: title, date: date, postUrl: url))
//                            group.leave()
//                        } catch {
//                            completion(.failure(.tryError))
//                        }
//                    case .failure(_):
//                        completion(.failure(.notFoundTitleAndDate))
//                    }
//                }
//            } else {
//                print("urlError")
//            }
//        }
//        group.notify(queue: .main) {
//            completion(.success(postModels))
//        }
//    }
//
//
// ----------------------------------------------------
//    static func postTest(members: [UserModel], type: CrawlingType, completion: @escaping (Result<String,CrawlingError>) -> ()) {
//
//        for member in members {
//
//            // 신규인지 기존인지 체크해서
//            // 신규면 금액 수정 못하게하고
//            // 기존이면 현재 벌금 현황을 입력하도록!!
//
//
//
//        }
//    }

// 페이지 마지막 번호 가지고오기
//    static func getLastPageNumber(members: UserModel, completion: @escaping (Result<[Int], Error>) -> ()) {
//
//        let urlStr = (members.blogUrl ?? "") + "/category"
//
//        if let url = URL(string: urlStr) {
//            AF.request(url).responseString { result in
//                guard let html = result.value else { return }
//
//                do {
//                    let pattern = #"(/category\?page=\d+)""#
//                    let regex = try NSRegularExpression(pattern: pattern, options: [])
//
//                    let range = NSRange(html.startIndex..<html.endIndex, in: html)
//                    let matches = regex.matches(in: html, options: [], range: range)
//
//                    let matchedStrings = matches.compactMap { match -> Int? in
//                        guard let range = Range(match.range(at: 1), in: html) else {
//                            return nil
//                        }
//
//                        let pageNumber = Int(String(html[range]).components(separatedBy: "=")[1])
//
//                        return pageNumber
//                    }
//
//                    let headContent = matchedStrings.sorted()
//
//                    print(headContent)
//
//                } catch {
//
//                }
//            }
//        }
//    }





//    // 작성한 게시글들 url 가지고오기
//    static func getPostsURL(url: URL, type: CrawlingType, completion: @escaping (Result<[String], CrawlingError>) -> ()) {
//
//        AF.request(url).responseString { result in
//            switch result.result {
//            case .success(let html):
//                guard let headContent = getHtmlHead(html: html) else {
//                    completion(.failure(.htmlError))
//                    return
//                }
//
//                do {
//                    let doc = try SwiftSoup.parse(headContent)
//                    let scriptElements = try doc.select("script[type=application/ld+json]")
//                    let jsonData = try scriptElements.first()?.html()
//
//                    guard let data = jsonData?.data(using: .utf8),
//                          let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
//                          let itemList = json["itemListElement"] as? [[String: Any]] else {
//                        completion(.failure(.notFoundItemListElement))
//                        return
//                    }
//
//                    var urls = [String]()
//
//                    if type == .currentWeek {
//                        // 최신 = type이 currentWeek인지 lastContentWeek인지 분기처리
//                        if let item = itemList.first?["item"] as? [String: String],
//                           let url = item["@id"] {
//                            completion(.success([url]))
//                        }
//                    } else {
//                        // 전체 = 여기서는 마지막 공지 날짜가 포함된 주에 포함하는 게시물이 있는지만 체크
//                        var urls = [String]()
//                        itemList.forEach { item in
//                            if let item = item["item"] as? [String: String],
//                               let url = item["@id"] {
//                                urls.append(url)
//                            }
//                        }
//                        completion(.success(urls))
//                    }
//                } catch {
//                    completion(.failure(.tryError))
//                }
//
//            case .failure(_):
//                completion(.failure(.getPostURLError))
//            }
//        }
//    }

