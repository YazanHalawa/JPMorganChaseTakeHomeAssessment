//
//  SchoolListView.swift
//  JPMorganChaseTakeHomeAssessment
//
//  Created by Yazan Halawa on 9/17/22.
//

import SwiftUI

struct SchoolListView: View {
    @ObservedObject private var viewModel: SchoolListViewModel
    
    init(viewModel: SchoolListViewModel = SchoolListViewModel()) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isFetchingData  {
                    ProgressView()
                } else {
                    List(viewModel.schools) { school in
                        NavigationLink("\(school.name)") {
                            SchoolDetailsView(viewModel: SchoolDetailsViewModel(forSchool: school))
                        }
                    }
                }
            }
            .navigationTitle("NYC Schools")
        }
        .onAppear {
            viewModel.fetchSchools()
        }
        .alert("Error", isPresented: $viewModel.shouldShowErrorState, actions: {
            Button("Retry") {
                viewModel.fetchSchools()
            }
        }, message: {
            switch viewModel.errorState {
            case .needToCheckNetworkConnectivity:
                Text("Check your Network Connection")
            case .needToUpdateApp:
                Text("Go to the app store and update our app")
            case .general:
                Text("Something went wrong. Try again later")
            case .none:
                // I can't add a break here so instead I add an empty text view to fix the error: Closure containing control flow statement cannot be used with result builder 'ViewBuilder'
                Text("")
            }
        })
    }
}

struct SchoolListView_Previews: PreviewProvider {
    static var viewModel: SchoolListViewModel = {
        let viewModel = SchoolListViewModel()
        viewModel.schools = [
            School(dbn: "", name: "School 1", overviewParagraph: "", location: "", latitude: 0, longitude: 0, phoneNumber: "")
        ]
        return viewModel
    }()
    static var previews: some View {
        SchoolListView(viewModel: viewModel)
    }
}
