# Power Automate Setup Guide - DRP-PRO

## Overview
Power Automate enables automated workflows to trigger actions based on events, send notifications, and integrate with Supabase backend.

## Prerequisites
- Microsoft 365 account with Power Automate access
- Power Apps app already created
- Supabase project set up
- Office 365 mailbox for sending emails

## Step 1: Create Cloud Flows

### 1.1 Automated Flow - New Transaction Created
1. Go to [https://flow.microsoft.com](https://flow.microsoft.com)
2. Click **Create** → **Cloud flows** → **Automated cloud flow**
3. Name: `New Transaction - Award Loyalty Points`
4. Trigger: **When a row is added** (Supabase Connector)
5. Configure:
   - **Location**: (your Supabase instance)
   - **Table**: transactions

### 1.2 Add Actions
1. Click **+ New step**
2. Add action: **Get a row** (Supabase)
   - Table: customers
   - Row ID: @{triggerOutputs()['body']['customer_id']}
3. Click **+ New step**
4. Add action: **Update a row** (Supabase)
   - Table: customers
   - Row ID: @{triggerOutputs()['body']['customer_id']}
   - loyalty_points: @{add(body('Get_a_row')?['loyalty_points'], int(div(body('Compose')?['total_amount'], 100)))}

### 1.3 Add Email Notification
1. Click **+ New step**
2. Add action: **Send an email** (Office 365)
   - To: @{body('Get_a_row')?['email']}
   - Subject: `Transaction Completed - Loyalty Points Earned`
   - Body:
   ```
   Dear @{body('Get_a_row')?['name']},
   
   Your transaction has been completed successfully!
   
   Amount: IDR @{body('Compose')?['total_amount']}
   Loyalty Points Earned: @{div(body('Compose')?['total_amount'], 100)}
   Total Points: @{add(body('Get_a_row')?['loyalty_points'], int(div(body('Compose')?['total_amount'], 100)))}
   
   Thank you for shopping with us!
   ```

## Step 2: Create Scheduled Flows

### 2.1 Daily Analytics Summary
1. Click **Create** → **Cloud flows** → **Scheduled cloud flow**
2. Name: `Daily Sales Report`
3. Configure:
   - **Frequency**: Daily
   - **Time**: 9:00 AM
   - **Timezone**: Your timezone

### 2.2 Add Actions
1. Click **+ New step**
2. Add action: **Get rows** (Supabase)
   - Table: transactions
   - Select columns: id, total_amount, transaction_date

3. Click **+ New step**
4. Add action: **Send an email** (Office 365)
   - To: manager@store.com
   - Subject: `Daily Sales Report - @{utcNow('yyyy-MM-dd')}`
   - Body:
   ```
   Good morning,
   
   Here's your daily sales summary:
   Total Transactions: @{length(body('Get_rows')?['value'])}
   Total Sales: IDR @{sum(map(body('Get_rows')?['value'], float(item()?['total_amount'])))}
   
   Best regards,
   DRP-PRO System
   ```

## Step 3: Create Instant Flows (Button Flows)

### 3.1 Manual Survey Send
1. Click **Create** → **Cloud flows** → **Instant cloud flow**
2. Name: `Send Survey to Customer`
3. Trigger: **Power Apps v2**

### 3.2 Configure Flow
1. Add input from Power Apps:
   - **customer_email** (Text)
   - **survey_type** (Text)
   - **survey_link** (Text)

2. Add action: **Send an email**
   - To: **customer_email** (from input)
   - Subject: `We'd love your feedback!`
   - Body:
   ```
   Please take a moment to complete our survey: **survey_link**
   Survey Type: **survey_type**
   ```

3. Return output to Power Apps:
   - Click **Add an output**
   - Type: Text
   - Name: status
   - Value: Email sent successfully

## Step 4: Advanced Automations

### 4.1 Low Stock Alert
1. Create automated flow triggered on **Updated products**
2. Add condition:
   ```
   If quantity_in_stock < reorder_level
   Then send email to manager
   ```

3. Actions:
   - Send notification: "Product @{triggerOutputs()['body']['name']} is running low on stock"
   - Create a task in To Do

### 4.2 Customer Tier Upgrade
1. Create automated flow when **Updated customers**
2. Conditions:
   - If tier changed to 'silver' or higher
   - Send personalized email

3. Email body:
   ```
   Congratulations @{body('Get_a_row')?['name']}!
   
   You've been upgraded to @{triggerOutputs()['body']['tier']} member!
   
   Enjoy exclusive benefits:
   - 2x loyalty points on purchases
   - Early access to promotions
   - Birthday specials
   ```

### 4.3 Revenue Milestone Alert
1. Monthly scheduled flow
2. Get total sales for the month
3. If exceeded target:
   - Send celebration email
   - Log achievement in SharePoint
   - Trigger Teams notification

## Step 5: Integration with Power Apps

### 5.1 Trigger Flow from Power App Button
1. In Power Apps, add Button control
2. Set **OnSelect** formula:
   ```powerappel
   PowerAutomateFlow.Run(
       customer_email: Combobox_Customer.SelectedItem.email,
       survey_type: "satisfaction"
   );
   Notify("Survey sent successfully!", NotificationType.Success)
   ```

### 5.2 Pass Parameters to Flow
Configure flow inputs in Power Apps:
```powerappel
PowerAutomateFlow.Run(
    transaction_id: GUID_Transaction.Value,
    customer_id: Selected_Customer.Id,
    amount: Value(Total_Amount.Value)
)
```

## Step 6: Error Handling & Retry Logic

### 6.1 Add Retry Policy
1. In flow actions, click **...**
2. Select **Settings**
3. Set retry policy:
   - **Retry count**: 3
   - **Interval**: 10 seconds

### 6.2 Add Error Handling
1. Add **Configure run after** for each action
2. Select: **has failed**, **is timed out**, **is skipped**
3. Add error notification action:
   ```
   Send email to admin with error details
   ```

## Step 7: Monitor & Debug Flows

### 7.1 View Run History
1. Go to flow details
2. Click **Run history**
3. Review successful/failed runs
4. Click run to see detailed logs

### 7.2 Add Analytics
1. Configure flow to log each run:
   ```
   Action: Create a record (Supabase - flow_logs table)
   Flow name: @{workflow()['name']}
   Status: @{result('Run_action')?['status']}
   Timestamp: @{utcNow()}
   ```

## Step 8: Testing & Validation

### 8.1 Test Transaction Flow
1. In Power Apps, create test transaction
2. Monitor flow run in Power Automate
3. Verify:
   - Loyalty points updated
   - Email sent to customer
   - Activity logged

### 8.2 Test Scheduled Flow
1. Change schedule to run in 2 minutes
2. Wait for execution
3. Verify email received
4. Reset schedule to production time

## Step 9: Deploy to Production

### 9.1 Enable/Disable Flows
1. Only enable tested flows in production
2. Keep development flows disabled
3. Use flow states: Draft → Test → Production

### 9.2 Share Flows
1. Click **Share**
2. Add users/groups with permissions:
   - Can run flows
   - Can edit flows
   - Can delete flows

## Step 10: Notifications & Alerts

### 10.1 Slack Integration (Optional)
1. Add Slack connector
2. Send message to Slack channel on important events:
   ```
   Message: High-value transaction completed!
   Customer: @{body('Get_a_row')?['name']}
   Amount: IDR @{triggerOutputs()['body']['total_amount']}
   ```

### 10.2 Teams Integration (Optional)
1. Send Teams notification
2. Include transaction summary
3. Add action buttons for quick response

## Common Workflows

### Workflow 1: Complete Sale with Rewards
- Trigger: New transaction in Power Apps
- Action 1: Update customer loyalty points
- Action 2: Check if customer reached milestone
- Action 3: If yes, send reward email
- Action 4: Log activity to database

### Workflow 2: Inventory Replenishment
- Trigger: Product quantity drops below reorder level
- Action 1: Send alert email to manager
- Action 2: Create task in To Do
- Action 3: Update status to "pending reorder"

### Workflow 3: Customer Feedback Collection
- Trigger: Manual trigger from Power Apps
- Action 1: Send survey email to customer
- Action 2: Log survey sent timestamp
- Action 3: Schedule follow-up if no response after 7 days

## Troubleshooting

### Flow Won't Trigger
- Check trigger condition is correct
- Verify table permissions in Supabase
- Check RLS policies allow access

### Action Fails Repeatedly
- Review error message in run history
- Check API credentials are valid
- Add detailed error logging

### Performance Issues
- Reduce data volume in Get rows action
- Add filters to limit results
- Use pagination for large datasets

## Related Documentation
- [POWERAPPS_SETUP.md](./POWERAPPS_SETUP.md)
- [SUPABASE_SETUP.md](./SUPABASE_SETUP.md)
- [API.md](../docs/API.md)
