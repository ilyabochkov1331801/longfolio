//
//  Date+Extensions.swift
//  SharedWorkers
//
//  Created by Илья Бочков on 17.04.26.
//

import Foundation

extension Date {
    func isSameDay(with other: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: other)
    }
    
    var isWeekend: Bool {
        Calendar.current.isDateInWeekend(self)
    }
}
