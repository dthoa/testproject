//
//  ViewController.swift
//  MammothChess
//
//  Created by Brandon Dinh on 1/2/19.
//  Copyright © 2019 htdsoft. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var lblDisplayTurnOUTLET: UILabel!
    
    @IBOutlet weak var lblDisplayCheckOUTLET: UILabel!
    
    @IBOutlet var panOUTLET: UIPanGestureRecognizer!
    
    @IBOutlet weak var vwBoard: UICollectionView!
    
    var pieceDragged: UIChessPiece!
    var sourceOrigin: CGPoint!
    var destOrigin: CGPoint!
    var preOrigin: CGPoint!
    
    static var SPACE_FROM_LEFT_EDGE: Int = 36;
    static var SPACE_FROM_TOP_EDGE: Int = 114;
    static var TILE_SIZE: Int = 46;
    static var ROW = 8
    static var COL = 8
    
    var myChessGame: ChessGame!
    var chessPieces: [UIChessPiece]!
    var isAgainstAI: Bool!
    
    func _viewDidLoad() {
        super.viewDidLoad()
        let boardWidth = CGFloat(ViewController.TILE_SIZE*ChessBoard.COLS)
        let boardHeight = CGFloat(ViewController.TILE_SIZE*ChessBoard.ROWS)
        let vw:UIView = self.view
        ViewController.SPACE_FROM_LEFT_EDGE = Int((vw.frame.width - boardWidth) / 2)
        
        vwBoard.frame = CGRect(
            x: CGFloat(ViewController.SPACE_FROM_LEFT_EDGE),
            y: CGFloat(ViewController.SPACE_FROM_TOP_EDGE),
            width: boardWidth,
            height: boardHeight)
        // Do any additional setup after loading the view, typically from a nib.
        
        chessPieces = []
        myChessGame = ChessGame(viewController: self);
        print("SINGLE PLAYER: \(isAgainstAI)")
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        pieceDragged = touches.first!.view as? UIChessPiece;
        if pieceDragged != nil {
            sourceOrigin = pieceDragged.frame.origin;
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if pieceDragged != nil {
            drag(piece: pieceDragged, usingGestureRecognizer: panOUTLET)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(pieceDragged != nil) {
            pieceDragged.frame.origin = sourceOrigin;
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if pieceDragged != nil {
            let touchLocation = touches.first!.location(in: view);
            var x = Int(touchLocation.x) - ViewController.SPACE_FROM_LEFT_EDGE;
            var y = Int(touchLocation.y) - ViewController.SPACE_FROM_TOP_EDGE;
            
            x = (x/ViewController.TILE_SIZE) * ViewController.TILE_SIZE;
            y = (y/ViewController.TILE_SIZE) * ViewController.TILE_SIZE;
            
            x += ViewController.SPACE_FROM_LEFT_EDGE;
            y += ViewController.SPACE_FROM_TOP_EDGE;
            
            destOrigin = CGPoint(x: x, y: y);
            let sourceIndex = ChessBoard.indexOf(origin: sourceOrigin);
            let destIndex = ChessBoard.indexOf(origin: destOrigin);
            
            if myChessGame.isMoveValid(piece: pieceDragged, fromIndex: sourceIndex, toIndex: destIndex ) {
                myChessGame.move(piece: pieceDragged, fromIndex: sourceIndex, toIndex: destIndex, toOrigin: destOrigin);
                
                if myChessGame.isGameOver() {
                    displayWinner()
                    return
                }
                
                if shouldPromotePawn() {
                    promptForPawnPromotion()
                } else {
                    resumeGame()
                }

                
                
            } else {
                pieceDragged.frame.origin = sourceOrigin;
            }
        }
    }
    
    func resumeGame() {
        //Display Checks, if any
        displayCheck();
        //change the turn
        myChessGame.nextTurn();
        //display turn
        updateTurnOnScreen();
        
        // make AI move if necessary
        if isAgainstAI && !myChessGame.isWhiteTurn {
            myChessGame.makeAIMove();
            
            if myChessGame.isGameOver() {
                displayWinner()
                return
            }
            if shouldPromotePawn() {
                promote(pawn: myChessGame.getPawnToBePromoted()!, into: "Queen")
            }
            
            displayCheck()
            myChessGame.nextTurn()
            updateTurnOnScreen()
        }

    }
    
    func displayWinner() {
        
    }
    
    func promote(pawn pawnToBePromoted: Pawn, into pieceName: String) {
        let pawnColor = pawnToBePromoted.color
        let pawnFrame = pawnToBePromoted.frame
        let pawnIndex = ChessBoard.indexOf(origin: pawnToBePromoted.frame.origin)
        myChessGame.theChessBoard.remove(piece: pawnToBePromoted)
        
        switch pieceName.lowercased() {
        case "queen":
            myChessGame.theChessBoard.board[pawnIndex.row][pawnIndex.col] = Queen(frame: pawnFrame, color: pawnColor, vc: self)
            break;
        case "knight":
            myChessGame.theChessBoard.board[pawnIndex.row][pawnIndex.col] = Knight(frame: pawnFrame, color: pawnColor, vc: self)
            break;
        case "rook":
            myChessGame.theChessBoard.board[pawnIndex.row][pawnIndex.col] = Rook(frame: pawnFrame, color: pawnColor, vc: self)
            break;
        case "bishop":
            myChessGame.theChessBoard.board[pawnIndex.row][pawnIndex.col] = Bishop(frame: pawnFrame, color: pawnColor, vc: self)
            break;

        default:
            break;
        }
    }
    
    func promptForPawnPromotion() {
        if let pawnToPromote = myChessGame.getPawnToBePromoted() {
            let box = UIAlertController(title: "Pawn Promotion", message: "Choose a Piece", preferredStyle: UIAlertController.Style.alert)
            
            //typealias handler = (action action: UIAlertAction) -> Void
            
            box.addAction(UIAlertAction(title: "Queen", style: UIAlertAction.Style.default, handler: { action in
                self.promote(pawn: pawnToPromote, into: action.title!)
                self.resumeGame()
            }))
            box.addAction(UIAlertAction(title: "Knight", style: UIAlertAction.Style.default, handler: { action in
                self.promote(pawn: pawnToPromote, into: action.title!)
                self.resumeGame()
            }))
            box.addAction(UIAlertAction(title: "Rook", style: UIAlertAction.Style.default, handler: { action in
                self.promote(pawn: pawnToPromote, into: action.title!)
                self.resumeGame()
            }))
            box.addAction(UIAlertAction(title: "Bishop", style: UIAlertAction.Style.default, handler: { action in
                self.promote(pawn: pawnToPromote, into: action.title!)
                self.resumeGame()
            }))
            
            self.present(box, animated:  true, completion: nil)
            
        }
    }
    

    func shouldPromotePawn() -> Bool {
        return (myChessGame.getPawnToBePromoted() != nil)
    }
    
    func displayCheck() {
        let playerChecked = myChessGame.getPlayerChecked()
        if playerChecked != nil {
            lblDisplayCheckOUTLET.text = playerChecked! +  " is in check!"
        } else {
            lblDisplayCheckOUTLET.text = "";
        }
    }
    
    func updateTurnOnScreen() {
        lblDisplayTurnOUTLET.text = myChessGame.isWhiteTurn ? "White's Turn" : "Black's Turn";
        lblDisplayTurnOUTLET.textColor = myChessGame.isWhiteTurn ? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) ;
    }

    func drag(piece: UIChessPiece, usingGestureRecognizer gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: view)
        
        piece.center = CGPoint(x: translation.x + piece.center.x, y: translation.y + piece.center.y)
        
        gestureRecognizer.setTranslation(CGPoint.zero, in: view);
    }

}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    override func viewDidLoad() {
        //super.viewDidLoad()
        _viewDidLoad()
        
        vwBoard.dataSource = self
        vwBoard.delegate = self
        vwBoard.register(UICollectionViewCellPiece.self, forCellWithReuseIdentifier: "BoardCell")
        vwBoard.reloadData()
    }
    
    
    
    // Data Source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BoardCell", for: indexPath)
        if((indexPath.row % 2) ^ (indexPath.section % 2) == 0) {
            cell.contentView.backgroundColor = UIColor(red: 1, green: 212/255.0, blue: 121/255.0, alpha: 1)
        } else {
            cell.contentView.backgroundColor = UIColor(red: 148/255.0, green: 82/255.0, blue: 0, alpha: 1)
        }
        return cell
    }
    
    
    // Flow
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: ViewController.TILE_SIZE, height: ViewController.TILE_SIZE)
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    public func getUIBoard() -> UICollectionView {
        return vwBoard
    }
    
}
