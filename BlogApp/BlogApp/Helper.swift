//
//  Helper.swift
//  BlogApp
//
//  Created by PKW on 2023/05/19.
//

import Foundation

// MVVM 패턴에서 데이터 바인딩을 위한 핼퍼 클래스
class Observable<T> {
    
    // listener는 값 변경 시 호출될 클로저를 저장
    private var listener: ((T) -> Void)?
    
    // #2
    // 값이 변경될 때마다 didSet 블록이 실행
    // didSet 블록 내에서 listener 클로저를 호출하여 값 변경
    var value: T {
        didSet {
            listener?(value)
        }
    }
    
    // #1
    // 초기값을 받아 Observable 인스턴스를 생성합니다.
    init(_ value: T) {
        self.value = value
    }
    
    // #3
    // bind 메서드는 값 변경 시 호출될 클로저를 전달
    // 클로저는 초기값을 전달받은 상태에서 바로 실행되며
    // listener에 클로저를 저장하여 값 변경 시 호출될 수 있도록 함
    func bind(_ closure: @escaping (T) -> Void) {
    
//        //원래 코드
//        closure(value)
        listener = closure
    }
}
