//
//  CoolCalcBrain.swift
//  CoolCalc
//
//  Created by Jody Abney on 4/15/20.
//  Copyright © 2020 AbneyAnalytics. All rights reserved.
//

import Foundation

enum ValidBinaryOperation: String {
    case addition = "+"
    case subtraction = "-"
    case multiplication = "x"
    case division = "/"
}

enum ValidUnaryOperation: String {
    case negation = "+/-"
    case percentage = "%"
}

struct CoolCalcBrain {
    
    var stack: [Double] = []
    
    var registerA: Double?
    var registerB: Double?
    var answer: Double?
    
    //var operandEntryInProgress: Bool = false
    //var firstOperandEntered: Bool = false
    //var operationEntered: Bool = false
    var binaryOperation: ValidBinaryOperation?
    
    mutating func performBinaryCalc(forOperation operation: ValidBinaryOperation) -> Double? {
        
        var result = 0.0

        let a = registerA!
        let b = registerB!
        
        switch operation {
        case .addition:
            result = a + b
        case .subtraction:
            result = a - b
        case .multiplication:
            result = a * b
        case .division:
            guard (a / b).isFinite else {
                return nil
            }
            result = a / b
        }
        answer = result
        stack.append(answer!)
        registerA = nil
        registerB = nil
        binaryOperation = nil
        return result
    }
    
    mutating func performUnaryCalc(forOperation operation: ValidUnaryOperation) -> Double? {
        
        var result = 0.0
        let a = registerA!
        
        switch operation {
        case .negation:
            result = -1.0 * a
        case .percentage:
            result = a / 100.0
        }
        answer = result
        registerA = nil
        return result
    }
    
    mutating func performClear() -> Double {
        
        registerA = nil
        registerB = nil
        answer = nil
        binaryOperation = nil
        return 0.0
    }
}
