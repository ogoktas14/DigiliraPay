
import UIKit
import Wallet


class ColoredCardView: CardView {

    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var cardNumber: UILabel!
    @IBOutlet weak var nameSurname: UILabel!
    
    @IBOutlet weak var indexLabel: UILabel!
    
    let digiliraPay = digiliraPayApi()
    var index: Int = 0 {
        didSet {
            cardNumber.text = "# \(index)"
            nameSurname.text = digiliraPay.getName()
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
    
    func randomColor() -> UIColor{
        let red = CGFloat(drand48())
        let green = CGFloat(drand48())
        let blue = CGFloat(drand48())
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    func presentedDidUpdate() {
                
        setGradientBackground(colorTop: randomColor(), colorBottom: randomColor())
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
