# Household Task Management App

A Sinatra-based web application for managing household chores and tasks among members.

## Core Concepts

- **Members**: Represents individuals in the household.
- **Task Templates**: Reusable templates for common chores (e.g., "Empty dishwasher").
- **Tasks**: Instances of a `TaskTemplate` assigned to a specific `Member`. Custom, one-off tasks can also be created.
- **Task Completions**: Records when a `Member` completes a `Task`, awarding points based on difficulty.
- **Leaderboard**: A ranked list of members based on points earned over a specific period.

## Admin Features

### Improved User Experience

All admin actions now provide a seamless user experience by redirecting back to the page you came from:
- **Smart Redirection**: After any admin action (create, update, delete), you'll be returned to the page you were working on
- **Fallback Protection**: If the referring page is unavailable, you'll be redirected to the appropriate default admin page
- **Consistent Behavior**: This works across all admin areas: members, templates, categories, settings, and task management

### Template Management for Custom Tasks

Admins have two powerful options for managing custom tasks:

1. **Assign Template**: Link an existing template to a custom task
   - Changes the task's name to match the template
   - Preserves all custom values (difficulty, category, description)
   - Makes the task no longer custom (linked to template)
   - Available in both admin dashboard and custom tasks page

2. **Convert to Template**: Create a new template from a custom task
   - Creates a new reusable template available to all members
   - Links the original task to the new template
   - Allows editing of template properties before creation
   - Available in both admin dashboard and custom tasks page

Both actions include modal dialogs for review and confirmation before committing changes.

## Member Dashboard Features

- **Sidebar with Date Filter & Available Tasks**: The left sidebar contains a collapsible date filter (with presets like Today, This Week, Custom Range, etc.) and a collapsible list of available task templates. The sidebar is narrower for a modern look. The filter auto-submits on change, and custom ranges require both a start and end date. Only custom range params are included in the URL when selected.
- **Task Templates Ordering**: Task templates are shown alphabetically by title, with the generic task always at the bottom.
- **Kanban Board**: The main area displays your tasks in a kanban board, grouped by status (To Do, In Progress, Done). The date filter controls which tasks are shown. Empty columns are always shown for clarity.
- **Collapsible Boxes**: Both the filter and available tasks boxes are collapsible, with chevron toggles and consistent icon styling.
- **Responsive & Accessible**: The layout is fully responsive and uses accessible markup and icons.

## Avatar Style Configuration

Admins can control which DiceBear avatar styles are available for members to select. This is managed in the Admin Settings page:
- Enable or disable any style with a simple toggle.
- Styles currently in use by members are locked and cannot be disabled.
- The avatar selector only shows enabled styles (plus the member's current style if it is disabled).

## Architecture

This application follows a modern, modular Sinatra architecture. Key features are encapsulated into self-contained **Plugins** located in the `plugins/` directory.

- **Admin Area**: The admin interface is fully integrated into the main app, with all routes, views, and assets in the core codebase.

For more detailed information, see [ARCHITECTURE.md](ARCHITECTURE.md).

## Getting Started

### Prerequisites

- Ruby (see `.ruby-version` for details)
- Bundler

### Installation

1.  Clone the repository.
2.  Install dependencies:
    ```sh
    bundle install
    ```

### Database Setup

The application uses `sinatra-activerecord` and Rake tasks to manage the database schema and data migrations.

1.  **Create the database:** This will create the database defined in `config/database.yml` for the current `RACK_ENV`.
    ```sh
    bundle exec rake db:create
    ```
2.  **Run Schema Migrations:** This will create all the necessary tables.
    ```sh
    bundle exec rake db:migrate
    ```
3.  **Run Data Migrations:** This will run any pending data migrations, such as creating the initial admin user.
    ```sh
    bundle exec rake db:data:migrate
    ```
4.  **(Optional) Seed the database:** To populate the application with sample data (members, task templates, etc.), run the seed task.
    ```sh
    bundle exec rake db:seed
    ```

### Running the Application

To run the application locally, use the Puma rack server:

```sh
bundle exec puma
```

The application will be available at `http://localhost:9292`.

### Running Tests

To run the test suite, use the provided script. This is the required method as it ensures the test database is correctly prepared before the tests run.

```sh
bin/rspec
```

To run a single test file:

```sh
bin/rspec spec/features/your_spec_file.rb
```

## How to Contribute

1.  Fork the repository.
2.  Create your feature branch (`git checkout -b my-new-feature`).
3.  Commit your changes (`git commit -am 'Add some feature'`).
4.  Push to the branch (`git push origin my-new-feature`).
5.  Create a new Pull Request.

## License

This project is open source and available under the [MIT License](LICENSE).

---

**Built with ❤️ for happy households everywhere!**
