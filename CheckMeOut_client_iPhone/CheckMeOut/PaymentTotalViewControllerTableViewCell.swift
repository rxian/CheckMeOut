//
//  PaymentTotalViewControllerTableViewCell.swift
//  CheckMeOut
//
//  Created by R. Xian on 11/7/15.
//

import UIKit

class PaymentTotalViewControllerTableViewCell: UITableViewCell {

    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var storeName: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
