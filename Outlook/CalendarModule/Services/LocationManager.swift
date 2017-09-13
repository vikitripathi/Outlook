//
//  LocationManager.swift
//  Outlook
//
//  Created by abhishek dutt on 12/09/17.
//  Copyright © 2017 abhishek dutt. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationManagerDelegate: class {
    func fetchedUserLocation(_ userLocation: Location)
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    var locationManager = CLLocationManager()
    var userLocation: Location? = nil
    
    weak var delegate: LocationManagerDelegate?
    
    private override init() { }

    static let sharedManager : LocationManager = {
        let instance = LocationManager()
        instance.configure()
        return instance
    }()
    
    func configure() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.distanceFilter = 1000  //in metre
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - Core Location
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil // TODO: to check for distance bw two location update then update model
        
        let currentLocation = locations.last!  //recent is at end
        let lat = currentLocation.coordinate.latitude.locationString
        let long = currentLocation.coordinate.longitude.locationString
        userLocation = Location(latitude: lat, longitude: long)
        
        guard let location = userLocation else { return  }
        delegate?.fetchedUserLocation(location)
    }
}
