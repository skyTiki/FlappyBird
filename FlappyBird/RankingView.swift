//
//  RankingView.swift
//  FlappyBird
//
//  Created by takatoshi.ichige on 2021/04/06.
//

import UIKit

class RankingView: UIView{
    @IBOutlet weak var bestScoreLabel: UILabel!
    @IBOutlet weak var secondScoreLabel: UILabel!
    @IBOutlet weak var thirdScoreLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        if let view = UINib(nibName: "Ranking", bundle: nil).instantiate(withOwner: self, options: nil).first as? RankingView {
            self.addSubview(view)
        }
        self.layer.borderWidth = 0.1
        self.layer.borderColor = UIColor.black.cgColor
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setScoreLabel(bestScore: Int, secondScore: Int, thirdScore: Int) {
        bestScoreLabel.text = "\(bestScore)"
        secondScoreLabel.text = "\(secondScore)"
        thirdScoreLabel.text = "\(thirdScore)"
    }
}
