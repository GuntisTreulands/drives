# Drives

[![GitHub license](https://img.shields.io/badge/license-MIT-lightgrey.svg?maxAge=2592000)](https://url.com)

 I present to you... an app that can record all your car drives automatically.

This has been a tiny hobby project of mine - to make an app, that would automatically record all the car drives I make and be able to export some "useful" data to email.

  

![PreviewImage](https://raw.githubusercontent.com/GuntisTreulands/drives/main/ExampleImages/v2_example4.gif)


**Version 2 Update!! Whoop Whoop!🙀**  

**1.)** Statistics page (To finally determine if owning a car costs more that rent services.. )

**2.)** Month drives / All drives - map view (Just to see all the drives at once. Looks so sweet)


**Statistics** 


![PreviewImage](https://raw.githubusercontent.com/GuntisTreulands/drives/main/ExampleImages/v2_example7.png)
![PreviewImage](https://raw.githubusercontent.com/GuntisTreulands/drives/main/ExampleImages/v2_example8.png)


Since for ever, I have collected all the costs I have with my car.. Fuel, Taxes, insurance, car wash, repairs, and
even - car value drop (once a year I see check some market place to see the aprox value of my car).
But what was missing - how often do I drive, and how long are the drives.

Here, in Latvia, we have 3 most popular car rent services:
Bolt Drive, CarGuru and CityBee.
- I investigated their homepages and apps, to determine all the possible costs for renting their cheapest car.

- Then I mapped within my app for each drive (actually I combined some of the drives, that were trips over multiple days), to determine price for each service.

- To add a cherry on top - For each drive/trip, I now knew the cheapest rentable service, so I created another entry: Mixed Rent (If I knew beforehand my trip length/distance, I could in theory, choose appropriate car rent service).

And the conclusion, for my specific car, and drive patterns are.. 🥁🥁🥁

**Definatelly it is worth to have my own car, than rent!(#)(#)**

(#) If I am being honest, In year 1 of owning my current car, it actually appears that my car was more expensive than renting would have been, because in year one I got premium insurance, had some initial post-buy repairs, car value dropped much more on first year, etc.  So - the longer I own a car, the cheaper it got, and in the last year, my car is cheaper by ~3.5x than if I would rent a car for each drive/trip

(#) I am using static rent service prices, while comparing my car costs 5 years ago. Yes, it sucks, but hey, it's a start, and it's pretty cool in my humble opinion.  Rent service prices are hardcoded for now.


**Month drives / All drives - map view**

![PreviewImage](https://raw.githubusercontent.com/GuntisTreulands/drives/main/ExampleImages/v2_example6.png)
![PreviewImage](https://raw.githubusercontent.com/GuntisTreulands/drives/main/ExampleImages/v2_example5.png)

Not much to comment here. It felt kinda awesome, if I could see All my drives at once, just to see that spider web on the map - where have I driven with my car.

It was actually (and still is) a challange. I started recording my drives since **2022.02.15** I think, and I have recorded about **533** drives, in total having around **480k** points. No easy feat for MKMapview.

So, I added some filtering, to determine and keep only pivotal points and ended up with around **67k** points.
Map is now more usable, but it still takes some time to load, and iOS **16.x** has a bug, that it will freeze app after a while (with so much data). Only solution is to refresh it (change mapType to something else and back) after each panning/zooming. Still room to improve.


![PreviewImage](https://raw.githubusercontent.com/GuntisTreulands/drives/main/ExampleImages/example9.gif)


--------------- 
**Drives recording**

How does it work.

---------------

  
![PreviewImage](https://raw.githubusercontent.com/GuntisTreulands/drives/main/ExampleImages/example3.gif)

**1.)** App needs "Location Updates" and "Background processing" capabilities

**2.)** App needs to get location access (ALWAYS USAGE)

**3.)** App needs to get motion access (to distinguish when the device is in driving mode)

 **4.)** LocationManager -> pausesLocaationUpdatesAutomatically = false

**5.)** LocationManager -> allowsBackgroundLocationUpdates = true

 **6.)** LocationManager -> activityType = .automotiveNavigation

 **7.)** Motion API checks for activity.

 **7.1.)** If it is driving, then LocationManager -> desiredAccuracy = kCLLocationAccuracyBestForNavigation

**7.2.)** If it is not driving, then: LocationManager -> desircedAccuracy = kCLLocationAccuracyThreeKilometers

With these things, the app will be able to work in the background, and not use GPS, while the device is not in driving mode (it will instead use phone towers to triangulate approximate location, but it is not too important), and when driving, it will switch to best navigation.

From my testing, it still happens that iOS closes your app. When that happens, in my experience, it rarely opens the app again.

  

So, for extra safety:

**8.) MONITOR VISITS!**

LocationManager -> startMonitoringVisits().  This will hopefully force iOS to launch the iOS app in the background again. This works, but the data is useless in this case. I just used this in the hopes that the iOS would launch this app in the background.

 **9.) REGION MONITORS!**

Whenever the app detects that an active car drive has ended, it sets up a region monitor with a radius of 100 meters for both exit and entry. These region monitors are not precise because they use phone towers, but this is another helpful way to open the app again in the background whenever we enter the car area again (or maybe we never left the car area, but now we are driving away, and it did not start to record the drive, then it will start once we leave the region). Again, not perfect, but every bit helps.

To help the application stay alive when launched in the background, every time the app is cold started, I activate GPS for 10 minutes to make iOS believe that it is necessary to keep it alive.

**10.) LOCAL NOTIFICATIONS!**

With the help of a timer, add UNMutableNotificationContent to notify the user when the app has stopped running in the background. (TODO: need to check if instead of timer, maybe applicationWillTerminate: will also work).

But anyway, this is a last resort helper for me. In the event that the app stops working, I receive a notification about it, informing me to launch the app manually to continue tracking it in the background. In my tests, app has never closed mid-drive, but instead, when I have not driven for some time, or using extensively other iOS apps, that take up RAM.)

WHAT MORE COULD I TRY? (Things I have not tried yet)

**11.) Background content downloading!**

By integrating performFetchWithCompletionHandler: into the AppDelegate, iOS could, at some random times, call this function to allow your app to download some content. Instead - just return .noData or .newData, and just be happy that the app has started working in the background again.

**12.) VOIP notifications**

I could rig up either a server sending some VOIP pushes from time to time to wake the app, or maybe use those silent pushes (but those are also not always getting through).


  

  
Motion API

---------------

Keep in mind, that Motion API can detect driving mode from the GPS movement itself, but it takes some time.

In my case, my phone connects to car Bluetooth, and that seems to be the primary thing for Motion API. Even if I stop the car (without turning it off), and walk around the car, while still connected to car Bluetooth - I am still in a driving mode.



More info

---------------

The app is just a barebones demo. There is so much more I wanted to add, but.. then it becomes like a full-time job.. so.. meh.

But for giggles.. I live in a place with a gate that is openable by calling a phone number. So, I also rigged up this application so that every time a car location is within the gate radius, it auto-calls (via some REST API's + TWILIO STUDIO) the gate! MAGIC!

I am also thinking of rigging it up for running activities (like, if I am running, it could also actively track the GPS and open the gates automatically). But maybe that is for a different app.

  

Got feedback?

---------------

  

If you have thought of something more than what I came up with (to make an app work in the background in a more stable way, or so that the app would use less battery), then reach out to me!

