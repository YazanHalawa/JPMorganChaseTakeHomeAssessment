//
//  JPMorganChaseTakeHomeAssessmentTests.swift
//  JPMorganChaseTakeHomeAssessmentTests
//
//  Created by Yazan Halawa on 9/17/22.
//

import XCTest
import Combine
@testable import JPMorganChaseTakeHomeAssessment

final class JPMorganChaseTakeHomeAssessmentTests: XCTestCase {
    private var networkService: MockNetworkService!
    private var viewModel: SchoolListViewModel!
    private var cancellables = Set<AnyCancellable>()
    
    enum RandomError: Error {
        case mock
    }

    class MockNetworkService: MakesNetworkRequests {
        var errorToReturn: NetworkError = .networkIsNotReachable
        func request<T>(endpoint: JPMorganChaseTakeHomeAssessment.Endpoint) -> AnyPublisher<T, JPMorganChaseTakeHomeAssessment.NetworkError> where T : Decodable {
            return Fail(error: errorToReturn).eraseToAnyPublisher()
        }
    }

    override func setUpWithError() throws {
        networkService = MockNetworkService()
        viewModel = SchoolListViewModel(networkService: networkService)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLocationParserWithValidLocationInfo() throws {
        let location = "10th Street, Brooklyn, NY, 11224 (50.3221, -72.44442)"
        let (address, lat, long) = LocationParser.parse(locationInfo: location)
        assert(address == "10th Street, Brooklyn, NY, 11224")
        assert(lat == 50.3221)
        assert(long == -72.44442)
    }
    
    func testLocationParserWithInvalidLocationInfo() throws {
        let location = "10th Street, Brooklyn, NY, 11224 (50.32dd21, -72.44442)"
        let (address, lat, long) = LocationParser.parse(locationInfo: location)
        assert(address == "10th Street, Brooklyn, NY, 11224")
        assert(lat == 0)
        assert(long == 0)
    }
    
    func testSchoolListViewModelErrorStateWithNoNetwork() throws {
        let expectation = XCTestExpectation(description: "Since the default of our mock service is no network connection, we should see the error state reflecting that")
        // When we fetch schools with the current service mock we should update our error state
        viewModel.$errorState
            .dropFirst() // drop initial value of .none
            .sink { state in
                assert(state == ErrorState.needToCheckNetworkConnectivity)
                expectation.fulfill()
        }.store(in: &cancellables)
        
        viewModel.fetchSchools()
        wait(for: [expectation], timeout: 1)
    }
    
    func testSchoolListViewModelErrorStateWithGenericError() throws {
        networkService.errorToReturn = .invalidResponse
        let expectation = XCTestExpectation(description: "Since the default of our mock service is no network connection, we should see the error state reflecting that")
        // When we fetch schools with the current service mock we should update our error state
        viewModel.$errorState
            .dropFirst() // drop initial value of .none
            .sink { state in
                assert(state == ErrorState.general)
                expectation.fulfill()
        }.store(in: &cancellables)
        
        viewModel.fetchSchools()
        wait(for: [expectation], timeout: 1)
    }
    
    func testSchoolListViewModelErrorStateWithNeedToUpdateAppError() throws {
        networkService.errorToReturn = .decodingError(RandomError.mock)
        let expectation = XCTestExpectation(description: "Since the default of our mock service is no network connection, we should see the error state reflecting that")
        // When we fetch schools with the current service mock we should update our error state
        viewModel.$errorState
            .dropFirst() // drop initial value of .none
            .sink { state in
                assert(state == ErrorState.needToUpdateApp)
                expectation.fulfill()
        }.store(in: &cancellables)
        
        viewModel.fetchSchools()
        wait(for: [expectation], timeout: 1)
    }
}
