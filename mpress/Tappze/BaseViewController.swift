

import UIKit
import AnimatedField

class BaseViewController: UIViewController {
    
    // api code
    let def = UserDefaults.standard
    var loadingView : UIView!
    var del : AppDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // to store the data in AppDelgate
        del = (UIApplication.shared.delegate as? AppDelegate)
        
        //SVProgressHUD code Circle
        loadingView = UIView(frame: view.frame)
        loadingView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view.addSubview(loadingView)
        loadingView.isHidden = true
        
    }
    
    // MBProgressHUD Obj-c file func
    // showLoading
    func showLoading()
    {
        self.loadingView.isHidden = false
        let loading = MBProgressHUD.showAdded(to: view, animated: true)
        loading.mode = MBProgressHUDMode.indeterminate
        loading.label.text = "Loading ..."
    }
    
    // hideLoading
    func hideLoading()
    {
        self.loadingView.isHidden = true
        MBProgressHUD.hide(for: self.view, animated: true)
    }
    
    // showAlert
    func showAlert(_ title: String, _ message: String, actions: [UIAlertAction]?, completion: (() -> Void)? = nil)
    {
        // alert message diaoulge
        let alertController = UIAlertController(title: title, message:
                                                    message, preferredStyle: .alert)
        
        if actions == nil{
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                print("Ok")
            }))
        } else {
            actions!.forEach({ (act) in
                alertController.addAction(act)
            })
        }
        self.present(alertController, animated: true, completion: completion)
    }
    
    //:-
    // textField animated code
    func animated_textField(tfName: AnimatedField)
    {
        tfName.format.lineColor = UIColor.lightGray
        tfName.format.titleColor = UIColor.lightGray
        tfName.format.textColor = UIColor.clrBlack
        tfName.format.highlightColor = UIColor.clrBlack
        // tint color
        tfName.tintColor = UIColor.lightGray
        // counter is hide
        tfName.format.counterEnabled = false
        // for external font used
        tfName.format.textFont = UIFont(name: "Poppins-Regular", size: 15)!
        tfName.format.titleFont = UIFont(name: "Poppins-Regular", size: 16)!
    }
    
}
