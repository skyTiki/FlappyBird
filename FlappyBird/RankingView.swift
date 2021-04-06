//
//  RankingView.swift
//  FlappyBird
//
//  Created by takatoshi.ichige on 2021/04/06.
//

import UIKit

class RankingView: UIView{
    @IBOutlet weak var topScoreLabel: UILabel!
    @IBOutlet weak var secondScoreLabel: UILabel!
    @IBOutlet weak var thirdScoreLabel: UILabel!
    
    
    var topScore: Int!
    var secondScore: Int!
    var thirdScore: Int!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        if let view = UINib(nibName: "Ranking", bundle: nil).instantiate(withOwner: self, options: nil).first as? RankingView {
            self.addSubview(view)
        }
        self.layer.borderWidth = 0.3
        self.layer.borderColor = UIColor.black.cgColor
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setScoreLabel(topScore: Int, secondScore: Int, thirdScore: Int) {
//        topScoreLabel.text = "\(topScore)"
//        secondScoreLabel.text = "\(secondScore)"
//        thirdScoreLabel.text = "\(thirdScore)"
    }
}
