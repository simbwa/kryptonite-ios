//
//  Resources.swift
//  Kryptonite
//
//  Created by Alex Grinman on 10/24/15.
//  Copyright © 2015 KryptCo. All rights reserved.
//

import Foundation
import UIKit

struct Resources {
    
    //MARK: Storyboards
    struct Storyboard {
        static let Main = UIStoryboard(name: "Main", bundle: Bundle.main)
        static let Approval = UIStoryboard(name: "Approval", bundle: Bundle.main)
        static let Approval = UIStoryboard(name: "Team", bundle: Bundle.main)
    }
    
    static func makeAppearences() {
        UINavigationBar.appearance().barTintColor = nil
        UINavigationBar.appearance().tintColor = UIColor.app
        
        
        
        if let font = UIFont(name: "AvenirNext-Bold", size: 18) {
            UINavigationBar.appearance().titleTextAttributes = [
                NSForegroundColorAttributeName: UIColor(hex: 0x555555),
                NSFontAttributeName: font,
            ]
        }


       // UIButton.appearance().tintColor = UIColor.app
        UISwitch.appearance().tintColor = UIColor.app
        UISegmentedControl.appearance().tintColor = UIColor.app
        

        // Custom Classes
        StyleFilledButton.appearance().backgroundColor = UIColor.app
        StyleFilledView.appearance().backgroundColor = UIColor.app
    }
}

func RGB(_ r:CGFloat, _ g:CGFloat, _ b:CGFloat, _ a:CGFloat = 1.0) -> UIColor {
    return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
}

//MARK: Extensions

extension UIColor {
    
    convenience init(hex: Int) {
        let components = (
            R: CGFloat((hex >> 16) & 0xff) / 255,
            G: CGFloat((hex >> 08) & 0xff) / 255,
            B: CGFloat((hex >> 00) & 0xff) / 255
        )
        
        self.init(red: components.R, green: components.G, blue: components.B, alpha: 1)
    }
    
    static var app:UIColor {
        return UIColor(hex: 0x5BC894)
    }
    
    static var reject:UIColor {
        return UIColor(hex: 0xFF6361)
    }
}



extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
    
    var coreImageColor: CIColor {
        return CIColor(color: self)
    }
    
    static func colorFromString(string: String) -> UIColor {
        let hash: Int = string.hashValue
        let r: Int = (hash & 0xFF0000) >> 16
        let g: Int = (hash & 0x00FF00) >> 8
        let b: Int = (hash & 0x0000FF)
        return RGB(CGFloat(r), CGFloat(g), CGFloat(b), 1.0)
    }

}

//MARK: Navigation Bar

extension UINavigationItem {
    func setKrLogo() {
        
        let logo = UIImageView(image: UIImage(named: "app-icon-nav-green"))
        
        //logo.tintColor = UIColor.black.withAlphaComponent(0.2)
        logo.frame = CGRect(origin: CGPoint(x: 0, y: 0), size:CGSize(width: 30, height: 34))

    
        let title = UIView()
        title.addSubview(logo)
        self.titleView = title
        logo.center = title.center
    }

}


//MARK: Custom UI Class

class KRButton:UIButton {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }

    @IBInspectable var defaultColor:UIColor = UIColor.app {
        didSet {
            setTitleColor(defaultColor, for: UIControlState.normal)
            layer.borderColor = defaultColor.cgColor
            layer.borderWidth = 1.0
        }
    }
    
    @IBInspectable var altForegroundColor:UIColor = UIColor.white {
        didSet {
            setTitleColor(altForegroundColor, for: UIControlState.highlighted)
            backgroundColor = UIColor.clear
        }
    }
    
    
    @IBInspectable var borderWidth: CGFloat = 1.0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }

    

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        backgroundColor = defaultColor

    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        backgroundColor = UIColor.clear
    }
}


class KRSimpleButton:UIButton {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    
    @IBInspectable var highlightedColor:UIColor = UIColor.white
    
    @IBInspectable var borderWidth: CGFloat = 1.0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if let originalColor = backgroundColor {
            backgroundColor = highlightedColor
            highlightedColor = originalColor
        }
        
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        if let highlight = backgroundColor {
            backgroundColor = highlightedColor
            highlightedColor = highlight
        }

    }
}


class KRImageView:UIImageView {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

class KRView:UIView {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    
    
    @IBInspectable var borderWidth: CGFloat = 0.0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor:UIColor = UIColor.clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}



class StyleFilledButton:UIButton {}
class StyleFilledView:UIView {}

extension UIView {
    
    func setBorder(color:UIColor = UIColor.app, cornerRadius:CGFloat = 0.0, borderWidth:CGFloat = 0.0) {
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = cornerRadius > 0

        layer.borderWidth = borderWidth
        layer.borderColor = color.cgColor
    }
}


// MARK: Animation Extensions

extension UIView {
    
    func pulse(scale:CGFloat, duration:TimeInterval) {
        
        UIView.animate(withDuration: duration, delay: 0.0, options:  [UIViewAnimationOptions.allowUserInteraction, UIViewAnimationOptions.autoreverse, UIViewAnimationOptions.repeat], animations: {
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
            
        }, completion: nil)
    }
    
    func spinningArc(lineWidth:CGFloat, ratio:CGFloat = 0.2, color:UIColor = UIColor.app) {
        let frameSize = self.frame.size
        
        let innerCircle = CAShapeLayer()
        innerCircle.path = UIBezierPath(ovalIn: CGRect(x: 0.0, y: 0.0, width: frameSize.width, height: frameSize.height)).cgPath
        
        innerCircle.lineWidth = lineWidth
        innerCircle.strokeStart = 0.1
        innerCircle.strokeEnd = 0.1+ratio
        innerCircle.lineCap = kCALineCapRound
        innerCircle.fillColor = UIColor.clear.cgColor
        innerCircle.strokeColor = color.cgColor
        self.layer.addSublayer(innerCircle)
        
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotateAnimation.toValue = CGFloat(Double.pi*2.0)
        rotateAnimation.duration = 2.0
        rotateAnimation.isCumulative = true
        rotateAnimation.repeatCount = .infinity
        self.layer.add(rotateAnimation, forKey: "rotation")
    }
    
    func timeoutProgress(lineWidth:CGFloat, seconds:Double, color:UIColor = UIColor.app) {
        let frameSize = self.frame.size
        
        let innerCircle = CAShapeLayer()
        innerCircle.path = UIBezierPath(ovalIn: CGRect(x: 0.0, y: 0.0, width: frameSize.width, height: frameSize.height)).cgPath
        
        innerCircle.lineWidth = lineWidth
        innerCircle.strokeStart = 0.0
        innerCircle.strokeEnd = 0.0
        innerCircle.lineCap = kCALineCapRound
        innerCircle.fillColor = UIColor.clear.cgColor
        innerCircle.strokeColor = color.cgColor
        self.layer.addSublayer(innerCircle)
        
        let strokeAnimation = CABasicAnimation(keyPath: "strokeEnd")
        strokeAnimation.toValue = 1.0
        strokeAnimation.duration = seconds
        strokeAnimation.isCumulative = true
        innerCircle.add(strokeAnimation, forKey: "stroke")
    }
    
    func stopAnimations() {
        self.layer.removeAllAnimations()
    }
    
}


class RoundedView:UIView {
    
    @IBInspectable var cornerRadius:CGFloat = 0

    @IBInspectable var topLeft:Bool = false
    @IBInspectable var topRight:Bool = false
    @IBInspectable var bottomLeft:Bool = false
    @IBInspectable var bottomRight:Bool = false

    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        var corners = UIRectCorner.allCorners
        
        if !topLeft {
            corners.remove(.topLeft)
        }
        
        if !bottomLeft {
            corners.remove(.bottomLeft)
        }
        
        if !bottomRight {
            corners.remove(.bottomRight)
        }
        if !topRight {
            corners.remove(.topRight)
        }
        
        self.set(corners: corners, radius: cornerRadius)
    }
    
    func set(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }

    
}
