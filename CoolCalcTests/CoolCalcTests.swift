//
//  CoolCalcTests.swift
//  CoolCalcTests
//
//  Created by Jody Abney on 6/29/20.
//  Copyright © 2020 AbneyAnalytics. All rights reserved.
//

import XCTest
@testable import CoolCalc

class CoolCalcTests: XCTestCase {
    
    //MARK: - Properties
    var sut: CoolCalcBrain!

    //MARK: - SetUp
    override func setUp() {
        super.setUp()
        
        sut = CoolCalcBrain()
    }

    //MARK: - TearDown
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    
    //MARK: - Clear Test
    
    func testClear_RegistersAnswerAndBinaryOperationCleared() {
        sut.answer = 25
        sut.registerA = 1
        sut.registerB = 400
        sut.binaryOperation = .multiplication
        let displayValue = sut.performClear()
        XCTAssertNil(sut.answer)
        XCTAssertNil(sut.registerA)
        XCTAssertNil(sut.registerB)
        XCTAssertNil(sut.binaryOperation)
        XCTAssertEqual(displayValue, "0")
    }
    
    //MARK: - CalcMode Tests
    
    func testCalcMode_InitialStartUp() {
        XCTAssertEqual(sut.calcMode, CalcMode.firstOrClear)
    }
    
    func testCalcMode_FirstCalcOrAfterCalc() {
        sut.registerA = nil
        sut.registerB = nil
        sut.answer = nil
        sut.binaryOperation = nil
        XCTAssertEqual(sut.calcMode, CalcMode.firstOrClear)
    }
    
    func testCalcMode_NewCalcUsingPriorAnswer() {
        sut.registerA = nil
        sut.registerB = nil
        sut.answer = 5
        sut.binaryOperation = nil
        XCTAssertEqual(sut.calcMode, CalcMode.newCalcPriorAnswer)
    }
    
    func testCalcMode_InprogressCalc() {
        sut.registerA = 7
        sut.registerB = nil
        sut.binaryOperation = .addition
        XCTAssertEqual(sut.calcMode, CalcMode.inprogressCalc)
    }
    
    func testCalcMode_ChainCalc() {
        sut.registerA = 5
        sut.registerB = 7
        sut.binaryOperation = .division
        XCTAssertEqual(sut.calcMode, CalcMode.chainCalc)
    }
    
    
    //MARK: - Unary Calculation Tests
    
    //MARK: - Negation Tests
    func testUnaryCalculations_NegationNoDecimal() {
        let displayValue = 10051
        let resultDisplay = sut.performUnaryCalc(forOperation: .negation, usingDisplayValue: Double(displayValue))
        XCTAssertEqual(resultDisplay, -10051)
    }
    
    func testUnaryCalculations_NegationWithDecimal() {
        let displayValue = -10.5641
        let resultDisplay = sut.performUnaryCalc(forOperation: .negation, usingDisplayValue: displayValue)
        XCTAssertEqual(resultDisplay, 10.5641)
    }
    
    //MARK: - Percentage Tests
    func testUnaryCalculations_PercentageWithNoDecimal() {
        let displayValue = 95
        let resultDisplay = sut.performUnaryCalc(forOperation: .percentage, usingDisplayValue: Double(displayValue))
        XCTAssertEqual(resultDisplay, 0.95)
    }
    
    func testUnaryCalculations_PercentageWithDecimal() {
        let displayValue = 8.98
        let resultDisplay = sut.performUnaryCalc(forOperation: .percentage, usingDisplayValue: displayValue)
        XCTAssertEqual(resultDisplay, 0.0898)
    }
    
    
    //MARK: - Binary Operation Tests
    
    //MARK: - Addition
    func testAddition_UsingTwoIntegerOperands() {
        sut.registerA = 5
        sut.registerB = 20
        _ = sut.performBinaryCalc(forOperation: .addition)
        XCTAssertEqual(sut.answer, 25)
    }
    
    func testAddition_UsingTwoDecimalOperands() {
        sut.registerA = 5.5
        sut.registerB = 20.5
        _ = sut.performBinaryCalc(forOperation: .addition)
        XCTAssertEqual(sut.answer, 26)
    }
    
    func testAddition_UsingOneDecimalOperand() {
        sut.registerA = 5.5
        sut.registerB = 20
        _ = sut.performBinaryCalc(forOperation: .addition)
        XCTAssertEqual(sut.answer, 25.5)
    }
    
    //MARK: - Subtraction
    func testSubstraction_UsingTwoIntegerOperands() {
        sut.registerA = 5
        sut.registerB = 2
        _ = sut.performBinaryCalc(forOperation: .subtraction)
        XCTAssertEqual(sut.answer, 3)
    }
    
    func testSubstraction_UsingTwoDecimalOperands() {
        sut.registerA = 5.0
        sut.registerB = 2.5
        _ = sut.performBinaryCalc(forOperation: .subtraction)
        XCTAssertEqual(sut.answer, 2.5)
    }
    
    func testSubstraction_UsingOneDecimalOperand() {
        sut.registerA = 5
        sut.registerB = 2.5
        _ = sut.performBinaryCalc(forOperation: .subtraction)
        XCTAssertEqual(sut.answer, 2.5)
    }
    
    // Multiplication
    func testMultiplication_UsingTwoIntegerOperands() {
        sut.registerA = 10
        sut.registerB = 5
        _ = sut.performBinaryCalc(forOperation: .multiplication)
        XCTAssertEqual(sut.answer, 50)
    }
    
    func testMultiplication_UsingTwoDecimalOperands() {
        sut.registerA = 10.7
        sut.registerB = 5.4
        _ = sut.performBinaryCalc(forOperation: .multiplication)
        XCTAssertEqual(sut.answer, 57.78)
    }
    
    func testMultiplication_UsingOneDecimalOperand() {
        sut.registerA = 10
        sut.registerB = 5.7
        _ = sut.performBinaryCalc(forOperation: .multiplication)
        XCTAssertEqual(sut.answer, 57)
    }
    
    //MARK: - Division
    func testDivision_UsingTwoIntegerOperands() {
        sut.registerA = 20
        sut.registerB = 4
        _ = sut.performBinaryCalc(forOperation: .division)
        XCTAssertEqual(sut.answer, 5)
    }
    
    func testDivision_UsingTwoDecimalOperands() {
        sut.registerA = 20.3
        sut.registerB = 4.5
        _ = sut.performBinaryCalc(forOperation: .division)
        // check result rounded to two decimal places
        XCTAssertEqual(round(sut.answer!*100.0)/100.0, 4.51)
    }
    
    func testDivision_UsingOneDecimalOperands() {
        sut.registerA = 20
        sut.registerB = 4.1
        _ = sut.performBinaryCalc(forOperation: .division)
        XCTAssertEqual(round(sut.answer! * 100) / 100, 4.88)
    }
    
    func testDivision_InvalidDivisionResult() {
        sut.registerA = 50
        sut.registerB = 0
        _ = sut.performBinaryCalc(forOperation: .division)
        XCTAssertNil(sut.answer)
    }



}
