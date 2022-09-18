//
//  SchoolListViewModel.swift
//  JPMorganChaseTakeHomeAssessment
//
//  Created by Yazan Halawa on 9/17/22.
//

import Foundation
import Combine
import OSLog

enum ErrorState: Equatable {
    case general, needToUpdateApp, needToCheckNetworkConnectivity, none
}
class SchoolListViewModel: ObservableObject {
    @Published var schools: [School] = []
    @Published var errorState: ErrorState = .none {
        didSet {
            shouldShowErrorState = errorState != .none
        }
    }
    @Published var shouldShowErrorState = false
    @Published var isFetchingData: Bool = false
    
    private var networkService: MakesNetworkRequests
    private var cancellables = Set<AnyCancellable>()
    
    init(networkService: MakesNetworkRequests = NetworkManager.shared) {
        self.networkService = networkService
    }
    
    func fetchSchools() {
        isFetchingData = true
        let schoolsDataPublisher: AnyPublisher<[School], NetworkError> =  self.networkService.request(endpoint: NYCOpenData.schools)
        schoolsDataPublisher
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
            } receiveValue: { [weak self] schools in
                self?.schools = schools
            }
            .store(in: &cancellables)
    }
}
