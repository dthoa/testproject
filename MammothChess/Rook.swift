//
//  Rook.swift
//  MammothChess
//
//  Created by Brandon Dinh on 1/2/19.
//  Copyright © 2019 htdsoft. All rights reserved.
//

import Foundation
import UIKit

class Rook: UIChessPiece {
    init(frame: CGRect, color: UIColor, vc: ViewController) {
        super.init(frame:frame, color:color, vc:vc, blackPieceName:"♜", whitePieceName:"♖");
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    override func isMoveValid(fromIndex sourceIndex: BoardIndex, toIndex destIndex: BoardIndex, forGame chessGame: ChessGame) -> Bool {
        if(sourceIndex.row == destIndex.row || sourceIndex.col == destIndex.col) {
            // Is there any piece in the middle
            if(abs(sourceIndex.row - destIndex.row) >= 2 || abs(sourceIndex.col - destIndex.col) >= 2) {
                return !self.isThereMiddlePiece(fromIndex: sourceIndex, toIndex:destIndex, forGame: chessGame);
            }
            return true
        }
        return false;
    }
    
}
