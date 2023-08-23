//
//  MapVC.swift
//  Tappze
//
//  Created by Apple on 19/06/2023.
//

import UIKit
import GoogleMaps
import GoogleMapsUtils
import GooglePlaces

protocol MapAddress {
    func addressSelected(address:String)
}

class GoogleMapVC: BaseClass {
    @IBOutlet weak var locationPinImgeVu: UIImageView!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var locationLbl: UILabel! {didSet{
        self.addShadowToView(view: locationLbl)
    }}
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var switchMapBtn: UIButton!
    var searchController: UISearchController?
    var resultView: UITextView?
    private var tableDataSource: GMSAutocompleteTableDataSource!
    var currentAddress: GMSAddress?

    
    var appleMapVC: AppleMapVC?
    var addressDelegate: MapAddress?
    //MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getLocation()
        self.locationManager.delegate = self

        self.showMapVu()
        
        searchTF.tag = 10
        searchTF.setLeftPaddingPoints(10.0)
        self.addShadowToView(view: searchTF)
        self.addShadowToView(view: switchMapBtn)
        searchTF.delegate = self
        
        tableDataSource = GMSAutocompleteTableDataSource()
        tableDataSource.delegate = self
        tableView.delegate = tableDataSource
        tableView.dataSource = tableDataSource
        tableView.isHidden = true
    }
    
    func showMapVu() {
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        
        let fancy = GMSCameraPosition.camera(
            withLatitude: Double(currentLocation?.coordinate.latitude ?? 31.578855) ,
            longitude: Double(currentLocation?.coordinate.longitude ?? 74.381094) ,
            zoom: 13)
        
        mapView.camera = fancy
    }
    
    //MARK: Button Actions
    @IBAction func switchMapBtnAction(_ sender: Any) {
        let bottomSheet = UIAlertController(title: "Directions", message: "Which app do you want to use?", preferredStyle: .actionSheet)

        bottomSheet.addAction(UIAlertAction(title: "Use Apple Maps", style: .default, handler: { (action: UIAlertAction!) in
            self.navigationController?.pushViewController(self.appleMapVC!, animated: false)
          }))
        bottomSheet.addAction(UIAlertAction(title: "Use Google Maps", style: .default, handler: { (action: UIAlertAction!) in
          }))

        bottomSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
          }))
        present(bottomSheet, animated: true, completion: nil)
    }
    @IBAction func saveBtnAction(_ sender: UIButton) {
        if let address = locationLbl.text, address.removeWhitespace() != "" {
            addressDelegate?.addressSelected(address: address)
            self.navigationController?.popViewController(animated: true)
        } else {
            self.showAlert(title: AlertConstants.Alert, message: "No address selected")
        }
    }
    @IBAction func backBtnAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    //MARK: Location updated
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
        
        print(self.location)
        
        let camera = GMSCameraPosition.camera(withLatitude: (currentLocation?.coordinate.latitude)! , longitude: (currentLocation?.coordinate.longitude)!, zoom: 13)
        self.mapView?.animate(to: camera)
    }
    
    //MARK: Get Address
    func reverseGeocode(coordinate: CLLocationCoordinate2D) {
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            guard
                let address = response?.firstResult(),
                let lines = address.lines
            else {
                return
            }
            self.locationLbl.text = lines.joined(separator: "\n")
            UIView.animate(withDuration: 0.25) {
                self.view.layoutIfNeeded()
            }
        }
    }
}

//MARK: Map View
extension GoogleMapVC: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        reverseGeocode(coordinate: position.target)
    }
    
    func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
        print("end dragging")
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        print("will move")
    }
//    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
//    }
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        print("Did tap a normal marker")
        return false
    }
    
    func searchAndShowMarkerDetail(marker: GMSMarker) {
        
    }
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        print(marker.title as Any)
    }
}


//MARK: Textfield Delegates
extension GoogleMapVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard textField.tag == 10 else {
            return true
        }
        
        if let text = textField.text, let textRange = Range(range, in: text) {
            let searchText = text.replacingCharacters(in: textRange, with: string)
            if searchText == "" {
                tableView.isHidden = true
            } else {
                tableDataSource.sourceTextHasChanged(searchText)
                tableView.isHidden = false
            }
        } else {
            tableView.isHidden = true
        }
        return true
    }
}

//MARK: Search address with tableview
extension GoogleMapVC: GMSAutocompleteTableDataSourceDelegate {
    func didUpdateAutocompletePredictions(for tableDataSource: GMSAutocompleteTableDataSource) {
        // Turn the network activity indicator off.
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        // Reload table data.
        tableView.reloadData()
    }
    
    func didRequestAutocompletePredictions(for tableDataSource: GMSAutocompleteTableDataSource) {
        // Turn the network activity indicator on.
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        // Reload table data.
        tableView.reloadData()
    }
    
    func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didAutocompleteWith place: GMSPlace) {
        // Do something with the selected place.
        print("Place name: \(place.name ?? "")")
        print("Place address: \(place.formattedAddress ?? "")")
        print("Place attributions: \(String(describing: place.attributions))")
        
        let fancy = GMSCameraPosition.camera(
            withLatitude: Double(place.coordinate.latitude) ,
            longitude: Double(place.coordinate.longitude) ,
            zoom: 13)
        mapView.camera = fancy
    }
    
    func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didFailAutocompleteWithError error: Error) {
        // Handle the error.
        print("Error: \(error.localizedDescription)")
    }
    
    func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didSelect prediction: GMSAutocompletePrediction) -> Bool {
        tableView.isHidden = true
        searchTF.text = ""
        searchTF.resignFirstResponder()
        return true
    }
}


