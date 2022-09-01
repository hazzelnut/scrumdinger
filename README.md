# Scrumdinger

I'm following the iOS app dev tutorial [here](https://developer.apple.com/tutorials/app-dev-training) in building a scrum organizing app.

The goal? To get a taste of iOS development and coding with Swift.

And, see what the development experience is like with SwiftUI.

So far, I quite like it. It reminds me a lot of web development in how it structures the UI layout.

## Progress

### September 1, 2022 - Updating App Data & Managing State and 

Two new features!
- Create a new scrum meeting
- Keep a history of scrum meetings already held

In terms of new code, it is relatively small. Here, I'm still using using `@Binding` and `@State` to pass data between views.

I personally find it very cool with how simple it is to create a toolbar. Perhaps it is standarized across all UI/UX views on iOS. Basically, we have this:

```swift
NavigationView {
  DetailEditView(data: $newScrumData)
    .toolbar {
        ToolbarItem(placement: .cancellationAction) {
            Button("Dismiss") {
                isPresentingNewScrumView = false
            }
        }
        ToolbarItem(placement: .confirmationAction) {
            Button("Add") {
                isPresentingNewScrumView = false
            }
        }
    }
}
```
Which makes this appear:


In any case, here's feature #1 with adding a new scrum meeting:

And feature #2 with keeping track of the history of scrum meetings after one has ended:



### August 24, 2022 - Adding Events and Observable Class

Turns out, there are different ways to define a source of truth (for holding data) in our app. There are value types, like `struct` and `enum` and references types, like `class`. 

In addition, there are ways for an app's view to respond to event changes. In SwiftUI, these event changes are described as Life Cycle Events. For example, you can use `.onAppear` or `.onDisappear` modifiers to trigger events.

```swift
struct MeetingView: View {
  var body: some View {
    ZStack {
      ...
    }
    .onAppear {
      ... // pass a closure here
      // ex. scrumTimer.startScrum()
    }
    .onDisappear {
      ... // pass a closure here
      // ex. scrumTimer.stopScrum()
    }
  }
}
```

I also learned to extract sections of a view into their own, smaller views. In other words, modularizing our views to be more re-usable.

And, I finally added sound! Whenever a scrum ends, it'll play a tune. Sound files are added under the `/Resources` folder.


### August 23, 2022 - Passing Data with Bindings

Wired up the app using `@Binding` and `@State` in order to pass data between views. Now the 'Edit' functionality works! 

Updating existing data is done by passing [*projectedValue*](https://developer.apple.com/documentation/swiftui/binding/projectedvalue) down the chain of views using the `${name_of_value}` syntax.

Defining `@State` in a struct creates a source of truth for a value type. To make modifications to that state value, we pass the value using the *`projectedValue`* syntax (ex. `${name_of_value}`) also known as 'passing a binding'. Depending on where that value is passed, a binding lets us share write access to that `@State` value in other views. And, we can use `@Binding` in a struct to declare a value with write access to a `@State` value in some other view.

For example, we have the parent view `DetailView.swift`:
```swift
import SwiftUI

struct DetailView: View {
  @State private var data = DailyScrum.Data() // Define source of truth
  ...
  List {
    ...
  }
  .sheet(...) // The 'Edit' modal
  NavigationView {
    DetailEditView(data: $data) // pass the projectedValue
  }
}
```
And in the child view `DetailEditView.swift`:
```swift
import SwiftUI

struct DetailEditView: View {
    @Binding var data: DailyScrum.Data // Reference to the 'data' @State value in DetailView
    ...
    Section(...) {
        ForEach(data.attendees) { attendee in
            Text(attendee.name)
        }
        .onDelete { indices in
            data.attendees.remove(atOffsets: indices)
        } // We modify the state value
    }
}
```

And this is what we have 🎉:


### August 22, 2022 - Navigating Between Views

Got `NavigationalViews` working. Now, a user can navigate to multiple views. In addition, we can also open up a 'modal' or a `.sheet` as it is called. In the app, that happens when we press on the 'Edit' button.

Also learned about `@Binding` and `@State`. SwiftUI's way of managing state information across the different views. Here, I'm using both property wrapper types to understand how 'state' values change. And how we can use new state values to update existing state values. 

Here's what all of it looks like so far:

https://user-images.githubusercontent.com/6500879/186221236-c533f008-4e75-45c8-9215-817d7b6f118c.mov


***Fast forward by about a week ⏱***

### August 16, 2022 - Stacks and Views

Just started out following the tutorial. So far, I'm learning about stacks and views. Quite basic, and not super interesting.

Here's what I have so far:

<img width="406" alt="Screen Shot 2022-08-23 at 1 00 03 PM" src="https://user-images.githubusercontent.com/6500879/186219358-279de5b3-ccdb-42a1-a623-cc8d741ff7b7.png">

<img width="419" alt="Screen Shot 2022-08-23 at 1 00 15 PM" src="https://user-images.githubusercontent.com/6500879/186219392-90fea761-e583-4fcf-802c-bc94b537a54f.png">

