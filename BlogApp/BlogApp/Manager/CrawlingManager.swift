//
//  CrawlingManager.swift
//  BlogApp
//
//  Created by PKW on 2023/05/16.
//

import Foundation
import Alamofire
import SwiftSoup

// MARK: ===== [Enum] =====
/// 크롤링에 실패한 경우 `Error` 유형을 정의하는 열거형 입니다.
enum CrawlingError: Error {

    // HTML을 가지고오지 못한 경우 
    case htmlError
    // 블로그 페이지 정보를 가지고오지 못한 경우
    case rangeError
    // URL이 잘못된 경우
    case urlError
    // 작성한 게시글 정보를 가지고오지 못한 경우
    case getPostError
    // catch 블록으로 빠진 경우
    case tryError
    // HTML에서 ItemListElement가 없는 경우
    case notFoundItemListElement
    // HTML에서 Item이 없는 경우
    case notFoundItem
    // HTML에서 Id이 없는 경우
    case notFoundId
    // HTML에서 Title과 Date가 없는 경우
    case notFoundTitleAndDate
    // 카테고리 번호를 가지고오지 못한 경우
    case categoryNumberError
}

/// 블로그URL 검사 실패에 대한 유형을 나타내는 열거형 입니다.
enum BlogURLError: Error {
    // 티스토리 주소가 아닌 경우
    case notTistoryURL
    // URL 형식이 아닌 경우
    case invalidURL
    // 요청에 실패한 경우
    case requestFailed
}

/// `CrawlingManager`는 웹 사이트 데이터 크롤링 작업을 관리합니다.
struct CrawlingManager {
    
    // MARK:  ===== [Function] =====

    /// HTML 문자열에서 `head` 블록의 문자열을 반환합니다.
    ///
    /// - Parameter html: 블로그 HTML 문자열
    ///
    /// - Returns: <head>부터 </head>까지의 모든 문자열
    static func getHtmlHead(html: String) -> String? {
        let pattern = "<head>([\\s\\S]*?)</head>"

        guard let range = html.range(of: pattern, options: .regularExpression) else { return nil }

        let headContent = html[range]
        
        return String(headContent)
    }

    /// 새로운 멤버를 추가할 경우 입력한 URL을 검사합니다.
    /// 1. 티스토리 주소인지 검사
    /// 2. 유효한 URL인지 검사
    /// 3. URL 요청 성공 여부 검사
    ///
    /// - Parameters:
    ///   - url: 티스토리 블로그 URL
    ///   - completion: 검증 작업이 완료된 후 호출할 콜백 함수입니다. 성공하면 success로, 실패하면 해당 오류로 반환됩니다.
    static func validateBlogURL(url: String, completion: @escaping (Result<Void, BlogURLError>) -> ())  {
        
        // 티스토리 블로그 URL인지 확인
        if !url.contains("tistory") {
            completion(.failure(.notTistoryURL))
        }
        
        // 유효한 URL인지 확인
        guard let validURL = URL(string: url) else {
            completion(.failure(.invalidURL))
            return
        }
        
        // 해당 URL로 접속 가능한지 확인
        AF.request(validURL).responseString { result in
            switch result.result {
            case .success(_):
                completion(.success(()))
            case .failure( _):
                completion(.failure(.requestFailed))
            }
        }
    }

    /// 시작 날짜와 마감 날짜 범위사이에 작성한 블로그 게시물을 멤버별로 가져옵니다.
    ///
    /// 이 메소드는 멤버의 블로그 URL을 통해 게시물을 가지고 오며 각 멤버의 블로그에서 1페이지부터 확인 합니다.
    /// 해당 페이지에서 시작 날짜와 마감 날짜 범위에 작성된 게시물이 있는지 확인합니다.
    /// 이후 모든 멤버에 대한 조회가 완료되면 콜백 함수를 호출합니다.
    ///
    /// - Parameters:
    ///   - members: 멤버 배열
    ///   - startDate: 해당 회차 시작 날짜
    ///   - deadlineDate: 해당 회차 마감 날짜
    ///   - completion: 작업이 완료된 후에 호출할 콜백 함수 입니다. 완료시 멤버별 작성 게시물의 정보 배열을 반환합니다.
    static func fetchMembersBlogPost(members: [User], startDate: Date?, deadlineDate: Date?, completion: @escaping ([PostResponse]) -> ()){
        
        let group = DispatchGroup()
        
        // 작성한 게시물에 대한 데이터를 담을 배열 입니다.
        var resultPostsData = Array(repeating: PostResponse(), count: members.count)
    
        for i in 0 ..< members.count {
    
            group.enter()
            
            // 멤버 블로그의 마지막 페이지 번호를 가지고옵니다.
            getCategoryLastPageNumber(blogUrl: members[i].blogUrl ?? "") { result in
            
                switch result {
                case .success(let lastPageNumber):
                    
                    // 첫페이지부터 마지막 페이지까지 순회하면서 날짜 범위내에 작성한 게시물을 가지고옵니다.
                    fetchPostsByPage(lastPageNumber: lastPageNumber, baseUrl: members[i].blogUrl ?? "", startDate: startDate, deadlineDate: deadlineDate) { result in
                        
                        switch result {
                        case .success(let postData):
                            // 작성한 게시물이 없는 경우
                            if postData?.title == nil {
                                resultPostsData[i] = PostResponse(name: members[i].name, data: nil, errorMessage: "작성된 게시물이 없습니다.")
                            } else { // 작성한 게시물이 있는 경우
                                resultPostsData[i] = PostResponse(name: members[i].name, data: postData, errorMessage: nil)
                            }
                            
                            group.leave()
                            
                        case .failure( _):
                            resultPostsData[i] = PostResponse(name: members[i].name, data: nil, errorMessage: "URL을 확인해주세요!")
                            group.leave()
                        }
                    }
                case .failure( _):
                    resultPostsData[i] = PostResponse(name: members[i].name, data: nil, errorMessage: "URL을 확인해주세요!")
                    group.leave()
                }
            }
        }
        group.notify(queue: .main) {
            // 멤버별 작성 게시물의 정보 배열을 반환
            completion(resultPostsData)
        }
    }
    
    /// 멤버의 블로그 마지막 페이지 번호를 가지고옵니다.
    ///
    /// 이 메소드는 첫페이지부터 마지막 페이지까지 순회하기 위해 마지막 페이지 번호를 가지고옵니다.
    ///
    /// - Parameters:
    ///   - blogUrl: 블로그 URL
    ///   - completion: 마지막 페이지 번호를 성공적으로 가져오면 해당 번호를 반환하며, 오류 발생 시 에러를 반환합니다.
    static func getCategoryLastPageNumber(blogUrl: String, completion: @escaping (Result<Int, CrawlingError>) -> ()){
        
        // 블로그 URL에 "/category"를 추가하여 URL 객체를 생성합니다.
        // 만약 URL 변환이 실패하면 에러를 반환합니다.
        if let url = URL(string: blogUrl + "/category") {
           
            // URL로 요청을 보냅니다.
            AF.request(url).responseString { result in
                switch result.result {
                case .success( _):
                    
                    // HTML 문자열을 추출합니다.
                    guard let html = result.value else { return }
                    
                    do {
                        // 페이지 번호를 찾기 위한 정규표현식 패턴을 생성합니다.
                        let pattern = #"(/category\?page=\d+)""#
                        let regex = try NSRegularExpression(pattern: pattern, options: [])
                        let range = NSRange(html.startIndex..<html.endIndex, in: html)
                        
                        // HTML 문자열에서 정규표현식과 일치하는 모든 문자열을 찾습니다.
                        let matches = regex.matches(in: html, options: [], range: range)
                        
                        // 일치하는 문자열에서 페이지 번호를 추출합니다.
                        let matchedStrings = matches.compactMap { match -> Int? in
                            guard let range = Range(match.range(at: 1), in: html) else { return nil }
                            
                            let pageNumber = Int(String(html[range]).components(separatedBy: "=")[1])
                            
                            return pageNumber
                        }
                        
                        // 추출한 페이지 번호 중 가장 큰 값을 반환합니다.
                        completion(.success(matchedStrings.sorted().last ?? 0))
                    } catch {
                        // 정규표현식 생성 또는 매칭 도중 오류가 발생한 경우 에러를 출력하고 에러를 반환합니다.
                        completion(.failure(.tryError))
                    }
                case .failure( _):
                    // 페이지 번호를 가져오는 데 실패하면 에러를 출력하고 에러를 반환합니다.
                    completion(.failure(.categoryNumberError))
                }
            }
        } else {
            // URL 변환에 실패하면 에러를 출력하고 에러를 반환합니다.
            completion(.failure(.urlError))
        }
    }
    
    /// 페이지별로 날짜 범위내에 작성된 게시글의 URL을 가지고옵니다.
    ///
    /// 이 메소드는 내부에서 checkBlogPostInPage()를 재귀적으로 호출합니다.
    /// 해당 페이지에 날짜 범위안에 속한 게시물이 있으면 콜백 함수를 호출합니다.
    ///
    /// - Parameters:
    ///   - lastPageNumber: 마지막 페이지 번호
    ///   - baseUrl: 기본 URL
    ///   - startDate: 시작 날짜
    ///   - deadlineDate: 마감 날짜
    ///   - completion: 포스트를 성공적으로 가져오면 포스트 모델을 반환하며, 오류 발생 시 에러를 반환합니다.
    static func fetchPostsByPage(lastPageNumber: Int, baseUrl: String, startDate: Date?, deadlineDate: Date?, completion: @escaping (Result<PostModel?,CrawlingError>) -> ()) {
        
        // 현재 페이지 번호를 저장하는 변수 입니다. 기본값은 첫페이지인 1 입니다.
        var currentPage = 1
        
        /// 현재 페이지에서 날짜 범위내에 작성된 게시물이 있는지 확인합니다.
        func checkBlogPostInPage() {
            
            // 현재 페이지가 마지막 페이지를 초과하면 함수를 종료합니다.
            guard currentPage <= lastPageNumber else { return }
            
            // 현재 페이지의 URL을 생성합니다.
            if let url = URL(string: baseUrl + "/category" + "/?page=\(currentPage)") {
                
                getPostsUrl(url: url) { result in
                    
                    switch result {
                    case .success(let urls):
                        
                        checkBlogPostsInRange(urls: urls, startDate: startDate, deadlineDate: deadlineDate) { result  in
                            switch result {
                            case .success(let postData):
                                if let post = postData {
                                    // 날짜 범위 내에 작성된 게시물이 있다면 반환 합니다.
                                    completion(.success(post))
                                } else {
                                    // 날짜 범위 내에 작성된 게시물이 없다면 다음 페이지로 넘어간 후 검사합니다.
                                    currentPage += 1
                                    checkBlogPostInPage()
                                }
                            case .failure( _):
                                // 날짜 범위 내에 작성된 게시물이 없다면 다음 페이지로 넘어간 후 검사합니다.
                                currentPage += 1
                                checkBlogPostInPage()
                            }
                        }
                    case .failure( _):
                        // URL 배열 가져오기에 실패하면 다음 페이지로 넘어가서 다시 검사합니다.
                        currentPage += 1
                        checkBlogPostInPage()
                    }
                }
            }
        }
        
        // 재귀 함수 호출
        checkBlogPostInPage()
    }
    
    /// 현재 페이지에있는 게시물 목록을 가지고 옵니다.
    ///
    /// - Parameters:
    ///   - url: 게시물 URL 목록을 가지고오기 위한 URL
    ///   - completion: URL 배열을 성공적으로 가져오면 반환하며, 오류 발생 시 에러를 반환합니다.
    static func getPostsUrl(url: URL, completion: @escaping (Result<[String],CrawlingError>) -> ()) {
        
        // URL로 요청을 보냅니다.
        AF.request(url).responseString { result in
            
            switch result.result {
            case .success(let html):
                
                // HTML의 head 태그 내용을 가져옵니다.
                // 실패하면 "htmlError"를 반환합니다.
                guard let headContent = getHtmlHead(html: html) else {
                    completion(.failure(.htmlError))
                    return
                }
    
                do {
                    // SwiftSoup을 사용하여 HTML을 파싱합니다.
                    let doc = try SwiftSoup.parse(headContent)
                    // 스크립트 태그 중 application/ld+json 타입을 선택합니다.
                    let scriptElements = try doc.select("script[type=application/ld+json]")
                    // 첫 번째 스크립트 태그의 내용을 가져옵니다.
                    let jsonData = try scriptElements.first()?.html()
                    
                    // JSON 데이터를 디코딩하여 URL 배열을 가져옵니다.
                    guard let data = jsonData?.data(using: .utf8),
                          let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                          let itemList = json["itemListElement"] as? [[String: Any]] else {
                        completion(.failure(.notFoundItemListElement))
                        return
                    }
                    
                    var urls = [String]()
                
                    // itemList에서 각 항목의 URL을 추출합니다.
                    itemList.forEach { item in
                        if let item = item["item"] as? [String: String],
                           let url = item["@id"] {
                            urls.append(url)
                        }
                    }
                    
                    // 완성된 URL 배열을 반환합니다.
                    completion(.success(urls))
                } catch {
                    // 파싱 중에 오류가 발생하면 해당 오류를 반환합니다.
                    completion(.failure(.tryError))
                }
            case .failure(_):
                // 웹 페이지 요청에 실패하면 해당 오류를 반환합니다.
                completion(.failure(.getPostError))
            }
        }
    }
    
    /// 시작 날짜와 마감 날짜 범위내에 작성된 게시물이 있는지 확인합니다.
    ///
    /// - Parameters:
    ///   - urls: 게시물 URL 배열
    ///   - startDate: 시작 날짜
    ///   - deadlineDate: 마감 날짜
    ///   - completion: 기간 내의 작성된 게시물을 확인하면 반환하며, 오류 발생 시 에러를 반환합니다.
    static func checkBlogPostsInRange(urls: [String], startDate: Date?, deadlineDate: Date?, completion: @escaping (Result<PostModel?,CrawlingError>) -> ()) {
        
        // 현재 게시물 URL의 인덱스 번호 입니다. 기본값은 0 입니다.
        var currentCount = 0
        
        /// 게시물을 확인합니다.
        func checkPost() {
            
            // 모든 게시물 URL을 확인했을 경우 함수를 종료 합니다.
            guard currentCount < urls.count else { return completion(.success(nil)) }
            
            // 확인할 게시물 URLString
            let currentUrl = urls[currentCount]
            
            // 확인할 게시물의 URL을 생성합니다.
            if let url = URL(string: currentUrl) {
                
                // URL로 요청합니다.
                AF.request(url).responseString { result in
                    switch result.result {
                    case .success(let html):
                        
                        // HTML의 head 태그 내용을 가져옵니다.
                        let headContent = getHtmlHead(html: html)
                        
                        do {
                            // SwiftSoup을 사용하여 HTML을 파싱 합니다.
                            let doc = try SwiftSoup.parse(headContent ?? "")
                            // 메타 태그에서 게시물의 제목과 날짜를 추출 합니다.
                            let title = try doc.select("meta[property=og:title]").first()?.attr("content")
                            let dateStr = try doc.select("meta[property=article:published_time]").first()?.attr("content")
                            
                            let postDate = dateStr?.toDate() ?? Date()
                            let startDate = startDate ?? Date()
                            let deadlineDate = deadlineDate ?? Date()

                            // 추출한 게시물 날짜가 지정된 기간 내에 있는지 확인 합니다.
                            if postDate >= startDate && postDate <= deadlineDate {
                                // 기간 내에 있다면 해당 포스트 정보를 반환 합니다.
                                completion(.success(PostModel(title: title, date: dateStr, postUrl: urls[currentCount])))
                            } else {
                                // 기간 내에 없다면 다음 URL로 이동하여 확인 합니다.
                                if postDate <= startDate {
                                    completion(.success(PostModel(title: nil, date: nil, postUrl: nil)))
                                } else {
                                    currentCount += 1
                                    checkPost()
                                }
                            }
                        } catch {
                            completion(.failure(.tryError))
                        }
                    case .failure(_):
                        completion(.failure(.getPostError))
                    }
                }
            }
        }
        checkPost()
    }
}














/// Blog URL에 "/category" 문자열을 추가하는 메소드
/// 이 메소드는 주어진 블로그 URL 뒤에 "/category" 문자열을 추가하여 새로운 URL을 반환합니다.
/// --------------------------------------------------------------
/// - Parameter blogUrl: 블로그 URL
/// - Returns: "/category"가 추가된 새로운 URL. blogUrl이 nil이거나 올바른 URL 형식이 아닌 경우, 이 메소드는 nil을 반환합니다.
//    static func addCategoryStr(blogUrl: String?) -> URL? {
//        guard let url = blogUrl else { return nil }
//        return URL(string: url + "/category")
//    }

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

///// 파라미터로 전달한 시작 날짜와 마감 날짜를 기준으로 해당 기간내에 작성한 게시글을 가져오는 메소드 입니다.
///// postUrl이 nil 여부를 체크하여 nil인경우 작성된 게시물 없음, 잘못된 URL등 Error메시지를 저장하며 nil이 아닌 경우
///// 전달받은 post 데이터를 저장합니다.
///// - Parameters:
/////   - members: <#members description#>
/////   - startDate: <#startDate description#>
/////   - endDate: <#endDate description#>
/////   - completion: <#completion description#>
//static func fetchMemberPostData(members: [User], startDate: Date, endDate: Date, completion: @escaping (Result<[PostResponse],CrawlingError>) -> ())  {
//
//    let group = DispatchGroup()
//
//    var resultMembersData = Array(repeating: PostResponse(), count: members.count)
//
//    for (index, member) in members.enumerated() {
//
//        group.enter()
//
//        if let url = URL(string: member.blogUrl ?? "" + "/category") {//addCategoryStr(blogUrl: member.blogUrl) {
//            getPostsURL(url: url) { result in
//                switch result {
//                case .success(let urls):
//
//                    getPostTitleAndDate(urls: urls, startDate: startDate, endDate: endDate) { result in
//                        switch result {
//                        case .success(let postData):
//                            if let postData = postData {
//                                resultMembersData[index] = postData.postUrl == nil ? PostResponse(name: member.name, data: nil, errorMessage: "작성된 게시글이 없습니다.") : PostResponse(name: member.name, data: postData, errorMessage: nil)
//                            }
//                            group.leave()
//                        case .failure(let error):
//                            print(error)
//                            group.leave()
//                        }
//                    }
//                case .failure(let error):
//                    resultMembersData[index] = PostResponse(name: member.name, data: nil, errorMessage: "블로그 URL을 확인 해주세요.")
//                    group.leave()
//                }
//            }
//        } else {
//            // URL이 잘못된 경우
//            resultMembersData[index] = PostResponse(name: member.name, data: nil, errorMessage: "블로그 URL을 확인 해주세요.")
//            group.leave()
//        }
//    }
//
//    group.notify(queue: .main) {
//        completion(.success(resultMembersData))
//    }
//}
//
//// 페이지 마지막 번호 가지고오기2
//static func getLastPageNumber(member: UserModel, completion: @escaping (Result<[Int], CrawlingError>) -> ()) {
//
//    let url = URL(string: member.blogUrl ?? "" + "/category")
//
//    // URL nil 체크
//    if let url = url {
//        AF.request(url).responseString { result in
//            switch result.result {
//            case .success(let data):
//                guard let html = result.value else {
//                    completion(.failure(.urlError))
//                    return
//                }
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
//                        let pageNumbers = Int(String(html[range]).components(separatedBy: "=")[1])
//
//                        return pageNumbers
//                    }
//
//                    let pagesNumbers = matchedStrings.sorted()
//                    completion(.success(pagesNumbers))
//
//                } catch {
//                    print("getLastPageNumber error")
//                }
//            case .failure(let error):
//                print("category 번호 못가져옴")
//                completion(.failure(.error))
//            }
//        }
//    } else {
//        completion(.failure(.urlError))
//    }
//}
//
//// 작성한 게시글들 url 가지고오기2
//static func getPostsURL(url: URL, completion: @escaping (Result<[String], CrawlingError>) -> ()) {
//
//    AF.request(url).responseString { result in
//        switch result.result {
//        case .success(let html):
//            guard let headContent = getHtmlHead(html: html) else {
//                completion(.failure(.htmlError))
//                return
//            }
//
//            do {
//                let doc = try SwiftSoup.parse(headContent)
//                let scriptElements = try doc.select("script[type=application/ld+json]")
//                let jsonData = try scriptElements.first()?.html()
//
//                guard let data = jsonData?.data(using: .utf8),
//                      let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
//                      let itemList = json["itemListElement"] as? [[String: Any]] else {
//                    completion(.failure(.notFoundItemListElement))
//                    return
//                }
//
//                var urls = [String]()
//
//                itemList.forEach { item in
//                    if let item = item["item"] as? [String: String],
//                       let url = item["@id"] {
//                        urls.append(url)
//                    }
//                }
//                completion(.success(urls))
//            } catch {
//                completion(.failure(.tryError))
//            }
//
//        case .failure(_):
//            completion(.failure(.getPostURLError))
//        }
//    }
//}
//
//static func getPostTitleAndDate(urls: [String], startDate: Date?, endDate: Date?, completion: @escaping (Result<PostModel?, CrawlingError>) -> ()) {
//
//    var currentIndex = 0
//    let calendar = Calendar.current
//
//    func next() {
//
//        guard currentIndex < urls.count else {
//            print("없음 - \(urls)")
//            completion(.success(nil))
//            return
//        }
//
//        let currentUrl = urls[currentIndex]
//
//        if let url = URL(string: currentUrl) {
//            AF.request(url).responseString { result in
//                switch result.result {
//                case .success(let html):
//
//                    let headContent = getHtmlHead(html: html)
//
//                    do {
//                        let doc = try SwiftSoup.parse(headContent ?? "")
//                        let title = try doc.select("meta[property=og:title]").first()?.attr("content")
//                        let dateStr = try doc.select("meta[property=article:published_time]").first()?.attr("content")
//
//                        // 날짜 비교
//                        let dateRange = DateInterval(start: startDate!, end: endDate!)
//
//                        if dateRange.contains(dateStr?.toDate() ?? Date()) {
//                            let postModel = PostModel(title: title, date: dateStr, postUrl: currentUrl)
//                            completion(.success(postModel))
//                        } else {
//
//                            let result = calendar.compare(dateStr?.toDate() ?? Date(), to: startDate!, toGranularity: .day)
//
//                            switch result {
//                            case .orderedAscending:
//                                let postModel = PostModel(title: nil, date: nil, postUrl: nil)
//                                completion(.success(postModel))
//                            case .orderedDescending:
//                                currentIndex += 1
//                                next()
//                            default:
//                                currentIndex += 1
//                                next()
//                            }
//                        }
//                    } catch {
//                        completion(.failure(.tryError))
//                    }
//                case .failure(_):
//                    completion(.failure(.urlError))
//                }
//            }
//        }
//    }
//    next()
//}
