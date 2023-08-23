

import UIKit
import iOSDropDown

class AddLinksReusableView: UICollectionReusableView {
    
    
    //@IBOutlet weak var addLogoBtn: UIButton!
    @IBOutlet weak var addProfileImg: UIButton!
    @IBOutlet weak var removeProfileImg: UIButton!
    
    @IBOutlet weak var removecoverImg: UIButton!
    @IBOutlet weak var addcoverImg: UIButton!
    //username btn and textField
    @IBOutlet weak var userNameVu: UIView!
    @IBOutlet weak var editUsernameBtn: UIButton! {
        didSet {
            editUsernameBtn.tag = 1
        }
    }
    @IBOutlet weak var nameTF: UITextField! {
        didSet {
            nameTF.tag = 11
        }
    }
    
    
    @IBOutlet weak var editBioBtn: UIButton! {
        didSet {
            editBioBtn.tag = 2
        }
    }
    @IBOutlet weak var bioLbl: UILabel!
    
    
    // phone
    @IBOutlet weak var phoneVu: UIView!
    @IBOutlet weak var editPhoneBtn: UIButton! {
        didSet {
            editPhoneBtn.tag = 3
        }
    }
    @IBOutlet weak var phoneTF: UITextField! {
        didSet {
            phoneTF.tag = 33
        }
    }
    
    @IBOutlet weak var companyVu: UIView!
    @IBOutlet weak var editCompanyBtn: UIButton! {
        didSet {
            editCompanyBtn.tag = 4
        }
    }
    @IBOutlet weak var companyTF: UITextField! {
        didSet {
            companyTF.tag = 44
        }
    }
    @IBOutlet weak var addressVu: UIView! {
        didSet {
//            addressVu.layer.backgroundColor = UIColor.white.cgColor
//            addressVu.layer.borderWidth = 0
//            addressVu.layer.shadowColor = UIColor.black.cgColor
//            addressVu.layer.shadowOffset = CGSize.zero
//            addressVu.layer.shadowRadius = 7.0
//            addressVu.layer.shadowOpacity = 0.5
//            addressVu.layer.masksToBounds = false
            
        }
    }
    
    @IBOutlet weak var addressTF: UITextField!
    @IBOutlet weak var profileImg: UIImageView!{
        didSet {
            profileImg.layer.cornerRadius = profileImg.frame.size.width / 2
            profileImg.clipsToBounds = true
//            let gradientLayer = CAGradientLayer()
//            gradientLayer.frame = profileImg.bounds
//            gradientLayer.frame.size.width = profileImg.frame.size.width + 50
//            gradientLayer.colors = [UIColor.white.withAlphaComponent(0.1).cgColor, UIColor.white.withAlphaComponent(0.5).cgColor]
//            self.profileImg.layer.addSublayer(gradientLayer)
        }
        
    }
    @IBOutlet weak var coverImg: UIImageView!{
        didSet {
         
    
        }
        
    }

    
    
    @IBOutlet weak var dobBtn: UIButton! {
        didSet {
            //dobBtn.layer.cornerRadius = 25
//            dobBtn.layer.backgroundColor = UIColor.white.cgColor
//            dobBtn.layer.borderWidth = 0
//            dobBtn.layer.shadowColor = UIColor.black.cgColor
//            dobBtn.layer.shadowOffset = CGSize.zero
//            dobBtn.layer.shadowRadius = 7.0
//            dobBtn.layer.shadowOpacity = 0.5
//            dobBtn.layer.masksToBounds = false
            
        }
    }
    
    
    
    @IBOutlet weak var outerVu: UIView!
    {
        didSet {
            self.layer.cornerRadius = 15
            self.layer.backgroundColor = UIColor.clear.cgColor
            self.layer.shadowColor = UIColor.gray.cgColor
            self.layer.shadowOffset = CGSize(width: 2.0, height: 0.0)
            self.layer.shadowOpacity = 0.5
            self.layer.shadowRadius = 5.0
            
            self.layer.masksToBounds = true
            

            
//            addSubview(outerVu)
//            outerVu.translatesAutoresizingMaskIntoConstraints = false
//
//            // pin the containerView to the edges to the view
//            outerVu.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
//            outerVu.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
//            outerVu.topAnchor.constraint(equalTo: topAnchor).isActive = true
//            outerVu.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        }
    }
    
    
}
