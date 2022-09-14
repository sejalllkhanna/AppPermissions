//
//  TableViewCell.swift
//  TableViewCell
//
//  Created by Sejal Khanna on 24/09/21.
//

import UIKit
import Foundation


class GrantPermissionCell: UITableViewCell {
    
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var TitleSubLabel: UILabel!
    @IBOutlet weak var SerialNumberLabel: UILabel!
    @IBOutlet weak var SelectedButton: UIButton!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
}
