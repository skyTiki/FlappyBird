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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        if let view = UINib(nibName: "Ranking", bundle: nil).instantiate(withOwner: self, options: nil).first as? RankingView {
            self.addSubview(view)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setScoreLabel(topScore: String, secondScore: String, thirdScore: String) {
        topScoreLabel.text = topScore
        secondScoreLabel.text = secondScore
        thirdScoreLabel.text = thirdScore
    }
}
