
import UIKit

extension UIView {
    
    static func reuseIdentifier() -> String {
        return NSStringFromClass(classForCoder()).components(separatedBy: ".").last!
    }
    
    static func UINibForClass(_ bundle: Bundle? = nil) -> UINib {
        return UINib(nibName: reuseIdentifier(), bundle: bundle)
    }
    
    static func nibForClass() -> Self {
        return loadNib(self)
        
    }
    
    static func loadNib<A>(_ owner: AnyObject, bundle: Bundle = Bundle.main) -> A {
        
        let nibName = NSStringFromClass(classForCoder()).components(separatedBy: ".").last!
        
        let nib = bundle.loadNibNamed(nibName, owner: owner, options: nil)!
        
        for item in nib {
            if let item = item as? A {
                return item
            }
        }
        
        return nib.last as! A
        
    }
    
    func addTransitionFade(_ duration: TimeInterval = 0.5) {
        let animation = CATransition()

        animation.type = CATransitionType.fade
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.default)
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.duration = duration

        layer.add(animation, forKey: "kCATransitionFade")

    }
    
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.6
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
        layer.add(animation, forKey: "shake")
    }
    
    func rotate() {
        
        let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: Double.pi)
        rotation.duration = 0.5
        rotation.isCumulative = true
        rotation.repeatCount = Float.greatestFiniteMagnitude
        layer.add(rotation, forKey: "rotationAnimation")
    }
    
    func setShadExt(view: UIView, cornerRad: CGFloat = 0, mask: Bool = false) {
        view.layer.shadowOpacity = 0.2
        view.layer.cornerRadius = cornerRad
        view.layer.masksToBounds = mask
        view.layer.shadowRadius = 1
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width:1, height: 1)
        
    }
    
}
