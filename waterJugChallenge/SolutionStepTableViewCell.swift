//
//  SolutionStepTableViewCell.swift
//  waterJugChallenge
//
//  Created by Henry Minden on 10/25/20.
//

import UIKit

class SolutionStepTableViewCell: UITableViewCell {

    
    @IBOutlet var solutionStepNumber: UILabel!
    @IBOutlet var solutionStepText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
