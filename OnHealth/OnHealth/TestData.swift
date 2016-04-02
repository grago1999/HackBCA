//
//  TestData.swift
//  OnHealth
//
//  Created by Gianluca Rago on 4/2/16.
//  Copyright © 2016 Ragoware LLC. All rights reserved.
//

class TestData {
    
    private var score:Int
    private var date:Int
    private var type:Int
    
    init(score:Int, date:Int, type:Int) {
        self.score = score
        self.date = date
        self.type = type
    }
    
    func getScore() -> Int {
        return score
    }
    
    func getDate() -> Int {
        return date
    }
    
    func getType() -> Int {
        return type
    }
    
}
