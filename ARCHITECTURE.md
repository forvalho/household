# Architecture

## Overview

This is a Sinatra-based web application for managing household chores and tasks among family members. The app follows a modular design with clear separation of concerns.

## Application Structure

```
household/
├── app.rb                 # Main Sinatra application
├── config.ru             # Rack configuration
├── config/
│   └── database.yml      # Database configuration
├── db/
│   ├── migrate/          # Database migrations
│   ├── data/             # Data migrations
│   ├── schema.rb         # Database schema
│   └── seeds.rb          # Seed data
├── models/               # ActiveRecord models
├── helpers/              # Application helpers
├── routes/               # Route definitions
├── views/                # ERB templates
│   ├── admin/            # Admin-specific views
│   ├── member/           # Member-specific views
│   └── common/           # Shared view components
├── public/               # Static assets
│   └── admin-assets/     # Admin-specific CSS
└── spec/                 # Test suite
```

## Key Architectural Decisions

### 1. Single App Class with Route Files

**Decision**: Use a single `App` class that loads route definitions from separate files.

**Implementation**:
- Main application logic in `app.rb`
- Route definitions in `routes/` directory
- Routes loaded using `class_eval` within the App class context

**Rationale**:
- Keeps the main app file focused on configuration and setup
- Allows for logical grouping of related routes
- Maintains Sinatra DSL context for all route definitions

### 2. Admin Integration

**Decision**: Admin functionality is integrated directly into the main application rather than as a separate plugin.

**Implementation**:
- Admin routes defined in `routes/admin.rb` using Sinatra DSL
- Admin views located in `views/admin/`
- Admin helpers in `helpers/admin_helper.rb`
- Admin assets in `public/admin-assets/`

**Rationale**:
- Simplifies deployment and maintenance
- Reduces complexity compared to plugin architecture
- Maintains clear separation through directory structure

### 3. State Machine in Models

**Decision**: Task state transitions are managed in the Task model, not in views.

**Implementation**: Task model contains methods for status transitions with proper validation.

**Rationale**: Ensures data consistency and makes state changes testable.

### 4. Route Loading Strategy

**Decision**: Load all route files within the App class context using `class_eval`.

**Implementation**:
```ruby
# In app.rb
Dir[File.join(__dir__, 'routes', '**', '*.rb')].sort.each do |file|
  class_eval(File.read(file), file)
end
```

**Rationale**: Ensures all Sinatra DSL methods (routes, helpers, before filters) are executed within the proper class context.

## Database Design

### Core Tables

- **members**: Family members who can be assigned tasks
- **admins**: Administrative users with full access
- **tasks**: Individual task instances assigned to members
- **task_templates**: Reusable task definitions
- **task_completions**: Records of completed tasks with timestamps
- **categories**: Task categories for organization
- **settings**: Application configuration

### Key Relationships

- Tasks belong to members and optionally to task templates
- Task templates belong to categories
- Task completions link tasks to members with completion metadata

## Authentication & Authorization

### Admin Authentication
- Session-based authentication using BCrypt
- Admin routes protected by `require_admin_login` helper
- Admin-specific views and functionality

### Member Selection
- Simple member selection via session
- No password required for family members
- Member-specific dashboard and task management

## Frontend Architecture

### CSS Framework
- Bootstrap for responsive layout and components
- FontAwesome for icons
- Custom CSS for application-specific styling

### JavaScript
- Minimal JavaScript for enhanced UX
- Bootstrap modals for task creation and date filtering
- AJAX for task status updates

## Testing Strategy

### Test Organization
- **Feature tests**: End-to-end user workflows
- **Request tests**: API endpoint testing
- **Model tests**: Business logic validation
- **Helper tests**: Utility function testing

### Test Database
- Separate test database with automatic setup/teardown
- Use `bin/rspec` script for proper test environment

## Deployment

### Production Ready
- SQLite database for simplicity
- Lightweight dependencies
- Raspberry Pi compatible
- Static asset serving optimized

### Configuration
- Environment-based configuration
- Database settings in `config/database.yml`
- Application settings stored in database

## Security Considerations

- BCrypt password hashing for admins
- Input validation on all forms
- SQL injection prevention via ActiveRecord
- XSS prevention through proper escaping
- CSRF protection via Sinatra's built-in mechanisms

## Performance Optimizations

- Database query optimization with includes/joins
- Efficient task grouping and filtering
- Minimal external dependencies
- Optimized asset delivery

## Future Considerations

- Potential for API endpoints
- Mobile app integration
- Real-time notifications
- Advanced reporting and analytics

## Avatar Style Management

- Enabled avatar styles are stored as a JSON array in the `settings` table (key: `enabled_avatar_styles`).
- The admin UI (Settings page) allows toggling which DiceBear styles are available.
- Styles currently in use by any member are locked and cannot be disabled (UI and backend enforced).
- The avatar selector only shows enabled styles, but always includes the member's current style (even if disabled, marked as such).
