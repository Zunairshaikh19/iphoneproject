//
//  LinkPrivacyCell.swift
//  Tappze
//
//  Created by Apple on 13/07/2023.
//

import UIKit

class LinkPrivacyCell: UITableViewCell {
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var isSharedSwitch: UISwitch!
    @IBOutlet weak var mainVu: UIView! {
        didSet {
            mainVu.layer.shadowColor = UIColor.gray.cgColor
            mainVu.layer.shadowOffset = CGSize(width: 0.5, height: 3.0)
            mainVu.layer.shadowRadius = 1.0
            mainVu.layer.shadowOpacity = 0.2
            mainVu.layer.masksToBounds = false
        }
    }
    
    @IBOutlet weak var imgVu: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
