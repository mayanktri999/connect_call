# ConnectCall 📞

ConnectCall is a Flutter-based 1-to-1 audio and video calling application built as an internship assignment. The application provides user authentication, contacts, real-time calling, incoming call handling, call controls, and call history.

The project uses **Firebase for authentication and real-time signaling** and **WebRTC for peer-to-peer audio/video communication**.

---

## ✨ Features

- 🔐 User registration and login
- 👤 User profiles
- 👥 Contacts / users list
- 🟢 Online / offline status
- 🔎 Search users
- 📞 1-to-1 audio calling
- 🎥 1-to-1 video calling
- 📲 Incoming call notifications/screens
- ✅ Accept incoming calls
- ❌ Reject incoming calls
- 🔇 Mute / unmute microphone
- 📷 Enable / disable camera
- 🔄 Switch front/rear camera
- ☎️ End active calls
- 🕘 Call history
- 🔥 Firebase real-time signaling
- 🌐 WebRTC peer-to-peer media communication
- 📱 Android APK support

---

## 🛠️ Tech Stack

| Technology | Purpose |
|------------|---------|
| Flutter | Mobile application framework |
| Dart | Programming language |
| Firebase Core | Firebase initialization |
| Firebase Authentication | User authentication |
| Cloud Firestore | Users, calls and WebRTC signaling |
| flutter_webrtc | Audio and video communication |
| GoRouter | Application navigation |
| Riverpod | State management |
| Google Fonts | Application typography |

---

## 🏗️ Application Architecture

```text
                         ConnectCall
                              │
             ┌────────────────┴────────────────┐
             │                                 │
        Flutter App                       Firebase
             │                                 │
      ┌──────┴──────┐                ┌─────────┴─────────┐
      │             │                │                   │
     UI          Services       Authentication       Firestore
      │             │                │                   │
      │             │                │             ┌─────┴─────┐
      │             │                │             │           │
      │             │                │           Users       Calls
      │             │                │                         │
      │             │                │                 ┌───────┴───────┐
      │             │                │                 │               │
      │             │                │               Offer           Answer
      │             │                │
      └─────────────┴────────────────┴──────────────────────┐
                                                            │
                                                         WebRTC
                                                            │
                                                   ┌────────┴────────┐
                                                   │                 │
                                                 Audio             Video
