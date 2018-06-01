//
//  InterfaceController.swift
//  Kaupunkifillarit-watchkit Extension
//
//  Created by Lauri Piispanen on 31/05/2018.
//  Copyright © 2018 Lauri Piispanen. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController, FillariDataSourceDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var stationsTable: WKInterfaceTable!
    var dataSource: FillariDataSource = FillariDataSource()
    var locationManager: CLLocationManager?
    var location: CLLocation?
    var stations: [Station] = []
    
    
    override init() {
        super.init()
        if (self.locationManager == nil) {
            self.locationManager = CLLocationManager()
            self.locationManager?.delegate = self
            self.locationManager?.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            self.locationManager?.activityType = .otherNavigation
            self.locationManager?.distanceFilter = 5
        }
        dataSource.delegate = self
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        /*
        bikeStandNameLabel.setText("Päivitetään...")
        numberOfBikesLabel.setText("--")
        distanceLabel.setText("")
        */
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        let authStatus = CLLocationManager.authorizationStatus()
        if (authStatus == .authorizedWhenInUse ||
            authStatus == .authorizedAlways) {
            self.locationManager?.startUpdatingLocation()
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
    
    func redrawStationData() {
        var sortedStations = self.stations
        if let loc = self.location {
            sortedStations = sortedStations.sorted(by: { s1, s2 in
                return loc.distance(from: stationToLoc(s1)) < loc.distance(from: stationToLoc(s2))
            })
        }
        sortedStations = Array(sortedStations.prefix(20))
        self.stationsTable.setNumberOfRows(sortedStations.count, withRowType: "StationRowType")

        (0 ..< self.stationsTable.numberOfRows).forEach { rowNum in
            if let row = stationsTable.rowController(at: rowNum) as? StationRowType {
                if rowNum < sortedStations.count {
                    let station = sortedStations[rowNum]

                    row.bikeStandNameLabel.setText(station.name)
                    row.numberOfBikesLabel.setText(String(station.bikesAvailable))
                    row.numberOfBikesLabel.setTextColor(
                        station.bikesAvailable == 0
                            ? UIColor.black
                            : Colors.BRANDYELLOW
                    )
                    if let loc = self.location {
                        let dist = Int(loc.distance(from: stationToLoc(station)))
                        row.distanceLabel.setText(String(dist) + "m")
                    } else {
                        row.distanceLabel.setText("")
                    }
                }
            }
        }
    }
    
    func updatedStationData(_ stations: [Station]) {
        self.stations = stations
        redrawStationData()
    }
    
    func updateStarting() {
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.location = locations.last
        redrawStationData()
    }

}

class StationRowType: NSObject {
    @IBOutlet weak var bikeStandNameLabel: WKInterfaceLabel!
    @IBOutlet weak var numberOfBikesLabel: WKInterfaceLabel!
    @IBOutlet weak var distanceLabel: WKInterfaceLabel!

}


fileprivate func stationToLoc(_ s: Station) -> CLLocation {
    return CLLocation(latitude: s.lat, longitude: s.lon)
}
