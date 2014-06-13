//
//  Calculator.swift
//  pegged
//
//  Created by Daniel Parnell on 12/06/2014.
//
//

import Foundation

class Calculator {
    var stack: Double[] = []
    var _negative = false

    var result: Double {
        get { return stack[stack.count-1] }
    }

    func performBinaryOperation(op: (left: Double, right: Double) -> Double) {
        var right = stack.removeLast()
        var left = stack.removeLast()
        
        stack.append(op(left: left, right: right))
    }
    
    func add() {
        performBinaryOperation({(left: Double, right: Double) -> Double in
            return left + right
        })
    }
    
    func divide() {
        performBinaryOperation({(left: Double, right: Double) -> Double in
            return left / right
            })
    }
    
    func exponent() {
        performBinaryOperation({(left: Double, right: Double) -> Double in
            return pow(left, right)
            })        
    }

    func multiply() {
        performBinaryOperation({(left: Double, right: Double) -> Double in
            return left * right
            })
        
    }
    
    func subtract() {
        performBinaryOperation({(left: Double, right: Double) -> Double in
            return left - right
            })
    
    }
    
    func negative() {
        _negative = !_negative
    }
    
    func pushNumber(text: String) {
        var value: Double = 0
        var decimal = -1
        var counter = 0
        for ch in text.utf8 {
            if(ch == 46) {
                decimal = counter
            } else {
                let digit: Int = Int(ch) - 48
                value = value * Double(10.0) + Double(digit)
                counter = counter + 1
            }
        }
        
        if(decimal >= 0) {
            value = value / pow(10.0, Double(counter - decimal))
        }
        
        if(_negative) {
            value = -value
        }
        
        stack.append(value)
    }

}