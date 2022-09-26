# Scrumdinger

I'm following the iOS app dev tutorial [here](https://developer.apple.com/tutorials/app-dev-training) in building a scrum organizing app.

The goal? To get a taste of iOS development and coding with Swift.

And, see what the development experience is like with SwiftUI.

So far, I quite like it. It reminds me a lot of web development in how it structures the UI layout.

## Progress

### Going forward to the future...

Now that I'm all finished with the tutorial, I'm happy to say that app development with SwiftUI is fairly painless. There wasn't that many hiccups, and besides the slow build times (I have an older Macbook), I got a working app going at the end!

What's next? If I get to it, I would like to try building an app without a tutorial and deploying it to the App Store. Now that I have some basics down, albeit more practice is needed, I at least have some foundational knowledge of what a simple app structure looks like in SwiftUI.

Now it's time for a break!

### Last day!
### September 26, 2022 - Transcribing the audio!
After a bit of travelling and seeing family, it's been hard to sit down and find some focus time to finish the rest of the tutorial. But I've finally did it!

I felt a bit more ambitious today. I wanted to get the last couple parts of the tutorial finished so I can move on! 

The last piece is transcribing the user's audio. Here I'm asking the user to allow Scrumdinger to use 'Speech Recognition' and the 'Microphone' abilities so we can transribe their speech and put it into the history.

The interesting part is I can customize what text I display to the user when I ask them for permission. I do that by navigating to the project's target, and adding an entry to the 'custom iOS Target Properties'.

[insert image]

Here's what the full interaction looks like:

[insert video]


### September 26, 2022 - Drawing the Timer

Here, I'm updating the circular timer view to be animated. Instead of a static circle like it was before. Nothing new, except I'm creating another `View` while implementing the `Shape` protocol to draw the circle.

Here's what it looks like:



https://user-images.githubusercontent.com/6500879/192343899-f6b0ee1d-2a3f-44ed-9288-55cdd3274289.mov


### September 21, 2022 - Error handling

Errors. Sometimes they are helpful, sometimes they are not. In this section of the tutorial, I'm building an error modal (aka `.sheet`) that will pop up when an error occurs. I created a new model and a new view. That is pretty much it. Oh, I guess one cool thing is with the `.sheet` modifier, we can pass a callback when it is dismissed. Here's what it looks like:

```swift
NavigationView {
  ...
}
.sheet(item: $errorWrapper, onDismiss: {
  ... // Insert call back here
}) { 
  ... // Insert view here
}
```

And here's what happens when I trigger an error. I do this by modifing the app's sandboxed data.
```bash
$ xcrun simctl get_app_container booted com.example.apple-samplecode.Scrumdinger data

> /Users/ericchan/Library/Developer/CoreSimulator/Devices/42AA7CDE-2B67-4A1C-9F4C-7BAA9C572CF7/data/Containers/Data/Application/A5DA6FB0-E395-46ED-9CD5-54E5956C2BDC

## Afterwards, I navigate to "{path}/Documents/scrum.data", and modify the contents of the json file.

```
:


https://user-images.githubusercontent.com/6500879/191641997-e76bbdba-3339-4bd5-a6c5-b2529f077212.mov



### September 9, 2022 - Making things asynchronous

With Swift 5.5, concurrency is introduced and we can now use `async/await` in our code.
In this part of the tutorial, we rewrite how we save and load data in our background queues.

This part is still a little confusing to me. I might have to go back and look at how it is done again. But the idea is that we can simplify our code by not having to pass closures.

For example, in the root of my app `ScrumdingerApp.swift`, I'm passing in a closure to `ScrumStore.save()`:

```swift
var body: some Scene {
    ...
    NavigationView {
      ScrumsView(scrums: $store.scrums) {
        ScrumStore.save(scrums: store.scrums) { result in
          if case .failure(let error) = result {
              fatalError(error.localizedDescription)
          }
        }
      }
    }
}
```

By making the implementation of `ScrumStore.save()` async, we can simplify it to:

```swift
var body: some Scene {
    ...
    NavigationView {
      ScrumsView(scrums: $store.scrums) {
        Task {
          do {
            try await ScrumStore.save(scrums: store.scrums)
          } catch {
            fatalError("Error saving scrums.")
          }
        } 
      }
    }
}

```

Using `Task` allows us to run asynchronous code, and so does the `.task()` modifier:

```swift
var body: some Scene {
    ...
    NavigationView {
      ... 
    }
    .task {
      do {
        store.scrums = try await ScrumStore.load()
      } catch {
        fatalError("Error loading scrums.")
      }
    }
}
```

All in all, the implementation behind making `ScrumStore.load()` and `ScrumStore.save()` use the new `async/await` syntax allows us to simplify the structure of the code when they're called.


### September 6, 2022 - Persisting Data

How do we store the user's data such that when they leave and re-open the app, all their information is up-to-date from their last change?

In my limited app dev experience, I feel like there are multiple ways to do it. I think it is possible to send the data across an API to store it in a DB. And later retrieve the data using an API when the app loads.

In this tutorial, I'm storing the data locally on the device. I started by creating a data store, in the form of a new class using the `@ObservableObject` protocol that includes a `load` and `save` method. We save the data to the phone's local and JSON encode the `ScrumStore` data model. All data is stored under the `/Documents` folder. We later decode the JSON data when the user re-opens the app.

The part that's confusing to me, and might require more exploration on my part, is how to use `DispatchQueue` for running background tasks. Without going into too much detail, we're basically running tasks in the background, by using dispatch queues, to save and load user data.

I also learned to use the `@Environment` property to grab the user's state. By using the `scenePhase` environment value, we can detect the current operational state of the app. This allows me to save user data when they are in an `inactive` state.

All this work means we can save and load data when the user quits the app, or when they are in `inactive` state. So when they re-open the app, all the information will be the same as when they left.

Here's what we have:


https://user-images.githubusercontent.com/6500879/188734263-251aaf72-8152-4b92-aded-fce7ca5bf490.mov




### September 1, 2022 - Updating App Data & Managing State and Life cycle Events

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

<img width="459" alt="Screen Shot 2022-09-01 at 7 38 05 PM" src="https://user-images.githubusercontent.com/6500879/188024534-aa5bc108-01f9-43fc-b1e7-c717f94ca8aa.png">


In any case, here's feature #1 with adding a new scrum meeting:


https://user-images.githubusercontent.com/6500879/188024552-51bf00d1-2626-4ce8-a920-0632077a9a34.mov



And feature #2 with keeping track of the history of scrum meetings after one has ended:



https://user-images.githubusercontent.com/6500879/188024560-b24f890f-d195-4666-aa18-6158eda4818a.mov



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


https://user-images.githubusercontent.com/6500879/186251652-c213eeed-3687-40ab-af75-b73b8586ac08.mov



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

