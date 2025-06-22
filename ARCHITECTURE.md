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
3. **Task Progression**: Tasks move through statuses: todo → in_progress → done
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

---
