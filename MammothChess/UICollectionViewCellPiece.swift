//
//  UICollectionViewCellPiece.swift
//  MammothChess
//
//  Created by Brandon Dinh on 2/6/19.
//  Copyright © 2019 htdsoft. All rights reserved.
//

import Foundation
import UIKit

class UICollectionViewCellPiece : UICollectionViewCell {
    var x: CGFloat = 0
    var y: CGFloat = 0
    var lblPiece : UILabel? = nil
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        setupView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    private func setupView() {
        if (lblPiece == nil) {
            lblPiece = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: self.frame.size))
        }
        lblPiece?.backgroundColor = UIColor.white.withAlphaComponent(0)
        lblPiece?.font = lblPiece?.font.withSize(34);
        
        lblPiece?.adjustsFontSizeToFitWidth = true
        lblPiece?.textAlignment = NSTextAlignment.center
        //lblPiece?.text = "T"
        self.addSubview(lblPiece!)
        //lblPiece?.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: self.frame.size)
    }

}
