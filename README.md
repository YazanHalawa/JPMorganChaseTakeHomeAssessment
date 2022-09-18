# JPMorganChaseTakeHomeAssessment

Hi Everyone! Thanks for taking the time to look through my submission.

I have organized the code in MVVM architecture. 
I tried to leverage dependency injection where I could to enable unit testing, and leveraged protocols like Decodable for parsing the network respones into models.

I have organized the code into several groups:
- School List contains all the code for the view and view model layers that concerns the school list and detail view pages
  - Inside that group, code is organized into Views, ViewModels, Models, and Helper methods/classes.
- Then we have all the Networking code
  - Inside that, I created a folder for endpoints which can scale to later on have multiple endpoints and a dev can quickly scan that folder to see all the endpoints we integrate with
  - The Network Manager is the main class that handles all the networking. It gets all the data it needs to construct a network request from the endpoint that gets passed into the request method
  - There is also a NetworkReachability class which monitors for whether the device is connected to the internet. This is handy for showing alerts/banners if we are disconnected from network
- Then we have a Logging group
  - This contains a handy extension on the native OSLog Logger which allows us to organize our log statements into separate domains like networking/view lifecycle etc. For most of my usecases I only needed the networking one, but this could later extend as more code is added

I build the UI using SwiftUI since there weren't any requests for complicated UI pages and all that was requested is a list and a detail view. What's great about SwiftUI is its declarative nature which blends well with Combine. Also it allows me to inspect multiple variants of the code during development using the preview canvas.

I added some error handling using alert dialogs and a progress view while we fetch data. 

I noticed that for the SAT scores endpoint, some schools didn't have SAT information. So you might see some schools that say "SAT Scores: Unavailable". I didn't want to show an error dialog here because the detail view still has some school information to show, so this doesn't block the user. And anyway the user can still contact the school if they wish to ask about SAT scores.

Finally inside the JPMorganChaseTakeHomeAssessmentTests folder you will find all the unit tests. Mainly I tested some business logic around error cases, and the location parsing logic. Since I leveraged dependency injection I could provide mocks of the network service into the view model and mock any behavior I want.

Let me know if you have any questions!
