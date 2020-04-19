//
//  ViewController.swift
//  CoolCalc
//
//  Created by Jody Abney on 4/15/20.
//  Copyright © 2020 AbneyAnalytics. All rights reserved.
//

import UIKit


class CoolCalcVC: UIViewController {
    
    //MARK: - Properties
    
    var coolCalcBrain = CoolCalcBrain()
    
    let decimalCharacter = Locale.current.decimalSeparator
    
    let numberFormatter: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.roundingMode = .halfUp
        nf.minimumFractionDigits = 0
        nf.maximumFractionDigits = 4
        nf.paddingPosition = .beforePrefix
        nf.paddingCharacter = "0"
        return nf
    }()
    
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
    
    //MARK: - IBOutlets
    
    // Set up a decimal button to enable localization
    @IBOutlet weak var decimalButton: RoundedButton!
    
    // Set up outlets for binary operation buttons
    @IBOutlet weak var divisionButton: UIButton!
    @IBOutlet weak var multplicationButton: UIButton!
    @IBOutlet weak var subtractionButton: UIButton!
    @IBOutlet weak var additionButton: UIButton!
    
    // Set up outlets for calculator Display
    @IBOutlet weak var calcDisplayLabel: UILabel!
    @IBOutlet weak var calcHistoryLabel: UILabel!
    
    //MARK: - Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set intial display
        calcDisplayLabel.text = "0"
        // set initial history
        calcHistoryLabel.text = " "
        
        // Set decimal chracter on the decimal button
        decimalButton.titleLabel?.text = decimalCharacter
    }
    
    //MARK: - IBActions
    
    @IBAction func numberPressed(_ sender: UIButton) {
        
        // starting a new operand?
        if !operandEntryInProgress {
            operandEntryInProgress = true
            calcDisplayLabel.text! = sender.currentTitle!
            calcHistoryLabel.text! += " " + sender.currentTitle!
        } else { // append if not a new operand
            calcDisplayLabel.text! += sender.currentTitle!
            calcHistoryLabel.text! += sender.currentTitle!
        }
    }
    
    @IBAction func binaryOperationPressed(_ sender: UIButton) {
        
        print(coolCalcBrain.calcMode!)
        
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
        
        print(coolCalcBrain.calcMode!)
    }
    
    
    @IBAction func equalPressed(_ sender: UIButton) {
        
        // ensure for a binary operation is set
        guard coolCalcBrain.binaryOperation != nil else {
            return
        }
        
        // ensure a valid operand is in the calc display
        guard let operand = Double(calcDisplayLabel.text!) else {
            calcDisplayLabel.text = "Error: invalid number"
            calcHistoryLabel.text! += " Error"
            return
        }
        
        // add the operand to the registerB
        if operandEntryInProgress {
            coolCalcBrain.registerB = operand
            operandEntryInProgress = false
        }
        
        // perform the calculation
        performCalc()
        
        // append to the history
        calcHistoryLabel.text! += " " + sender.currentTitle!
        // reset first operand indicator
        firstOperandEntered = false
        // update the UI
        updateUI(currentOperationButton)
        // reset the VC
        resetVC()
        
    }
    
    
    @IBAction func clearPressed(_ sender: UIButton) {
        
        // clear the calc display
        calcDisplayLabel.text = coolCalcBrain.performClear()
        // reset the VC
        resetVC()
        // clear the history
        calcHistoryLabel.text = " "
        // reset the calc brain
        coolCalcBrain.reset()
        
        // reset binary buttons
        updateUI(divisionButton)
        updateUI(multplicationButton)
        updateUI(subtractionButton)
        updateUI(additionButton)
    }
    
    
    @IBAction func decimalPressed(_ sender: UIButton) {
        
        // if decimalKey hasn't been pressed before and starting a new operand entry
        if !decimalKeyPressed && operandEntryInProgress == false {
            operandEntryInProgress = true
            decimalKeyPressed = true
            calcDisplayLabel.text! = "0" + decimalCharacter!
            calcHistoryLabel.text! += " 0" + decimalCharacter!
            
            // if decimalKey hasn't been pressed before and currently entering an operand
            // otherwise, ignore decimalKey press
        } else if !decimalKeyPressed && operandEntryInProgress == true {
            decimalKeyPressed = true
            calcDisplayLabel.text! += decimalCharacter!
            calcHistoryLabel.text! += decimalCharacter!
        }
    }
    
    @IBAction func unaryPressed(_ sender: UIButton) {
        
        // set theunary operation based on which key was pressed
        let unaryOperation = UnaryOperation(rawValue: sender.currentTitle!)!
        
        // ensure a valid operand is in the calc display
        if let operand = Double(calcDisplayLabel.text!) {
            
            // ignore if the calc display is zero
            if operand == 0 {
                return
            } else {
                // append the keypress
                calcHistoryLabel.text! += " " + sender.currentTitle!
                // perform the unary calc
                let result = coolCalcBrain.performUnaryCalc(forOperation: unaryOperation,
                                                            usingDisplayValue: operand)
                // update the calc display
                calcDisplayLabel.text = numberFormatter.string(from: NSNumber(value: result))
            }
            
            // calc display doesn't contain a valid operand
        } else {
            // report the error
            calcDisplayLabel.text = "Error: invalid operand"
            // reset the calc brain
            coolCalcBrain.reset()
            // reset the VC
            resetVC()
            
            // reset binary buttons
            updateUI(divisionButton)
            updateUI(multplicationButton)
            updateUI(subtractionButton)
            updateUI(additionButton)
        }
    }
    
    
    //MARK: - Helpers
    
    // handle highlighting the active binaryOperation button
    private func updateUI(_ sender: UIButton?) {
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
    
    private func performCalc() {
        
        // perform the calculation
        guard coolCalcBrain.registerA != nil && coolCalcBrain.registerB != nil else {
            calcDisplayLabel.text = "Error: insufficient operands"
            calcHistoryLabel.text! += " Error"
            return
        }
        
        if let result = coolCalcBrain.performBinaryCalc(forOperation: coolCalcBrain.binaryOperation!) {
            // update the calculator display
            calcDisplayLabel.text = numberFormatter.string(from: NSNumber(value: result))
            
        } else {
            
            calcDisplayLabel.text = "Error: invalid calc"
            calcHistoryLabel.text! += " Error"
        }
    }
    
    private func resetVC() {
        operandEntryInProgress = false
        decimalKeyPressed = false
        currentOperationButton = nil
    }
}

