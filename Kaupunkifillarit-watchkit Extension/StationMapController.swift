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

    static let DEFAULT_MAP_SPAN = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    @IBOutlet weak var bikeStandNameLabel: WKInterfaceLabel!
    @IBOutlet weak var numberOfBikesLabel: WKInterfaceLabel!
    @IBOutlet weak var distanceLabel: WKInterfaceLabel!
    @IBOutlet weak var stationMap: WKInterfaceMap!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        if let station = context as? Station {
            bikeStandNameLabel.setText(station.name)
            numberOfBikesLabel.setText(String(station.bikesAvailable))
            stationMap.removeAllAnnotations()
            
            let coords = CLLocationCoordinate2D(latitude: station.lat, longitude: station.lon)
            stationMap.addAnnotation(coords, with: .red)
            stationMap.setRegion(MKCoordinateRegion(center: coords, span: StationMapController.DEFAULT_MAP_SPAN))
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
