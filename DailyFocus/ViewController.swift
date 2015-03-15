//
//  ViewController.swift
//  DailyFocus
//
//  Created by Marcus Smith on 3/14/15.
//  Copyright (c) 2015 Marcus Smith. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dailyContent: UITextField!
    @IBOutlet weak var stepperLabel: UILabel!
    @IBOutlet weak var stepper: UIStepper!
    
    var stepperDelay: Double = 8

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dailyContent.delegate = self
        stepperLabel.text = String(Int(stepperDelay).description)
        stepper.wraps = false
        stepper.minimumValue = 1
        stepper.maximumValue = 48
        stepper.autorepeat = true
        stepper.value = stepperDelay
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        dailyContent.resignFirstResponder()
        println("\(textField.text)")
        return true
    }
    
    @IBAction func stepperValueChange(sender: AnyObject) {
        println(stepper.value)
        var x = stepper.value
        stepperLabel.text = String(Int(stepper.value).description)
    }
}

