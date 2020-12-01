
import UIKit
import Wallet


class ColoredCardView: CardView {

    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var cardNumber: UILabel!
    @IBOutlet weak var remarks: UILabel!
    @IBOutlet weak var nameSurname: UILabel!
    @IBOutlet weak var logoView: UIImageView!
    @IBOutlet weak var bgView: UIImageView!

    @IBOutlet weak var indexLabel: UILabel!
    weak var delegate: ColoredCardViewDelegate?
    let generator = UINotificationFeedbackGenerator()
    var color: UIColor?
    var logo: UIImage?
    var apiSet: Bool = false
    var cardMode: String = ""
    
    var cardInfo: digilira.cardData = digilira.cardData.init(org: "", bgColor: .red, logoName: "", cardHolder: "", cardNumber: "1", remarks: "")
    
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
            remarks.isHidden = false
            remarks.sizeToFit()
        } else {
            cardNumber.isUserInteractionEnabled = false
            cardNumber.isHidden = true

            remarks.isHidden = true
        }
        
        cardNumber.text = cardInfo.cardNumber
        nameSurname.text = cardInfo.cardHolder
        cardNumber.text = cardInfo.cardNumber
        logoView.image = UIImage(named: cardInfo.logoName)
        cardMode = cardInfo.org
        remarks.text = cardInfo.remarks
        
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
