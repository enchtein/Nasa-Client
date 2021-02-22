//
//  NewTableViewCell.swift
//  Nasa Client
//
//  Created by enchtein on 21.02.2021.
//

import UIKit
import Kingfisher

class NewTableViewCell: UITableViewCell {
    @IBOutlet weak var roverLabel: UILabel!
    @IBOutlet weak var cameraLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!

    public func setImageView(strUrl: String?) {
        if let avatarUrl = URL(string: strUrl ?? "") {
          avatarImageView.kf.indicatorType = .activity
          avatarImageView.kf.setImage(with: avatarUrl)
        } else {
          avatarImageView.image = nil
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
