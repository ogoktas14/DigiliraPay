
import UIKit
import Wallet


class ColoredCardView: CardView {

    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var l1: UILabel!
    
    @IBOutlet weak var cardNumber: UILabel!
    @IBOutlet weak var remarks: UIView!
    @IBOutlet weak var nameSurname: UILabel!
    @IBOutlet weak var logoView: UIImageView!
    @IBOutlet weak var bgView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var indexLabel: UILabel!
    weak var delegate: ColoredCardViewDelegate?
    let generator = UINotificationFeedbackGenerator()
    var color: UIColor?
    var logo: UIImage?
    var apiSet: Bool = false
    var cardMode: String = ""
    
    var cardInfo: Constants.cardData = Constants.cardData.init(org: "", bgColor: .red, logoName: "", cardHolder: "", cardNumber: "1")
    
    var index: Int = 0 {
        didSet {
            //indexLabel.text = "# \(index)"

        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(setLogo))
        cardNumber.addGestureRecognizer(tap)

        contentView.layer.cornerRadius  = 10
        contentView.layer.masksToBounds = true 
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        presentedDidUpdate()

    }
    
    override var presented: Bool { didSet { presentedDidUpdate() } }
    
    
    func presentedDidUpdate() {
                
        if presented {
            cardNumber.isUserInteractionEnabled = true
            cardNumber.isHidden = false
            scrollView.isScrollEnabled = true
            remarks.isHidden = false
        } else {
            UIView.animate(withDuration: 1, animations: { [self] in
                            let bottomOffset = CGPoint(x: 0, y: 0)
                            scrollView.setContentOffset(bottomOffset, animated: true)
                
            })
            cardNumber.isUserInteractionEnabled = false
            cardNumber.isHidden = true
            scrollView.isScrollEnabled = false
            remarks.isHidden = true
        }
        
        cardNumber.text = cardInfo.cardNumber
        nameSurname.text = cardInfo.cardHolder
        cardNumber.text = cardInfo.cardNumber
        logoView.image = UIImage(named: cardInfo.logoName)
        cardMode = cardInfo.org
        
        if let line1 = cardInfo.line1 {
            l1.text = line1
        }

        
        setGradientBackground(colorTop: cardInfo.bgColor, colorBottom: cardInfo.bgColor)
        contentView.addTransitionFade()
        
    }
    
    override func longPressed(gestureRecognizer: UILongPressGestureRecognizer) {
        setLogo()
    }
    
    @objc func setLogo () {
         
            if !cardInfo.apiSet {
                generator.notificationOccurred(.success)
                delegate?.passData(data: cardInfo.org)
            }
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
