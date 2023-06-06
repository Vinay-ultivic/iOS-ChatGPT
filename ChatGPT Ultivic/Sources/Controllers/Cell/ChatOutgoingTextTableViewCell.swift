//
//  ChatOutgoingTextTableViewCell.swift
//  ChatGPT Ultivic
//
//  Created by SHIVAM GAIND on 02/05/23.
//

import UIKit

class ChatOutgoingTextTableViewCell: UITableViewCell {

    @IBOutlet weak var viewMessage: UIView!
    @IBOutlet weak var lblMessage: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewMessage.clipsToBounds = true
        viewMessage.layer.cornerRadius = 16
        viewMessage.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        viewMessage.layoutIfNeeded()
        viewMessage.setCornerRaius(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radious: 4)
    }
    
    //MARK:-  Buttons Clicked Action

    
    //MARK:-  Functions
    func configureCell(message: String, time: String) {
        
        self.lblMessage.text = message
        
    }
}
