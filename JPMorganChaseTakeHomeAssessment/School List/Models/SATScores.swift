//
//  SATScores.swift
//  JPMorganChaseTakeHomeAssessment
//
//  Created by Yazan Halawa on 9/17/22.
//

import Foundation

struct SATScores: Decodable {
    let dbn: String
    let numOfTestTakers: Int
    let criticalReadingAvgScore: Int
    let mathAvgScore: Int
    let writingAvgScore: Int
    
    /// I chose to add coding keys here because I want the properties to have the swift-like naming standard
    /// and the json properties don't match that naming convention so I am mapping them here
    enum CodingKeys: String, CodingKey {
        case dbn
        case numOfTestTakers = "num_of_sat_test_takers"
        case criticalReadingAvgScore = "sat_critical_reading_avg_score"
        case mathAvgScore = "sat_math_avg_score"
        case writingAvgScore = "sat_writing_avg_score"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.dbn = try container.decode(String.self, forKey: .dbn)
        self.numOfTestTakers = Int(try container.decode(String.self,
                                                        forKey: .numOfTestTakers)) ?? 0
        self.criticalReadingAvgScore = Int(try container.decode(String.self,
                                                                forKey: .criticalReadingAvgScore)) ?? 0
        self.mathAvgScore = Int(try container.decode(String.self,
                                                     forKey: .mathAvgScore)) ?? 0
        self.writingAvgScore = Int(try container.decode(String.self,
                                                        forKey: .writingAvgScore)) ?? 0
    }
    
    init(dbn: String,
         numOfTestTakers: Int,
         criticalReadingAvgScore: Int,
         mathAvgScore: Int,
         writingAvgScore: Int) {
        self.dbn = dbn
        self.numOfTestTakers = numOfTestTakers
        self.criticalReadingAvgScore = criticalReadingAvgScore
        self.mathAvgScore = mathAvgScore
        self.writingAvgScore = writingAvgScore
    }
}
