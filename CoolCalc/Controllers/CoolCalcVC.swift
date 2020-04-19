//
//  ViewController.swift
//  CoolCalc
//
//  Created by Jody Abney on 4/15/20.
//  Copyright © 2020 AbneyAnalytics. All rights reserved.
//

import UIKit


//MARK: - TODO: Numberformatter to limit number of digits displayed

class CoolCalcVC: UIViewController {
    
    var coolCalcBrain = CoolCalcBrain()
    
    var decimalKeyPressed = false
    var operandEntryInProgress = false
    var firstOperandEntered = false
    var currentOperationButton: UIButton?
    
    var calcInProgress: Bool {
        get {
            if coolCalcBrain.registerA != nil && coolCalcBrain.registerB == nil {
                return true
            } else {
                return false
            }
        }
    }
    
    // Set up outlets for binary operation buttons
    @IBOutlet weak var divisionButton: UIButton!
    @IBOutlet weak var multplicationButton: UIButton!
    @IBOutlet weak var subtractionButton: UIButton!
    @IBOutlet weak var additionButton: UIButton!
    
    // Set up outlets for calculator Display
    @IBOutlet weak var calcDisplayLabel: UILabel!
    @IBOutlet weak var calcHistoryLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calcDisplayLabel.text = "0"
        calcHistoryLabel.text = " "

    }
    
    @IBAction func numberPressed(_ sender: UIButton) {
        
        // starting a new operand?
        if !operandEntryInProgress {
            operandEntryInProgress = true
            calcDisplayLabel.text! = sender.currentTitle!
            calcHistoryLabel.text! += " " + sender.currentTitle!
        } else {
            calcDisplayLabel.text! += sender.currentTitle!
            calcHistoryLabel.text! += sender.currentTitle!
        }
    }
    
    @IBAction func binaryOperationPressed(_ sender: UIButton) {
        
        /*
         Calc Mode                   RegisterA   RegisterB   Answer      currentBinaryOperation
         First Calc / after Clear    Nil         Nil         Nil         nil
         New Calc use prior answer   Nil         Nil         Not Nil     nil
         In progress                 Not Nil     Nil         N/A         Not nil
         Chain calc                  Not Nil     Not Nil     N/A         Not nil
         */
        
//        print("start binary:")
//        printStatus()
        
        // First calc (or after Clear is pressed)
        if coolCalcBrain.calcMode == CalcMode.firstOrClear {
            
            if let operand = Double(calcDisplayLabel.text!) {
                coolCalcBrain.registerA = operand
                coolCalcBrain.binaryOperation = BinaryOperation(rawValue: sender.currentTitle!)
                resetVC()
                currentOperationButton = sender
                updateUI(currentOperationButton)
                calcHistoryLabel.text! += " " + sender.currentTitle!
                
            } else {
                coolCalcBrain.binaryOperation = nil
                calcDisplayLabel.text = "Error: invalid number"
                calcHistoryLabel.text = ""
                resetVC()
                return
            }
            
            // New calc using prior answer
        } else if coolCalcBrain.calcMode == CalcMode.newCalcPriorAnswer {
            
            coolCalcBrain.binaryOperation = BinaryOperation(rawValue: sender.currentTitle!)
            coolCalcBrain.registerA = coolCalcBrain.answer!
            updateUI(currentOperationButton)
            resetVC()
            currentOperationButton = sender
            updateUI(currentOperationButton)
            calcHistoryLabel.text! += " " + sender.currentTitle!
            
            // Inprogress calc
        } else if coolCalcBrain.calcMode == CalcMode.inprogressCalc {
            
            if let operand = Double(calcDisplayLabel.text!) {
                coolCalcBrain.registerB = operand
                performCalc()
                updateUI(currentOperationButton)
                coolCalcBrain.registerA = coolCalcBrain.answer
                coolCalcBrain.binaryOperation = BinaryOperation(rawValue: sender.currentTitle!)
                updateUI(sender)
                resetVC()
                currentOperationButton = sender
                calcHistoryLabel.text! += " " + sender.currentTitle!
            }
            // Chain calc
        } else if coolCalcBrain.calcMode == CalcMode.chainCalc {
            
            updateUI(currentOperationButton)
            performCalc()
            calcHistoryLabel.text! += " " + sender.currentTitle!
            resetVC()
            currentOperationButton = sender
            updateUI(sender)
        }
        
//        print("end binary")
//        printStatus()
    }
    
    // handle highlighting the active binaryOperation button
    func updateUI(_ sender: UIButton?) {
        if let sender = sender {
            if calcInProgress {
                sender.backgroundColor = .systemBlue
                sender.titleLabel?.textColor = .white
            } else {
                sender.backgroundColor = .systemGray
                sender.titleLabel?.textColor = .label
            }
        }
    }
    
    func performCalc() {
        
        // perform the calculation
        guard coolCalcBrain.registerA != nil && coolCalcBrain.registerB != nil else {
            calcDisplayLabel.text = "Error: insufficient operands"
            calcHistoryLabel.text! += " Error"
            return
        }
        
        if let result = coolCalcBrain.performBinaryCalc(forOperation: coolCalcBrain.binaryOperation!) {
            // update the calculator display
            calcDisplayLabel.text = String(result)
            
        } else {
            
            calcDisplayLabel.text = "Error: invalid calc"
            calcHistoryLabel.text! += " Error"
        }
    }
    
//    func printStatus() {
//        print("registerLabel: \(String(describing: calcDisplayLabel.text))")
//        print("RegisterA: \(String(describing: coolCalcBrain.registerA))")
//        print("RegisterB: \(String(describing: coolCalcBrain.registerB))")
//        print("Answer: \(String(describing: coolCalcBrain.answer))")
//        print("BinaryOperation: \(String(describing: coolCalcBrain.binaryOperation))")
//        print("currentOperationButton: \(String(describing: currentOperationButton?.currentTitle))")
//        print("CalcMode: \(String(describing: coolCalcBrain.calcMode))")
//        print()
//    }
    
    @IBAction func equalPressed(_ sender: UIButton) {
        
//        print("begin equal")
//        printStatus()
        
        guard coolCalcBrain.binaryOperation != nil else {
            return
        }
        
        guard let operand = Double(calcDisplayLabel.text!) else {
            calcDisplayLabel.text = "Error: invalid number"
            calcHistoryLabel.text! += " Error"
            return
        }
        
        // add the operand to the stack
        if operandEntryInProgress {
            coolCalcBrain.registerB = operand
            operandEntryInProgress = false
        }
        
        performCalc()
        
        calcHistoryLabel.text! += " " + sender.currentTitle!
        
        firstOperandEntered = false
        updateUI(currentOperationButton)
        resetVC()
        
//        print("end equal")
//        printStatus()
    }
    
    
    @IBAction func clearPressed(_ sender: UIButton) {
        
        calcDisplayLabel.text = coolCalcBrain.performClear()
        resetVC()
        calcHistoryLabel.text = " "
        coolCalcBrain.reset()

        // reset binary buttons
        updateUI(divisionButton)
        updateUI(multplicationButton)
        updateUI(subtractionButton)
        updateUI(additionButton)
        
//        print("after clear")
//        printStatus()
        
    }
    
    
    @IBAction func decimalPressed(_ sender: UIButton) {
        
        if !decimalKeyPressed {
            operandEntryInProgress = true
            decimalKeyPressed = true
            calcDisplayLabel.text! += "."
            calcHistoryLabel.text! += "."
        }
    }
    
    @IBAction func unaryPressed(_ sender: UIButton) {
        
//        print("start percent:")
//        printStatus()
        
        let unaryOperation = UnaryOperation(rawValue: sender.currentTitle!)!
        
        if let operand = Double(calcDisplayLabel.text!) {
            
            if operand == 0 {
                return
            }
            
            calcHistoryLabel.text! += " " + sender.currentTitle!
            
            let result = coolCalcBrain.performUnaryCalc(forOperation: unaryOperation,
                                                        usingDisplayValue: operand)
            calcDisplayLabel.text = String(result)
            
        } else {
            calcDisplayLabel.text = "Error: invalid operand"
            coolCalcBrain.reset()
            resetVC()
            
            // reset binary buttons
            updateUI(divisionButton)
            updateUI(multplicationButton)
            updateUI(subtractionButton)
            updateUI(additionButton)
            return
        }
        
//        print("end percent")
//        printStatus()
    }
    
    func resetVC() {
        operandEntryInProgress = false
        decimalKeyPressed = false
        currentOperationButton = nil
    }
    
}

