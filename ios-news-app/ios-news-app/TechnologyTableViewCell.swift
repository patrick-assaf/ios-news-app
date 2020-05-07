//
//  TechnologyTableViewCell.swift
//  ios-news-app
//
//  Created by Patrick Assaf on 5/6/20.
//  Copyright © 2020 patrickassaf. All rights reserved.
//

import UIKit

class TechnologyTableViewCell: UITableViewCell {

    @IBOutlet weak var articleView: UIView!

    @IBOutlet weak var articleContainer: UIView! {
        didSet {
            articleContainer.layer.cornerRadius = 10
            articleContainer.layer.borderWidth = 1
            articleContainer.layer.borderColor = UIColor(red:160/255, green:160/255, blue:175/255, alpha: 1).cgColor
        }
    }

    @IBOutlet weak var articleImage: UIImageView! {
        didSet{
            articleImage.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var articleTitle: UILabel!
    @IBOutlet weak var articleDate: UILabel!
    @IBOutlet weak var articleSection: UILabel!
    
    @IBOutlet weak var bookmarkButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
