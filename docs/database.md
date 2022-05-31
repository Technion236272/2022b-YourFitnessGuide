# Database
![App Structure Diagram](database_structure.png "App Structure Diagram")

This doc explains the structure of our databases in Firebase
## Firestore
### versions
This is a collection of documents, each is related to different TutorPick version.
* v{i}: This is a document, which contains two collections:
    *  users
    *  lessons

### users
This is a collection, which contains a document for each registered user in TutorPick.
Each user in the system has a unique `uid`, which is the same as his document id.
#### A user's document
Each user document contains all his data, such as:
* Data for every TutorPick user:
    * First name
    * Last name
    * Uid
    * Email address
    * Bio
    * Role
    * Phone number
    * URL to his image (stored in our storage, to be introduced later).
    * Token - used for sending notifications.
    * Token registration time - used for sending notifications.
    * Pick history - saves the picked lessons history of the user.
* Data for Tutors only:
    * Lessons (List of the tutor's published lessons)
    * Hourly price rate
    * Spoken languages (list)
    * Home availability (bool)
    * Online availability (bool)
    * Available time slots (Map of the tutor's weekly schedule {day, list of hour-pairs})
    * Picked time slots (Map of the tutor's picked slots, same as Available time slots + the date).
    * Rating Data (Array of the tutor's received feedbacks, each element is a map that contains a review).
    * Location (Geopoint)
    * averageRating (double)
### lessons
This is a collection, which contains a document for each lesson in TutorPick.
Each lesson in the system has a unique uid\
`{Tutor's uid}_{Course number}`, which is the same as its document id.
#### A lesson's document
* Each lesson document contains all its data, such as:
    * Course name
    * Course number
    * Tutor id
    * additional tutor's notes.
### notificationsForUser
This is a collection, which contains a document for each registered user in TutorPick, that stores his notifications.
The document name is the same as the uid of the relevant user, and it contains a collection named `notifications`, which stores all the notifications of the user.
#### The `notifications` collection
* The `notifications` collection contains all the notifications of the relevant user, which can be of three types:
    * Pick request
    * Request response
    * New feedback received


## Storage
Our Firebase storage contains a directory name images/, which stores all the TutorPick user's profile pictures.
The image URL in the user's document redirects to an image that is saved in this storage. 