//
//  SchoolNetworkResponse.swift
//  JPMorganChaseTakeHomeAssessment
//
//  Created by Yazan Halawa on 9/17/22.
//

import Foundation
import OSLog

// I chose the following info to parse from the API
// I am imagining this app being used by parents looking for a school for their kid
// Most parents would prefer to have a call with the school to discuss at length, so
// we just want most basic details to show for the parent to know if this is a potential school
// This info would be the name, maybe an overview, the location to see if it's in their district, and final grades offered. I know this assumes an idealistic scenario where the
// school is filled up and operating fully, but I am assuming that for now
// Then a contact phone number for the school for the parent to discuss more details
struct School: Decodable {
    let dbn: String
    let name: String
    let overviewParagraph: String
    let location: String
    let latitude: Double
    let longitude: Double
    let phoneNumber: String
    
    /// I chose to add coding keys here because I want the properties to have the swift-like naming standard
    /// and the json properties don't match that naming convention so I am mapping them here
    enum CodingKeys: String, CodingKey {
        case dbn
        case name = "school_name"
        case overviewParagraph = "overview_paragraph"
        case location
        case phoneNumber = "phone_number"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.dbn = try container.decode(String.self, forKey: .dbn)
        self.name = try container.decode(String.self, forKey: .name)
        self.overviewParagraph = try container.decode(String.self, forKey: .overviewParagraph)
        
        // Locations are in the format 10th Street, Brooklyn, NY, 11224 (50.3221, -72.44442)
        let location = try container.decode(String.self, forKey: .location)
        (self.location, self.latitude, self.longitude) = LocationParser.parse(locationInfo: location)
       
        self.phoneNumber = try container.decode(String.self, forKey: .phoneNumber)
    }
    
    init(dbn: String,
         name: String,
         overviewParagraph: String,
         location: String,
         latitude: Double,
         longitude: Double,
         phoneNumber: String) {
        self.dbn = dbn
        self.name = name
        self.overviewParagraph = overviewParagraph
        self.location = location
        self.latitude = latitude
        self.longitude = longitude
        self.phoneNumber = phoneNumber
    }
}

// MARK: - Identifiable Protocol Conformance
// I am conforming the response model to identifiable to use it with a list view in SwiftUI. For SwiftUI Identity is key in being able to tell view hierarchy changes
extension School: Identifiable {
    var id: String {
        return dbn
    }
}
