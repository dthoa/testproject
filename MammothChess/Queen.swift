//
//  Queen.swift
//  MammothChess
//
//  Created by Brandon Dinh on 1/2/19.
//  Copyright © 2019 htdsoft. All rights reserved.
//

import Foundation
import UIKit

class Queen: UIChessPiece {
    init(frame: CGRect, color: UIColor, vc: ViewController) {
        super.init(frame:frame, color:color, vc:vc, blackPieceName:"♛", whitePieceName:"♕");
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    override func isMoveValid(fromIndex sourceIndex: BoardIndex, toIndex destIndex: BoardIndex, forGame chessGame: ChessGame) -> Bool {
        let diffRow = destIndex.row - sourceIndex.row
        let diffCol = destIndex.col - sourceIndex.col
        if(diffRow == 0 || diffCol == 0 || abs(diffRow) == abs(diffCol)) {
            // Is there any piece in the middle
            if(abs(diffRow) >= 2 || abs(diffCol) >= 2) {
                return !self.isThereMiddlePiece(fromIndex: sourceIndex, toIndex:destIndex, forGame: chessGame);
            }
            return true
        }
        return false;
    }
}
