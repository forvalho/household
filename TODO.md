# TODO - Future Features & Improvements

This document tracks planned features and improvements for the household task management application.

## High Priority Features

### 🎯 Automated Task Assignment System
**Status**: Planned
**Priority**: High

Create a system that automatically assigns tasks to members based on specific rules:

- **Weekday-based assignments**: Different tasks for different days of the week
- **Rotation system**: Automatically rotate tasks between members
- **Load balancing**: Ensure fair distribution of tasks across members
- **Custom rules engine**: Allow admins to define assignment rules
- **Recurring tasks**: Automatically recreate tasks on a schedule

**Technical considerations**:
- New model for assignment rules
- Background job system for automatic assignment
- Rule evaluation engine
- Conflict resolution for overlapping rules

### 📅 Google Calendar Integration
**Status**: Planned
**Priority**: High

Sync with Google Calendar to track when children are at different houses:

- **Calendar sync**: Connect to Google Calendar API
- **House tracking**: Know when kids are at dad's vs mom's house
- **Availability-based assignments**: Only assign tasks when kids are present
- **Schedule awareness**: Adjust task assignments based on calendar events
- **Custody schedule**: Automatically handle shared custody arrangements

**Technical considerations**:
- Google Calendar API integration
- OAuth2 authentication
- Calendar event parsing
- Timezone handling
- Privacy considerations for calendar data

### 🎯 Minimum Point Quotas
**Status**: Planned
**Priority**: Medium

Implement daily and weekly minimum point requirements per member:

- **Daily quotas**: Minimum points required per day
- **Weekly quotas**: Minimum points required per week
- **Quota tracking**: Visual indicators of progress toward quotas
- **Quota notifications**: Reminders when quotas aren't met
- **Flexible quotas**: Different quotas for different members/ages
- **Quota history**: Track quota completion over time

**Technical considerations**:
- New model for quota definitions
- Quota calculation logic
- Notification system
- Progress tracking and reporting

### 🔔 Calendar-Based Reminders
**Status**: Planned
**Priority**: Medium

Calendar integration for extracurricular activities and reminders:

- **Activity reminders**: Notifications for sports, music lessons, etc.
- **Task scheduling**: Schedule tasks around activities
- **Preparation tasks**: Pre-activity tasks (pack bags, get equipment)
- **Post-activity tasks**: Cleanup and follow-up tasks
- **Integration**: Connect with existing calendar system

**Technical considerations**:
- Calendar event parsing
- Reminder notification system
- Task scheduling logic
- Integration with existing calendar features

### ✅ Task Approval System
**Status**: Planned
**Priority**: High

Implement a comprehensive task approval system:

- **Admin approval required**: Tasks require admin approval before completion
- **Auto-approval**: Tasks auto-approve after configurable time (default 24h)
- **Approval/rejection workflow**: Admins can approve or reject completed tasks
- **Custom task approval**: Special approval process for custom tasks
- **Approval history**: Track all approval decisions and reasons
- **Notification system**: Alert admins when approval is needed

**Technical considerations**:
- New model for task approvals
- Approval workflow state machine
- Auto-approval background job
- Admin notification system
- Approval audit trail

### 🎮 RPG Level System
**Status**: Planned
**Priority**: Medium

Implement a role-playing game style leveling system:

- **Member levels**: Each member has a level (1, 2, 3, etc.)
- **XP from tasks**: Points earned from tasks convert to experience points
- **Level progression algorithm**: TBD algorithm for level advancement
- **Level-based rewards**: Unlock features or bonuses at higher levels
- **Level display**: Show current level and XP progress
- **Level history**: Track level progression over time

**Technical considerations**:
- New model for member levels and XP
- Level calculation algorithm
- XP-to-level conversion logic
- Level-based feature gating
- Progress visualization

### 🏗️ Plugin Architecture
**Status**: Planned
**Priority**: High

Create a modular, plugin-based architecture for extensibility:

- **Plugin system**: Allow third-party integrations as plugins
- **Admin area plugin**: Modular admin interface components
- **Calendar integration plugin**: Extensible calendar system
- **Monzo integration plugin**: Financial integration capabilities
- **Plugin marketplace**: Repository of available plugins
- **Plugin management**: Install, configure, and manage plugins

**Technical considerations**:
- Plugin framework design
- Plugin API and interfaces
- Plugin configuration system
- Plugin lifecycle management
- Security considerations for plugins

## Medium Priority Features

### 💰 Monzo Integration
**Status**: Planned
**Priority**: Medium

Integrate with Monzo for automatic allowance management:

- **Performance-based allowance**: Adjust allowance based on task completion
- **Automatic transfers**: Send allowance based on performance metrics
- **Allowance rules**: Configurable rules for allowance calculation
- **Financial tracking**: Track allowance history and performance correlation
- **Parental controls**: Admin oversight of financial transactions

**Technical considerations**:
- Monzo API integration
- OAuth2 authentication
- Financial transaction handling
- Performance-to-allowance algorithm
- Security for financial data

### 🎯 Custom Task Management
**Status**: Planned
**Priority**: Medium

Enhanced custom task functionality:

- **Template from custom task**: Convert custom tasks to reusable templates
- **Custom task approval**: Special approval workflow for custom tasks
- **Custom task history**: Track all custom tasks created
- **Template suggestions**: Suggest templates based on custom task patterns
- **Custom task analytics**: Analyze custom task usage and effectiveness

**Technical considerations**:
- Template creation from custom tasks
- Custom task approval workflow
- Template suggestion algorithm
- Custom task analytics
- Template versioning

### 🏆 Bonus/Penalty System
**Status**: Planned
**Priority**: Medium

Admin-controlled bonus and penalty system:

- **Bonus points**: Admins can award bonus points for exceptional work
- **Penalty points**: Admins can apply penalties for poor performance
- **Bonus/penalty reasons**: Track reasons for bonuses and penalties
- **Bonus/penalty history**: Complete audit trail of all adjustments
- **Notification system**: Notify members of bonuses/penalties
- **Performance impact**: Bonuses/penalties affect overall performance metrics

**Technical considerations**:
- New model for bonuses/penalties
- Admin interface for awarding adjustments
- Notification system integration
- Performance calculation updates
- Audit trail system

### ⚙️ Dynamic Difficulty System
**Status**: Planned
**Priority**: Medium

Flexible difficulty management system:

- **CRUD difficulties**: Create, read, update, delete difficulty levels
- **Custom difficulties**: Add new difficulty levels beyond bronze/silver/gold
- **Difficulty points**: Configurable points for each difficulty level
- **Difficulty progression**: Suggest difficulty progression for members
- **Difficulty analytics**: Track performance by difficulty level

**Technical considerations**:
- Dynamic difficulty model
- Difficulty configuration interface
- Points calculation updates
- Difficulty suggestion algorithm
- Performance analytics by difficulty

### 📱 Mobile App
**Status**: Future
**Priority**: Medium

Native mobile application for easier task management:

- **iOS/Android apps**: Native mobile applications
- **Offline support**: Work without internet connection
- **Push notifications**: Real-time task reminders
- **Quick actions**: Swipe to complete tasks
- **Photo evidence**: Take photos of completed tasks

### 🔄 Task Recurrence
**Status**: Future
**Priority**: Medium

Advanced recurring task system:

- **Flexible recurrence**: Daily, weekly, monthly, custom patterns
- **Skip days**: Handle holidays and special days
- **Recurrence rules**: Complex patterns (every 2nd Tuesday, etc.)
- **Recurrence history**: Track completion of recurring tasks
- **Auto-assignment**: Automatically assign recurring tasks

## Low Priority Features

### 📊 Advanced Analytics
**Status**: Future
**Priority**: Low

Enhanced reporting and analytics:

- **Trend analysis**: Track performance over time
- **Predictive insights**: Suggest optimal task assignments
- **Performance comparisons**: Compare periods and members
- **Export functionality**: Export reports to PDF/Excel
- **Custom dashboards**: Personalized views for different users

### 🎨 Enhanced UI/UX
**Status**: Future
**Priority**: Low

User interface improvements:

- **Dark mode**: Alternative color scheme
- **Custom themes**: Personalized appearance
- **Drag and drop**: Enhanced Kanban board interactions
- **Keyboard shortcuts**: Power user features
- **Accessibility**: Screen reader support and keyboard navigation

### 🤖 AI-Powered Features
**Status**: Future
**Priority**: Low

Artificial intelligence enhancements:

- **Smart task suggestions**: AI suggests optimal task assignments
- **Difficulty adjustment**: Automatically adjust task difficulty based on performance
- **Predictive scheduling**: Suggest best times for tasks
- **Natural language processing**: Allow voice input for task creation

### 🔗 Third-Party Integrations
**Status**: Future
**Priority**: Low

Integration with external services:

- **Slack/Discord**: Task notifications in chat platforms
- **Smart home**: Integration with smart home devices
- **Chore apps**: Sync with existing chore management apps
- **School systems**: Integration with school assignment systems

### 📈 Gamification Enhancements
**Status**: Future
**Priority**: Low

Additional gamification features:

- **Achievement badges**: Unlockable achievements for milestones
- **Streaks**: Track consecutive days of task completion
- **Challenges**: Time-limited challenges with bonus points
- **Leaderboards**: More detailed ranking systems
- **Reward system**: Integration with actual rewards/allowance

## Technical Debt & Improvements

### 🔧 Code Quality
- **API versioning**: Prepare for future API changes
- **Database migrations**: Implement proper migration system
- **Error handling**: Improve error handling and user feedback
- **Performance optimization**: Optimize database queries and page load times
- **Security audit**: Comprehensive security review

### 🧪 Testing
- **Integration tests**: More comprehensive integration test coverage
- **Performance tests**: Load testing for concurrent users
- **Security tests**: Automated security testing
- **Mobile testing**: Test mobile browser compatibility
- **Accessibility testing**: Ensure accessibility compliance

### 📚 Documentation
- **API documentation**: Comprehensive API documentation
- **User guides**: Detailed user documentation
- **Developer guides**: Onboarding documentation for contributors
- **Deployment guides**: Production deployment documentation
- **Troubleshooting**: Common issues and solutions

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
- **Plugin architecture**: The plugin system will enable rapid feature development
- **Approval workflow**: Task approval system will add quality control to task completion
- **RPG elements**: Level system will increase engagement and motivation

## Features
- [ ] Member-specific task ordering/pinning
- [ ] Task comments or notes section
- [ ] User-facing notifications (e.g., "You have a new task")
- [ ] "Vacation mode" for members to pause task assignments

## Architecture & Refactoring
- [ ] **(Future)** Fully decouple plugin migrations. Investigate creating custom Rake tasks to allow plugins to manage their own schema and data migrations from within their own directory (`plugins/admin/db/migrate`).
- [ ] **(Future)** Fully decouple plugin tests. Configure RSpec to discover and run tests from within each plugin's directory (`plugins/admin/spec/`) in addition to the main `spec/` folder.
- [ ] **(Future)** Fully decouple plugin seeding. Create a mechanism for plugins to register their own seed tasks that can be called by the main `db:seed` Rake task.
- [ ] Evaluate replacing the custom data migration system with a more robust, existing gem if the need arises.

## User's New Feature and Improvement List

### 🛠️ Core Improvements & Refactors
**Status**: Planned
**Priority**: High

#### Admin System Overhaul
- Replace the current admin model with member-based admin privileges:
  - Members can have optional PINs or passwords.
  - Admin privileges are granted to members (no separate admin model).
  - A default admin member is created in each environment with a default PIN/password (e.g., 0000 or "password").
  - Admin login becomes a simplified landing page showing only admin members, where PIN/password is required for access.
  - Admin login state is isolated: admin members are logged out when leaving the admin area to prevent accidental misuse.
- Redesign the admin area for improved usability and appearance.
- Replace all admin functionality to work with the new member-admin model.

#### Member Management
- Add the ability to pause/unpause members or set them as active/away:
  - Inactive/away time is not counted toward performance or leaderboard.
  - XP/points can be adjusted based on activity percentage (e.g., double XP for 50% activity).
- Optionally allow non-admins to create member profiles (feature flag, already implemented).
- Add optional PIN/password to member profiles for secure access.

#### Task & Board Enhancements
- Allow setting a completion percentage when completing a task (e.g., "folded half the laundry").
- Order task templates alphabetically in member boards, with the generic task always at the bottom.
- Group task templates by category in member boards:
  - Display one entry per category, expandable to show templates within.
  - Simplify task template cards to show less information; clicking a card assigns the task to the member.
  - Admins should still be able to assign tasks to others easily from this view.

#### Testing & Quality
- Fix all pending and skipped tests to ensure full test coverage and reliability.

### 📝 Project Tooling
**Status**: Planned
**Priority**: Medium

#### Cursor AI Rules
- Create and document Cursor rules for this project to guide AI assistance and code reviews.

---
