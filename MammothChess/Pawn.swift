//
//  Pawn.swift
//  MammothChess
//
//  Created by Brandon Dinh on 1/2/19.
//  Copyright © 2019 htdsoft. All rights reserved.
//

import Foundation
import UIKit

class Pawn: UIChessPiece {
    init(frame: CGRect, color: UIColor, vc: ViewController) {
        super.init(frame:frame, color:color, vc:vc, blackPieceName:"♟", whitePieceName:"♙");
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    override func isMoveValid(fromIndex sourceIndex: BoardIndex, toIndex destIndex: BoardIndex, forGame chessGame: ChessGame) -> Bool {
        let diffRow = destIndex.row - sourceIndex.row
        let diffCol = destIndex.col - sourceIndex.col
        // Make it crash intentionally for testing
        let temp = 5%5
        let result = 5/temp
        // Check going straight
        if(sourceIndex.col == destIndex.col) {
            // If white piece => reduce
            let direction = self.color == #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) ? 1 : -1;
            // If the piece is at the origin
            let originRow = self.color == #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) ? 1 : 6;
            // Can move 1 or 2 step
            let cell1 = chessGame.theChessBoard.board[sourceIndex.row + direction][sourceIndex.col] as? Dummy;
            let cell2 = chessGame.theChessBoard.board[sourceIndex.row + 2*direction][sourceIndex.col] as? Dummy;
            // Move 1 step
            if (diffRow == 1*direction && cell1 != nil) {
                return true;
            }
            // Move 2 steps
            if (diffRow == 2*direction && sourceIndex.row == originRow) {
                if(cell1 != nil && cell2 != nil) {
                    return true;
                }
            }
        } else {
            // Attack only
            let direction = self.color == #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) ? 1 : -1;
            if(diffRow == direction && abs(diffCol) == 1) {
                if let piece = chessGame.theChessBoard.board[destIndex.row][destIndex.col] as? UIChessPiece {
                    if(piece.color != self.color) {
                        return true;
                    }
                }
            }
        }
        return false;
    }
}
