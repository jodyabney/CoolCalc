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
    
    @IBOutlet weak var registerLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func numberPressed(_ sender: UIButton) {
        
        print("Start numberPressed")
        printStatus()
        
        // starting a new operand?
        if !operandEntryInProgress {
            operandEntryInProgress = true
            registerLabel.text! = sender.currentTitle!
        } else {
            registerLabel.text! += sender.currentTitle!
        }
        
        print("End numberPressed")
        printStatus()
    }
    
    @IBAction func binaryOperationPressed(_ sender: UIButton) {
        
        /*
         Calc Mode                   RegisterA   RegisterB   Answer      currentBinaryOperation
         First Calc / after Clear    Nil         Nil         Nil         nil
         New Calc use prior answer   Nil         Nil         Not Nil     nil
         In progress                 Not Nil     Nil         N/A         Not nil
         Ready for Equal             Not Nil     Not Nil     N/A         Not nil
         */
        
        // First calc (or after Clear is pressed)
        if coolCalcBrain.registerA == nil && coolCalcBrain.registerB == nil &&
            coolCalcBrain.answer == nil && coolCalcBrain.binaryOperation == nil {
            
            print("start first calc")
            printStatus()
            
            if let operand = Double(registerLabel.text!) {
                coolCalcBrain.registerA = operand
                coolCalcBrain.binaryOperation = ValidBinaryOperation(rawValue: sender.currentTitle!)
                decimalKeyPressed = false
                operandEntryInProgress = false
                currentOperationButton = sender
                updateUI(currentOperationButton)
                
                print("End first calc")
                printStatus()
                
            } else {
                coolCalcBrain.binaryOperation = nil
                decimalKeyPressed = false
                operandEntryInProgress = false
                registerLabel.text = "Error: invalid number"
                currentOperationButton = nil
                return
            }
            
        // New calc using prior answer
        } else if coolCalcBrain.registerA == nil && coolCalcBrain.registerB == nil &&
            coolCalcBrain.answer != nil && coolCalcBrain.binaryOperation == nil {
            
            print("Start New Calc using Prior Answer")
            printStatus()
            
            coolCalcBrain.binaryOperation = ValidBinaryOperation(rawValue: sender.currentTitle!)
            coolCalcBrain.registerA = coolCalcBrain.answer!
            operandEntryInProgress = false
            decimalKeyPressed = false
            updateUI(currentOperationButton)
            currentOperationButton = sender
            updateUI(currentOperationButton)
            
            print("End New Calc using Prior Answer")
            printStatus()
            
        // Inprogress calc
        } else if coolCalcBrain.registerA != nil && coolCalcBrain.registerB == nil &&
            coolCalcBrain.binaryOperation != nil {
            
            print("Start Inprogress Calc")
            printStatus()
            
            if let operand = Double(registerLabel.text!) {
                coolCalcBrain.registerB = operand
                performCalc()
                updateUI(currentOperationButton)
                coolCalcBrain.registerA = coolCalcBrain.answer
                coolCalcBrain.binaryOperation = ValidBinaryOperation(rawValue: sender.currentTitle!)
                operandEntryInProgress = false
                decimalKeyPressed = false
                updateUI(sender)
                currentOperationButton = sender
                
                print("End Inprogress Calc")
                printStatus()
            }
            
        // Ready for equal
        } else if coolCalcBrain.registerA != nil && coolCalcBrain.registerB != nil &&
            coolCalcBrain.binaryOperation != nil {
            
            print("shouldn't get to this path")
            
        }
    }
    
    
    func printStatus() {
        print("registerLabel: \(String(describing: registerLabel.text))")
        print("RegisterA: \(String(describing: coolCalcBrain.registerA))")
        print("RegisterB: \(String(describing: coolCalcBrain.registerB))")
        print("Answer: \(String(describing: coolCalcBrain.answer))")
        print("BinaryOperation: \(String(describing: coolCalcBrain.binaryOperation))")
        print()
    }
    
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
            registerLabel.text = "Error: insufficient operands"
            return
        }
        
        if let result = coolCalcBrain.performBinaryCalc(forOperation: coolCalcBrain.binaryOperation!) {
            
            // put the result on the stack and update the register display
            registerLabel.text = String(result)
            
        } else {
            
            registerLabel.text = "Error: invalid calc"
        }
    }
    
    
    @IBAction func equalPressed(_ sender: UIButton) {
        
        print("Start Equal")
        printStatus()
        
        guard let operand = Double(registerLabel.text!) else {
            registerLabel.text = "Error: invalid number"
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
        
        print("End Equal")
        printStatus()
        
    }
    
    
    @IBAction func clearPressed(_ sender: UIButton) {
        
        print("Start Clear")
        printStatus()
        
        registerLabel.text = String(Int(coolCalcBrain.performClear()))
        operandEntryInProgress = false
        decimalKeyPressed = false
        updateUI(currentOperationButton)
        currentOperationButton = nil
        
        print("End Clear")
        printStatus()
    }
    
    
    @IBAction func decimalPressed(_ sender: UIButton) {
        
        if !decimalKeyPressed {
            operandEntryInProgress = true
            decimalKeyPressed = true
            registerLabel.text! += "."
        }
    }
    
    @IBAction func percentPressed(_ sender: UIButton) {
        
        if operandEntryInProgress {
            if let operand = Double(registerLabel.text!) {
                coolCalcBrain.stack.append(operand)
            } else {
                registerLabel.text = "Error: percent calc"
                return
            }
        }
        let result = coolCalcBrain.performUnaryCalc(forOperation: .percentage)
        registerLabel.text = String(result!)
        operandEntryInProgress = false
        decimalKeyPressed = false
        print(coolCalcBrain.stack)
    }
    
    
}

