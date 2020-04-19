//
//  CoolCalcBrain.swift
//  CoolCalc
//
//  Created by Jody Abney on 4/15/20.
//  Copyright © 2020 AbneyAnalytics. All rights reserved.
//

import Foundation


struct CoolCalcBrain {
    
    var registerA: Double?
    var registerB: Double?
    var answer: Double?
    
    var binaryOperation: BinaryOperation?
    
    var calcMode: CalcMode? {
        get {
            /*
             Calc Mode                   RegisterA   RegisterB   Answer      binaryOperation
             First Calc / after Clear    Nil         Nil         Nil         nil
             New Calc use prior answer   Nil         Nil         Not Nil     nil
             In progress                 Not Nil     Nil         N/A         Not nil
             Chain Calc                  Not Nil     Not Nil     N/A         Not nil
             */
            
            var mode: CalcMode?
            
            // First Calc / After Calc
            if registerA == nil && registerB == nil && answer == nil && binaryOperation == nil {
                mode = .firstOrClear
                
                // New Calc Using Prior Answer
            } else if registerA == nil && registerB == nil && answer != nil && binaryOperation == nil {
                mode = .newCalcPriorAnswer
                
                // Inprogress Calc
            } else if registerA != nil && registerB == nil && binaryOperation != nil {
                mode = .inprogressCalc
                
                // Chain calc
            } else if registerA != nil && registerB != nil && binaryOperation != nil {
                mode = .chainCalc
            }
            
            return mode
        }
    }
    
    mutating func performBinaryCalc(forOperation operation: BinaryOperation) -> Double? {
        
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
        registerA = nil
        registerB = nil
        binaryOperation = nil
        return result
    }
    
    func performUnaryCalc(forOperation operation: UnaryOperation,
                          usingDisplayValue displayValue: Double) -> Double {
        
        guard displayValue != 0.0 else {
            return 0.0
        }
        
        switch operation {
        case .negation:
            return displayValue * -1.0
        case .percentage:
            return displayValue / 100.0
        }
    }
    
    mutating func performClear() -> String {
        
        reset()
        return "0"
    }
    
    mutating func reset() {
        registerA = nil
        registerB = nil
        answer = nil
        binaryOperation = nil
    }
    
}
