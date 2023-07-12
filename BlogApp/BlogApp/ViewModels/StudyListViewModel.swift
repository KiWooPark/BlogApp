//
//  StudyListViewModel.swift
//  BlogApp
//
//  Created by PKW on 2023/05/17.
//

import Foundation

class StudyListViewModel {
    
    // 스터디 데이터를 담을 배열
    var list: Observable<[Study]> = Observable([])
    
    // 스터디 데이터 배열의 카운트
    var listCount: Int {
        return list.value.count
    }
    
    // 코어데이터에 저장되어있는 스터디 데이터 가져오기
    func fetchStudys() {
        list.value = CoreDataManager.shared.fetchStudys()
        
        let contents = CoreDataManager.shared.fetchContent(studyEntity: list.value[0])

        for i in contents {
            print(i.finishDate, list.value.first?.startDate?.calculateWeekNumber(finishDate: i.finishDate!))

        }
        
        // 코어데이터 경로
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        print(paths)
    }
    
    // 기존 list에 스터디 데이터 추가
    func addStudy(_ study: Study?, completion: @escaping () -> ()) {
        // 전달받은 데이터 list 배열에 추가
        list.value.append(study!)
        // 코어데이터에 study 데이터 저장
        
        //CoreDataManager.shared.saveContext()
        completion()
    }
    
    func updateList(study: Study?) {
        if let index = list.value.firstIndex(where: {$0.id == study?.id}), let study = study {
            list.value[index] = study
        }
    }
    
    func deleteStudy(study: Study?, completion: @escaping () -> ()) {
        if let index = list.value.firstIndex(where: {$0.id == study?.id}), let study = study {
            list.value.remove(at: index)
            CoreDataManager.shared.deleteStudy(study: study)
            
            completion()
        }
    }
}



