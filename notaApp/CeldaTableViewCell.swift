//
//  CeldaTableViewCell.swift
//  notaApp
//
//  Created by Jonh Parra on 08/11/19.
//  Copyright © 2019 Jonh Parra. All rights reserved.
//

import UIKit

class CeldaTableViewCell: UITableViewCell {

    @IBOutlet weak var titulo: UILabel!
    @IBOutlet weak var fecha: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
