//
//  JSONTokenizer.swift
//  JSONParser
//
//  Created by Daniel Donenfeld on 12/15/14.
//  Copyright (c) 2014 Daniel Donenfeld. All rights reserved.
//

import UIKit

public class JSONTokenizer{
   
    private let str: String
    private let strLen: Int
    
    private var charArray: [String] = []
    
    private var tokenReady: Bool = false
    private var currToken: Token? = nil
    
    private var nextIndex: Int = 0
   
    public init(JSONString: String){
        str = JSONString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        strLen = countElements(str)
        var temp = Array(str)
        for i in 0..<strLen{
            charArray.append(String(temp[i]))
        }
    }
    
    public func charAt(value: Int) -> String{
        return charArray[value]
    }
    
    ///Gets the next token and removes it.
    ///If at the end of the string, returns nil
    public func next()->Token?{
        peek()
        let nextTok = currToken
        currToken = nil
        tokenReady = false
        return nextTok
    }
    
    ///Returns the next token without removing it.
    public func peek()->Token?{
        if(tokenReady){ return currToken }
        if(nextIndex<strLen){
            if(!tokenReady){
                if let curr = lexToken(){
                    currToken = curr
                    tokenReady = true
                    return currToken
                } else {
                    return nil
                }
            } else{
                return currToken
            }
        } else {
            return nil
        }
    }
    
    
    private func lexToken()->Token?{
        if(nextIndex>=strLen){
            return nil
        }
        nextNonWhitespace()
        var nextChar: String = charArray[nextIndex]
        
        switch(nextChar){
        case "{":
            nextIndex++
            return Token.leftCurlyBrace
        case "}":
            nextIndex++
            return Token.rightCurlyBrace
        case "[":
            nextIndex++
            return Token.leftSquareBracket
        case "]":
            nextIndex++
            return Token.rightSquareBracket
        case ":":
            nextIndex++
            return Token.colon
        case ",":
            nextIndex++
            return Token.comma
        case "\"":
            return lexString()
        case "t":
            return lexTrueToken()
        case "f":
            return lexFalseToken()
        case "n":
            return lexNullToken()
        case "0","1","2","3","4","5","6","7","8","9":
            return lexDigits()
        case ".":
            nextIndex++
            return Token.dot
        case "e", "E":
            switch(charArray[nextIndex+1]){
            case "+":
                nextIndex+=2
                return Token.ePlus
            case "-":
                nextIndex+=2
                return Token.eMinus
            default:
                nextIndex++
                return Token.ePlus
                
            }
        default:
            println("\(nextChar) at index \(nextIndex)")

        }
        return nil
    }
    
    private func lexTrueToken()->Token?{
        if(charArray[nextIndex].lowercaseString=="t" && charArray[nextIndex+1].lowercaseString=="r" && charArray[nextIndex+2].lowercaseString=="u" && charArray[nextIndex+3].lowercaseString=="e"){
            nextIndex += 4
            return Token.trueValue
        } else {
            return Token.errorToken("Expected true token")
        }
    }
    
    private func lexFalseToken()->Token?{
        if(charArray[nextIndex].lowercaseString=="f" && charArray[nextIndex+1].lowercaseString=="a" && charArray[nextIndex+2].lowercaseString=="l" && charArray[nextIndex+3].lowercaseString=="s" && charArray[nextIndex+4].lowercaseString=="e"){
            nextIndex += 5
            return Token.falseValue
        } else {
            return Token.errorToken("Expected false token")
        }

    }
    
    private func lexNullToken()->Token?{
        if(charArray[nextIndex].lowercaseString=="n" && charArray[nextIndex+1].lowercaseString=="u" && charArray[nextIndex+2].lowercaseString=="l" && charArray[nextIndex+3].lowercaseString=="l"){
            nextIndex += 4
            return Token.null
        } else {
            return Token.errorToken("Expected null token")
        }
    }
    
    private func lexString()->Token?{
        nextIndex++
        var nextChar: String = charArray[nextIndex]
        var string = ""
        while(nextChar != "\"" && nextIndex<strLen){
            if(nextChar=="\\"){
                nextIndex++
                nextChar = charArray[nextIndex]
                switch(nextChar){
                case "\"":
                    string += "\""
                case "\\":
                    string += "\\"
                case "/":
                    string += "/"
                case "b":
                    string += "\u{8}"
                case "f":
                    string += "\u{12}"
                case "n":
                    string += "\n"
                case "r":
                    string += "\r"
                case "t":
                    string += "\t"
                case "u":
                    if let code = lexUnicode(){
                        if ((0<=code && code<=55295) || (57344<=code && code<=1114111)){
                            string += String(UnicodeScalar(code))
                        } else {
                            if(charArray[nextIndex+1] == "\\" && charArray[nextIndex+2] == "u"){
                                nextIndex += 2
                                if let code2 = lexUnicode(){
                                    let total = (code - 55296) * 1024 + (code2 - 56320) + 65536
                                    string += String(UnicodeScalar(total))
                                } else{
                                    return Token.errorToken("High surrogate not paired with low surrogate")
                                }
                            } else{
                                return Token.errorToken("High surrogate not paired with low surrogate")
                            }
                        }
                    } else {
                        return Token.errorToken("Unicode code must be a 4 digit hex number")
                    }
                default:
                    return Token.errorToken("\\ must be followed with an appropriate character")

                }
                nextIndex++
                nextChar = charArray[nextIndex]
            }else{
                string += nextChar
                nextIndex++
                nextChar = charArray[nextIndex]
            }
        }
        if(nextChar != "\""){
            return Token.errorToken("String must terminate ")
        }
        nextIndex++
        return Token.stringToken(string)
    }
    
    private func lexUnicode()-> Int?{
        var code = 0
        var array : [Int] = [Int(pow(16.0,3.0)), Int(pow(16.0,2.0)), Int(pow(16.0,1.0)),Int(pow(16.0,0.0))]
        for i in array{
            nextIndex++
            let char = charArray[nextIndex].uppercaseString
            if(char.toInt()==nil &&
                !(char=="A" ||
                    char=="B" ||
                    char=="C" ||
                    char=="D" ||
                    char=="E" ||
                    char=="F") ){
                        return nil
            }
            if(char.toInt() != nil){
                code += i * char.toInt()!
            } else{
                switch (char){
                case "A" :
                    code += i*10
                case "B" :
                    code += i*11
                case "C" :
                    code += i*12
                case "D" :
                    code += i*13
                case "E" :
                    code += i*14
                case "F" :
                    code += i*15
                default:
                    return nil
                }
            }
        }
        return code
    }
    
    private func lexDigits()->Token?{
        var nextChar: String = charArray[nextIndex]
        var digits = ""
        while(nextChar.toInt()? != nil){
            digits += nextChar
            nextIndex++
            if(nextIndex >= strLen){ break }
            nextChar = charArray[nextIndex] 
        }
        let digitsInt = digits.toInt()
        if let num = digitsInt{
            return Token.digits(digits)
        } else {
            return Token.errorToken("Error converting to Digits Token")
        }
    }
    
    private func nextNonWhitespace(){
        var nextChar: String = charArray[nextIndex]
        let whitespace = NSCharacterSet.whitespaceAndNewlineCharacterSet()
        while (nextChar.rangeOfCharacterFromSet(whitespace) != nil){
            nextIndex++
            if(nextIndex >= strLen){ break }
            nextChar = charArray[nextIndex]
        }
    }
    
    
}

public enum Token: Equatable,Printable{
    case rightCurlyBrace
    case leftCurlyBrace
    case doubleQuote
    case rightSquareBracket
    case leftSquareBracket
    case colon
    case comma
    case trueValue
    case falseValue
    case null
    
    //Token if error encountered
    case errorToken(String)
    
    //Cases for String
    case stringToken(String)
    
    
    //Cases for Number
    case digits(String)
    case dot
    case ePlus
    case eMinus
    
    public var description: String{
        return self.toString()
    }
    
    public func isStringToken() -> Bool {
        switch self {
        case stringToken(let str):
            return true
        default:
            return false
        }
    }
    
    public func isDigitsToken() -> Bool {
        switch self {
        case digits(let val):
            return true
        default:
            return false
        }
    }
    
    
    public func toString() -> String {
        switch self {
        case rightCurlyBrace:
            return "}"
        case leftCurlyBrace:
            return "{"
        case doubleQuote:
            return "\""
        case rightSquareBracket:
            return "]"
        case leftSquareBracket:
            return "["
        case colon:
            return ":"
        case comma:
            return ","
        case trueValue:
            return "true"
        case falseValue:
            return "false"
        case null:
            return "null"
            
            //Token if error encountered
        case errorToken(let errorMsg):
            return "ERROR"
            
            //Cases for String
        case stringToken(let str):
            return str
            
            //Cases for Number
        case digits(let intVal):
            return "\(intVal)"
        case dot:
            return "."
        case ePlus:
            return "e+"
        case eMinus:
            return "e-"
        }
    }
    
    
}


public func ==(lhs: Token, rhs: Token) -> Bool {
    return lhs.toString() == rhs.toString()
}



extension String{
    func toDouble()->Double{
        return (self as NSString).doubleValue
    }
    
    subscript (i: Int) -> String {
        return String(Array(self)[i])
    }
    
    subscript (r: Range<Int>) -> String {
        var start = advance(startIndex, r.startIndex)
        var end = advance(startIndex, r.endIndex)
        return substringWithRange(Range(start: start, end: end))
    }

}


