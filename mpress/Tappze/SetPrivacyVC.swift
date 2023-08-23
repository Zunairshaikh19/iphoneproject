//
//  SetPrivacyVC.swift
//  Tappze
//
//  Created by Apple on 13/07/2023.
//

import UIKit

class SetPrivacyVC: BaseClass {
    
    
    @IBOutlet weak var tableVu: UITableView!
    var profileSharingArr:[IsProfileSharedModel] = []

    var userDetails: User?
    //MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTableVu()
        userDetails = self.readUserData()
        print(userLinks)
        self.setupProfileSharingArr()
    }
    //MARK: Private Methods
    private func setupTableVu() {
        tableVu.delegate = self
        tableVu.dataSource = self
        tableVu.register(UINib(nibName: "ProfilePrivacyCell", bundle: nil), forCellReuseIdentifier: "ProfilePrivacyCell")
        tableVu.register(UINib(nibName: "LinkPrivacyCell", bundle: nil), forCellReuseIdentifier: "LinkPrivacyCell")
    }
    private func setupProfileSharingArr() {
        let infoShareable = userDetails?.infoShareable
        profileSharingArr.append(IsProfileSharedModel(title: "Profile picture sharing", isShared: (infoShareable?.profileShared ?? true), childName: "profileShared"))
        profileSharingArr.append(IsProfileSharedModel(title: "Name sharing", isShared: (infoShareable?.nameShared ?? true), childName: "nameShared"))
        profileSharingArr.append(IsProfileSharedModel(title: "Bio sharing", isShared: (infoShareable?.bioShared ?? true), childName: "bioShared"))
        profileSharingArr.append(IsProfileSharedModel(title: "Email sharing", isShared: (infoShareable?.emailShared ?? true), childName: "emailShared"))

        profileSharingArr.append(IsProfileSharedModel(title: "Address sharing", isShared: (infoShareable?.addressShared ?? true), childName: "addressShared"))
        profileSharingArr.append(IsProfileSharedModel(title: "Date of birth sharing", isShared: (infoShareable?.dobShared ?? true), childName: "dobShared"))
        profileSharingArr.append(IsProfileSharedModel(title: "Phone sharing", isShared: (infoShareable?.phoneShared ?? true), childName: "phoneShared"))
        profileSharingArr.append(IsProfileSharedModel(title: "Company sharing", isShared: (infoShareable?.companyShared ?? true), childName: "companyShared"))
        profileSharingArr.append(IsProfileSharedModel(title: "All social links sharing", isShared: (infoShareable?.allShared ?? true), childName: "allShared"))

    }
    //MARK: Button Actions
    @IBAction func backBtnAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func profileSharedSwitchAction(_ sender: UISwitch) {
        let infoChild = profileSharingArr[sender.tag].childName
        let val = Constants.refs.databaseUser.child(getUserId())
        val.child("infoShareable").child(infoChild).setValue(sender.isOn)
    }
    @IBAction func linkSharedSwitchAction(_ sender: UISwitch) {
        userLinks?[sender.tag].isShared = sender.isOn
        
        APIManager.updateUserLinks { status in
            print(status)
        }
    }
}

//MARK: Tableview Methods
extension SetPrivacyVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Personal settings"
        } else {
            return "Social links settings"
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 9
        } else {
            return (userLinks?.count ?? 0)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfilePrivacyCell", for: indexPath) as! ProfilePrivacyCell
            cell.titleLbl.text = "\(indexPath.row + 1): " + profileSharingArr[indexPath.row].title
            cell.isSharedSwitch.isOn = profileSharingArr[indexPath.row].isShared
            cell.isSharedSwitch.tag = indexPath.row
            cell.isSharedSwitch.addTarget(self, action: #selector(profileSharedSwitchAction), for: .valueChanged)
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LinkPrivacyCell", for: indexPath) as! LinkPrivacyCell
            cell.titleLbl.text = userLinks?[indexPath.row].name
            cell.isSharedSwitch.isOn = userLinks?[indexPath.row].isShared ?? true
            cell.isSharedSwitch.tag = indexPath.row
            cell.isSharedSwitch.addTarget(self, action: #selector(linkSharedSwitchAction), for: .valueChanged)
            
            let link = userLinks?[indexPath.row]
            cell.imgVu.image = UIImage(named: link?.name?.lowercased() ?? "")
            if let link = link, (link.image ?? "") != "", (link.value ?? "") != "", (link.linkID == 4 || link.linkID == 22 || link.linkID == 23 || link.linkID == 24 || link.linkID == 25)  {
                
                cell.imgVu.layer.cornerRadius = 10
                cell.imgVu.layer.masksToBounds = true
                cell.imgVu.contentMode = .scaleToFill
                if link.linkID == 4, let img = UIImage(contentsOfFile: self.customLogoImgUrl.path)  {
                    cell.imgVu.image = img
                }
                if link.linkID == 22, let img = UIImage(contentsOfFile: self.customLogo2ImgUrl.path)  {
                    cell.imgVu.image = img
                }
                if link.linkID == 23, let img = UIImage(contentsOfFile: self.customLogo3ImgUrl.path)  {
                    cell.imgVu.image = img
                }
                if link.linkID == 24, let img = UIImage(contentsOfFile: self.customLogo4ImgUrl.path)  {
                    cell.imgVu.image = img
                }
                if link.linkID == 25, let img = UIImage(contentsOfFile: self.customLogo5ImgUrl.path)  {
                    cell.imgVu.image = img
                }
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 60
        } else {
            return 70
        }
    }
}
//extension SetPrivacyVC {
//    func getPrivacy
//}

struct IsProfileSharedModel {
    let title: String
    let isShared: Bool
    let childName: String
}


