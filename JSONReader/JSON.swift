//
//  JSON.swift
//  JSONParser
//
//  Created by Daniel Donenfeld on 12/15/14.
//  Copyright (c) 2014 Daniel Donenfeld. All rights reserved.
//

import UIKit


@objc public protocol JSON {
    optional var value: AnyObject{get}
    optional subscript(key:String)->JSON?{get set}
    
    func equals(other: JSON) -> Bool
}

public class JSONDict : JSON, Equatable, Printable{
    
    private var dict: [String: JSON]
    
    public init(){
        dict = [String: JSON]()
    }
    
    public var value: [String: JSON]{
        get{
            return dict
        }
    }
    
    public var description: String{
        get{
            var desc = "{\n"
            for (name, value) in dict {
                desc += "    \(name) : \(value)\n"
            }
            desc += "}"
            return desc
        }
    }
    
    public subscript(key: String) -> JSON? {
        get {
            return dict[key]
        }
        set {
            dict[key] = newValue
        }
    }
    
    public func equals(other: JSON) -> Bool{
        if let otherdict = other as? JSONDict {
            for (name, value) in self.dict {
                if let otherValue = otherdict.dict[name]{
                    if (!otherValue.equals(value)) {
                        return false
                    }

                } else {
                    return false
                }
            }
            return true
        } else {
            return false
        }
    }


}


public class JSONArray : JSON, Equatable {
    private var arr: [JSON?]
    
    var value: [JSON?]{
        get{
            return arr
        }
    }
    
    
    public init(){
        arr = []
    }

    
    public subscript(key: Int) -> JSON? {
        get{
            if(key > arr.count){
                return arr[key]
            } else {
                return nil
            }
        }
        set{
            if (key == arr.count){
                arr.append(newValue)
            } else if (key < arr.count){
                arr[key] = newValue
            }
        }
    }
    
    public func equals(other: JSON) -> Bool{
        if let otherarr = other as? JSONArray {
            if (arr.count != otherarr.arr.count){
                return false
            }
            if((arr.count == 0) ^ (otherarr.arr.count==0)){
                return false
            }

            for i in 0..<self.arr.count {
                if(self.arr[i] != nil && otherarr.arr[i] != nil){
                    if (!self.arr[i]!.equals(otherarr.arr[i]!)) { return false }
                } else if (!(self.arr[i] == nil && otherarr.arr[i] == nil)) {
                    return false
                }
            }
            return true
        } else {
            return false
        }
    }
    
    public func append(value: JSON){
        arr.append(value)
    }

}

public class JSONString : JSON, Equatable {
    private var str: String = ""
    
    var value: String{
        return str
    }
    
    public init(string: String){
        str = string
    }
    
    public func equals(other: JSON) -> Bool{
        if let otherstr = other as? JSONString {
            return self.str == otherstr.str
        } else {
            return false
        }
    }

}

public class JSONNumber : JSON, Equatable {
    private var num: Double
    private var _type: NumericType
    
    public var value: Double{
        return num
    }
    
    var type: NumericType {
        return _type
    }
    
    public init(number: Double){
        _type = .Double
        num = number
        
    }
    
    public init(number: Int){
        _type = .Int
        num = Double(number)
    }
    
    enum NumericType{
        case Int
        case Double
    }
    
    public func equals(other: JSON) -> Bool{
        if let othernum = other as? JSONNumber {
            return self.num == othernum.num && self._type == othernum._type
        } else {
            return false
        }
    }


}

public class JSONBool : JSON, Equatable {
    private var bool: Bool
    
    var value: Bool{
        return bool
    }
    
    init(JSONbool: Bool){
        bool = JSONbool
    }
    
    public func equals(other: JSON) -> Bool{
        if let otherbool = other as? JSONBool {
            return self.bool == otherbool.bool
        } else {
            return false
        }
    }


}

public class JSONNull : JSON, Equatable{
    public init(){}
    
    public func equals(other: JSON) -> Bool{
        if let otherarr = other as? JSONNull {
          return true
        } else {
            return false
        }
    }

}

public func ==(lhs: JSON, rhs: JSON)->Bool{
    return lhs.equals(rhs)
}

public func ==(lhs: JSONDict, rhs: JSONDict)->Bool{
    return lhs.equals(rhs)
}

public func ==(lhs: JSONArray, rhs: JSONArray)->Bool{
    return lhs.equals(rhs)
}

public func ==(lhs: JSONString, rhs: JSONString)->Bool{
    return lhs.equals(rhs)
}

public func ==(lhs: JSONBool, rhs: JSONBool)->Bool{
    return lhs.equals(rhs)
}

public func ==(lhs: JSONNumber , rhs: JSONNumber)->Bool{
    return lhs.equals(rhs)
}

public func ==(lhs: JSONNull, rhs: JSONNull)->Bool{
    return lhs.equals(rhs)
}


