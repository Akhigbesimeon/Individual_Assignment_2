# BookSwap

BookSwap is a full-stack mobile application built with Flutter and Firebase, designed as a marketplace for students to list, browse, and exchange textbooks. The app features real-time database syncing, user authentication, and a complete swap-management workflow.

<img width="1919" height="877" alt="Image" src="https://github.com/user-attachments/assets/6bde4024-f771-4292-a87e-68a440e048d7" />
<img width="1919" height="871" alt="Image" src="https://github.com/user-attachments/assets/926d8032-80e5-4531-b957-6735b321fa42" />
<img width="1917" height="869" alt="Image" src="https://github.com/user-attachments/assets/301de5d2-41e9-45e6-8946-dcd7fef57c01" />
<img width="1919" height="876" alt="Image" src="https://github.com/user-attachments/assets/a61c755f-5ca4-4641-97e3-dac4413aa755" />
<img width="1918" height="873" alt="Image" src="https://github.com/user-attachments/assets/5a947b3b-21e4-43f3-8948-b80a84bfa2f6" />
<img width="1919" height="874" alt="Image" src="https://github.com/user-attachments/assets/5e1bae9f-c145-43e3-a1d1-33aef7120c9e" />
<img width="1919" height="878" alt="Image" src="https://github.com/user-attachments/assets/24e6e997-95a1-4c7f-aa5f-1a02d6247291" />
<img width="1919" height="869" alt="Image" src="https://github.com/user-attachments/assets/2525c2e6-d433-45b5-8060-62e98b6de5ba" />
<img width="1919" height="873" alt="Image" src="https://github.com/user-attachments/assets/29bc09a9-377c-4863-b7ad-9e5563e26bc6" />
<img width="1919" height="879" alt="Image" src="https://github.com/user-attachments/assets/46587774-02a5-4531-883f-1dff678ca97f" />
<img width="1919" height="878" alt="Image" src="https://github.com/user-attachments/assets/458e30a5-34e4-45bb-9f41-56e7b699a87f" />
<img width="1919" height="874" alt="Image" src="https://github.com/user-attachments/assets/0bc90468-675e-40e2-b494-36da7fd904c0" />
<img width="1919" height="875" alt="Image" src="https://github.com/user-attachments/assets/52b461a7-955f-4d02-8d6f-7cf0d7e87a4b" />

## Core Features

- Full Authentication: Secure user sign-up (with email verification), sign-in, and log-out flow using Firebase Authentication.

- Browse Real-time Listings: A "Browse" screen that streams all available books from Firestore in real-time.

## Full CRUD Operations:

- Create: Users can post new book listings with a title, author, and condition.

- Read: All users can browse and view the details of any listing.

- Update: Users can edit the details of their own listings.

- Delete: Users can delete their listings, which also cleans up any associated swap offers.

## Swap Management System:

- Request: Users can request a swap for any available book.

- Manage: Book owners can view "Received Offers" in a dedicated tab and choose to Accept or Reject them.

- Track: Users can see the status (Pending, Accepted, Rejected) of their "Sent Offers."

- Real-time Chat: When a swap is Accepted, a private chat room is automatically created, allowing both users to coordinate their exchange.



## Tech Stack

- Frontend: Flutter

- State Management: Riverpod (using Provider for services and StreamProvider for real-time data)

- Backend: Firebase

- Authentication: Firebase Auth

- Database: Cloud Firestore (for real-time data)

## Installation

### Requirements
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (v3.x or newer)  
- Dart (latest stable)  
- Android Studio or VS Code  

### Run the App

```bash
# Clone the repository
https://github.com/Akhigbesimeon/Individual_Assignment_2.git

# Navigate to the project directory
cd Individual_Assignment_2

# Navigate to the project root
cd book_swap

# Get Flutter dependencies
flutter pub get

# Run on connected device or emulator
flutter run
