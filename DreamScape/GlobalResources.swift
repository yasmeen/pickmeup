//
//  GlobalResources.swift
//  MakeDrop
//
//  Created by mjhowell on 1/3/17.
//  Copyright © 2017 Morgan. All rights reserved.
//

import UIKit
import CoreLocation

//Some resources, such as location, are used throughout the app in every single base controller
//This particular class helps avoid memory cycles and over allocating threads which call the same resources
public class GlobalResources: NSObject, CLLocationManagerDelegate {
    
    public struct Location {
        static var locationManager = CLLocationManager()
        static var lat: String = String(0.0)
        static var long: String = String(0.0)
    }
    
    override init() {
        super.init()
        Location.locationManager.delegate = self
        Location.locationManager.distanceFilter = kCLDistanceFilterNone
        Location.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        Location.locationManager.startUpdatingLocation()
        Location.locationManager.requestWhenInUseAuthorization()
        Location.locationManager.requestAlwaysAuthorization()
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let mostRecentUpdate: CLLocation? = locations.last
        if let locationUpdate = mostRecentUpdate {
            Location.lat = String(locationUpdate.coordinate.latitude)
            Location.long = String(locationUpdate.coordinate.longitude)
        }
    }
}
