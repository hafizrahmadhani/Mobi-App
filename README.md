# Mobi App - Shoulder Pose Detection

**Mobi App** is an **individual project** developed for the "Americano" (Challenge 2) at the **Apple Developer Academy @ UNINA**. This app was built solo, not as part of a team.

This project serves as a practical application of a personal learning goal: mastering **Human Body Pose Detection** using VisionKit. It deconstructs a core feature inspired by real-world mobility apps to achieve this specific technical objective.

---

## 🎯 The Challenge: Deconstruction

The "Americano" challenge required us (the students) to deconstruct an existing App Store application. We had to analyze its UI and core technology, then choose a specific feature or UI element to rebuild based on a **personal learning goal**.

### Inspiration

This project was inspired by the **[Reflex: Shoulder Mobility](https://apps.apple.com/it/app/reflex-shoulder-mobility-app/id1555112791?l=en-GB)** app. The key functionality of *Reflex* is its ability to analyze a user's movement and **shoulder posture**, which relies heavily on real-time body tracking.

---

## 🚀 My Personal Learning Goal

For this challenge, each student defined their own unique learning objective. While others may have focused on UI, networking, or different frameworks, **my specific goal** was to master a core machine learning technology on iOS.

My personal learning objective for this project was:

> "To be able to use Machine Learning for Detecting human body pose using the VisionKit framework."

This **Mobi App** is the direct result of pursuing that goal. It is not a full clone of *Reflex*, but a focused technical implementation that uses the device's camera and **VisionKit** to detect and track human body joint positions in real-time. This technology is the foundation for analyzing specific movements, such as shoulder pose and mobility.

---

## 🎨 Design & UI

The user interface and conceptual flow for this project were planned using Sketch. You can view the complete design file to see the intended UI and user experience.

**[View the Sketch Design File](https://sketch.com/s/c92b3e81-ebb7-4d58-be38-7be2483e542b)**

---

## 🛠️ Core Technologies & Frameworks

This project was built using:

* **SwiftUI:** For building the modern, declarative user interface.
* **VisionKit:** Utilized for the `VNDetectHumanBodyPoseRequest` to analyze video frames and identify human body landmarks.
* **AVFoundation:** To manage the live camera feed (input) that VisionKit analyzes.
