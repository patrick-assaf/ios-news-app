//
//  HomeArticlesTableViewCell.swift
//  ios-news-app
//
//  Created by Patrick Assaf on 4/25/20.
//  Copyright © 2020 patrickassaf. All rights reserved.
//

import UIKit

class HomeArticlesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var articleImage: UIImageView!
    @IBOutlet weak var articleTitle: UILabel!
    @IBOutlet weak var articleDate: UILabel!
    @IBOutlet weak var articleSection: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
