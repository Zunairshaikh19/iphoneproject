//
//  AppleMapVC.swift
//  Tappze
//
//  Created by Apple on 21/06/2023.
//

import UIKit
import MapKit
import CoreLocation

class AppleMapVC: BaseClass {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var locationLbl: UILabel! {didSet{
        self.addShadowToView(view: locationLbl)
    }}
    @IBOutlet weak var switchMapBtn: UIButton!

    var matchingItems:[MKMapItem] = []
    
    var addressDelegate: MapAddress?
    //MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getLocation()
        self.locationManager.delegate = self
        self.initialSetup()
    }
    //MARK: Private Methods
    private func initialSetup() {
        mapView.delegate = self
        searchTF.tag = 10
        searchTF.setLeftPaddingPoints(10.0)
        self.addShadowToView(view: searchTF)
        self.addShadowToView(view: switchMapBtn)
        searchTF.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = true
    }
    private func getAddressFromPlacemark(pm: CLPlacemark?) -> String{
        var addressString : String = ""
        if pm?.subLocality != nil {
            addressString = addressString + (pm?.subLocality)! + ", "
        }
        if pm?.thoroughfare != nil {
            addressString = addressString + (pm?.thoroughfare)! + ", "
        }
        if pm?.locality != nil {
            addressString = addressString + (pm?.locality)! + ", "
        }
        if pm?.country != nil {
            addressString = addressString + (pm?.country)! + ", "
        }
        if pm?.postalCode != nil {
            addressString = addressString + (pm?.postalCode)! + " "
        }
        print(addressString)
        return addressString
    }
    private func moveToAddLinksVC() {
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: AddLinksVC.self) {
                self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
    }
    //MARK: Button Actions
    @IBAction func switchMapBtnAction(_ sender: Any) {
        let bottomSheet = UIAlertController(title: "Directions", message: "Which app do you want to use?", preferredStyle: .actionSheet)

        bottomSheet.addAction(UIAlertAction(title: "Use Apple Maps", style: .default, handler: { (action: UIAlertAction!) in
            
          }))
        bottomSheet.addAction(UIAlertAction(title: "Use Google Maps", style: .default, handler: { (action: UIAlertAction!) in
            self.navigationController?.popViewController(animated: false)
          }))

        bottomSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
          }))
        present(bottomSheet, animated: true, completion: nil)
    }
    @IBAction func saveBtnAction(_ sender: UIButton) {
        if let address = locationLbl.text, address.removeWhitespace() != "" {
            addressDelegate?.addressSelected(address: address)
            self.moveToAddLinksVC()
        } else {
            self.showAlert(title: AlertConstants.Alert, message: "No address selected")
        }
    }
    @IBAction func backBtnAction(_ sender: UIButton) {
        self.moveToAddLinksVC()
    }
}

//MARK: Location updated
extension AppleMapVC {
    override func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.last {
            currentLocation = location
            print("Location data received",location.coordinate)
            //locationManager.stopUpdatingLocation()
        }
        let userLocation :CLLocation = locations.last!
        let currentUserLat = userLocation.coordinate.latitude
        let currentUserLong = userLocation.coordinate.longitude
        print("user latitude = \(currentUserLat)")
        print("user longitude = \(currentUserLong)")
        
        self.location = "\(userLocation.coordinate.latitude)" + ",\(userLocation.coordinate.longitude)"
        
        let viewRegion = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters:800, longitudinalMeters: 800)
        self.mapView.setRegion(viewRegion, animated: true)
        
        currentLocation?.lookUpPlaceMark { (pm) in
            self.locationLbl.text = self.getAddressFromPlacemark(pm: pm)
        }
        //self.getAddressesFromText(searchText: "iqbal")
    }
}
//MARK: Mapview Delegates
extension AppleMapVC: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let tempLocation = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        tempLocation.lookUpPlaceMark { (pm) in
            self.locationLbl.text = self.getAddressFromPlacemark(pm: pm)
        }
    }
}
//MARK: Search Locations by text
extension AppleMapVC {
    func getAddressesFromText(searchText:String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = MKCoordinateRegion(center: currentLocation!.coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response else {
                return
            }
            print("----------Matching Items---------")
            self.matchingItems = response.mapItems
            print(self.matchingItems)
            print("----------Addresses------------")

            for addressItem in self.matchingItems {
                let address = self.getAddressFromPlacemark(pm:addressItem.placemark)
                self.tableView.reloadData()
                print(address)
            }
        }
    }
}
//MARK: Tableview for search options
extension AppleMapVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        
        cell.textLabel?.text = self.getAddressFromPlacemark(pm:matchingItems[indexPath.row].placemark)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let matchingLocation = matchingItems[indexPath.row].placemark.location {
            
            self.mapView.setCenter(matchingLocation.coordinate, animated: true)
        }
        self.locationLbl.text = self.getAddressFromPlacemark(pm:matchingItems[indexPath.row].placemark)
        self.tableView.isHidden = true
    }
}
//MARK: Textfield Delegates
extension AppleMapVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard textField.tag == 10 else {
            return true
        }
        
        if let text = textField.text, let textRange = Range(range, in: text) {
            let searchText = text.replacingCharacters(in: textRange, with: string)
            if searchText == "" {
                self.tableView.isHidden = true
            } else {
                //tableDataSource.sourceTextHasChanged(searchText)
                self.getAddressesFromText(searchText: searchText)
                self.tableView.isHidden = false
                self.tableView.reloadData()
            }
        } else {
            self.tableView.isHidden = true
        }
        return true
    }
}

//MARK: Location Placemark
extension CLLocation {
    func lookUpPlaceMark(_ handler: @escaping (CLPlacemark?) -> Void) {
        let geocoder = CLGeocoder()
        // Look up the location and pass it to the completion handler
        geocoder.reverseGeocodeLocation(self) { (placemarks, error) in
            if error == nil {
                let firstLocation = placemarks?[0]
                print(firstLocation as Any)
                handler(firstLocation)
            }
            else {
                handler(nil)
            }
        }
    }
}

