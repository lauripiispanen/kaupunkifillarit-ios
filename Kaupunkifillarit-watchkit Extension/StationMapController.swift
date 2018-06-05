//
//  StationMapController.swift
//  Kaupunkifillarit-watchkit Extension
//
//  Created by Lauri Piispanen on 04/06/2018.
//  Copyright © 2018 Lauri Piispanen. All rights reserved.
//

import Foundation
import WatchKit

class StationMapController: WKInterfaceController {

    static let DEFAULT_MAP_SPAN = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
    @IBOutlet weak var bikeStandNameLabel: WKInterfaceLabel!
    @IBOutlet weak var numberOfBikesLabel: WKInterfaceLabel!
    @IBOutlet weak var distanceLabel: WKInterfaceLabel!
    @IBOutlet weak var stationMap: WKInterfaceMap!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        if let station = context as? StationMapContext {

            bikeStandNameLabel.setText(station.name)
            numberOfBikesLabel.setText(String(station.bikesAvailable))
            distanceLabel.setText(String(station.distanceMeters) + "m")
            stationMap.removeAllAnnotations()

            stationMap.addAnnotation(station.location, with: .red)
            stationMap.setRegion(MKCoordinateRegion(center: station.location, span: StationMapController.DEFAULT_MAP_SPAN))

            self.setTitle("Kaupunkifillarit.fi")
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
}

struct StationMapContext {
    var name: String
    var bikesAvailable: Int
    var location: CLLocationCoordinate2D
    var distanceMeters: Int

    init(_ station: Station, distance: Int) {
        self.name = station.name
        self.bikesAvailable = station.bikesAvailable
        self.location = CLLocationCoordinate2D(latitude: station.lat, longitude: station.lon)
        self.distanceMeters = distance
    }
}
