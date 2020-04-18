//
//  ViewController.swift
//  CoolCalc
//
//  Created by Jody Abney on 4/15/20.
//  Copyright © 2020 AbneyAnalytics. All rights reserved.
//

import UIKit

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
    
    // Set up outlet for calculator Display
    @IBOutlet weak var calcDisplayLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func numberPressed(_ sender: UIButton) {
        
        // starting a new operand?
        if !operandEntryInProgress {
            operandEntryInProgress = true
            calcDisplayLabel.text! = sender.currentTitle!
        } else {
            calcDisplayLabel.text! += sender.currentTitle!
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
        
        print("start binary:")
        printStatus()
        
        // First calc (or after Clear is pressed)
        if coolCalcBrain.calcMode == CalcMode.firstOrClear {
            
            if let operand = Double(calcDisplayLabel.text!) {
                coolCalcBrain.registerA = operand
                coolCalcBrain.binaryOperation = BinaryOperation(rawValue: sender.currentTitle!)
                decimalKeyPressed = false
                operandEntryInProgress = false
                currentOperationButton = sender
                updateUI(currentOperationButton)
                
            } else {
                coolCalcBrain.binaryOperation = nil
                decimalKeyPressed = false
                operandEntryInProgress = false
                calcDisplayLabel.text = "Error: invalid number"
                currentOperationButton = nil
                return
            }
            
            // New calc using prior answer
        } else if coolCalcBrain.calcMode == CalcMode.newCalcPriorAnswer {
            
            coolCalcBrain.binaryOperation = BinaryOperation(rawValue: sender.currentTitle!)
            coolCalcBrain.registerA = coolCalcBrain.answer!
            operandEntryInProgress = false
            decimalKeyPressed = false
            updateUI(currentOperationButton)
            currentOperationButton = sender
            updateUI(currentOperationButton)
            
            // Inprogress calc
        } else if coolCalcBrain.calcMode == CalcMode.inprogressCalc {
            
            if let operand = Double(calcDisplayLabel.text!) {
                coolCalcBrain.registerB = operand
                performCalc()
                updateUI(currentOperationButton)
                coolCalcBrain.registerA = coolCalcBrain.answer
                coolCalcBrain.binaryOperation = BinaryOperation(rawValue: sender.currentTitle!)
                operandEntryInProgress = false
                decimalKeyPressed = false
                updateUI(sender)
                currentOperationButton = sender
            }
            // Chain calc
        } else if coolCalcBrain.calcMode == CalcMode.chainCalc {
            
            updateUI(currentOperationButton)
            performCalc()
            operandEntryInProgress = false
            decimalKeyPressed = false
            currentOperationButton = sender
            updateUI(sender)
        }
        
        print("end binary")
        printStatus()
    }
    
    // handle highlighting the active binaryOperation button
    func updateUI(_ sender: UIButton?) {
        if let sender = sender {
            if calcInProgress {
                sender.backgroundColor = .blue
                sender.titleLabel?.textColor = .white
            } else {
                sender.backgroundColor = .systemGray
                sender.titleLabel?.textColor = .black
            }
        }
    }
    
    func performCalc() {
        
        // perform the calculation
        guard coolCalcBrain.registerA != nil && coolCalcBrain.registerB != nil else {
            calcDisplayLabel.text = "Error: insufficient operands"
            return
        }
        
        if let result = coolCalcBrain.performBinaryCalc(forOperation: coolCalcBrain.binaryOperation!) {
            // update the calculator display
            calcDisplayLabel.text = String(result)
            
        } else {
            
            calcDisplayLabel.text = "Error: invalid calc"
        }
    }
    
    func printStatus() {
        print("registerLabel: \(String(describing: calcDisplayLabel.text))")
        print("RegisterA: \(String(describing: coolCalcBrain.registerA))")
        print("RegisterB: \(String(describing: coolCalcBrain.registerB))")
        print("Answer: \(String(describing: coolCalcBrain.answer))")
        print("BinaryOperation: \(String(describing: coolCalcBrain.binaryOperation))")
        print("currentOperationButton: \(String(describing: currentOperationButton?.currentTitle))")
        print("CalcMode: \(String(describing: coolCalcBrain.calcMode))")
        print()
    }
    
    @IBAction func equalPressed(_ sender: UIButton) {
        
        print("begin equal")
        printStatus()
        
        guard coolCalcBrain.binaryOperation != nil else {
            return
        }
        
        guard let operand = Double(calcDisplayLabel.text!) else {
            calcDisplayLabel.text = "Error: invalid number"
            return
        }
        
        // add the operand to the stack
        if operandEntryInProgress {
            coolCalcBrain.registerB = operand
            operandEntryInProgress = false
        }
        
        performCalc()
        
        decimalKeyPressed = false
        firstOperandEntered = false
        operandEntryInProgress = false
        updateUI(currentOperationButton)
        currentOperationButton = nil
        
        print("end equal")
        printStatus()
    }
    
    
    @IBAction func clearPressed(_ sender: UIButton) {
        
        calcDisplayLabel.text = String(Int(coolCalcBrain.performClear()))
        operandEntryInProgress = false
        decimalKeyPressed = false
        updateUI(divisionButton)
        updateUI(multplicationButton)
        updateUI(subtractionButton)
        updateUI(additionButton)
        currentOperationButton = nil
        coolCalcBrain.registerA = nil
        coolCalcBrain.registerB = nil
        coolCalcBrain.answer = nil
        coolCalcBrain.binaryOperation = nil
        
        print("after clear")
        printStatus()
        
    }
    
    
    @IBAction func decimalPressed(_ sender: UIButton) {
        
        if !decimalKeyPressed {
            operandEntryInProgress = true
            decimalKeyPressed = true
            calcDisplayLabel.text! += "."
        }
    }
    
    @IBAction func unaryPressed(_ sender: UIButton) {
        
        print("start percent:")
        printStatus()
        
        let unaryOperation = UnaryOperation(rawValue: sender.currentTitle!)!
        
        if let operand = Double(calcDisplayLabel.text!) {
            
            let result = coolCalcBrain.performUnaryCalc(forOperation: unaryOperation,
                                                        usingDisplayValue: operand)
            calcDisplayLabel.text = String(result)
            
        } else {
            calcDisplayLabel.text = "Error: invalid operand"
            coolCalcBrain.answer = nil
            coolCalcBrain.registerA = nil
            coolCalcBrain.registerB = nil
            operandEntryInProgress = false
            decimalKeyPressed = false
            updateUI(divisionButton)
            updateUI(multplicationButton)
            updateUI(subtractionButton)
            updateUI(additionButton)
            currentOperationButton = nil
            return
        }
        
        print("end percent")
        printStatus()
    }
    
}

