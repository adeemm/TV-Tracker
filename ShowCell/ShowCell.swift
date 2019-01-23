//
//  ShowCell.swift
//  TV Tracker
//
//  Created by Adeem on 10/29/18.
//  Copyright © 2018 Adeem. All rights reserved.
//

import UIKit

class ShowCell: UITableViewCell {
    
    @IBOutlet weak var banner: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setBanner(image: UIImage?) {
        if image != nil {
            self.banner.image = image
        }
    }
}
