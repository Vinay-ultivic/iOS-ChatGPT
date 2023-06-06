//
//  ChatVC.swift
//  ChatGPT Ultivic
//
//  Created by SHIVAM GAIND on 02/05/23.

import Speech
import AVKit
import UIKit

class ChatVC: UIViewController, UIPopoverPresentationControllerDelegate, UIGestureRecognizerDelegate, TableViewCellDelegate, AVSpeechSynthesizerDelegate {
    
    
    // MARK: -  Outlets
    @IBOutlet weak var viewSendmsg: UIView!
    @IBOutlet weak var tblview: UITableView!
    @IBOutlet weak var sendbtn: UIButton!
    @IBOutlet weak var btnmic: UIButton!
    @IBOutlet weak var txtSendmsg: UITextField!
    @IBOutlet weak var textViewQQ: UIView!
    @IBOutlet weak var viewSendMessageBottom: NSLayoutConstraint!
    //  @IBOutlet weak var textviewmsg: UITextView!
    
    // MARK: - Variables
    let speechRecognizer        = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    var recognitionRequest      : SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask         : SFSpeechRecognitionTask?
    let audioEngine             = AVAudioEngine()
    var btSendClick = false
    var speechSynthesizer: AVSpeechSynthesizer?
    
    var isUpdate = false
    
    
    private var  loaderView : ChatbotThreeDotLoaderView?
    
    enum FindType {
        
        case Text, Code
    }
    var isFind: FindType = .Text
    
    private struct ChatGPT {
        
        let questionAnswer: String
        let isSend: Bool
        var isImage: ImageURL? = nil
    }
    
    private var arrOfQuestionAnswer = [ChatGPT]()
    var arrOfImages = [ImageURL]()
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.backgroundColor = .white
        initWithObjects()
        self.setupSpeech()
        loaderView = ChatbotThreeDotLoaderView(frame: CGRect(x: 0, y: 0, width: 80, height: 20))
        loaderView?.center = view.center
        txtSendmsg.delegate = self
        textViewQQ.layer.cornerRadius = 26
        textViewQQ.layer.masksToBounds = true
        txtSendmsg.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        btnmic.addTarget(self, action: #selector(hideKeyboard), for: .touchUpInside)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.backgroundColor = .white
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    @objc func hideKeyboard() {
        // Resign the first responder status of the text input field
        txtSendmsg.resignFirstResponder()
        btnmic.setImage(UIImage(named: "Vector3"), for: .selected)
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        if txtSendmsg.text!.trime().isEmpty == true {
            btnmic.isHidden = false
        } else {
            btnmic.isHidden = true
        }
    }
    
    //MARK: - Buttons Clicked Action
    @IBAction func backbtn(_ sender: UIBarButtonItem) {
        speechSynthesizer?.stopSpeaking(at: .immediate)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSendClicked(_ sender: UIButton) {
        self.view.endEditing(true)
        
        if (txtSendmsg.text?.trime() == "") {
            self.showAlertWithOkButton(message: "Please type a message to continue.")
        } else {
            getChatGPTResponse(text: txtSendmsg.text ?? "")
            btSendClick = true
            endAudioRecording()
        }
        self.scrollToBottom()
        btnmic.setImage(UIImage(named: "Group 1"), for: .normal)
    }
    
    @IBAction func btnMic(_ sender: UIButton) {
        speechSynthesizer?.stopSpeaking(at: .immediate)
        //  btnmic.isSelected = !btnmic.isSelected
        btnmic.setImage(UIImage(named: "Vector3"), for: .normal)
        //  self.sendbtn.isEnabled = true
        if audioEngine.isRunning {
            //            self.audioEngine.stop()
            //            self.recognitionRequest?.endAudio()
            self.btnmic.isEnabled = false
            //            self.btnmic.setTitle("Start Recording", for: .normal)
        } else {
            self.startRecording()
            // self.btnmic.setImage(UIImage(named: "Vector3"), for: .selected)
            // self.btnmic.setTitle("Stop Recording", for: .normal)
        }
    }
    
    //MARK: - Functions
    private func getChatGPTResponse(text: String) {
        self.scrollToBottom()
        if let loaderView = self.loaderView {
            self.view.addSubview(loaderView)
            loaderView.startAnimation()
        }
        self.sendMessage(question: text.trime(), isSend: true)
        let isFind = isFind == .Text ? true:false
        
        OpenAIManager.shared.processPrompt(prompt: text.trime(), isType: isFind) { reponse in
            if let loaderView = self.loaderView {
                loaderView.stopAnimation()
                loaderView.removeFromSuperview()
            }
            self.sendMessage(question: reponse.trime(), isSend: false)
            self.scrollToBottom()
        }
    }
    
    @objc private func initWithObjects() {
        
        let isFind = isFind == .Text ? "ChatGPT":"Code Completion"
        // self.lbltitle.text = isFind
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    // MARK: - Keyboard Hide
    @objc func keyboardWillHide(_ sender: Notification) {
        
        if let userInfo = (sender as NSNotification).userInfo {
            if let _ = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height {
                self.viewSendMessageBottom.constant =  16
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    // MARK: - Keyboard Showing
    @objc func keyboardWillShow(_ sender: Notification) {
        
        if let userInfo = (sender as NSNotification).userInfo {
            if let keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height {
                self.view.layoutIfNeeded()
                if #available(iOS 11.0, *) {
                    self.viewSendMessageBottom.constant = (keyboardHeight - (APPDEL.window?.safeAreaInsets.bottom ?? 0) - -16)
                    btnmic.isHidden = false
                    txtSendmsg.placeholder = Constant.Typeamessage
                    btnmic.setImage(UIImage(named: "Group 1"), for: .normal)
                    //  self.sendbtn.isEnabled = false
                    self.audioEngine.stop()
                    self.recognitionRequest?.endAudio()
                    DispatchQueue.main.async {
                        self.reloadTable()
                        self.scrollToBottom()
                    }
                } else {
                    self.viewSendMessageBottom.constant = (keyboardHeight - 16)
                    tblview.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                }
                
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    
    // MARK: -  Response Language Change
    func translateResponse(isHindi:Bool = false, isJapanese:Bool = false, isSpanish:Bool = false, sender:UIButton) {
        self.view.endEditing(true)
        if let loaderView = self.loaderView {
            self.view.addSubview(loaderView)
            loaderView.startAnimation()
        }
        var text = ""
        if isHindi {
            text = Constant.translateinhindi
        }else if isJapanese {
            text = Constant.translateinjapanese
        }else if isSpanish {
            text = Constant.translateinspanish
        }
        let isFind = isFind == .Text ? true:false
        
        OpenAIManager.shared.processPrompt(prompt: arrOfQuestionAnswer[sender.tag].questionAnswer + text , isType: isFind) { reponse in
            
            if let loaderView = self.loaderView {
                loaderView.stopAnimation()
                loaderView.removeFromSuperview()
            }
            self.sendMessage(question: reponse.trime(), isSend: false)
            self.scrollToBottom()
        }
    }
    
    // MARK: - Image Showing
    func convertImage(sender: UIButton) {
        self.view.endEditing(true)
        if let loaderView = self.loaderView {
            self.view.addSubview(loaderView)
            loaderView.startAnimation()
        }
        let selectedRow = sender.tag
        var existingData = arrOfQuestionAnswer[selectedRow]
        
        OpenAIManager.shared.fetchImageForPrompt(prompt: existingData.questionAnswer) { url in
            DispatchQueue.main.async {
                print(url)
                let imageEntry = ChatGPT(questionAnswer: "", isSend: false, isImage: url)
                existingData.isImage = nil // Clear existing image URL if any
                self.arrOfQuestionAnswer.insert(imageEntry, at: selectedRow + 1) // Insert the new image entry below the existing row
                self.tblview.reloadData()
                if let loaderView = self.loaderView {
                    loaderView.stopAnimation()
                    loaderView.removeFromSuperview()
                    self.scrollToBottom()
                }
            }
        }
    }
    
    @objc func buttonCopy(sender:UIButton) {
        showAlertWithOkButton(message: Constant.Textcopied)
    }
    
    // MARK: - Button translate
    @objc func buttonClicked(sender:UIButton) {
        
        if #available(iOS 14.0, *) {
            let defareliment = UIDeferredMenuElement {(menuElements) in
                let Hindi = UIAction(title:"            In Hindi") {
                    _ in
                    
                    self.translateResponse(isHindi: true,sender: sender)
                }
                let Japanese = UIAction(title:"            In Japanese"){
                    _ in
                    self.translateResponse(isJapanese: true,sender: sender)
                    
                }
                let Spanish = UIAction(title:"            In Spanish"){
                    _ in
                    self.translateResponse(isSpanish: true, sender: sender)
                    
                }
                let menu = UIMenu(title: Constant.Translate, image: UIImage(named: "Translate") ,children: [Hindi,Japanese,Spanish])
                // DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                menuElements([menu])
                // }
            }
            // MARK: - Button image Generater
            let Generate = UIAction(title: Constant.GenerateImage,image: UIImage(named: "GenerateImage")) {
                _ in
                self.convertImage(sender: sender)
                
            }
            let menu = UIMenu(title: Constant.Options , children: [defareliment,Generate])
            if #available(iOS 14.0, *) {
                sender.showsMenuAsPrimaryAction = true
            } else {
                // Fallback on earlier versions
            }
            sender.menu = menu
        }else {
            let destruct = UIAction(title: Constant.Destruct, attributes: .destructive) { _ in }
            let button = ContextMenuButton()
            button.actionProvider = { _ in
                UIMenu(title: "", children: [destruct])
            }
        }
    }
    private func reloadTable() {
        self.tblview.reloadData()
        if self.arrOfQuestionAnswer.count > 0 {
            self.tblview.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: true)
        }
    }
    
    // MARK: - Tableview Scroll Automatic
    func scrollToBottom() {
        let lastRowIndex = tblview.numberOfRows(inSection: 0) - 1
        if lastRowIndex >= 0 {
            let lastIndexPath = IndexPath(row: lastRowIndex, section: 0)
            tblview.scrollToRow(at: lastIndexPath, at: .bottom, animated: true)
        }
    }
    
    private func sendMessage(question: String, isSend: Bool) {
        
        self.arrOfQuestionAnswer.append(ChatGPT(questionAnswer: question, isSend: isSend))
        self.reloadTable()
        
        //     self.sendbtn.isEnabled = false
    }
    func speakerButtonTapped(in cell: ChatIncomingTextTableViewCell) {
        cell.btnSpeaker.isSelected = !cell.btnSpeaker.isSelected
        if cell.btnSpeaker.isSelected  {
            cell.btnSpeaker.setImage(UIImage(named: "Group 14"), for: .selected)
            if let messageText = cell.lblMessage.text {
                let speechUtterance = AVSpeechUtterance(string: messageText)
                speechUtterance.voice = AVSpeechSynthesisVoice(language: NSLinguisticTagger.dominantLanguage(for: messageText))
                
                // Initialize the speech synthesizer if it doesn't exist
                if speechSynthesizer == nil {
                    speechSynthesizer = AVSpeechSynthesizer()
                    speechSynthesizer?.delegate = self
                }
                
                do {
                    try AVAudioSession.sharedInstance().setCategory(.playback)
                    try AVAudioSession.sharedInstance().setActive(true, options: [])
                    speechSynthesizer?.speak(speechUtterance)
                } catch {
                    print("Error setting up audio session: \(error)")
                }
            } else {
                // Handle the case when lblMessage.text is nil
                print("Text is nil")
            }
        } else {
            // Stop the speech synthesizer
            speechSynthesizer?.stopSpeaking(at: .immediate)
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance){
        isUpdate = true
        tblview.reloadData()
    }
}

extension ChatVC {
    
    func setupSpeech() {
        self.btnmic.isEnabled = false
        self.speechRecognizer?.delegate = self
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            
            var isButtonEnabled = false
            
            switch authStatus {
            case .authorized:
                isButtonEnabled = true
                
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
                
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            @unknown default:
                break
            }
            
            OperationQueue.main.addOperation() {
                self.btnmic.isEnabled = isButtonEnabled
            }
        }
    }
    
    func startRecording() {
        // Clear all previous session data and cancel task
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        // Create instance of audio session to record voice
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.record, mode: AVAudioSession.Mode.measurement, options: AVAudioSession.CategoryOptions.defaultToSpeaker)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        self.recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        self.recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            
            if result != nil {
                if self.btSendClick == true {
                    self.btSendClick = false
                    self.txtSendmsg.text = ""
                    self.txtSendmsg.placeholder = Constant.Typeamessage
                } else {
                    self.txtSendmsg.text = result?.bestTranscription.formattedString
                }
                
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
      ///          self.sendbtn.isEnabled = true
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
//                self.txtSendmsg.text = ""
                self.recognitionRequest = nil
                self.recognitionTask = nil
//                self.txtSendmsg.placeholder = Constant.Typeamessage
                self.btnmic.isEnabled = true
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        self.audioEngine.prepare()
        
        do {
            try self.audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        btnmic.setImage(UIImage(named: "Vector3"), for: .normal)
        self.txtSendmsg.placeholder = Constant.Saysomething
    }
    
    func endAudioRecording() {
        // End Audio Recording
        if self.audioEngine.isRunning {
            self.audioEngine.stop()
            self.recognitionRequest?.endAudio()
            self.recognitionTask?.cancel()
            self.recognitionRequest = nil
            self.recognitionTask = nil
            self.audioEngine.inputNode.removeTap(onBus: 0)
        }
        
        self.txtSendmsg.text = ""
        self.txtSendmsg.placeholder = Constant.Typeamessage
    }
}

//MARK: - UITableViewDataSource Methods
extension ChatVC: UITableViewDelegate, UITableViewDataSource {
   
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrOfQuestionAnswer.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.arrOfQuestionAnswer[indexPath.row].isImage == nil {
            //indexPath.row % 2 == 0
            if self.arrOfQuestionAnswer[indexPath.row].isSend == true {
                
                //Outgoing
                let cell1 = tableView.dequeueReusableCell(withIdentifier: "ChatOutgoingTextTableViewCell") as! ChatOutgoingTextTableViewCell
                
                let question = arrOfQuestionAnswer[indexPath.row].questionAnswer
                let currentTime = Date.getCurrentDateTime(format: "h:mm a")
                cell1.configureCell(message: question, time: currentTime)
                
                return cell1
            } else {
                
                //Incoming
                let cell2 = tableView.dequeueReusableCell(withIdentifier: "ChatIncomingTextTableViewCell") as! ChatIncomingTextTableViewCell
                
                let answer = arrOfQuestionAnswer[indexPath.row].questionAnswer
                let currentTime = Date.getCurrentDateTime(format: "h:mm a")
                cell2.configureCell(message: answer, time: currentTime)
                cell2.btntranslate.tag = indexPath.row
                cell2.delegate = self
                
                if isUpdate {
                    cell2.btnSpeaker.setImage(UIImage(named: "Group 13"), for: .selected)
                } else {
                    cell2.btnSpeaker.setImage(UIImage(named: "Group 14"), for: .selected)
                }

                if #available(iOS 14.0, *) {
                    cell2.btntranslate.addTarget(self, action: #selector(buttonClicked), for: UIControl.Event.touchUpInside)
                } else {
                    // Fallback on earlier versions
                }
                cell2.btnCopy.addTarget(self, action: #selector(buttonCopy), for: UIControl.Event.touchUpInside)
                return cell2
            }
        }
        else {
            // image
            let cell = tableView.dequeueReusableCell(withIdentifier: "ImageGeneratCell") as! ImageGeneratCell
            let url = self.arrOfQuestionAnswer[indexPath.row].isImage?.url ?? ""//arrOfImages[indexPath.row].url
            cell.generateImg.loadImageUsingCache(withUrl: url)
            
            return cell
        }
    }
    
    //    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    //        cell.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
    //
    //        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: .curveEaseOut, animations: {
    //            cell.transform = .identity
    //        }, completion: nil)
    //    }
    
    func tableView(_ tableView: UITableView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        
        guard let indexPath = configuration.identifier as? IndexPath, let cell = tableView.cellForRow(at: indexPath) else {
            return nil
        }
        
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        
        return UITargetedPreview(view: cell, parameters: parameters)
    }
    
    // MARK: - Table view in rows press to hold on COPY and SHARE text
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        let font = self.arrOfQuestionAnswer[indexPath.row].questionAnswer
        return UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: nil) { _ -> UIMenu? in
            
            let copyAction = UIAction(title: "Copy", image: UIImage(systemName: "doc.on.doc"), identifier: nil) { _ in
                
                UIPasteboard.general.string = font
            }
            
            let shareAction = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { _ in
                
                let textToShare = [font]
                let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self.view
                activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
                self.present(activityViewController, animated: true, completion: nil)
            }
            
            //            let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { action in
            //
            //                self.arrOfQuestionAnswer.remove(at: indexPath.row)
            //                tableView.deleteRows(at: [indexPath], with: .automatic)
            //            }
            
            let menu = UIMenu(title: Constant.kAppName, image: nil, identifier: nil, options: [], children: [copyAction, shareAction])
            return menu
        }
    }
    
    func tableView(_ tableView: UITableView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        
        guard let indexPath = configuration.identifier as? IndexPath, let cell = tableView.cellForRow(at: indexPath) else {
            return nil
        }
        
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        
        return UITargetedPreview(view: cell, parameters: parameters)
    }
    
    func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        
        animator.addCompletion {
            if let viewController = animator.previewViewController {
                self.show(viewController, sender: self)
            }
        }
    }
}

//MARK: - UITextFieldDelegate Methods
extension ChatVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        switch textField {
            
        default:
            
            textField.resignFirstResponder()
        }
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let updatedText = textField.getUpadatedText(string: string, range: range)
        txtSendmsg.placeholder = Constant.Typeamessage
//        switch textField {
//        case txtSendmsg:
//            let isEnabled = updatedText.trime() == "" ? false:true
//            self.sendbtn.isEnabled = isEnabled
//            if isEnabled {
//                txtSendmsg.placeholder = Constant.Typeamessage
//            }
//
//
//        default:
//            break
//       }
        
        return true
    }
}

extension ChatVC: SFSpeechRecognizerDelegate {
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            self.btnmic.isEnabled = true
        } else {
            self.btnmic.isEnabled = false
        }
    }
}

