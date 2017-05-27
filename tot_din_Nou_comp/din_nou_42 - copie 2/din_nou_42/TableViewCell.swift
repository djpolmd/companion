//
//  TableViewCell.swift
//  din_nou_42
//
//  Created by Dobos Pavel on 25.05.2017.
//  Copyright © 2017 Dobos Pavel. All rights reserved.
//
import Foundation
import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var level: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.level.layer.cornerRadius = 5
        self.level.clipsToBounds = true

    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
