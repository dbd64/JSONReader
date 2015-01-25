//
//  JSONTest.swift
//  JSONReader
//
//  Created by Daniel Donenfeld on 1/14/15.
//  Copyright (c) 2015 Daniel Donenfeld. All rights reserved.
//

import UIKit
import XCTest
import JSONReader

class JSONTest: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testJSONDict(){
        var dict1 = JSONDict()
        var dict2 = JSONDict()
        XCTAssertEqual(dict1, dict2)
        
        dict1["string1"] = JSONDict()
        dict2["string1"] = JSONDict()
        println(dict1.equals(dict2))
        XCTAssertEqual(dict1, dict2)

    }
    
    func testJSONArray(){
        var arr1 = JSONArray()
        var arr2 = JSONArray()
        XCTAssertEqual(arr1, arr2)
        
        arr1[0] = JSONDict()
        arr2[0] = JSONDict()
        println(arr1.equals(arr2))
        XCTAssertEqual(arr1, arr2)
        
    }
    
    func testJSONNull(){
        var null1 = JSONNull()
        var null2 = JSONNull()
                
        XCTAssertEqual(null1, null2)
    }


}
