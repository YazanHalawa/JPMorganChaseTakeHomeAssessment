//
//  SchoolListView.swift
//  JPMorganChaseTakeHomeAssessment
//
//  Created by Yazan Halawa on 9/17/22.
//

import SwiftUI
import MapKit

struct SchoolDetailsView: View {
    private enum Constants {
        static let SpanFromLatAndLongToShow = 0.01
    }
    @ObservedObject private var viewModel: SchoolDetailsViewModel
    @State private var region: MKCoordinateRegion

    init(viewModel: SchoolDetailsViewModel) {
        self.viewModel = viewModel
        region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: viewModel.school.latitude, longitude: viewModel.school.longitude), span: MKCoordinateSpan(latitudeDelta: Constants.SpanFromLatAndLongToShow, longitudeDelta: Constants.SpanFromLatAndLongToShow))
    }
    
    var body: some View {
        ZStack {
            if viewModel.isFetchingData {
                ProgressView()
            } else {
                // Since the paragraph could get large we want the view to scroll to fit the content
                ScrollView {
                    Map(coordinateRegion: $region)
                        .frame(width: 300, height: 200)

                    Text("\(viewModel.school.name)")
                        .padding()
                        .font(.title)
                    VStack {
                        Text("Location: \(viewModel.school.location)")
                            .font(.title3)
                        Button("Open in maps") {
                            if let url = URL(string: "maps://?saddr=&daddr=\(viewModel.school.latitude),\(viewModel.school.longitude)")
                            , UIApplication.shared.canOpenURL(url) {
                                  UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            }
                        }
                    }
                    .padding()

                    
                    Text(viewModel.school.overviewParagraph)
                        .font(.body)
                        .padding()
                    // For now I am just exposing the phone number as the way to contact but we could do the same with email
                    Link("Contact Us", destination: URL(string: "tel:\(viewModel.school.phoneNumber)")!)
                    if let satScores = viewModel.satScores {
                        Text("SAT Scores:")
                        Text("Avg Reading Score: \(satScores.criticalReadingAvgScore)")
                        Text("Avg Math Score: \(satScores.mathAvgScore)")
                        Text("Avg Writing Score: \(satScores.writingAvgScore)")
                    } else {
                        Text("SAT Scores: Unavailable")
                    }
                    Spacer()
                }
            }
        }
        .onAppear {
            viewModel.fetchSATScores()
        }
        .alert("Error", isPresented: $viewModel.shouldShowErrorState, actions: {
            //Default behavior without needing to add an action is just to have an ok button because there will be information available to show even with the error view so there is no need to retry for example
            //Also, the error handling logic is duplicated here and in the school list view. I chose to do that because each screen may want to handle errors in a different manner. But realistically usually some error handling will be the same everywhere in the app. This needs a conversation with design and product to align on the right experience. Once that is figured out there could be a general error view that houses this logic to avoid duplication.
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

struct SchoolDetailView_Previews: PreviewProvider {
    static var viewModel: SchoolDetailsViewModel = {
        let viewModel = SchoolDetailsViewModel(forSchool: School(dbn: "2", name: "School 1", overviewParagraph: "This is a really awesome test school", location: "San Francisco, CA", latitude: 0, longitude: 0, phoneNumber: "888-888-8888"))
        viewModel.satScores = SATScores(dbn: "2", numOfTestTakers: 20, criticalReadingAvgScore: 500, mathAvgScore: 400, writingAvgScore: 600)
        return viewModel
    }()
    static var previews: some View {
        // I picked to do this in SwiftUI because I could leverage the Canvas and run through all layout variants for light mode, dark mode, landscape, dynamic type etc
        // Since the text is all centered, there are no concerns with right to left languages. Naturally for stuff like "Location: <school location>" we'd have to localize the string so that when it gets flipped it reads correctly right to left but that's a future concern.
        NavigationView {
            SchoolDetailsView(viewModel: viewModel)
        }
    }
}
