//
//  King.swift
//  MammothChess
//
//  Created by Brandon Dinh on 1/2/19.
//  Copyright © 2019 htdsoft. All rights reserved.
//

import Foundation
import UIKit

class King: UIChessPiece {
    init(frame: CGRect, color: UIColor, vc: ViewController) {
        super.init(frame:frame, color:color, vc:vc, blackPieceName:"♚", whitePieceName:"♔");
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    override func isMoveValid(fromIndex sourceIndex: BoardIndex, toIndex destIndex: BoardIndex, forGame chessGame: ChessGame) -> Bool {
        let diffRow = destIndex.row - sourceIndex.row
        let diffCol = destIndex.col - sourceIndex.col
        if(diffRow == 0 || diffCol == 0 || abs(diffRow) == abs(diffCol)) {
            if(abs(diffRow) <= 1 && abs(diffCol) <= 1) {
                return true
            }
        }
        return false;
    }
    
}
