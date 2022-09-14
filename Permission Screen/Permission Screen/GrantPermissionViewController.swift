//
//  ViewController.swift
//  Permission Screen
//
//  Created by Sejal Khanna on 24/09/21.
//

import UIKit
import Foundation
import CoreLocation
import AVFoundation



class GrantPermissionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var GrantPermissionButton: UIButton!
    @IBOutlet weak var GrantPermissionTableView: UITableView!
    var locationIndex = 0
    var sections =  [
        Section(TitleLabel: " Camera", TitleSubLabel: "We need this access for seamless Video\nKYC process",SerialNumberLabel:"1.",AskingPermission: false,PermissionsBool: 0,type: .camera ),
        Section(TitleLabel: "Location", TitleSubLabel: "We need this access to verify communication address during Video KYC process",SerialNumberLabel:"2.",AskingPermission: false,PermissionsBool: 0,type: .location),
        Section(TitleLabel: "Microphone", TitleSubLabel: "We need this access for seamless Video\nKYC process",SerialNumberLabel:"3.",AskingPermission: false,PermissionsBool: 0,type: .microphone),
    ]
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "GrantPermissionCell", bundle: nil)
        GrantPermissionTableView.delegate = self
        GrantPermissionTableView.dataSource = self
        GrantPermissionTableView.rowHeight = UITableView.automaticDimension
        GrantPermissionTableView.estimatedRowHeight = 300
        GrantPermissionButton.layer.cornerRadius = 10
        self.GrantPermissionTableView.register(nib, forCellReuseIdentifier: "GrantPermissionCell")
        checkAccess(AVMediaType: .video, index: 0)
        CheckLocationAccess(index: 1)
        checkAccess(AVMediaType: .audio, index: 2)
        sections = sections.sorted(by: {$0.PermissionsBool<$1.PermissionsBool})
        GrantPermissionTableView.reloadData()
        AskForAllPermissions()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
    
        if CheckIncompletePermissions(){
            GrantPermissionButton.isEnabled = true
        }else{
            GrantPermissionButton.isEnabled = false
            GrantPermissionButton.isHidden = true
            AskForAllPermissions()
        }
        
        
    }
    func CheckIncompletePermissions()->Bool{
        for i in sections{
            if i.PermissionsBool == 1{
                return false
            }
        }
        return true
    }

    

    func checkAccess(AVMediaType:AVMediaType, index: Int) {
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType)
        switch status {
        case .authorized:
            switch AVMediaType{
            case .video:
                sections[0].PermissionsBool = 1
            case .audio:
                sections[2].PermissionsBool = 1
            default:break
            }
        default:
            switch AVMediaType{
            case .video:
                sections[0].PermissionsBool = 0
            case .audio:
                sections[2].PermissionsBool = 0
            default:break
            }
        }
    }
    
    func CheckLocationAccess(index: Int){
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .authorizedAlways, .authorizedWhenInUse:
                self.sections[index].PermissionsBool = 1
            @unknown default:
                self.sections[index].PermissionsBool = 0
                break
            }
        } else {
            print("Location services are not enabled")
        }
    }
    func getLocationManger(locationManger: CLLocationManager) {
        let latitude: CLLocationDegrees = (locationManager.location?.coordinate.latitude)!
        let longitude: CLLocationDegrees = (locationManager.location?.coordinate.longitude)!
        let location = CLLocation(latitude: latitude, longitude: longitude) //changed!!!
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            if error != nil {
                return
            }else if let country = placemarks?.first?.country,
                     let city = placemarks?.first?.locality {
                print(country)
//                self.cityNameStr = city
            }
            else {
            }
        })
    }
    
    func GrantAccess(AVMediaType: AVMediaType, index:Int){
        let Status = AVCaptureDevice.authorizationStatus(for: AVMediaType)
        switch Status {
        case .denied,.restricted:
            switch AVMediaType{
            case .video:
                MoveToPermisssion(image: "name-graphic", title: "Camera", type: .camera)
            case .audio:
                MoveToPermisssion(image: "name-graphic", title: "Microphone", type: .microphone)
            default: break
            }
        case .notDetermined:
            sections[index].AskingPermission = true
            moveCellToTop(sourceIndexPath: IndexPath(row: index, section: 0))
            RequestAccess(avMediaType: AVMediaType, index: index)
        case .authorized:
            sections[index].PermissionsBool = 1
            break
        @unknown default:
            break
        }
    }
    
    func GrantLocationAccess(index:Int){
        if CLLocationManager.locationServicesEnabled(){
            switch CLLocationManager.authorizationStatus(){
            case .notDetermined:
                
                locationManager.delegate = self
                locationManager.requestAlwaysAuthorization()
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.startUpdatingLocation()
                locationManager.startMonitoringSignificantLocationChanges()
                moveCellToTop(sourceIndexPath: IndexPath(row: index, section: 0))
                locationIndex = index
            case .denied,.restricted:
                MoveToPermisssion(image: "name-graphic", title: "LOCATION", type: .location)
            case .authorizedAlways ,.authorizedWhenInUse:
                print("Location Permission is enabled")
            @unknown default:
                break
            }
        }
        
    }
    
    func RequestAccess(avMediaType: AVMediaType, index: Int){
        AVCaptureDevice.requestAccess(for: avMediaType) { success in
            if success {
                self.sections[index].PermissionsBool = 1
                DispatchQueue.main.async {
                    
                    self.GrantPermissionTableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
                }
            }
            self.AskForAllPermissions()
        }
    }
    
    func GrantAllPermission(access: Permissions, index:Int){
        switch access{
        case .camera:
            GrantAccess(AVMediaType: .video, index: index)
        case.location:
            GrantLocationAccess(index: index)
        case .microphone:
            GrantAccess(AVMediaType: .audio, index: index)
        }
    }
    
    //If disabled, move to neext screen and ask user to enable permission
    func MoveToPermisssion(image:String,title:String,type:Permissions){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let destinationVc  =  storyBoard.instantiateViewController(withIdentifier: "PermissionViewController")  as! PermissionViewController
            destinationVc.titleString = title
            self.navigationController?.pushViewController(destinationVc, animated: true)
        })
    }
    
    func AskForAllPermissions(){
        if sections[0].PermissionsBool == 0{
            GrantAllPermission(access: sections[0].type, index: 0)
        }else if sections[1].PermissionsBool == 0{
            GrantAllPermission(access: sections[1].type, index:1)
        }else if sections[2].PermissionsBool == 0{
            GrantAllPermission(access: sections[2].type, index: 2)
        }else{
            sections = sections.sorted(by: { $0.SerialNumberLabel < $1.SerialNumberLabel })
            DispatchQueue.main.async {
                self.GrantPermissionTableView.reloadData()
            }
            getLocationManger(locationManger: locationManager)        }
    }
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt sourceIndexPath: IndexPath) -> UITableViewCell {
        let GrantPermissionCell = tableView.dequeueReusableCell(withIdentifier: "GrantPermissionCell", for: sourceIndexPath) as! GrantPermissionCell
        GrantPermissionCell.TitleLabel.text = sections[sourceIndexPath.section].TitleLabel
        GrantPermissionCell.TitleSubLabel.text = sections[sourceIndexPath.section].TitleSubLabel
        GrantPermissionCell.SerialNumberLabel.text = sections[sourceIndexPath.section].SerialNumberLabel
        //Green tick will show accordingly
        if sections[sourceIndexPath.row].AskingPermission == false {
            GrantPermissionCell.SelectedButton.isHidden = false
        }else{
            GrantPermissionCell.SelectedButton.isHidden = true
        }
        return GrantPermissionCell
    }
    func tableView(_ tableView: UITableView, heightForRowAt sourceIndexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt sourceIndexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func moveCellToTop(sourceIndexPath: IndexPath) {
        DispatchQueue.main.async { [self] in
            let itemToMove = sections[sourceIndexPath.row]
            sections.remove(at: sourceIndexPath.row)
            sections.insert(itemToMove, at: 0)
            let destinationIndexPath = IndexPath(row: 0, section: 0)
            GrantPermissionTableView.moveRow(at: sourceIndexPath, to: destinationIndexPath )
            GrantPermissionTableView.reloadRows(at: [sourceIndexPath], with: .automatic)
        }
    }

enum Permissions{
    case camera
    case location
    case microphone
}
class Section{
    let TitleLabel: String
    var TitleSubLabel: String
    let SerialNumberLabel: String
    var SelectedButton = false
    var PermissionsBool: CFBit
    var AskingPermission: Bool
    var type : Permissions
    
    
    init(TitleLabel:String,TitleSubLabel: String,SerialNumberLabel: String,SelectedButton: Bool = false,AskingPermission: Bool,PermissionsBool: CFBit,type: Permissions) {
        self.TitleLabel = TitleLabel
        self.TitleSubLabel = TitleSubLabel
        self.SerialNumberLabel = SerialNumberLabel
        self.SelectedButton = SelectedButton
        self.AskingPermission = AskingPermission
        self.PermissionsBool = PermissionsBool
        self.type = type
    }
}
}
extension GrantPermissionViewController:CLLocationManagerDelegate{
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        CheckLocationAccess(index: locationIndex)
        AskForAllPermissions()
    }
}
