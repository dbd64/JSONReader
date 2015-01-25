//
//  JSONParserTest.swift
//  JSONReader
//
//  Created by Daniel Donenfeld on 1/14/15.
//  Copyright (c) 2015 Daniel Donenfeld. All rights reserved.
//

import UIKit
import XCTest
import JSONReader


class JSONParserTest: XCTestCase {
    
    var parser: JSONParser! = JSONParser()
   
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testParseObject(){
        XCTAssertEqual(JSONDict(), parser.parseObject(JSONTokenizer(JSONString: "{}"))!)
        XCTAssertEqual(JSONDict(), parser.parseObject(JSONTokenizer(JSONString: "  {   }     "))!)
        //XCTAssertEqual(JSONDict(), parser.parseObject(JSONTokenizer(JSONString: "{\"string\":23}"))!)
        XCTAssert(nil == parser.parseObject(JSONTokenizer(JSONString: "{1}")))


    }
    
    func testParseMembers(){
        var members = parser.parseMembers(JSONTokenizer(JSONString: ""))
        if let mems = members {
            XCTFail("Fail")
        } else {
            XCTAssert(true)
        }
        
        var tok = JSONTokenizer(JSONString: "\"str1\":\"str2\"")
        members = parser.parseMembers(tok)
        if let mems = members {
            XCTAssertEqual(mems[0].name, "str1")
            if let value = mems[0].value as? JSONString{
                XCTAssertEqual(value, JSONString(string: "str2"))
            } else {
                XCTFail("FAILLL")
            }
        } else {
            XCTFail("Fail")
        }

        tok = JSONTokenizer(JSONString: "\"str1\"  :\"str2\", \"str3\":\"str4\"")
        members = parser.parseMembers(tok)
        if let mems = members {
            XCTAssertEqual(mems[0].name, "str1")
            if let value = mems[0].value as? JSONString{
                XCTAssertEqual(value, JSONString(string: "str2"))
            } else {
                XCTFail("FAILLL")
            }
            
            XCTAssertEqual(mems[1].name, "str3")
            if let value = mems[1].value as? JSONString{
                XCTAssertEqual(value, JSONString(string: "str4"))
            } else {
                XCTFail("FAILLL")
            }

        } else {
            XCTFail("Fail")
        }
        
        tok = JSONTokenizer(JSONString: "\"str1\":{\"str2\":\"str3\"}")
        members = parser.parseMembers(tok)
        if let mems = members {
            XCTAssertEqual(mems[0].name, "str1")
            if let value = mems[0].value as? JSONDict{
                var dict = JSONDict()
                dict["str2"] = JSONString(string: "str3")
                XCTAssertEqual(value, dict)
            } else {
                XCTFail("FAILLL")
            }
        } else {
            XCTFail("Fail")
        }
        
        
        members = parser.parseMembers(JSONTokenizer(JSONString: "1"))
        if let mems = members {
            XCTFail("Fail")
        } else {
            XCTAssert(true)
        }
        
        tok = JSONTokenizer(JSONString: "\"str1\"  :\"str2\" \"str3\":\"str4\"")
        members = parser.parseMembers(tok)
        if let mems = members {
            XCTAssertEqual(mems[0].name, "str1")
            if let value = mems[0].value as? JSONString{
                XCTAssertEqual(value, JSONString(string: "str2"))
            } else {
                XCTFail("FAILLL")
            }
        } else {
            XCTFail("Fail")
        }
        

    }
    
    func testParseNumber(){
        JSONNumberTestNil("1.o")

        JSONNumberTest("1", actual: 1.0)
        JSONNumberTest("1.0", actual: 1.0)
        JSONNumberTest("1e0", actual: 1.0)
        JSONNumberTest("1.0e0", actual: 1.0)
        
        JSONNumberTest("100.23412", actual: 100.23412)
        JSONNumberTest("0.012321", actual: 0.012321)
        JSONNumberTest("1e0", actual: 1.0)
        JSONNumberTest("2.0e4", actual: 20000)


        
        JSONNumberTestNil("1.o")

    }
    
    private func JSONNumberTest(JNumStr: String, actual: Double){
        var num: JSON? = parser.parseNumber(JSONTokenizer(JSONString: JNumStr))
        if let number = num as? JSONNumber {
            XCTAssertEqual(number.value, actual)
        } else {
            XCTFail("Returned nil")
        }
    }
    
    private func JSONNumberTestNil(JNumStr: String){
        var num: JSON? = parser.parseNumber(JSONTokenizer(JSONString: JNumStr))
        if let number = num as? JSONNumber {
            XCTFail("Should have returned nil")

        } else {
            XCTAssert(true)
        }
    }

    func testParseArray(){
        var arr = parser.parseArray(JSONTokenizer(JSONString: "[]"))
        if let array = arr{
            XCTAssertEqual(array, JSONArray())
        } else {
            XCTFail("Array is nil")
        }
        
        arr = parser.parseArray(JSONTokenizer(JSONString: "[1]"))
        if let array = arr{
            var arrayActual = JSONArray()
            arrayActual.append(JSONNumber(number: 1))
            XCTAssertEqual(array, arrayActual)
        } else {
            XCTFail("Array is nil")
        }
        
        arr = parser.parseArray(JSONTokenizer(JSONString: "[\"hello\"]"))
        if let array = arr{
            var arrayActual = JSONArray()
            arrayActual.append(JSONString(string: "hello"))
            XCTAssertEqual(array, arrayActual)
        } else {
            XCTFail("Array is nil")
        }

    }
    
}

