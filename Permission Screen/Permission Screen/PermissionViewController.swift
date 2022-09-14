//
//  PermissionViewController.swift
//  PermissionViewController
//
//  Created by Apple on 07/10/21.
//

import Foundation
import UIKit
import CoreLocation
import AVFoundation
class PermissionViewController: UIViewController, CLLocationManagerDelegate{
    
    @IBOutlet weak var CaricatureImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var enableLabel: UILabel!
    
    
    var titleString = ""
    var image = ""
    var access:Permissions = .camera
    let locationManager = CLLocationManager()
    override func viewDidLoad() {
        titleLabel.text = titleString
        CaricatureImage.image = UIImage(named: image)
        NotificationCenter.default.addObserver(self, selector: #selector(CheckPermission), name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    @objc func CheckPermission(){
        switch access{
        case .camera:
            checkAccess(AVMediaType: AVMediaType.video, access: .camera)
        case .microphone:
            checkAccess(AVMediaType: AVMediaType.audio, access: .microphone)
        case .location:
            CheckLocationAccess()
        }
    }
    @IBAction func enableButtonPressed(_ sender: Any) {
        if let url = URL(string: "\(UIApplication.openSettingsURLString)") {
            UIApplication.shared.open(url, options: [:], completionHandler: { _ in
                
            })
        }
    }

    func CheckLocationAccess(){
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined:

                locationManager.delegate = self
                locationManager.requestAlwaysAuthorization()
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.startUpdatingLocation()
                locationManager.startMonitoringSignificantLocationChanges()
            case .denied,.restricted:break
            case .authorizedAlways, .authorizedWhenInUse:
                DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                }

                print("Access")
            @unknown default:
                break
            }
        } else {
            print("Location services are not enabled")
        }
    }


    func checkAccess(AVMediaType:AVMediaType,access:Permissions){
        let Status = AVCaptureDevice.authorizationStatus(for:AVMediaType)

        switch Status {
        case .denied,.restricted:break

        case .authorized:
            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            }
            break
            // Has access
        @unknown default: break
            // Has access
        }
    }

    enum Permissions{
        case camera
        case microphone
        case location
    }
}


