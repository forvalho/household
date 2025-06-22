# Household

A simple web application for managing household tasks and activities. Built with Ruby, Sinatra, and SQLite.

## Features

- **Task Template System**: Reusable task templates that members can assign to themselves
- **Admin Dashboard**: Create and manage task templates, view member statistics, and generate reports
- **Member Dashboard**: View available task templates and manage assigned tasks with a simple interface
- **Task Management**: Create templates, assign tasks, and track task completion
- **Tasks Board**: A Kanban board for members to see their tasks categorized by status (To Do, In Progress, Done)
- **Points System**: Tasks earn points based on difficulty (Bronze=1, Silver=3, Gold=5)
- **Member Profiles**: Customizable avatars and names
- **Interactive Leaderboard**: Click any member row to view their task board

## Core Features

- **Profile-Based Login**: A visual, avatar-based login screen for family members
- **Role-Based Access**:
    - **Members**: Can view their dashboard, assign task templates to themselves, and complete assigned tasks
    - **Admins**: Can manage members, task templates, admins, and view reports
- **Task Template System**:
    - Reusable task templates available to all members
    - Members can assign templates to themselves (creates individual tasks)
    - Templates remain available for other members to use
    - Includes a "Generic Task" template for custom chores
- **Customizable Avatars**: Users can personalize their avatars using the DiceBear API, choosing from dozens of styles and custom background colors
- **Tasks Board**: A Kanban board for members to see their tasks categorized by status (To Do, In Progress, Done)
- **Admin Dashboard**: A central place for admins to oversee all tasks and manage task templates with a modern sidebar layout
- **Interactive Leaderboard**: Click any member row to navigate directly to their task board
- **RSpec Test Suite**: A solid testing foundation to ensure application stability

## Technology Stack

- **Backend**: Ruby 3.3+ with Sinatra
- **Database**: SQLite3
- **Authentication**: `bcrypt` for secure admin passwords
- **Frontend**: ERB (Embedded Ruby) with Bootstrap 5 and vanilla JavaScript
- **Testing**: RSpec, Capybara, and SimpleCov for test coverage

## Getting Started

### Prerequisites

- Ruby (version 3.3.0 or newer is recommended)
- Bundler (`gem install bundler`)

### Installation & Setup

1.  **Clone the repository:**
    ```bash
    git clone <repository-url>
    cd household
    ```

2.  **Install dependencies:**
    ```bash
    bundle install
    ```

3.  **Run the application:**
    This command will also create the database and run the initial seed data.
    ```bash
    bundle exec ruby app.rb
    ```

4.  **Access the application:**
    - **Member Login**: Open your browser to `http://localhost:4567`
    - **Admin Login**: Navigate to `http://localhost:4567/admin/login`

### Default Credentials

-   **Username**: `admin`
-   **Password**: `admin123`

### Running Tests

To run the RSpec test suite and generate a coverage report:

```bash
bundle exec rspec
```
Coverage reports are generated in the `coverage/` directory.

**Current Status**: The test suite is stable with comprehensive coverage of all core functionality.

## Project Structure

The application follows a modular structure for better organization and maintainability:

```
├── app.rb              # Main Sinatra application file, loads all components
├── config.ru           # Rackup file for deployment
├── Gemfile             # Ruby gem dependencies
├── README.md           # You are here!
├── db/
│   └── schema.rb       # Database schema definition
├── helpers/
│   ├── application_helper.rb # Core helpers (auth, flash messages)
│   └── data_helper.rb      # Data and statistics helpers
├── models/             # ActiveRecord models
│   ├── admin.rb
│   ├── member.rb
│   ├── task.rb
│   ├── task_template.rb
│   └── task_completion.rb
├── routes/             # Sinatra route definitions
│   ├── admin.rb
│   ├── members.rb
│   └── tasks.rb
├── spec/               # RSpec tests
│   ├── features/
│   ├── models/
│   └── requests/
├── public/
│   └── styles.css      # Consolidated CSS styles
└── views/              # ERB templates
    ├── admin/          # Views for the admin section (with sidebar layout)
    ├── common/         # Shared partials (avatar_selector, task_card)
    ├── member/         # Views for the member section
    └── layout.erb      # Main application layout
```

## Features

### 🎯 Task Template System
- **Reusable Templates**: Create task templates that all members can access
- **Self-Assignment**: Members can assign templates to themselves with one click
- **Multiple Assignments**: Multiple members can work on the same type of task simultaneously
- **Template Management**: Admins can create, edit, and delete task templates
- **Generic Tasks**: Bronze-level "Generic Task" template for custom chores

### 🎯 Tasks Board Interface
- **Modern UI**: Clean, responsive design with Bootstrap 5.
- **Kanban Board**: A drag-and-drop interface for managing tasks, with columns for To Do, In Progress, and Done.
- **Template Cards**: Consistent design with regular task cards for seamless UX
- **Equal-Height Columns**: All columns on the board dynamically adjust to the same height for a clean, symmetrical layout.
- **Visual Task Management**: Color-coded difficulty levels and user assignments.
- **Compact Cards**: Optimized task cards for better information density.

### 👥 User Management
- **Role-based Access**: Admin and regular user roles.
- **Family Profiles**: Add household members with customizable avatars
- **Secure Authentication**: BCrypt password hashing
- **Modern Admin Interface**: Sidebar navigation for better organization

### 📊 Comprehensive Reporting
- **Points System**: Tasks earn points based on difficulty (Bronze=1, Silver=3, Gold=5)
- **Performance Tracking**: Completion rates and progress monitoring
- **Interactive Leaderboard**: Click any member row to view their task board
- **Visual Charts**: Interactive charts showing points distribution and completion rates

### 🎁 Reward System
- **Quantifiable Progress**: Track points earned over time periods
- **Smart Suggestions**: Age-appropriate reward recommendations
- **Performance Levels**: Excellent, Good, Needs Improvement, Poor ratings

## Performance Benefits

✅ **Lightweight**: Minimal dependencies, fast startup
✅ **Low Memory**: SQLite database, efficient queries
✅ **Responsive**: Works on tablets, phones, and old computers
✅ **Offline Capable**: No external API dependencies
✅ **Optimized CSS**: Consolidated styles for faster loading

## Deployment on Raspberry Pi

### Option 1: Direct Ruby Execution
```bash
# Install Ruby on Raspberry Pi
sudo apt update
sudo apt install ruby ruby-bundler sqlite3

# Navigate to app directory
cd /path/to/household

# Install gems
bundle install

# Run the app
bundle exec ruby app.rb
```

### Option 2: Production with Puma
```bash
# Install gems including puma
bundle install

# Run with puma server
bundle exec puma -p 4567
```

### Option 3: Systemd Service (Recommended)
1. Create service file:
   ```bash
   sudo nano /etc/systemd/system/household.service
   ```

2. Add content:
   ```ini
   [Unit]
   Description=Household App
   After=network.target

   [Service]
   Type=simple
   User=pi
   WorkingDirectory=/home/pi/household
   ExecStart=/usr/bin/bundle exec puma -p 4567
   Restart=always
   RestartSec=10

   [Install]
   WantedBy=multi-user.target
   ```

3. Enable and start the service:
   ```bash
   sudo systemctl enable household
   sudo systemctl start household
   ```

## Development

### Database Migrations

The application uses a simple schema file approach. To modify the database structure:

1. Edit `db/schema.rb`
2. Delete the existing database file (`db/test.sqlite3`)
3. Restart the application to recreate the database

### Adding New Features

1. **Models**: Add new ActiveRecord models in the `models/` directory
2. **Routes**: Add new routes in the appropriate file in `routes/`
3. **Views**: Add new ERB templates in the `views/` directory
4. **Tests**: Add corresponding RSpec tests in the `spec/` directory

### Code Style

- Follow Ruby conventions
- Use meaningful variable and method names
- Add comments for complex logic
- Write tests for new functionality

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

## License

This project is open source and available under the [MIT License](LICENSE).

---

**Built with ❤️ for happy households everywhere!**
