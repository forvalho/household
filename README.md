# Household Chores Kanban Board

A simple, efficient household chore management application built with Ruby and Sinatra, designed to run on low-spec hardware like Raspberry Pi 2.

## Features

### 🎯 Kanban Board Interface
- **Drag & Drop**: Move tasks between columns (To Do → In Progress → Done/Skipped)
- **Visual Task Management**: Color-coded difficulty levels and user assignments
- **Real-time Updates**: AJAX-powered status changes without page reloads

### 👥 User Management
- **Role-based Access**: Admin and regular user roles
- **Family Profiles**: Add household members with ages and preferences
- **Secure Authentication**: BCrypt password hashing

### 📊 Comprehensive Reporting
- **Points System**: Tasks earn points based on difficulty (Easy=1, Medium=2, Hard=3)
- **Performance Tracking**: Completion rates, skip tracking, and progress monitoring
- **Reward Suggestions**: Automated recommendations based on performance
- **Visual Charts**: Interactive charts showing points distribution and completion rates

### 🎁 Reward System
- **Quantifiable Progress**: Track points earned over time periods
- **Smart Suggestions**: Age-appropriate reward recommendations
- **Performance Levels**: Excellent, Good, Needs Improvement, Poor ratings

## Technology Stack

- **Backend**: Ruby 2.7+ with Sinatra framework
- **Database**: SQLite (perfect for embedded systems)
- **Frontend**: Bootstrap 5 + Vanilla JavaScript
- **Charts**: Chart.js for data visualization
- **Drag & Drop**: SortableJS for Kanban functionality

## Performance Benefits

✅ **Lightweight**: Minimal dependencies, fast startup
✅ **Low Memory**: SQLite database, efficient queries
✅ **Responsive**: Works on tablets, phones, and old computers
✅ **Offline Capable**: No external API dependencies

## Installation

### Prerequisites
- Ruby 2.7 or higher
- Bundler gem

### Setup
1. **Clone or download the application**
   ```bash
   cd household
   ```

2. **Install dependencies**
   ```bash
   bundle install
   ```

3. **Run the application**
   ```bash
   bundle exec ruby app.rb
   ```

4. **Access the application**
   - Open your browser to `http://localhost:4567`
   - Default admin login: `admin` / `admin123`

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
   sudo nano /etc/systemd/system/household-chores.service
   ```

2. Add content:
   ```ini
   [Unit]
   Description=Household Chores App
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
   sudo systemctl enable household-chores
   sudo systemctl start household-chores
   ```

## Usage Guide

### For Parents (Admins)
1. **Add Family Members**: Go to Users page and add household members
2. **Create Tasks**: Use the "Add New Task" button on the dashboard
3. **Monitor Progress**: Check the Reports page for performance metrics
4. **Assign Rewards**: Use the reward suggestions to motivate children

### For Children (Users)
1. **View Tasks**: See your assigned tasks on the Kanban board
2. **Start Tasks**: Click "Start" to move tasks to "In Progress"
3. **Complete Tasks**: Click "Complete" when finished to earn points
4. **Skip Tasks**: If needed, provide a reason when skipping

### Task Workflow
1. **To Do** → Tasks waiting to be started
2. **In Progress** → Tasks currently being worked on
3. **Done** → Completed tasks (earn points)
4. **Skipped** → Tasks that couldn't be completed (with reasons)

## Future Enhancements

### Planned Features
- 📅 **Google Calendar Integration**: Sync with family calendar
- 🏫 **School Calendar**: Consider school schedules for task assignments
- 🔄 **Recurring Tasks**: Automatically create daily/weekly chores
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
- **UI Colors**: Customize CSS in `layout.erb`

## Troubleshooting

### Common Issues
1. **Port already in use**: Change port in `app.rb` or kill existing process
2. **Database errors**: Delete `household.db` to reset (loses all data)
3. **Permission errors**: Ensure proper file permissions on Raspberry Pi

### Logs
- **Development**: Check console output
- **Production**: Check systemd logs: `sudo journalctl -u household-chores`

## Security Notes

- Change default admin password after first login
- Use HTTPS in production environments
- Regularly backup the SQLite database
- Keep Ruby and gems updated

## License

This project is open source and available under the MIT License.

---

**Built with ❤️ for happy households everywhere!**
