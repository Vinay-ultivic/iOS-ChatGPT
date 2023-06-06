//
//  Extension.swift
//  ChatGPT Ultivic
//  Created by SHIVAM GAIND on 05/05/23.


import Foundation
import UIKit

extension UIViewController {
    // MARK: - Toast
    func showToast(message : String, font: UIFont) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor(named: "liteRed")
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}
//MARK: - Custom Dot Loading Animation
class ChatbotThreeDotLoaderView: UIView {
    
    private var isAnimating = false
    
    private let dotSize: CGFloat = 20.0
    private let dotSpacing: CGFloat = 20.0
    private let animationDuration: CFTimeInterval = 0.8
    
    private lazy var dot1: CAShapeLayer = {
        let layer = createDot()
        layer.position = CGPoint(x: bounds.midX - dotSpacing, y: bounds.midY)
        return layer
    }()
    
    private lazy var dot2: CAShapeLayer = {
        let layer = createDot()
        layer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        return layer
    }()
    
    private lazy var dot3: CAShapeLayer = {
        let layer = createDot()
        layer.position = CGPoint(x: bounds.midX + dotSpacing, y: bounds.midY)
        return layer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(dot1)
        layer.addSublayer(dot2)
        layer.addSublayer(dot3)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        animateDots()
    }
    
    private func createDot() -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.bounds = CGRect(x: 0, y: 0, width: dotSize, height: dotSize)
        layer.path = UIBezierPath(ovalIn: layer.bounds).cgPath
        layer.fillColor = UIColor.gray.cgColor
        return layer
    }
    
    private func animateDots() {
        dot1.isHidden = false
        dot2.isHidden = false
        dot3.isHidden = false
        let dot1Animation = createDotAnimation(beginTime: 0.0)
        let dot2Animation = createDotAnimation(beginTime: animationDuration / 3)
        let dot3Animation = createDotAnimation(beginTime: animationDuration * 2 / 3)
        dot1.add(dot1Animation, forKey: "dot1Animation")
        dot2.add(dot2Animation, forKey: "dot2Animation")
        dot3.add(dot3Animation, forKey: "dot3Animation")
    }
    
    private func createDotAnimation(beginTime: CFTimeInterval) -> CAKeyframeAnimation {
        let animation = CAKeyframeAnimation(keyPath: "transform.scale")
        animation.duration = animationDuration
        animation.values = [1.0, 0.4, 1.0]
        animation.keyTimes = [0.0, 0.5, 1.0]
        animation.timingFunctions = [
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut)
        ]
        animation.repeatCount = .infinity
        animation.beginTime = beginTime
        animation.isRemovedOnCompletion = false
        return animation
    }
    
    func stopAnimation() {
        guard isAnimating else { return }
        isAnimating = false
        dot1.removeAnimation(forKey: "dot1Animation")
        dot2.removeAnimation(forKey: "dot2Animation")
        dot3.removeAnimation(forKey: "dot3Animation")
        dot1.isHidden = true
        dot2.isHidden = true
        dot3.isHidden = true
    }
    
    func startAnimation() {
        guard !isAnimating else { return }
        isAnimating = true
        animateDots()
    }
}
// MARK: - Context Menu Button
class ContextMenuButton: UIButton {
    var previewProvider: UIContextMenuContentPreviewProvider?
    var actionProvider: UIContextMenuActionProvider?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func setup() {
        let interaction = UIContextMenuInteraction(delegate: self)
        addInteraction(interaction)
    }

    public override func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: previewProvider,
            actionProvider: actionProvider
        )
    }
}
