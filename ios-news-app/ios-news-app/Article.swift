//
//  Article.swift
//  ios-news-app
//
//  Created by Patrick Assaf on 4/25/20.
//  Copyright © 2020 patrickassaf. All rights reserved.
//

import Foundation

class Article {
    var key: String = ""
    var id: String = ""
    var title: String = ""
    var date: String = ""
    var section: String = ""
    var imageURL: String = ""
    var description: String = ""
    var bookmarked: Bool = false
    
    init(key: String, id: String, title: String, date: String, section: String, imageURL: String, description: String, bookmarked: Bool = false) {
        self.key = key
        self.id = id
        self.title = title
        self.date = date
        self.section = section
        self.imageURL = imageURL
        self.description = description
        self.bookmarked = bookmarked
    }
}
