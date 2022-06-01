# Database
![App Database Diagram](database.png "App Database Diagram")

This doc explains the structure of our databases in Firebase
## Firestore
### versions
This is a collection of documents, each is related to different YourFitnessGuide version.
* v1: This is a document, which contains two collections:   
    *  users
    *  posts

# users
- [ ] name
- [ ] picture
- [ ] rating
- [ ] current_weight
- [ ] initial_weight
- [ ] goal_weight
- [ ] saved
- [ ] saved_posts
- [ ] goal


# posts
- [ ] category
- [ ] createdAt
- [ ] description
- [ ] image_url
- [ ] rating
- [ ] title
- [ ] user_uid
- [ ] goals
- [ ] exercises
- [ ] meals_name
- [ ] meal_contents
- [ ] meal_ingredients
