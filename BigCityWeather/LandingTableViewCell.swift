//
//  LandingTableViewCell.swift
//  BigCityWeather
//
//  Created by Tobias Robert Brysiewicz on 8/21/16.
//  Copyright © 2016 Tobias Robert Brysiewicz. All rights reserved.
//

import UIKit

class LandingTableViewCell: UITableViewCell {

    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
