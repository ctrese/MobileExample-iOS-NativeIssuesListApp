### Predix Mobile SDK for iOS -- Native App Example

While the Predix Mobile environment was created with hybrid apps in mind, it is possible to create a completely native iOS experience with the Predix Mobile SDK for iOS. This examples shows a similar issues-tracking system like the [Sample app] but uses a native UI instead of web/hybrid one. This technique can be used to create entire iOS apps, or components of larger native/hybrid apps where a particular native look and feel are desired, for performance reasons, or anything else you can imagine.

This sample demonstrates a number of techniques, including creating database views, calling services from native Swift code, and using properties from the webapp document to determine what native components to load.

#### Example Setup

This example requires some sample data imported into your development Predix Mobile space. This data, an app.json and a webapp.json file can be found in the _setup_ directory with this repo's root.

For your convienence, two scripts have been provided to quickly get you started:
* set-pm-host.sh : Adds your pm server as the default in the app's Settings bundle.
* pm-setup.sh : Publishes the webapp.json, defines the app.json, and imports the data.json files to your Predix Mobile space

From the command line type these commands:

    pm auth myusername
    ./set-pm-host.sh
	./pm-setup.sh

#### Key components of this example:

##### IssueView Storyboard
This storyboard contains the UI for the native app. The app is centered around a UISplitViewController, and size class aware constraints to give a device appropriate look for any iOS device the app is running on:

###### IssueView Storyboard   
![IssueView Storyboard Screenshot](README/screenshots/storyboard.png?raw=true)

###### Screenshots:
**iPad Landscape** | **iPad Portrait Detail** | **iPad Portrait Summary**
--- | --- | ---
![iPad Landscape Screenshot](README/screenshots/iPadLandscape.png?raw=true) | ![iPad Portrait Detail Screenshot](README/screenshots/iPadPortraitDetail.png?raw=true) | ![iPad Portrait Summary Screenshot](README/screenshots/iPadPortraitSummary.png?raw=true)
**iPhone Portrait Summary** | **iPhone Portrait Detail** | **iPhone Landscape Detail**
![iPhone Portrait Summary Screenshot](README/screenshots/iPhonePortraitSummary.png?raw=true) | ![iPhone Portrait Detail Screenshot](README/screenshots/iPhonePortraitDetail.png?raw=true) | ![iPhone Landscape Detail Screenshot](README/screenshots/iPhoneLandscapeDetail.png?raw=true)

##### PredixAppWindow
An instance of this object is passed to the PredixMobilityManager intializer as the packageWindow parameter. This object is responsible for determining what UI components the Predix Mobile SDK for iOS is requesting to be put on the screen.

In this example we largely ignore the _URL_ parameter of the LoadURL PredixAppWindowProtocol method, and focus instead of the _parameters_ prameter, which is the webapp document dictionary created by the webapp.json file used with the 'pm publish' command. In the webapp.json of this example, we've added an additional property: *storyboardId* which is expected to be the name of a storyboard bundled with the iOS app. In this case the PredixAppWindow object dynamically loads the storyboard indicated by this property.

###### webapp.json:

	{
	   "name": "native-issue-viewer",
       "version": "1.0",
       "main": "native",
       "storyboardId": "IssueView",
       "src-folder": "./dist/",
       "output-folder": "./dist-zip/"
    }

You may also notice in this example the webapp source _dist_ directory is empty. This example doesn't require any files to be provided for the UI. However, if files were included in this directory they would be compressed and provided to the container. In this way media files could be provided to the native application at runtime.

##### AuthenticationVC
This UIViewController implements the PredixAppWindowProtocol protocol, and is used to display the web-based authentication UI.

##### MasterViewController
This is the class that handles the loading of the master list view. Of most interest is the call to the CBD service to load the view that returns the data for the list. This can be found in the LoadIssues method.

##### Models.swift
In this file is the IssueSummary structure, and the IssueDetail structure. The getDetail method on the IssueSummary structure is where the document for the summary view row is loaded using the CBD service.
