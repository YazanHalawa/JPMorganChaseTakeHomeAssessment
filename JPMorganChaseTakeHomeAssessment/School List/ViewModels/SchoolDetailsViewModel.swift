//
//  SchoolDetailViewModel.swift
//  JPMorganChaseTakeHomeAssessment
//
//  Created by Yazan Halawa on 9/17/22.
//

import Foundation
import Combine
import OSLog

class SchoolDetailsViewModel: ObservableObject {
    let school: School
    @Published var satScores: SATScores?
    @Published var errorState: ErrorState = .none {
        didSet {
            shouldShowErrorState = errorState != .none
        }
    }
    @Published var shouldShowErrorState = false
    @Published var isFetchingData: Bool = false
    
    private var networkService: MakesNetworkRequests
    private var cancellables = Set<AnyCancellable>()
    
    init(forSchool school: School, networkService: MakesNetworkRequests = NetworkManager.shared) {
        self.school = school
        self.networkService = networkService
    }
    
    func fetchSATScores() {
        isFetchingData = true
        let satScoresDataPublisher: AnyPublisher<[SATScores], NetworkError> =  self.networkService.request(endpoint: NYCOpenData.satScores)
        satScoresDataPublisher
            .first()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] res in
                defer { self?.isFetchingData = false }
                switch res {
                case .failure(let error):
                    switch error {
                    case .networkIsNotReachable:
                        self?.errorState = .needToCheckNetworkConnectivity
                    case .decodingError:
                        // I am making the assumption that the response changed on the server and the user needs to update the app
                        self?.errorState = .needToUpdateApp
                    default:
                        self?.errorState = .general
                    }
                case .finished:
                    self?.errorState = .none
                }
            } receiveValue: { [weak self] satScoresForAllSchools in
                guard let self = self else { return }
                let targetSchoolSATScores = satScoresForAllSchools.filter { $0.dbn == self.school.dbn }.first
                self.satScores = targetSchoolSATScores
            }
            .store(in: &cancellables)
    }
}
