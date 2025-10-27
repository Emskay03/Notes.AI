# 🧠 Notes AI  

A sleek, modern note-taking app built with **Flutter** and **Firebase**, enhanced with **AI-powered note summarization**.  
Simple, smart, and focused on helping you keep your thoughts organized effortlessly.  

🎥 **Watch the Demo:**  
[▶ Click here to watch on Google Drive](https://drive.google.com/file/d/1PSYmjnGEGgB0326_6_x9O0MorP3KWgeQ/view?usp=sharing)

---

## 🚀 Features  

- 📝 **Create, View, and Edit Notes**  
  Keep all your thoughts organized with a minimal, distraction-free UI.  

- 🔐 **Firebase Authentication**  
  Secure sign-up and login flow using Firebase Auth.  

- ☁️ **Real-time Cloud Sync**  
  Your notes are stored in Firestore — synced instantly across sessions.  

- ✨ **AI Summarization (Coming Soon)**  
  Automatically summarize long notes into short, meaningful insights.  

- 🎨 **Modern Material 3 Design**  
  A clean and responsive interface that feels fresh and smooth.  

---

## 🧩 Tech Stack  

| Component | Purpose |
|------------|----------|
| **Flutter** | Frontend Framework |
| **Firebase Auth** | Authentication |
| **Cloud Firestore** | Real-time Database |
| **Firebase Core** | App Initialization |
| **Material 3** | Modern UI Toolkit |
| **API** | HuggingFace |

---

## 🧠 Project Structure  

lib/
├── main.dart                 # Entry point, Firebase init + auth state
├── auth_screen.dart          # Login & Sign-up UI
├── home_screen.dart          # Displays all user notes
├── add_note_screen.dart      # Add a new note
├── note_detail_screen.dart   # View/Edit notes + AI summary
└── firebase_options.dart     # Firebase config file


## 🛠️ Setup & Installation  

### 1. Clone this repository  
```bash
git clone https://github.com/yourusername/notes-ai.git
cd notes-ai
