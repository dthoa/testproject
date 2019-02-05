//
//  Knight.swift
//  MammothChess
//
//  Created by Brandon Dinh on 1/2/19.
//  Copyright © 2019 htdsoft. All rights reserved.
//

import Foundation
import UIKit

class Knight: UIChessPiece {
    init(frame: CGRect, color: UIColor, vc: ViewController) {
        super.init(frame:frame, color:color, vc:vc, blackPieceName:"♞", whitePieceName:"♘");
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    override func isMoveValid(fromIndex sourceIndex: BoardIndex, toIndex destIndex: BoardIndex,  forGame chessGame: ChessGame) -> Bool {
        let n = 8
        let xs = [-2, -2, -1, -1,  1, 1, 2, 2]
        let ys = [-1,  1, -2,  2, -2, 2, -1, 1]
        
        let diffX = destIndex.row - sourceIndex.row;
        let diffY = destIndex.col - sourceIndex.col;
        
        for i in 0..<n {
            if(diffX == xs[i] && diffY == ys[i]) {
                return true;
            }
        }
        return false;
    }
}
