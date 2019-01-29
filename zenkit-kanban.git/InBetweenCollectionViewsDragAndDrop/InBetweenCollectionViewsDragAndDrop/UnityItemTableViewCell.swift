//
//  UnityItemTableViewCell.swift
//  InBetweenCollectionViewsDragAndDrop
//
//  Created by Jean Joseph on 9/13/17.
//  Copyright © 2017 Jean Joseph. All rights reserved.
//

import UIKit

class UnityItemTableViewCell: UITableViewCell {

    @IBOutlet weak var view: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
