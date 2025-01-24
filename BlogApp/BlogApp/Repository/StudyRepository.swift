//
//  StudyRepository.swift
//  BlogApp
//
//  Created by PKW on 1/23/25.
//

import Foundation

protocol StudyRepository {
    func fetchStudys() -> [Study]
    func fetchLastContentDeadlineDate(study: Study) -> Date
    func calculateDday(study: Study) -> Int
    func isDeadlinePassed(study: Study) -> Bool
}

class DefaultStudyRepository: StudyRepository {
    private func fetchLastContent(for study: Study) -> Content? {
        return CoreDataManager.shared.fetchLastContent(studyEntity: study)
    }
    
    func fetchStudys() -> [Study] {
        return CoreDataManager.shared.fetchStudyList()
    }
    
    func fetchLastContentDeadlineDate(study: Study) -> Date {
        guard let deadline = fetchLastContent(for: study)?.deadlineDate else {
            return Date()
        }
        return deadline
    }
    
    func calculateDday(study: Study) -> Int {
        guard let lastContent = fetchLastContent(for: study) else {
            return 9999
        }
        
        return lastContent.calculateDday()
    }
    
    func isDeadlinePassed(study: Study) -> Bool {
        guard let lastContent = fetchLastContent(for: study) else {
            return true
        }
    
        return lastContent.isDeadlinePassed()
    }
}
