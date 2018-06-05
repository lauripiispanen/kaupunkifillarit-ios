//
//  LoadingInterfaceController.swift
//  Kaupunkifillarit-watchkit Extension
//
//  Created by Lauri Piispanen on 05/06/2018.
//  Copyright © 2018 Lauri Piispanen. All rights reserved.
//

import WatchKit

class LoadingInterfaceController: WKInterfaceController, FillariDataSourceDelegate, CLLocationManagerDelegate {
    
    var dataSource: FillariDataSource = FillariDataSource()
    var locationManager: CLLocationManager?
    var location: CLLocation?
    var stations: [Station] = []
    
    override init() {
        super.init()
        if (self.locationManager == nil) {
            self.locationManager = CLLocationManager()
            self.locationManager?.delegate = self
            self.locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.locationManager?.activityType = .otherNavigation
            self.locationManager?.distanceFilter = 10
        }
        self.dataSource.delegate = self
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        let authStatus = CLLocationManager.authorizationStatus()
        if (authStatus == .authorizedWhenInUse ||
            authStatus == .authorizedAlways) {
            self.locationManager?.requestLocation()
        } else {
            self.locationManager?.requestWhenInUseAuthorization()
        }

        dataSource.startRefresh()
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        self.locationManager?.stopUpdatingLocation()
        dataSource.stopRefresh()
        super.didDeactivate()
    }
    
    func updatedStationData(_ stations: [Station]) {
        self.stations = stations
        showStationSelectorIfNeeded()
    }
    
    func showStationSelectorIfNeeded() {
        if let loc = self.location, self.stations.count > 0 {
            let ctx = StationSelectorContext(location: loc, stations: stations)
            WKInterfaceController.reloadRootControllers(withNamesAndContexts: [
                (name: "stationList", context: ctx as AnyObject)
            ])
        }
    }
    
    func updateStarting() {
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.location = locations.last
        showStationSelectorIfNeeded()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Couldn't get location", error)
    }
    
}
