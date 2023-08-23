

import UIKit

class CollectionHeaderView: UICollectionReusableView {
    
    @IBOutlet weak var imgVu: UIImageView! {
        didSet {
            imgVu.layer.cornerRadius = imgVu.frame.size.width / 2
                       imgVu.clipsToBounds = true
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = imgVu.bounds
            gradientLayer.frame.size.width = imgVu.frame.size.width + 50
            gradientLayer.colors = [UIColor.white.withAlphaComponent(0.1).cgColor, UIColor.white.withAlphaComponent(0.5).cgColor]
            self.imgVu.layer.addSublayer(gradientLayer)
        }
        
    }
    @IBOutlet weak var coverVu: UIImageView!{
        didSet {
            
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = coverVu.bounds
            gradientLayer.frame.size.width = coverVu.frame.size.width + 50
            gradientLayer.colors = [UIColor.white.withAlphaComponent(0.1).cgColor, UIColor.white.withAlphaComponent(0.5).cgColor]
            self.coverVu.layer.addSublayer(gradientLayer)
        }
        
    }
    @IBOutlet weak var leadCapture_toggleBtn: UISwitch!
    @IBOutlet weak var profileOnOff_toggleBtn: UISwitch!

    @IBOutlet weak var nameLbl: UILabel! {
        didSet {
            self.addShadowToView(view: nameLbl)
        }
    }
    @IBOutlet weak var userNameLbl: UILabel! {
        didSet {
            self.addShadowToView(view: userNameLbl)
        }
    }
    @IBOutlet weak var emailLbl: UILabel! {
        didSet {
            self.addShadowToView(view: emailLbl)
        }
    }
    @IBOutlet weak var phoneLbl: UILabel! {
        didSet {
            self.addShadowToView(view: phoneLbl)
        }
    }
    @IBOutlet weak var companyLbl: UILabel! {
        didSet {
            self.addShadowToView(view: companyLbl)
        }
    }
    @IBOutlet weak var editUserBtn: UIButton!
    @IBOutlet weak var segment: UISegmentedControl!
    
    var delegate: SegmentChanged? = nil
    @IBOutlet weak var containerView: UIView!
    
    @IBAction func segmentChange(_ sender: Any) {
        self.delegate?.didChangeSegment(segment: segment)
    }

    func addShadowToView(view: UIView) {
        view.layer.shadowColor = UIColor.white.cgColor
        view.layer.shadowOffset = CGSize(width: 0.5, height: 3.0)
        view.layer.shadowRadius = 10.0
        view.layer.shadowOpacity = 1
        view.layer.masksToBounds = false
    }
}

protocol SegmentChanged {
    func didChangeSegment(segment: UISegmentedControl)
}

