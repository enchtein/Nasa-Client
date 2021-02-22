//
//  HistoryTableViewCell.swift
//  Nasa Client
//
//  Created by enchtein on 22.02.2021.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {
    @IBOutlet weak var roverLabel: UILabel!
    @IBOutlet weak var cameraLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var pageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
