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



📞 Calling Flow
Caller
  │
  ├── Select Contact
  │
  ├── Create Call
  │
  ├── Generate WebRTC Offer
  │
  └── Save Offer → Firestore
                    │
                    ▼
                 Receiver
                    │
                    ├── Incoming Call
                    │
                    ├── Accept / Reject
                    │
                    └── Generate Answer
                              │
                              ▼
                         Firestore
                              │
                              ▼
                      WebRTC Connection
                              │
                    ┌─────────┴─────────┐
                    │                   │
                  Audio               Video

🔥 Firestore Structure
users/
  └── {userId}
       ├── uid
       ├── name
       ├── email
       ├── profileImage
       ├── isOnline
       └── createdAt

calls/
  └── {callId}
       ├── callerId
       ├── receiverId
       ├── type
       ├── status
       ├── createdAt
       ├── answeredAt
       ├── endedAt
       ├── offer
       └── answer

       ├── callerCandidates/
       │
       └── receiverCandidates/


🌐 WebRTC

WebRTC is responsible for the real-time peer-to-peer communication.

Audio
Microphone
    ↓
Local Audio Track
    ↓
WebRTC Peer Connection
    ↓
Remote Audio Track
    ↓
Speaker
Video
Camera
   ↓
Local Video Track
   ↓
WebRTC Peer Connection
   ↓
Remote Video Track
   ↓
Video Renderer


📱 Call Controls
Audio Call
🎤 Mute / Unmute
☎️ End Call
Video Call
🎤 Mute / Unmute
📷 Camera On / Off
🔄 Switch Camera
☎️ End Call

📂 Project Structure
lib/
│
├── core/
│   └── theme/
│       ├── app_colors.dart
│       ├── app_theme.dart
│       ├── app_text_styles.dart
│       └── app_design_system.dart
│
├── models/
│   ├── user_model.dart
│   └── call_model.dart
│
├── services/
│   ├── authentication/
│   ├── calls/
│   └── users/
│
├── widgets/
│   ├── app_bottom_nav.dart
│   ├── user_avatar.dart
│   ├── search_field.dart
│   ├── call_action_card.dart
│   ├── contact_tile.dart
│   ├── call_history_tile.dart
│   └── status_indicator.dart
│
├── screens/
│   ├── auth/
│   ├── splash/
│   ├── home/
│   ├── contacts/
│   ├── calls/
│   └── profile/
│
├── routing/
│   └── app_router.dart
│
└── main.dart

🚧 Future Improvements
TURN server integration
Push notifications
Background incoming calls
Better call-quality monitoring
Network quality indicator
Call reconnection
Profile image upload
Improved Firestore security rules
Missed-call notifications
Call duration tracking
