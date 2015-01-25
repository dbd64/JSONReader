//
//  JSONReaderTests.swift
//  JSONReaderTests
//
//  Created by Daniel Donenfeld on 12/15/14.
//  Copyright (c) 2014 Daniel Donenfeld. All rights reserved.
//

import UIKit
import XCTest
import JSONReader

class JSONReaderTests: XCTestCase {
    
    var longJSONString = "{}"
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        var jsonObject = JSONParser.parseToObject("{\"key1\":\"value1\",\"key2\":34.067e2}")
        XCTAssert(jsonObject != nil)
        if let j = jsonObject?.value{
            if let s = j["key1"]?.value as? String{
                XCTAssertEqual(s, "value1")
            }
            if let n = j["key2"]?.value as? Double{
                XCTAssertEqual(n, (34.067 * pow(10.0, 2.0)))
            }
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            var j = JSONParser.parseToObject(self.longJSONString)
            XCTAssert(j != nil)
        }
    }
    
}
