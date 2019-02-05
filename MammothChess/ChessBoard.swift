//
//  ChessBoard.swift
//  MammothChess
//
//  Created by Brandon Dinh on 1/2/19.
//  Copyright © 2019 htdsoft. All rights reserved.
//

import Foundation
import UIKit

class ChessBoard: NSObject {
    var board: [[Piece]]!
    var vc: ViewController!
    let ROWS = 8;
    let COLS = 8;
    var whiteKing: King!
    var blackKing: King!
    

    
    init(viewController: ViewController) {
        vc = viewController;
        
        let oneRowOfBoard = Array(repeating: Dummy(), count: COLS);
        board = Array(repeating: oneRowOfBoard, count: ROWS);
        
        for row in 0 ..< ROWS {
            let color = row < 4 ? #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) ;
            for col in 0 ..< COLS {
                switch row {
                case 0, 7:
                    switch col {
                    case 0, COLS-1:
                        board[row][col] = Rook(frame: ChessBoard.getFrame(forRow: row, forCol: col), color: color , vc: vc)
                        break;
                    case 1, COLS-2:
                        board[row][col] = Knight(frame: ChessBoard.getFrame(forRow: row, forCol: col), color: color , vc: vc)
                        break;
                    case 2, COLS-3:
                        board[row][col] = Bishop(frame: ChessBoard.getFrame(forRow: row, forCol: col), color: color , vc: vc)
                        break;
                    case 3:
                        board[row][col] = Queen(frame: ChessBoard.getFrame(forRow: row, forCol: col), color: color , vc: vc)
                        break;
                    case 4:
                        board[row][col] = King(frame: ChessBoard.getFrame(forRow: row, forCol: col), color: color , vc: vc)
                        if(color == #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)) {
                            self.blackKing = (board[row][col] as! King);
                        } else {
                            self.whiteKing = (board[row][col] as! King);
                        }
                        break;
                    default:
                        break;
                    }
                    break;
                case 1, 6:
                    board[row][col] = Pawn(frame: ChessBoard.getFrame(forRow: row, forCol: col), color: color , vc: vc)
                    break;
                
                default:
                    board[row][col] = Dummy(frame: ChessBoard.getFrame(forRow: row, forCol: col))
                    break;
                }
            }
        }
    }
    
    static func getFrame(forRow row: Int, forCol col: Int) -> CGRect {
        let x = CGFloat(ViewController.SPACE_FROM_LEFT_EDGE + col*ViewController.TILE_SIZE)
        let y = CGFloat(ViewController.SPACE_FROM_TOP_EDGE + row*ViewController.TILE_SIZE)
        
        return CGRect( origin: CGPoint(x: x, y: y), size: CGSize(width: ViewController.TILE_SIZE, height: ViewController.TILE_SIZE));
    }
    
    static func indexOf(origin: CGPoint) -> BoardIndex {
        var row = Int(origin.y) - ViewController.SPACE_FROM_TOP_EDGE;
        var col = Int(origin.x) - ViewController.SPACE_FROM_LEFT_EDGE;
        row /= ViewController.TILE_SIZE;
        col /= ViewController.TILE_SIZE;
        return BoardIndex(row: row, col: col)
    }
    
    func getIndex(forChessPiece chessPieceToFind: UIChessPiece) -> BoardIndex?{
        for row in 0..<ROWS{
            for col in 0..<COLS{
                if let aChessPiece = board[row][col] as? UIChessPiece{
                    if chessPieceToFind == aChessPiece{
                        return BoardIndex(row: row, col: col)
                    }
                }
            }
        }
        
        return nil
    }
    
    func remove(piece: Piece) {
        if let chessPiece = piece as? UIChessPiece {
            let indexOnBoard = ChessBoard.indexOf(origin: chessPiece.frame.origin)
            board[indexOnBoard.row][indexOnBoard.col] = Dummy(frame: chessPiece.frame)
            if let indexInChessPiecesArray = vc.chessPieces.index(of: chessPiece) {
                vc.chessPieces.remove(at: indexInChessPiecesArray)
            }
            //remove from scree
            chessPiece.removeFromSuperview()
        }
    }
    
    func place(chessPiece: UIChessPiece, toIndex destIndex: BoardIndex, toOrigin destOrigin: CGPoint) {
        chessPiece.frame.origin = destOrigin
        board[destIndex.row][destIndex.col] = chessPiece
    }
}
