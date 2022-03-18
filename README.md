# Drives
[![GitHub license](https://img.shields.io/badge/license-MIT-lightgrey.svg?maxAge=2592000)](https://url.com)

I present to you... an app that can record all your car drives automatically.

This has been a tiny hobby project of mine - to make an app, that would record all the car drives I make automatically, and be able to export some "useful" data to email.

![PreviewImage](https://raw.githubusercontent.com/GuntisTreulands/drives/main/example2.png)

How does it work
---------------

1.) App needs "Location Updates" and "Background processing" capabilities  
2.) App needs to get location access (ALWAYS USAGE)
3.) App needs to get motion access (to distinguish when the device is in driving mode)
4.) LocationManager -> pausesLocaationUpdatesAutomatically = false
5.) LocationManager -> allowsBackgroundLocationUpdates = true
6.) LocationManager -> activityType = .automotiveNavigation

7.) Motion API checks for activity. 
If it is driving, then:
	7.1.) LocationManager -> desiredAccuracy = kCLLocationAccuracyBestForNavigation
If it is not driving, then:
	7.2.) LocationManager -> desircedAccuracy = kCLLocationAccuracyThreeKilometers 	


With these things, app will be able to work in bacground, and not use GPS, while device is not driving (it will instead use phone towers to triangulate aproximate location, but it is not too important), and when driving, it will be switch to best navigation.
 
From my testing, it still can happen, that iOS closes your app. When that happens, In my experience, it rarely opens the app again. 

So, for extra safety:
 
8.) MONITOR VISITS! 
	LocationManager -> startMonitoringVisits().  This will hopefully force iOS to launch iOS app in background again. This works, but the data is useless in this case. I just use this, in the hopes, that the iOS will launch this app in background.

9.) REGION MONITORS!
	Whenever app detects that an active car drive has ended - set up a region monitor, with a radius of 100 meters, for both exit and entry. These region monitors are not precise, because they use phone towers, but this is another helpful way, to open the app again in background, whenever we enter the car area again (or maybe we never left car area, but now we are driving away, and it did not start to record drive, then it will start, once we leave the region). Again - not perfect, but, every bit helps.
	To help application stay alive when launched in background - every time app is cold started, I activate GPS for 10 minutes, to make iOS believe, that It is necessary to keep it alive.   

10.) LOCAL NOTIFICATIONS!
	With the help of a timer, add UNMutableNotificationContent, to notify user, when the app has stopped running in the background.  (TODO: need to check if instead of timer, maybe applicationWillTerminate: will also work). 
	But anyways - this is a last resort helper for me. In case app stops working, I have a notification about it, informing me, to launch the app manually to continue tracking it in background. In my tests, app has never closed mid-drive, but instead, when I have not driven in some time, or using extensively other iOS apps, that take up RAM.)


WHAT MORE COULD I TRY? (Things I did not try yet)

11.) Background content downloading!
	By integrating performFetchWithCompletionHandler: in the AppDelegate, iOS could, at some random times, call this function to allow your app to download some content. Instead.. just return .noData or .newData, and just be happy that app has started working in background again.   

12.) VOIP notifications
	I could rig up, either server sending some VOIP pushes from time to time to wake the app, or maybe use those silent pushes (but those are also - not always getting through)
	
13.) One more thing.. but while I wrote other things, I forgot about this one. Will add later.



More info
---------------

App is just a barebones demo. There is so much more I wanted to add, but.. then it becomes like a full time job.. so.. meh.


But for giggles.. I live in a place with a gate, that is openable via calling a phone number. So, I also rigged up this application, so that every time car location is within the gate radius, it auto-calls (via some REST API's + TWILIO STUDIO) the gate! MAGIC!

Also thinking to rig it up for running activities (Like, if I am running, it could also actively track the gps, and also open the gates automatically.).. But maybe that is for a different app. 
 

Got feedback?
---------------

If you have thought of something more than what I came up with (to make app work in the background in a more stable way, or so that app would use less battery), then reach out to me!


