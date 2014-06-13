//
//  SwiftCalculatorTest.swift
//  SwiftCalculatorTest
//
//  Created by Daniel Parnell on 9/06/2014.
//
//

import XCTest




class SwiftCalculatorTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSimple() {
        let parser = CalculatorParser()
  
        XCTAssert(parser.parseString("1 + 2"))
        XCTAssertEqual(parser.calculator.result, 3)
    }

    func testComplex() {
        let parser = CalculatorParser()
        
        XCTAssert(parser.parseString("(1 + 2) * (3 + 4)"))
        XCTAssertEqual(parser.calculator.result, 21)
    }
    
    func testDecimal() {
        let parser = CalculatorParser()
        
        XCTAssert(parser.parseString("0.5 * 10"))
        XCTAssertEqual(parser.calculator.result, 5)
    }
    
}
