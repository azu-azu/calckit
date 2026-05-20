import Foundation

struct CalcEngine {
    private(set) var displayValue: String = "0"
    private(set) var expression: String = ""

    private var tokens: [Token] = []
    private var currentNumber: String = "0"
    private var hasInput = false
    private var hasDecimalPoint = false
    private var lastActionWasEquals = false
    private var openParenCount = 0
    private var frozenSteps: [String] = []
    private var snapshotBeforeEquals: Snapshot?

    private struct Snapshot {
        let displayValue: String
        let expression: String
        let tokens: [Token]
        let currentNumber: String
        let hasInput: Bool
        let hasDecimalPoint: Bool
        let openParenCount: Int
    }

    enum Operator: String {
        case add = "+"
        case subtract = "-"
        case multiply = "×"
        case divide = "÷"

        var symbol: String { rawValue }

        var precedence: Int {
            switch self {
            case .add, .subtract: 1
            case .multiply, .divide: 2
            }
        }

        func apply(_ lhs: Decimal, _ rhs: Decimal) -> Decimal? {
            switch self {
            case .add: lhs + rhs
            case .subtract: lhs - rhs
            case .multiply: lhs * rhs
            case .divide: rhs == 0 ? nil : lhs / rhs
            }
        }
    }

    private enum Token {
        case number(Decimal)
        case op(Operator)
        case openParen
        case closeParen

        var display: String {
            switch self {
            case .number(let v): Self.formatDecimal(v)
            case .op(let o): o.symbol
            case .openParen: "("
            case .closeParen: ")"
            }
        }

        static func formatDecimal(_ value: Decimal) -> String {
            let nsDecimal = value as NSDecimalNumber
            let doubleValue = nsDecimal.doubleValue
            if doubleValue == doubleValue.rounded() && abs(doubleValue) < 1e15 {
                return String(format: "%.0f", doubleValue)
            }
            let formatter = NumberFormatter()
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 10
            formatter.numberStyle = .decimal
            formatter.usesGroupingSeparator = false
            return formatter.string(from: nsDecimal) ?? "\(value)"
        }
    }

    // MARK: - Input

    mutating func inputDigit(_ digit: String) {
        if lastActionWasEquals {
            clear()
        }

        if currentNumber == "0" && digit != "0" {
            currentNumber = digit
        } else if currentNumber == "0" && digit == "0" {
            // do nothing
        } else {
            currentNumber += digit
        }
        hasInput = true
        displayValue = displayForCurrentNumber
        updateExpression()
    }

    mutating func inputDecimal() {
        if lastActionWasEquals {
            clear()
        }
        if !hasDecimalPoint {
            currentNumber += "."
            hasDecimalPoint = true
            hasInput = true
            displayValue = displayForCurrentNumber
            updateExpression()
        }
    }

    mutating func inputOperator(_ op: Operator) {
        lastActionWasEquals = false
        flushCurrentNumber()

        // 最後の token が operator なら置き換える
        if case .op = tokens.last {
            tokens[tokens.count - 1] = .op(op)
        } else {
            tokens.append(.op(op))
        }

        updateExpression()

        // 中間結果を表示（末尾の operator を除いて evaluate）
        let tokensWithoutTrailingOp = tokens.filter { _ in true }.dropLast()
        if let result = evaluateTokens(Array(tokensWithoutTrailingOp)) {
            displayValue = formatNumber(result)
        }

        currentNumber = "0"
        hasInput = false
        hasDecimalPoint = false
    }

    mutating func inputOpenParen() {
        if lastActionWasEquals {
            clear()
        }

        // 数字の直後や ) の直後は暗黙の × を挿入
        if hasInput {
            flushCurrentNumber()
            tokens.append(.op(.multiply))
        } else if isImplicitMultiplyNeeded() {
            tokens.append(.op(.multiply))
        }

        tokens.append(.openParen)
        openParenCount += 1
        updateExpression()
        currentNumber = "0"
        hasInput = false
        hasDecimalPoint = false
    }

    mutating func inputCloseParen() {
        guard openParenCount > 0 else { return }

        flushCurrentNumber()
        tokens.append(.closeParen)
        openParenCount -= 1
        updateExpression()

        // 閉じ括弧後の display は式の途中評価を表示
        if let result = evaluateTokens(tokens) {
            displayValue = formatNumber(result)
        }
        currentNumber = "0"
        hasInput = false
        hasDecimalPoint = false
    }

    mutating func inputPercent() {
        if var value = Decimal(string: currentNumber) {
            value = value / 100
            currentNumber = formatNumber(value)
            displayValue = currentNumber
        }
    }

    mutating func toggleSign() {
        if hasInput, let value = Decimal(string: currentNumber), value != 0 {
            let negated = -value
            currentNumber = formatNumber(negated)
            hasDecimalPoint = currentNumber.contains(".")
            displayValue = displayForCurrentNumber
            updateExpression()
        }
    }

    // MARK: - Evaluate

    mutating func evaluate() {
        flushCurrentNumber()

        // 閉じ忘れた括弧を自動で閉じる
        while openParenCount > 0 {
            tokens.append(.closeParen)
            openParenCount -= 1
        }

        // = 前の state を保存
        snapshotBeforeEquals = Snapshot(
            displayValue: displayValue,
            expression: expression,
            tokens: tokens,
            currentNumber: currentNumber,
            hasInput: hasInput,
            hasDecimalPoint: hasDecimalPoint,
            openParenCount: openParenCount
        )

        guard let result = evaluateTokens(tokens) else {
            displayValue = "Error"
            return
        }

        let resultStr = formatNumber(result)

        // 現在の intermediate steps を freeze
        frozenSteps = intermediateSteps

        expression = tokens.map(\.display).joined(separator: " ")
        displayValue = resultStr

        tokens = []
        currentNumber = resultStr
        hasInput = true
        hasDecimalPoint = currentNumber.contains(".")
        lastActionWasEquals = true
    }

    // MARK: - Actions

    mutating func clear() {
        displayValue = "0"
        expression = ""
        currentNumber = "0"
        hasInput = false
        tokens = []
        hasDecimalPoint = false
        lastActionWasEquals = false
        openParenCount = 0
        frozenSteps = []
    }

    mutating func backspace() {
        if lastActionWasEquals, let snap = snapshotBeforeEquals {
            displayValue = snap.displayValue
            expression = snap.expression
            tokens = snap.tokens
            currentNumber = snap.currentNumber
            hasInput = snap.hasInput
            hasDecimalPoint = snap.hasDecimalPoint
            openParenCount = snap.openParenCount
            lastActionWasEquals = false
            frozenSteps = []
            snapshotBeforeEquals = nil
            // return せずそのまま下の backspace 処理へ
        }

        if hasInput && currentNumber.count > 1 {
            let removed = currentNumber.removeLast()
            if removed == "." {
                hasDecimalPoint = false
            }
            // マイナス記号だけ残った場合は 0 に戻す
            if currentNumber == "-" {
                currentNumber = "0"
                hasInput = false
            }
            displayValue = displayForCurrentNumber
            updateExpression()
        } else if hasInput {
            currentNumber = "0"
            hasInput = false
            displayValue = currentNumber
            updateExpression()
        } else if let last = tokens.last {
            // 数字入力中でなければ直前の token を消す
            switch last {
            case .openParen:
                openParenCount -= 1
            case .closeParen:
                openParenCount += 1
            default:
                break
            }
            tokens.removeLast()
            updateExpression()
        }
    }

    // MARK: - State for saving

    var fullExpression: String {
        if expression.isEmpty {
            return displayValue
        }
        return "\(expression) = \(displayValue)"
    }

    var result: String {
        displayValue
    }

    /// 段階的に簡略化した中間ステップ
    /// 例: ( 1 + 2 ) × 3 × → ["3 × 3", "9"]
    var intermediateSteps: [String] {
        // = 押した後は frozen steps を返す
        if lastActionWasEquals {
            return frozenSteps
        }

        var allTokens = tokens
        if hasInput, let value = Decimal(string: currentNumber) {
            allTokens.append(.number(value))
        }
        guard allTokens.count > 1 else { return [] }

        var steps: [String] = []
        let originalStr = allTokens.map(\.display).joined(separator: " ")

        // Step 1: 括弧を resolve
        let resolved = resolveParenGroups(allTokens)
        let resolvedStr = resolved.map(\.display).joined(separator: " ")
        if resolvedStr != originalStr {
            steps.append(resolvedStr)
        }

        // Step 2: resolve 後の式を evaluate できるなら結果を追加
        // （末尾が operator なら除いて evaluate）
        var evalTokens = resolved
        if case .op = evalTokens.last {
            evalTokens = Array(evalTokens.dropLast())
        }
        // 数字1つだけなら追加不要（すでに resolvedStr で表示済み）
        if evalTokens.count > 1, let value = evaluateTokens(evalTokens) {
            let resultStr = formatNumber(value)
            if steps.last != resultStr {
                steps.append(resultStr)
            }
        }

        return steps
    }

    /// 完結した括弧グループだけを evaluate して置き換える
    private func resolveParenGroups(_ tokens: [Token]) -> [Token] {
        var result: [Token] = []
        var i = 0

        while i < tokens.count {
            if case .openParen = tokens[i] {
                // matching close paren を探す
                var depth = 1
                var j = i + 1
                while j < tokens.count && depth > 0 {
                    if case .openParen = tokens[j] { depth += 1 }
                    if case .closeParen = tokens[j] { depth -= 1 }
                    j += 1
                }

                if depth == 0 {
                    // i..<j が完結した括弧グループ
                    let inner = Array(tokens[(i + 1)..<(j - 1)])
                    // inner にネストした括弧があれば再帰的に resolve
                    let resolvedInner = resolveParenGroups(inner)
                    if let value = evaluateTokens(resolvedInner) {
                        result.append(.number(value))
                    } else {
                        // evaluate できなければそのまま残す
                        result.append(contentsOf: tokens[i..<j])
                    }
                    i = j
                } else {
                    // 閉じてない括弧 → そのまま残す
                    result.append(tokens[i])
                    i += 1
                }
            } else {
                result.append(tokens[i])
                i += 1
            }
        }

        return result
    }

    // MARK: - Private

    private mutating func flushCurrentNumber() {
        guard hasInput, let value = Decimal(string: currentNumber) else { return }
        tokens.append(.number(value))
        currentNumber = "0"
        hasInput = false
    }

    private var displayForCurrentNumber: String {
        currentNumber.hasPrefix("-") ? "(\(currentNumber))" : currentNumber
    }

    private mutating func updateExpression() {
        var parts = tokens.map(\.display)
        if hasInput {
            if currentNumber.hasPrefix("-") {
                parts.append("(\(currentNumber))")
            } else {
                parts.append(currentNumber)
            }
        }
        expression = parts.joined(separator: " ")
    }

    private func isImplicitMultiplyNeeded() -> Bool {
        guard let last = tokens.last else { return false }
        switch last {
        case .number, .closeParen: return true
        default: return false
        }
    }

    // MARK: - Shunting-yard evaluation

    private func evaluateTokens(_ tokens: [Token]) -> Decimal? {
        guard !tokens.isEmpty else { return nil }

        // Shunting-yard → RPN
        var output: [Token] = []
        var opStack: [Token] = []

        for token in tokens {
            switch token {
            case .number:
                output.append(token)

            case .op(let op):
                while let top = opStack.last {
                    if case .op(let topOp) = top, topOp.precedence >= op.precedence {
                        output.append(opStack.removeLast())
                    } else {
                        break
                    }
                }
                opStack.append(token)

            case .openParen:
                opStack.append(token)

            case .closeParen:
                while let top = opStack.last {
                    if case .openParen = top {
                        opStack.removeLast()
                        break
                    }
                    output.append(opStack.removeLast())
                }
            }
        }

        while !opStack.isEmpty {
            let top = opStack.removeLast()
            if case .openParen = top { continue }
            output.append(top)
        }

        // Evaluate RPN
        var stack: [Decimal] = []

        for token in output {
            switch token {
            case .number(let value):
                stack.append(value)
            case .op(let op):
                guard stack.count >= 2 else { return nil }
                let right = stack.removeLast()
                let left = stack.removeLast()
                guard let result = op.apply(left, right) else { return nil }
                stack.append(result)
            default:
                break
            }
        }

        return stack.last
    }

    // MARK: - Formatting

    private func formatNumber(_ value: Decimal) -> String {
        Token.formatDecimal(value)
    }
}
