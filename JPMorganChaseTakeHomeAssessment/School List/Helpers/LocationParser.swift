//
//  LocationParser.swift
//  JPMorganChaseTakeHomeAssessment
//
//  Created by Yazan Halawa on 9/17/22.
//

import Foundation
import OSLog

/// Putting this logic in its own entity so that if any other API sends locations in this format we can reuse the parsing logic
struct LocationParser {
    
    /// Parses a location info string combined of an address and lat long info in the form <address> (<lat>, <long>)
    /// - Parameter locationInfo: the combined location info string
    /// - Returns: a tuple of the address, the latitude, the longitude
    static func parse(locationInfo: String) -> (String, Double, Double) {
        // We first split into address and lat/long pair
        let locationComponents = locationInfo.components(separatedBy: ["(", ")"])
        let locationAddress = locationComponents[0].trimmingCharacters(in: .whitespaces)
        // Next we split the latlong pair into lat and long
        let latLongPair = locationComponents[1].components(separatedBy: ",")
        // then we try to cast them to Double so they can be later on used in MapKit APIs
        if let latitude =  Double(latLongPair[0]), let longitude = Double(latLongPair[1].trimmingCharacters(in: .whitespaces)) {
            return (locationAddress, latitude, longitude)
        } else {
            Logger.businessLogic.warning("location info \(locationInfo) could not be parsed into valid lat/long")
            return (locationAddress, 0, 0)
        }
    }
}
