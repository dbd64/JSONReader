//
//  JSONParser.swift
//  JSONParser
//
//  Created by Daniel Donenfeld on 12/15/14.
//  Copyright (c) 2014 Daniel Donenfeld. All rights reserved.
//

import UIKit

public class JSONParser: NSObject {
    public class func parseToObject(input: String) -> JSONDict?{
        var parser: JSONParser = JSONParser()
        return parser.parse(input)
    }
    
    public class func parseToArray(input: String) -> JSONArray?{
        var parser: JSONParser = JSONParser()
        return parser.parseArray(JSONTokenizer(JSONString: input))
    }
    
    public class func parseJSON(input: String) -> JSON? {
        if let obj = parseToObject(input){
            return obj
        } else if let arr = parseToArray(input){
            return arr
        } else{
            return nil
        }
    }
    
    func parse(JSONString:String ) -> JSONDict?{
        var tok = JSONTokenizer(JSONString: JSONString)
        return parseObject(tok)
    }
    
    public func parseObject(tok: JSONTokenizer)->JSONDict?{
        var tokPeek = tok.peek()!
        if (tok.peek() == Token.leftCurlyBrace && tok.next() != nil){
            if(tok.peek() == Token.rightCurlyBrace && tok.next() != nil){
                return JSONDict()
            }
            var members = parseMembers(tok)
            if (members == nil) { return nil }
            if (tok.peek() != Token.rightCurlyBrace && tok.next() == nil) { return nil }
            //if (tok.peek() != nil) { return nil }
            var obj = JSONDict()
            if let mems = members? {
                for mem in mems {
                    obj[mem.name] = mem.value
                }
                return obj
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    public func parseMembers(tok: JSONTokenizer)->[Member]?{
        var members: [Member] = []
        
        let pair = parsePair(tok)
        if(pair == nil) {return nil}
        members.append(pair!)
        while  (tok.peek() == Token.comma && tok.next() != nil){
            let nextPair = parsePair(tok)
            if (nextPair == nil) { return nil }
            members.append(nextPair!)
        }
        return members
        
    }
    
    func parsePair(tok: JSONTokenizer)->Member?{
        let str = parseString(tok)
        if (str == nil || tok.peek() != Token.colon) { return nil }
        tok.next()
        let value = parseValue(tok)
        if(value == nil) { return nil }
        return Member(name: str!.value, value: value!)
    }
    
    func parseString(tok: JSONTokenizer)->JSONString?{
        if let isStr = tok.peek()?.isStringToken() {
            if isStr {
                return JSONString(string: tok.next()!.toString())
            }
        }
        return nil
    }
    
    func parseValue(tok: JSONTokenizer)->JSON?{
        if let peek = tok.peek(){
            switch(peek){
            case Token.stringToken(let str):
                return parseString(tok)
            case Token.digits(let intVal):
                return parseNumber(tok)
            case Token.leftCurlyBrace:
                return parseObject(tok)
            case Token.leftSquareBracket:
                return parseArray(tok)
            case Token.trueValue:
                return JSONBool(JSONbool: true)
            case Token.falseValue:
                return JSONBool(JSONbool: false)
            case Token.null:
                return JSONNull()
            default:
                return nil

            }
        } else {
            return nil
        }
    }
    
    func numToFrac(num: Int)-> Double{
        var l: Double
        var n = abs(num)
        for (l = 0;n>0;++l){
            n/=10
        }
        return Double(num)/pow(10.0, l)
        
    }

    
    public func parseNumber(tok: JSONTokenizer)->JSON?{
        var num: Double = 0
        var jNum: JSONNumber
        if let intNum = parseInt(tok){
            num += Double(intNum)
            jNum = JSONNumber(number: Int(num))
        } else {
            return nil
        }
        
        if let frac = parseFrac(tok){
            if frac.error == true {
                return nil
            }
            num += frac.value
            if let exp = parseExp(tok){
                num *= pow(10.0, Double(exp))
            }
            jNum = JSONNumber(number: num)
            return jNum
        }
        
        if let exp = parseExp(tok){
            num *= pow(10.0, Double(exp))
            jNum = JSONNumber(number: num)
        }
        
        return jNum
    }
    
    func parseInt(tok: JSONTokenizer)->Int?{
        if let tokPeek = tok.peek() {
            switch(tokPeek){
            case Token.digits(let digits):
                var intNum = digits.toInt()
                tok.next()
                return intNum
            default:
                return nil
            }
        } else {
            return nil
        }
    }

    func parseFrac(tok: JSONTokenizer)->Frac?{
        if let tokPeek = tok.peek(){
            if tokPeek != Token.dot{
                return nil
            }
            tok.next()
            if let tokPeek = tok.peek() {
                switch(tokPeek){
                case Token.digits(let digits):
                    var numstring = "." + digits
                    var doubleNum = numstring.toDouble()
                    tok.next()
                    return Frac(value: doubleNum)
                default:
                    return Frac(error: true)
                }
            } else {
                return Frac(error: true)
            }
        } else {
            return nil
        }
    }
    
    func parseExp(tok: JSONTokenizer)->Int?{
        if let token = tok.peek(){
            switch(token){
            case Token.ePlus:
                tok.next()
                if let token = tok.peek(){
                    switch(token){
                    case Token.digits(let digits):
                        return digits.toInt()
                    default:
                        return nil
                    }
                }
                return nil
            case Token.eMinus:
                tok.next()
                if let token = tok.peek(){
                    switch(token){
                    case Token.digits(let digits):
                        return digits.toInt()
                    default:
                        return nil
                    }
                }
                return nil
            default:
                return nil
            }
        } else{
            return nil
        }

    }
    
    public func parseArray(tok: JSONTokenizer)->JSONArray?{
        if let tokPeek = tok.peek() {
            if tokPeek != Token.leftSquareBracket {
                return nil
            }
            tok.next()
            var jArray = JSONArray()
            var tokPeekNext = tok.peek()
            var tokPeekUNWRAPPED = tokPeekNext!

            
            while (tokPeekNext != Token.rightSquareBracket && tokPeekNext != Token.errorToken("ERROR")){
                var value = parseValue(tok)
                if let val = value {
                    jArray.append(val)
                }
                if tok.peek() == Token.comma {
                    tok.next()
                } else {
                    break
                }
            }
            if (tok.peek() != Token.rightSquareBracket) && (tok.peek() != Token.errorToken("ERROR")){
                return nil
            }
            tok.next()
            return jArray

        } else {
            return nil
        }
    }


    
    public class Member {
        public let name: String
        public let value : JSON
        
        init(name: String, value: JSON){
            self.name = name
            self.value = value
        }
        
    }
    
    public class Frac {
        public let value: Double
        public let error: Bool
        
        init(value: Double){
            self.value = value
            self.error = false
        }
        
        init(error: Bool){
            self.error = error
            self.value = 0.0
        }
    }
    
}
