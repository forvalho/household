# TODO

## Completed ✅

- [x] Fix categories not displaying in production
- [x] Group task templates by category in member dashboard
- [x] Remove card/box wrappers from sidebar
- [x] Display template counts in grey instead of red
- [x] Implement custom date range filter as modal
- [x] Remove per-day grouping from Kanban board
- [x] Reintegrate admin plugin back into main app
- [x] Member profile pictures/avatars (with admin-configurable DiceBear styles)

## High Priority 🎯

### Core System Improvements
- [ ] Admin system overhaul (member-based admin privileges with PINs)
- [ ] Task completion notes/feedback system
- [ ] Task approval system with auto-approval
- [ ] Member pause/unpause functionality (active/away status)
- [ ] Task completion percentage tracking
- [ ] Fix all pending and skipped tests

### Task Management
- [ ] Task due dates and reminders
- [ ] Task comments or notes section
- [ ] Task completion history view
- [ ] Member-specific task ordering/pinning
- [ ] "Vacation mode" for members to pause task assignments

### Integration & Automation
- [ ] Google Calendar integration (custody tracking, availability-based assignments)
- [ ] Automated task assignment system (weekday-based, rotation, load balancing)
- [ ] Calendar-based reminders for extracurricular activities
- [ ] User-facing notifications system

### Gamification
- [ ] RPG level system (XP, levels, rewards)
- [ ] Task difficulty-based point system
- [ ] Minimum point quotas (daily/weekly requirements)
- [ ] Bonus/penalty system (admin-controlled adjustments)

## Medium Priority 📋

### Enhanced Features
- [ ] Monzo integration (performance-based allowance)
- [ ] Custom task management improvements
- [ ] Dynamic difficulty system (CRUD difficulties, custom points)
- [ ] Task recurrence system (flexible patterns, skip days)
- [ ] Task search and filtering
- [ ] Task assignment notifications

### Member Management
- [ ] Optional PIN/password for member profiles
- [ ] Member activity tracking and analytics

### UI/UX Improvements
- [ ] Category visual customization (icons and colors)
- [ ] Admin area redesign for improved usability
- [ ] Mobile-responsive design improvements
- [ ] Task template UI/UX enhancements

### Technical Infrastructure
- [ ] Plugin architecture system
- [ ] API versioning
- [ ] Database migration system improvements
- [ ] Performance optimization (queries, page load times)

## Low Priority 🚀

### Advanced Features
- [ ] Mobile app (iOS/Android with offline support)
- [ ] Advanced analytics and reporting
- [ ] AI-powered features (smart suggestions, predictive scheduling)
- [ ] Third-party integrations (Slack, smart home, school systems)
- [ ] Dark mode theme

### Gamification Enhancements
- [ ] Achievement badges and streaks
- [ ] Time-limited challenges
- [ ] Task completion celebrations/animations
- [ ] Task completion sharing on social media
- [ ] Enhanced leaderboards and statistics

### Quality & Documentation
- [ ] Accessibility testing and compliance
- [ ] Comprehensive error handling
- [ ] Proper logging system
- [ ] API rate limiting
- [ ] Security audit
- [ ] API documentation
- [ ] User and developer guides

## Technical Debt 🔧

### Testing & Quality
- [ ] Integration test coverage improvements
- [ ] Performance and load testing
- [ ] Security testing automation
- [ ] Mobile browser compatibility testing
- [ ] Test coverage for edge cases

### Architecture & Infrastructure
- [ ] Evaluate robust data migration gem replacement
- [ ] Plugin system decoupling (migrations, tests, seeding)
- [ ] Error handling and user feedback improvements
- [ ] Deployment and troubleshooting documentation

## Environment Configuration

### Required Environment Variables
- `AUTO_APPROVAL_HOURS`: Time in hours before tasks auto-approve (default: 24)
- `GOOGLE_CALENDAR_CLIENT_ID`: Google Calendar API client ID
- `GOOGLE_CALENDAR_CLIENT_SECRET`: Google Calendar API client secret
- `MONZO_CLIENT_ID`: Monzo API client ID
- `MONZO_CLIENT_SECRET`: Monzo API client secret
- `PLUGIN_DIRECTORY`: Directory for plugin storage
- `NOTIFICATION_EMAIL`: Admin notification email address

## Notes

- **Priority levels**: High (next 3 months), Medium (3-6 months), Low (6+ months)
- **Dependencies**: Some features depend on others (e.g., mobile app needs API)
- **User feedback**: Priorities may change based on user feedback and usage patterns
- **Technical constraints**: Some features may require additional infrastructure or services

## High Priority 🎯
- [ ] **Accessibility audit and improvement:**
    - Perform a full accessibility sweep using a standard tool (e.g., Lighthouse, axe-core).
    - Set a compliance goal (e.g., WCAG 2.1 AA, Lighthouse score ≥ 90).
    - Track and improve accessibility issues across the app.
