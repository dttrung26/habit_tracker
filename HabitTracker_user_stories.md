# Habit Tracker User Story

Habit Tracker is a Flutter mobile app that helps people build positive daily habits. Users create an account, pick the habits they want to build, tick them off each day, look at their progress, and get reminders.

## Personas

| Persona | Who they are | What they need |
|---|---|---|
| **Busy student (primary user)** | A university student juggling classes, assignments and part-time work | A quick way to keep healthy routines (sleep, water, exercise) on track without much effort |
| **Young professional** | Works full time and wants to grow self-improvement habits such as reading and meditating | Reminders at the right time of day and a clear view of progress |
| **App admin** | The person who looks after the app and its content | Activity data and control over settings so the app stays useful and safe |

---

## 1. Login and Registration

- **Application registration:** As a new user, I want to register by entering my username, email and password and then tapping the **Sign Up** button, so that I can create my own Habit Tracker account.
- **Application login:** As a registered user, I want to enter my email and password and tap the **Log in** button, so that I can access my account and my habits.
- **Error feedback on sign up and login:** As a user, I want to see a clear message if I tap **Sign Up** without entering my details, or if my email or password is incorrect when I log in, so that I know what went wrong and how to fix it.
- **Store user data:** As a user, I want my account details saved in local storage, so that my data is still there between app sessions.

## 2. Home Screen

- As a user, I want to see an overview of today's habits on the home screen (what is still **To Do** and what is **Done**), so that I can check my progress at a glance.
  - *Example:* "3 of 5 habits done today" is shown under the greeting.
- As a new user, I want short hints on the home screen (for example, "Use the + button to create some habits!" and "Swipe right on an activity to mark as done"), so that I can learn how to use the app quickly.
- As a user, I want quick access to the most-used features from the home screen (the + button to add a habit, swipe to complete, and the menu), so that I can use the app with fewer taps.

## 3. Detail Screen

- As a user, I want to see detailed information about a habit I select (its description, category and today's status), so that I understand the habit and how to complete it.
- As a user, I want to take actions on the detail screen, such as marking the habit as done or deleting it, so that I can manage it without going back to the list.
- As a user, I want to see my other habits on the detail screen, so that I can explore what else I have planned for today.

## 4. Persistent Data

- As a user, I want my login state to persist across sessions, so that I do not need to log in again every time I open the app (until I sign out).
- As a user, I want my preferences, such as dark mode and notification settings, to be saved, so that the app remembers my settings.
- As an admin, I want a log of user activity (habits completed, habits added, logins) to be stored, so that progress reports can be generated over time.

## 5. External API Integration

- As a new user, I want to choose my country from a complete, up-to-date list when I register, so that my profile is accurate.
  - *Example:* The app calls the REST Countries API and fills the country dropdown with every country name.
- As a user, I want the same country list when I edit my personal info, so that I can update my country at any time.
- As a user, I want to see a short list of countries if the API cannot be reached (for example, when I am offline), so that I can still finish signing up.

## 6. Settings Menu

- As a user, I want to open a settings menu from the home screen (hamburger icon or settings icon), so that I can change my preferences at any time.
- As a user, I want the settings menu to show clear options with icons (Configure, Personal Info, Reports, Notifications, About, Sign Out) and a greeting with my name, so that I can quickly find what I need.
- As a user, I want a **Sign Out** option in the menu that ends my session and returns me to the login screen, so that my account stays secure on a shared device.

## 7. Settings Screen

- As a user, I want to turn on dark mode in the settings screen, so that I can reduce eye strain at night.
- As a user, I want to update my personal info (name, username, age and country), so that my profile stays correct.
- As a user, I want to update my email and password on the settings screen, so that I can keep my account secure.

## 8. Notifications

- As a user, I want to turn notifications on or off for the whole app, so that I only get alerts when I want them.
- As a user, I want to choose which habits and which times of day (morning, afternoon, evening) I am reminded about, so that I only get reminders that are relevant to me.
- As a user, I want to send a test notification, so that I can check that reminders work on my phone.

## 9. Reports and Analytics

- As a user, I want to see how many habits I have completed today and my completion rate, so that I stay motivated.
- As a user, I want to see a list of my recent activity, so that I can look back at what I have done.
- As an admin, I want activity to be recorded consistently, so that trends can be analysed in the future.
