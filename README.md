# Unfu*ck Your Life
A project made years ago. *The current version has working notifications, but they are often broken. The core UI and functions work, though.*

*Once again, this is an old project, so please don’t judge the UI design!*

## Project Overview
The idea for this project came after I watched videos about routines. The main goal was: **make creating todos easy, fast, and reliable.** *So original, right?*

The app has one core feature: channels. Each channel has its own time frame for sending reminder notifications. For example, you might set a work notification for **8 AM** because that’s when you arrive at work. Then, you might have a housework channel that reminds you at **5 PM**.

The app also allows for custom notification todos, which remind you at a specific time of your choosing. Todos can be recurring or one-time.

Enjoy a recording of how you can add a new channel, create a normal todo, and set up a recurring todo:
https://github.com/user-attachments/assets/f1bf9961-b60e-46da-aff8-3c3ece93e4c4

### Onboarding
Around this time, I wanted to create an onboarding experience for the app in the style of: *let’s build a connection with the user.*
![Image](https://github.com/user-attachments/assets/6c656189-207a-44cc-9280-b05ddf94ca66)

## App Internals
If you’re interested in how the SQL database works, here’s a diagram:

<img src="https://github.com/JanKubesIsBest/Todo-app/blob/main/lib/model/database/model_diagram/model_diagram.png">

I won’t dive into the code logic… Once again, this is an old project, and my past self’s logic resulted in very spaghetti code.