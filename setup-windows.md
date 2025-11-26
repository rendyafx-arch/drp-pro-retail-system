# DRP Pro - Windows Installation & Setup Guide

## Overview

This guide provides step-by-step instructions for installing and configuring the DRP Pro (Djarum Retail Partner Hub System) on Windows systems. The system consists of:

- **Frontend**: Microsoft Power Apps (Low-code platform)
- **Backend**: Supabase (PostgreSQL with real-time capabilities)
- **Automation**: Power Automate (Workflow automation)
- **Database**: PostgreSQL with Row-Level Security (RLS)

## Prerequisites

Before starting the installation, ensure you have the following:

### System Requirements

- **Operating System**: Windows 10 (Build 18362) or Windows 11
- **Processor**: Intel i5 or equivalent (or higher for better performance)
- **RAM**: Minimum 8GB, Recommended 16GB
- **Disk Space**: 10GB free space for installation and data
- **Internet Connection**: Stable internet connection required
- **Administrator Rights**: Local admin access for installation

### Required Software

1. **Git for Windows**
   - Download: https://git-scm.com/download/win
   - Latest version (v2.40+)
   - Include Git Bash and Git GUI in installation

2. **Node.js (Optional - for API development)**
   - Download: https://nodejs.org/
   - Version 18.x LTS or higher
   - npm automatically included

3. **Microsoft Edge or Chrome**
   - Latest version for Power Apps compatibility
   - Required for Power Apps web access

4. **Docker Desktop (Optional - for containerized deployment)**
   - Download: https://www.docker.com/products/docker-desktop
   - Required if using docker-compose.yml
   - Includes Docker Engine and Docker Compose

5. **Text Editor (Optional but recommended)**
   - Visual Studio Code: https://code.visualstudio.com/
   - Notepad++ or similar
   - For editing configuration files

### Microsoft Accounts & Services

1. **Microsoft 365 Account**
   - Active Microsoft account with appropriate licenses
   - Power Apps licensing
   - Power Automate licensing

2. **Supabase Account**
   - Free tier available at https://supabase.com
   - Or use existing Supabase project

## Installation Steps

### Step 1: Clone the Repository

#### Method A: Using Git Bash

1. Open **Git Bash** (installed with Git for Windows)
2. Navigate to your desired installation directory:
   ```bash
   cd C:\Users\YourUsername\Documents
   ```
3. Clone the repository:
   ```bash
   git clone https://github.com/rendyafx-arch/drp-pro-retail-system.git
   cd drp-pro-retail-system
   ```
4. Verify installation:
   ```bash
   git status
   ```

#### Method B: Using install.bat (Windows Batch Script)

1. Download `install.bat` from the repository root
2. Save it to your desired installation location
3. Right-click on `install.bat`
4. Select **"Run as administrator"**
5. Follow the prompts in the installation wizard

### Step 2: Configure Environment Variables

1. Navigate to the installation directory:
   ```
   C:\path\to\drp-pro-retail-system
   ```

2. You should see `.env.example` file

3. Create a copy and rename it to `.env`:
   ```bash
   copy .env.example .env
   ```

4. Open `.env` file with your text editor (e.g., Notepad++, VS Code)

5. Configure the following sections:

#### Supabase Configuration

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
SUPABASE_SERVICE_KEY=your-service-key-here
SUPABASE_JWT_SECRET=your-jwt-secret-here
```

**How to find these values:**
- Go to https://app.supabase.com
- Select your project
- Navigate to Settings > API
- Copy the values from there

#### Power Apps Configuration

```env
POWERAPPS_TENANT_ID=your-tenant-id
POWERAPPS_CLIENT_ID=your-client-id
POWERAPPS_CLIENT_SECRET=your-client-secret
POWERAPPS_ENVIRONMENT_URL=https://your-environment.crm.dynamics.com
```

**How to find/create these values:**
1. Go to https://admin.powerplatform.microsoft.com
2. Register an application in Azure AD
3. Create a client secret
4. Note down these values

#### Database Configuration

```env
DB_HOST=your-database-host
DB_PORT=5432
DB_NAME=drp_pro
DB_USER=your-db-user
DB_PASSWORD=your-secure-password
DB_SSL=true
```

**For local development:** Use Supabase database connection details
**For production:** Use your managed PostgreSQL instance

### Step 3: Set Up Supabase Backend

1. **Create Supabase Project**:
   - Go to https://supabase.com
   - Click "New Project"
   - Enter project details
   - Wait for provisioning (2-3 minutes)

2. **Initialize Database Schema**:
   - Open SQL Editor in Supabase dashboard
   - Copy content from `database/schema.sql`
   - Paste and execute in SQL Editor
   - Verify tables are created: `profile`, `customers`, `products`, `transactions`, `loyalty_points`, `rewards`, `promotions`, `surveys`, `analytics`

3. **Enable Row-Level Security (RLS)**:
   - Navigate to Authentication > Policies
   - Verify RLS is enabled on all tables
   - Check that policies are properly configured

4. **Configure Email Provider (Optional for notifications)**:
   - Go to Settings > Email
   - Configure SMTP or use Supabase built-in email
   - Test email sending

### Step 4: Deploy Power Apps Application

1. **Access Power Apps**:
   - Go to https://make.powerapps.com
   - Sign in with your Microsoft account
   - Select your environment

2. **Create New App**:
   - Click "Create" > "Canvas app"
   - Enter app name: "DRP Pro Retail System"
   - Select desired layout (Mobile or Tablet)

3. **Connect to Supabase**:
   - Add New Connection > Custom Connector > Supabase
   - Configure API authentication
   - Test connection

4. **Deploy Screens**:
   - Follow setup-guides/POWERAPPS_SETUP.md for detailed screen creation
   - Import screens from provided app templates if available

### Step 5: Configure Power Automate Workflows

1. **Access Power Automate**:
   - Go to https://make.powerautomate.com
   - Sign in with your Microsoft account

2. **Create Required Flows**:
   - Cloud flows for notifications
   - Scheduled flows for data sync
   - Follow setup-guides/POWER_AUTOMATE_SETUP.md

3. **Test Workflows**:
   - Manually trigger each flow
   - Verify email notifications
   - Check database updates

## Post-Installation Configuration

### 1. User Management

- Create user accounts in Supabase
- Assign roles (Admin, Manager, Staff)
- Configure access permissions

### 2. System Security

- Enable HTTPS for all connections
- Configure firewall rules
- Set up IP whitelisting if needed
- Enable audit logging

### 3. Data Configuration

- Add initial product data
- Configure store locations
- Set up promotional campaigns
- Initialize customer database

### 4. Testing

- Test login functionality
- Verify POS transactions
- Test reward point calculations
- Check customer data sync

## Troubleshooting

### Git Installation Issues

**Problem**: "git" command not recognized
- **Solution**: Restart command prompt/PowerShell after Git installation
- **Alternative**: Use GitHub Desktop GUI instead of command line

### Supabase Connection Issues

**Problem**: Cannot connect to Supabase
- **Solution**: Verify credentials in .env file
- Check internet connectivity
- Verify Supabase project is active
- Check firewall/VPN restrictions

### Power Apps Deployment Issues

**Problem**: Cannot create Power Apps connection
- **Solution**: Verify Power Apps license is active
- Check Microsoft account permissions
- Ensure Power Automate license is assigned

### Database Connection Issues

**Problem**: Database connection timeout
- **Solution**: Check database host and port in .env
- Verify SSL settings (set to true for cloud databases)
- Check database user permissions
- Verify password doesn't contain special characters causing escaping issues

## Uninstallation

### To Remove DRP Pro

1. Stop all running services/applications
2. Delete the installation directory:
   ```bash
   rmdir /s /q C:\path\to\drp-pro-retail-system
   ```
3. Remove environment variables from system
4. Delete database backup files if local storage was used
5. Remove Power Apps canvas app from Power Apps
6. Delete Power Automate flows

## Next Steps

1. **Read Documentation**:
   - docs/FEATURES.md - System features overview
   - docs/ARCHITECTURE.md - Technical architecture
   - docs/DATABASE.md - Database schema details
   - docs/API.md - API endpoints

2. **User Training**:
   - Train staff on using the system
   - Document business processes
   - Create user manuals

3. **Data Migration**:
   - If migrating from existing system, plan data migration
   - Test data import procedures
   - Verify data integrity

4. **Production Deployment**:
   - Set up monitoring and alerting
   - Configure backups
   - Plan rollback procedures
   - Document runbooks

## Support & Resources

- **GitHub Repository**: https://github.com/rendyafx-arch/drp-pro-retail-system
- **Supabase Documentation**: https://supabase.com/docs
- **Microsoft Power Apps Docs**: https://docs.microsoft.com/en-us/powerapps/
- **Power Automate Docs**: https://docs.microsoft.com/en-us/power-automate/

## Version History

- **v1.0** (Current) - Initial release with core features
  - Basic POS functionality
  - Loyalty program integration
  - Customer management
  - Real-time analytics

## License

This project is licensed under the MIT License. See LICENSE file for details.

---

**Last Updated**: 2024
**Maintained By**: DRP Development Team
