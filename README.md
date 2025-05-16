#  Flutter Library App with Back4App (Parse SDK)

This is a simple **library management mobile app** built using **Flutter** and **Back4App** (Parse Server SDK). It allows users to register, manage their profile, and browse a list of books stored in the cloud.

---

## 🛠️ Features

-  **Authentication**: Signup, Login, Password Reset via Back4App Parse `_User` class
-  **Profile Completion**: First Name, Last Name, Age stored in `userRecords` class
-  **Profile Management**: Update name, age, and email; change password
-  **Book Listing**: View books from the `Books` collection
- ️ **Account Deletion**: Removes user and associated profile cleanly

---

## Technologies Used

- **Flutter** (UI Framework)
- **Parse Server SDK (Flutter)** for backend services
- **Back4App** as BaaS for database and authentication

---

## Parse Classes

| Class Name     | Purpose                 | Fields                                                  |
|----------------|--------------------------|---------------------------------------------------------|
| `_User`        | Built-in auth system     | `username`, `password`, `email`                        |
| `userRecords`  | User profile details     | `fname`, `lname`, `age`, `owner` (Pointer → `_User`)   |
| `Books`        | Book listings            | `title`, `author`, `genre`, `year`                     |

---

##  Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/YOUR_USERNAME/flutter-library-app.git
cd flutter-library-app
```

### 2. Install dependencies
```bash
flutter pub get

```
### 3. Configure Back4App Credentials
```bash
In database_helper.dart, update:

const appId = 'YOUR_APP_ID';
const clientKey = 'YOUR_CLIENT_KEY';
const serverUrl = 'https://parseapi.back4app.com';
```
### 4. Set up Back4App Database
```bash
In Back4App Console:

Use _User (default)

Create class userRecords with:

    fname: String
    
    lname: String
    
    age: Number
    
    owner: Pointer → _User

Create class Books with:

    title: String
    
    author: String
    
    genre: String
    
    year: Number
```

### 5. Run the app
```bash
flutter run

```

### Youtube Demo
https://www.youtube.com/watch?v=ttqBGKgp3gM

### Presentation slides
[Slides](add flutter_demo.pdf)