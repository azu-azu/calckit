import Foundation

extension Calendar {
    func businessDaysBetween(from start: Date, to end: Date) -> Int {
        var count = 0
        var current = start

        while current <= end {
            if !isDateInWeekend(current) {
                count += 1
            }
            guard let next = date(byAdding: .day, value: 1, to: current) else { break }
            current = next
        }
        return count
    }

    func totalDaysBetween(from start: Date, to end: Date) -> Int {
        let components = dateComponents([.day], from: startOfDay(for: start), to: startOfDay(for: end))
        return (components.day ?? 0) + 1 // inclusive
    }

    func date(byAddingBusinessDays days: Int, to startDate: Date) -> Date {
        guard days != 0 else { return startDate }
        var remaining = abs(days)
        var current = startDate
        let increment = days > 0 ? 1 : -1
        while remaining > 0 {
            guard let next = date(byAdding: .day, value: increment, to: current) else { break }
            current = next
            if !isDateInWeekend(current) {
                remaining -= 1
            }
        }
        return current
    }
}
