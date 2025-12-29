# WcsStudio

WcsStudio is a comprehensive web application designed for dance education management, specifically tailored for West Coast Swing and partner dance communities. Built on the Elixir ecosystem using Phoenix LiveView, it provides a real-time, interactive platform for students to track their progress and for instructors to manage educational content.

## Available at
<https://wcsstudio.nextserwewusek.top/> hosted on my own machine
## Project Overview

This application serves as a centralized hub for dance resources, allowing users to catalog patterns, attend virtual lessons, and track their learning curve. It features a robust role-based system distinguishing between administrators (instructors) and standard users (students), ensuring content integrity while fostering community engagement through blogs and profiles.

## Key Features

## Technology Stack

*   **Backend:** Elixir, Phoenix Framework
*   **Frontend:** Phoenix LiveView, Tailwind CSS
*   **Database:** PostgreSQL, Ecto
*   **Image Processing:** Image (Libvips wrapper)
*   **HTTP Client:** Finch
*   **Email:** Swoosh

### Educational Resources
*   **Pattern Database:** A searchable library of dance patterns including detailed descriptions for leaders and followers, categorized by dance style (e.g., Latin, Swing, Social).
*   **Video Integration:** Support for embedded YouTube video demonstrations within patterns and lessons.
*   **Lesson Management:** Administrative tools to organize video lessons with specific instructors, dates, and locations.
*   **Practice Mode:** A randomized practice generator to assist students in recalling and drilling different dance patterns.

### User Progress Tracking
*   **Learning Status:** Users can track the status of specific patterns.
*   **Attendance Tracking:** System for users to mark attendance on specific lessons.
*   **Analytics:** Visual data representation displaying individual progress regarding lessons attended and patterns mastered.

### Social and Community
*   **User Profiles:** customizable profiles with avatar upload support.
*   **Blog Engine:** A fully functional blog system allowing for article publication, tagging, and user comments.

### Technical Capabilities
*   **Internationalization:** Full localization support for English and Polish languages.
*   **Image Processing:** Automatic optimization and conversion of user uploads (profiles and QR codes) to WebP format.
*   **Responsive Design:** Mobile-first interface utilizing Tailwind CSS.
*   **Role-Based Access Control:** Secure routes and feature gating for Admin vs. User roles.

## Prerequisites

To run this project locally, ensure you have the following installed:

*   **Elixir** (Version 1.14 or later)
*   **Erlang/OTP**
*   **PostgreSQL**
*   **Libvips** (Required for image processing dependencies)
    *   macOS: `brew install vips`
    *   Ubuntu/Debian: `sudo apt install libvips-dev`

## Project Structure

*   **lib/wcs_studio/accounts:** Handles user authentication, profile management, and role logic.
*   **lib/wcs_studio/blog:** Contains logic for posts and comment threads.
*   **lib/wcs_studio/dance_types:** Manages dance styles and pattern definitions.
*   **lib/wcs_studio_web/live:** Contains all LiveView modules, handling real-time UI interactions.
*   **lib/wcs_studio_web/components:** Reusable UI components (Modals, Tables, Charts).

## Author
**Karol Półchłopek**