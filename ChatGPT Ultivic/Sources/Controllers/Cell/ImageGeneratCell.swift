//
//  ImageGeneratCell.swift
//  ChatGPT Ultivic
//
//  Created by SHIVAM GAIND on 16/05/23.
//

import UIKit

class ImageGeneratCell: UITableViewCell {

    @IBOutlet weak var generateImg: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        generateImg.clipsToBounds = true
        generateImg.layer.cornerRadius = 16
        generateImg.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }

}
