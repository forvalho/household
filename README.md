# Household

A simple web application for managing household tasks and activities. Built with Ruby, Sinatra, and SQLite.

## Features

- **Admin Dashboard**: Create and manage tasks, view member statistics, and generate reports
- **Member Dashboard**: View and manage assigned tasks with a simple interface
- **Task Management**: Create, assign, and track task completion
- **Tasks Board**: A simple board for members to see their tasks categorized by status (To Do, In Progress, Done)
- **Points System**: Tasks earn points based on difficulty
- **Recurring Tasks**: Support for daily and weekly recurring tasks
- **Member Profiles**: Customizable avatars and names

## Core Features

- **Profile-Based Login**: A visual, avatar-based login screen for family members
- **Role-Based Access**:
    - **Members**: Can view their dashboard and complete assigned tasks
    - **Admins**: Can manage members, tasks, admins, and view reports
- **Customizable Avatars**: Users can personalize their avatars using the DiceBear API, choosing from dozens of styles and custom background colors
- **Tasks Board**: A simple board for members to see their tasks categorized by status (To Do, In Progress, Done)
- **Admin Dashboard**: A central place for admins to oversee all tasks assigned to all members with a modern sidebar layout
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

**Current Status**: Test suite is being refined. Coverage is approximately 73% with ongoing improvements to ensure all features are properly tested.

## Project Structure

The application follows a modular structure for better organization and maintainability:

```
├── app.rb              # Main Sinatra application file, loads all components
├── config.ru           # Rackup file for deployment
├── Gemfile             # Ruby gem dependencies
├── README.md           # You are here!
├── db/
│   ├── schema.rb       # Database schema definition
│   └── seeds.rb        # Initial seed data for admins and members
├── helpers/
│   ├── application_helper.rb # Core helpers (auth, flash messages)
│   └── data_helper.rb      # Data and statistics helpers
├── models/             # ActiveRecord models
│   ├── admin.rb
│   ├── member.rb
│   └── ...
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

### 🎯 Tasks Board Interface
- **Modern UI**: Clean, responsive design with Bootstrap 5
- **Always-Visible Actions**: Assign and Move buttons are always shown, with unavailable options disabled
- **Visual Task Management**: Color-coded difficulty levels and user assignments
- **Compact Cards**: Optimized task cards for better information density

### 👥 User Management
- **Role-based Access**: Admin and regular user roles
- **Family Profiles**: Add household members with customizable avatars
- **Secure Authentication**: BCrypt password hashing
- **Modern Admin Interface**: Sidebar navigation for better organization

### 📊 Comprehensive Reporting
- **Points System**: Tasks earn points based on difficulty (Easy=1, Medium=2, Hard=3)
- **Performance Tracking**: Completion rates, skip tracking, and progress monitoring
- **Reward Suggestions**: Automated recommendations based on performance
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

3. Enable and start:
   ```bash
   sudo systemctl enable household
   sudo systemctl start household
   ```

## Usage Guide

### For Parents (Admins)
1. **Add Family Members**: Go to Members page and add household members
2. **Create Tasks**: Use the "Add New Task" button on the dashboard
3. **Monitor Progress**: Check the Reports page for performance metrics
4. **Assign Rewards**: Use the reward suggestions to motivate children

### For Children (Users)
1. **View Tasks**: See your assigned tasks on the tasks board
2. **Start Tasks**: Use "Move to..." dropdown to move tasks to "In Progress"
3. **Complete Tasks**: Use "Move to..." dropdown to mark tasks as "Done" and earn points
4. **Skip Tasks**: If needed, use "Move to..." dropdown to skip tasks

### Task Workflow
1. **Unassigned** → Tasks waiting to be assigned
2. **To Do** → Tasks waiting to be started
3. **In Progress** → Tasks currently being worked on
4. **Done** → Completed tasks (earn points)
5. **Skipped** → Tasks that couldn't be completed

## Recent Updates

### UI/UX Improvements
- **Simplified Naming**: Application name changed from "Household Chores" to "Household"
- **Modern Admin Layout**: New sidebar navigation for admin area
- **Always-Visible Actions**: Assign and Move buttons are always shown with proper disabled states
- **Consolidated CSS**: All styles moved to `public/styles.css` for better maintainability
- **Improved Task Cards**: More compact design with better information density

### Navigation Updates
- **Admin Menu**: Simplified to "Tasks", "Members", "Admins", "Reports"
- **Member Interface**: "Kanban Board" renamed to "Tasks Board"
- **Consistent Branding**: "Household" branding throughout the application

## Future Enhancements

### Planned Features
- 📅 **Google Calendar Integration**: Sync with family calendar
- 🏫 **School Calendar**: Consider school schedules for task assignments
- 🔄 **Recurring Tasks**: Automatically create daily/weekly tasks
- 📱 **Mobile App**: Native mobile application
- 🔔 **Notifications**: Reminders for due tasks
- 🎯 **Achievement Badges**: Gamification elements

### Technical Improvements
- **API Endpoints**: RESTful API for external integrations
- **Data Export**: Export reports to PDF/Excel
- **Backup System**: Automated database backups
- **Multi-language**: Internationalization support

## Configuration

### Environment Variables
Create a `.env` file for custom configuration:
```bash
# Database
DATABASE_URL=sqlite3:household.db

# Session secret
SESSION_SECRET=your-secret-key-here

# Port (optional)
PORT=4567
```

### Customization
- **Points System**: Modify point values in `app.rb` (Task model)
- **Reward Thresholds**: Adjust reward suggestions in `reports.erb`
- **UI Colors**: Customize CSS in `public/styles.css`

## Troubleshooting

### Common Issues
1. **Port already in use**: Change port in `app.rb` or kill existing process
2. **Database errors**: Delete `household.db` to reset (loses all data)
3. **Permission errors**: Ensure proper file permissions on Raspberry Pi

### Logs
- **Development**: Check console output
- **Production**: Check systemd logs: `sudo journalctl -u household`

## Security Notes

- Change default admin password after first login
- Use HTTPS in production environments
- Regularly backup the SQLite database
- Keep Ruby and gems updated

## License

This project is open source and available under the MIT License.

---

**Built with ❤️ for happy households everywhere!**
