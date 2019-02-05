//
//  BoardIndex.swift
//  MammothChess
//
//  Created by Brandon Dinh on 1/2/19.
//  Copyright © 2019 htdsoft. All rights reserved.
//

import Foundation

struct BoardIndex {
    var row: Int;
    var col: Int;
    
    init(row: Int, col: Int) {
        self.row = row;
        self.col = col;
    }
    
    static func ==(lhs: BoardIndex, rhs: BoardIndex) -> Bool {
        return (lhs.row == rhs.row && lhs.col == rhs.col);
    }
    
    static func !=(lhs: BoardIndex, rhs: BoardIndex) -> Bool {
        return !(lhs == rhs)
    }
}
