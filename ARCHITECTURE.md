# Architecture & Technical Decisions

This document tracks the key architectural and technical decisions made during the development of the household task management application.

## Technology Stack

- **Backend**: Ruby 3.3+ with Sinatra framework
- **Database**: SQLite3 with ActiveRecord ORM
- **Authentication**: BCrypt for secure admin passwords, session-based member selection
- **Frontend**: ERB templates with Bootstrap 5 and vanilla JavaScript
- **Testing**: RSpec with Capybara for integration tests
- **Deployment**: Designed for Raspberry Pi deployment with systemd service

## Database Design

### Core Models

1. **Admin** - System administrators with username/password authentication
2. **Member** - Household members with customizable avatars and names
3. **TaskTemplate** - Reusable task definitions with difficulty levels and categories
4. **Task** - Individual task instances assigned to members
5. **TaskCompletion** - Records of completed tasks with timestamps and notes

### Key Design Decisions

- **No "unassigned" task status**: Tasks are always assigned to a member or destroyed when unassigned
- **No "skipped" task status**: Removed to simplify workflow - tasks can be unassigned and re-picked up from templates
- **Task destruction on unassignment**: When a member unassigns themselves, the task is destroyed rather than marked as unassigned
- **Template-based workflow**: Members pick up task templates which create individual task instances

## Application Architecture

### Directory Structure

```
├── app.rb              # Main Sinatra application entry point
├── config.ru           # Rack configuration for deployment
├── db/
│   └── schema.rb       # Database schema definition (not migrations)
├── helpers/
│   ├── application_helper.rb # Core helpers (auth, flash, formatting)
│   └── data_helper.rb      # Data processing and statistics helpers
├── models/             # ActiveRecord models
├── routes/             # Sinatra route definitions (modular)
├── views/              # ERB templates organized by feature
└── spec/               # RSpec test suite
```

### Route Organization

Routes are organized into separate files by feature:
- `routes/admin.rb` - Admin-only functionality
- `routes/members.rb` - Member profile management
- `routes/tasks.rb` - Task and template management

### Authentication & Authorization

- **Admin authentication**: Username/password with BCrypt hashing
- **Member selection**: Session-based member selection (no passwords for members)
- **Role-based access**: Admins can manage everything, members can only manage their own tasks
- **Permission checks**: Centralized in route handlers with helper methods

## Key Features & Decisions

### Task Management Workflow

1. **Template Creation**: Admins create reusable task templates
2. **Task Assignment**: Members assign templates to themselves (creates individual tasks)
3. **Task Progression**: Tasks can move flexibly between statuses: todo ↔ in_progress ↔ done (including direct todo → done)
4. **Task Unassignment**: Tasks are destroyed when unassigned, can be re-picked up from templates

### Points System

- **Difficulty-based points**: Bronze (1), Silver (3), Gold (5)
- **Completion tracking**: Points awarded when tasks are marked as done
- **Leaderboard**: Real-time ranking based on points earned in configurable time periods

### UI/UX Decisions

- **Kanban board**: Visual task management with drag-and-drop columns
- **Avatar-based member selection**: Visual, family-friendly login experience
- **Responsive design**: Bootstrap 5 for mobile-friendly interface
- **Modal dialogs**: For task creation and custom task assignment

### Custom Task Feature

- **Generic Task template**: Special template that opens a modal for custom task creation
- **Custom difficulty selection**: Button-like radio inputs with medal styling
- **Category dropdown**: Predefined categories for organization

## Testing Strategy

- **Comprehensive test suite**: RSpec with feature, request, and model specs
- **Test data management**: Clean database between test runs
- **Pending complex tests**: Some UI interaction tests marked as pending for future improvement
- **Coverage reporting**: SimpleCov integration for test coverage tracking

## Deployment Considerations

- **Raspberry Pi ready**: Lightweight dependencies and SQLite database
- **Systemd service**: Production deployment configuration provided
- **Environment-based configuration**: Development vs test vs production settings
- **Port configuration**: Default port 4567 with easy customization

## Performance Optimizations

- **Minimal dependencies**: Only essential gems included
- **Efficient queries**: ActiveRecord associations and eager loading
- **Static asset optimization**: Consolidated CSS and minimal JavaScript
- **Database indexing**: Proper foreign key relationships

## Security Decisions

- **BCrypt password hashing**: Secure admin password storage
- **Session management**: Secure session handling for member selection
- **Input validation**: ActiveRecord validations and parameter sanitization
- **Permission checks**: Comprehensive authorization at route level

## Future Considerations

- **Database migrations**: Current schema-based approach may need migration system for production
- **API endpoints**: JSON API for potential mobile app integration
- **Real-time updates**: WebSocket integration for live task updates
- **Backup strategy**: Database backup and recovery procedures

## Decision Record: Database Deletion Policy

**Date:** 2025-06-22

**Decision:**
- Never delete the production database (or any other database) without explicit user confirmation.
- All destructive actions involving data loss must be confirmed by the user, regardless of environment.
- This policy is in place to protect user data and prevent accidental loss.

**Rationale:**
- Deleting a database is irreversible and can result in permanent data loss.
- User trust and data integrity are paramount.
- This policy applies to all environments: production, development, test, and any others.

**Action:**
- All future code, scripts, and assistant actions must prompt for confirmation before any destructive database operation.

## Architectural Decisions

### State Machine in Models
**Decision:** Task state transitions are managed in the Task model, not in views.

**Context:** Initially, the valid status transitions were hardcoded in the view template, which violated separation of concerns and made the logic harder to test and maintain.

**Implementation:**
- Added `valid_status_transitions` method to Task model that returns allowed transitions for current status
- Added `can_transition_to?(new_status)` method for validation
- Added `transition_to!(new_status)` method for safe state changes
- Updated view to use `task.valid_status_transitions` instead of hardcoded logic
- Added comprehensive model tests for state machine functionality

**Benefits:**
- ✅ Business logic is in the model where it belongs
- ✅ Easier to test state transitions
- ✅ Reusable across different views and API endpoints
- ✅ Clear separation of concerns
- ✅ More maintainable and extensible

### Admin Area as a Sinatra Extension Plugin

**Decision:** The "Admin" feature set has been decoupled from the main application into a self-contained Sinatra Extension, located in the `plugins/admin/` directory.

**Context:** As the application grew, the admin-specific routes, views, and logic were intertwined with the core member-facing application, making the code harder to maintain and reason about. We wanted to create a clear separation of concerns.

**Implementation:**
- A new top-level `plugins/` directory was created to house extensions.
- All admin routes, views, and specific CSS assets were moved into `plugins/admin/`.
- The plugin is loaded and registered in the main `app.rb` file (`register Household::Admin`).
- The plugin is responsible for its own concerns, including serving its own assets and registering its navigation links with the main application via a shared `@nav_links` collection.

**What is Not Decoupled (And Why):**
- **Database Migrations:** The schema migration for the `admins` table remains in the main `db/migrate` folder.
- **Data Migrations/Seeds:** The data migration to create the initial admin user is in the main `db/data` folder.
- **Tests:** All specs for the admin feature are still within the main `spec/` directory.

**Reasoning for a Partial Decoupling:** Our primary goal was to achieve a clean separation of the *runtime application logic*. While a full decoupling (including migrations and tests, as if for a distributable gem) is possible, it would add significant complexity (custom Rake tasks, test runner configurations) for little practical benefit for a single, self-contained application. The current approach provides excellent logical separation without unnecessary overhead.

### Standardized Test Execution

**Decision:** All tests must be run using the `bin/rspec` script.

**Context:** To ensure a reliable and consistent test environment, especially when dealing with database schemas, we needed to standardize the test execution process.
**Implementation:** The `bin/rspec` script was created to automatically set `RACK_ENV=test` and, most importantly, run `bundle exec rake db:prepare` before executing the `rspec` command. This guarantees that the test database is always created and migrated to the latest version before any tests are run, preventing a common source of test failures.

## Plugin Architecture

### Admin Plugin Structure
The admin functionality is encapsulated in a self-contained plugin located in `plugins/admin/`. This follows the principle of separation of concerns and allows for better maintainability.

**Structure:**
- `plugins/admin/admin.rb` - Main plugin registration and routes
- `plugins/admin/helpers.rb` - Admin-specific helper methods
- `plugins/admin/views/` - Admin-specific ERB templates
- `plugins/admin/public/` - Admin-specific CSS assets

**Helper Methods:**
Admin helper methods (`admin_logged_in?`, `current_admin`, `require_admin_login`) are defined in their own module (`Household::Admin::Helpers`) and included via `app.helpers Household::Admin::Helpers`. This keeps admin functionality completely isolated from the main application.

### Navigation Registry System
The main application initializes an `@nav_links` array on each request. Plugins can programmatically add their navigation links to this collection. The main header simply renders the links provided in the registry.

**Trade-offs:**
- ✅ Clean separation between main app and plugins
- ✅ Plugins can add navigation without modifying main app
- ❌ Slightly more complex than direct navigation in views
- ❌ Migrations and tests remain coupled to main app (avoiding over-engineering)

## Route Loading Strategy

### Single App Class with Route Files
All routes are defined within a single `App` class. Route files are loaded within the App class context and contain only route definitions, not class definitions.

**Structure:**
- `app.rb` - Main App class definition
- `routes/` - Route definitions loaded into App class
- `plugins/` - Self-contained plugins registered with App

**Benefits:**
- Consistent routing context
- Shared helpers and configuration
- Clean separation of concerns
- Easy to understand and maintain

---
