
import UIKit
import Wallet


class ColoredCardView: CardView {

    @IBOutlet weak var contentView: UIView!
    

    @IBOutlet weak var indexLabel: UILabel!
    var index: Int = 0 {
        didSet {
            indexLabel.text = "# \(index)"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.layer.cornerRadius  = 10
        contentView.layer.masksToBounds = true
                
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        presentedDidUpdate()

    }
    
    override var presented: Bool { didSet { presentedDidUpdate() } }
    
    func presentedDidUpdate() {
        
        let col1 = UIColor(red: 0.13, green: 0.58, blue: 0.69, alpha: 1.00)
        let col2 = UIColor(red: 0.43, green: 0.84, blue: 0.93, alpha: 1.00)
        contentView.backgroundColor = presented ? col1: col2
        setGradientBackground(colorTop: col1, colorBottom: col2)
        contentView.addTransitionFade()
        
    }
    
    func setGradientBackground(colorTop: UIColor, colorBottom: UIColor) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorBottom.cgColor, colorTop.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.locations = [0, 2]
        gradientLayer.frame = bounds

        contentView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    @IBOutlet weak var removeCardViewButton: UIButton!
    @IBAction func removeCardView(_ sender: Any) {
        walletView?.remove(cardView: self, animated: true)
    }
    
}
