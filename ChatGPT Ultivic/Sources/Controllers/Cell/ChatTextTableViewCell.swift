//
//  ChatTextTableViewCell.swift
//  ChatGPT Ultivic
//
//  Created by SHIVAM GAIND on 02/05/23.
//

import UIKit
import AVFoundation

protocol TableViewCellDelegate: AnyObject {
    func speakerButtonTapped(in cell: ChatIncomingTextTableViewCell)
    
}

class ChatIncomingTextTableViewCell: UITableViewCell, AVSpeechSynthesizerDelegate {
    
    // MARK: -  Outlets
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var viewMessage: UIView!
    @IBOutlet weak var btnCopy: UIButton!
    @IBOutlet weak var btntranslate: UIButton!
    @IBOutlet weak var btnSpeaker: UIButton!
    
    weak var delegate: TableViewCellDelegate?
    
    var popUpView: UIView!
//    var speechSynthesizer: AVSpeechSynthesizer?
    
    // MARK: - LifeCycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        viewMessage.clipsToBounds = true
        viewMessage.layer.cornerRadius = 16
        viewMessage.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
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
    
    //MARK: - Functions
    func configureCell(message: String, time: String) {
        
        self.lblMessage.text = message
    }
    // MARK: - Button Actions
    @IBAction func btnCopy(_ sender: UIButton) {
        UIPasteboard.general.string = lblMessage.text
        
    }
    
    
    @IBAction func btnSpeaker(_ sender: UIButton) {
        delegate?.speakerButtonTapped(in: self)

//        sender.isSelected = !sender.isSelected
//        if sender.isSelected {
//            btnSpeaker.setImage(UIImage(named: "Group 14"), for: .selected)
//            if let messageText = lblMessage.text {
//                let speechUtterance = AVSpeechUtterance(string: messageText)
//                speechUtterance.voice = AVSpeechSynthesisVoice(language: NSLinguisticTagger.dominantLanguage(for: messageText))
//
//                // Initialize the speech synthesizer if it doesn't exist
//                if speechSynthesizer == nil {
//                    speechSynthesizer = AVSpeechSynthesizer()
//                    speechSynthesizer?.delegate = self
//                }
//
//                do {
//                    try AVAudioSession.sharedInstance().setCategory(.playback)
//                    try AVAudioSession.sharedInstance().setActive(true, options: [])
//                    speechSynthesizer?.speak(speechUtterance)
//                } catch {
//                    print("Error setting up audio session: \(error)")
//                }
//            } else {
//                // Handle the case when lblMessage.text is nil
//                print("Text is nil")
//            }
//        } else {
//            // Stop the speech synthesizer
//            speechSynthesizer?.stopSpeaking(at: .immediate)
//        }
    }
//    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance){
//        btnSpeaker.setImage(UIImage(named: "Group 13"), for: .selected)
//    }
    
    @IBAction func btntrenslate(_ sender: UIButton) {
        
    }
}
