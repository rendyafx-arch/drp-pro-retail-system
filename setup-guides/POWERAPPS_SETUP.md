# Microsoft Power Apps Setup Guide - DRP-PRO

## Prerequisites

Before starting, ensure you have:
- Microsoft 365 subscription with Power Apps included
- Access to Power Apps portal (make.powerapps.com)
- Supabase account and credentials (API URL, Anon Key)
- Administrator access to create connections

## Step 1: Create Power Apps Application

### 1.1 Create New App
1. Go to [make.powerapps.com](https://make.powerapps.com)
2. Click **Create** → **Canvas app from blank**
3. Enter app name: `DRP-PRO-Retail-Management`
4. Select **Tablet** or **Phone + Tablet** layout
5. Click **Create**

### 1.2 Configure App Settings
1. Go to **File** → **Settings**
2. Under **General**:
   - Set **Aspect ratio** to your target device
   - Enable **Auto save**
3. Under **Upcoming features**:
   - Enable **Formula bar in editors for canvas apps**
4. Click **Save**

## Step 2: Create Supabase Data Connection

### 2.1 Add Data Connection
1. In Power Apps, go to **Data** → **Add data**
2. Search for **REST**
3. Click **REST** connector

### 2.2 Configure REST Connection Settings
1. Click **+ New connection**
2. Set **Base URL** to your Supabase project URL:
   ```
   https://your-project.supabase.co/rest/v1
   ```
3. Click **Create**

### 2.3 Create Tables Data Queries

#### Get Products
```
Method: GET
URL: https://your-project.supabase.co/rest/v1/products
?select=*
&apikey=YOUR_ANON_KEY

Headers:
- Authorization: Bearer YOUR_JWT_TOKEN
- apikey: YOUR_ANON_KEY
```

#### Get Customers
```
Method: GET
URL: https://your-project.supabase.co/rest/v1/customers
?select=*
&apikey=YOUR_ANON_KEY
```

#### Get Transactions
```
Method: GET
URL: https://your-project.supabase.co/rest/v1/transactions
?select=*,transaction_items(*),customers(*)
&apikey=YOUR_ANON_KEY
```

## Step 3: Build App Screens

### 3.1 Authentication Screen
1. Create new blank screen named `LoginScreen`
2. Add controls:
   - **TextInput_Email**: Email input field
   - **TextInput_Password**: Password input field (set `Type` to `Password`)
   - **Button_Login**: Login button

3. Set **Button_Login** `OnSelect` formula:
```powerappel
ClearCollect(
    loginResult,
    JSON({
        "email": TextInput_Email.Value,
        "password": TextInput_Password.Value
    })
);
Navigate(DashboardScreen)
```

### 3.2 Dashboard Screen
1. Create new screen named `DashboardScreen`
2. Add gallery to display summary cards:
   - Total Sales
   - Total Transactions
   - New Customers
   - Loyalty Points
3. Add formula to calculate metrics:
```powerappel
ClearCollect(
    DashboardData,
    {
        TotalSales: Sum(transactions, total_amount),
        TotalTransactions: CountRows(transactions),
        NewCustomers: CountRows(Filter(customers, registration_date >= Today())),
        LoyaltyPoints: Sum(customers, loyalty_points)
    }
);
```

### 3.3 Products Screen
1. Create screen named `ProductsScreen`
2. Add:
   - **SearchBox** for product search
   - **Gallery** showing products with columns:
     - Product Name
     - SKU
     - Current Price
     - Stock Quantity
     - Status

3. Set gallery's `Items` property:
```powerappel
Search(
    productsCollection,
    SearchBox_Products.Value,
    "name",
    "sku"
)
```

### 3.4 POS/Transactions Screen
1. Create screen named `POSScreen`
2. Add controls:
   - **Customer Lookup** (Combobox)
   - **Product Scanner** (TextInput)
   - **Items Gallery** (showing cart items)
   - **Total Display** (Label)
   - **Complete Sale Button**

3. Set **Product Scanner** `OnChange` formula:
```powerappel
If(
    TextInput_Scan.Value <> "",
    {
        product: LookUp(productsCollection, barcode = TextInput_Scan.Value),
        quantity: 1,
        price: LookUp(productsCollection, barcode = TextInput_Scan.Value).current_price
    },
    Blank()
)
```

### 3.5 Customers Screen
1. Create screen named `CustomersScreen`
2. Add gallery showing:
   - Customer Name
   - Phone
   - Loyalty Points
   - Tier
   - Total Purchases

### 3.6 Rewards Screen
1. Create screen named `RewardsScreen`
2. Display active rewards with:
   - Reward Name
   - Type (Points Multiplier, Discount, etc.)
   - Description
   - Start/End Dates

### 3.7 Analytics Screen
1. Create screen named `AnalyticsScreen`
2. Add charts using built-in **Column chart** and **Line chart** controls
3. Configure data sources for:
   - Daily Sales Trend
   - Category Sales Distribution
   - Customer Tier Breakdown

## Step 4: Configure Navigation

### 4.1 Create Navigation Menu
1. Add a **Menu screen** with buttons for:
   - Dashboard
   - Products
   - POS
   - Customers
   - Rewards
   - Analytics
   - Surveys
   - Profile

2. Set each button's `OnSelect` formula:
```powerappel
Navigate(DashboardScreen, ScreenTransition.Fade)
```

## Step 5: Configure Supabase Authentication

### 5.1 Set Up Authentication Flow
1. In Supabase console:
   - Go to **Authentication** → **Providers**
   - Enable **Email** provider
   - Configure redirect URL: `https://make.powerapps.com`

2. In Power Apps:
   - Add **Supabase Auth** data connection
   - Configure with Project URL and Anon Key

### 5.2 Implement Login Logic
```powerappel
Set(
    authToken,
    If(
        supabaseAuth.SignIn(TextInput_Email.Value, TextInput_Password.Value).success,
        supabaseAuth.Token,
        Blank()
    )
);

If(
    Not(IsBlank(authToken)),
    Navigate(DashboardScreen),
    Notify("Login failed", NotificationType.Error)
)
```

## Step 6: Add Real-time Data Synchronization

### 6.1 Configure Collections
Create collections for offline support:
```powerappel
ClearCollect(
    productsCollection,
    supabaseProducts.GetItems()
);

ClearCollect(
    customersCollection,
    supabaseCustomers.GetItems()
);

ClearCollect(
    transactionsCollection,
    supabaseTransactions.GetItems()
);
```

### 6.2 Set Refresh Timer
1. Add **Timer** control to main screen
2. Set **Duration** to 60000 (60 seconds)
3. Set **OnTimerEnd** formula:
```powerappel
Refresh(productsCollection);
Refresh(customersCollection);
Refresh(transactionsCollection)
```

## Step 7: Test Application

### 7.1 Test Login Flow
1. Click **Play** (F5) to preview
2. Enter test credentials
3. Verify navigation to Dashboard

### 7.2 Test Data Loading
1. Verify products load correctly
2. Check customer list displays
3. Confirm transactions appear

### 7.3 Test POS Functions
1. Add products to cart
2. Verify total calculation
3. Complete a test transaction

## Step 8: Deploy to Production

### 8.1 Publish App
1. Click **Publish** button
2. Select **Publish this version**
3. Choose **Publish to current version** or **Create new version**

### 8.2 Configure Sharing
1. Click **Share**
2. Add users/groups with:
   - **Store Managers**: Can edit and run
   - **Staff**: Can run only
   - **Owner**: Full access

### 8.3 Enable Power Apps Mobile
1. Users install **Power Apps** mobile app
2. Sign in with their credentials
3. App appears in their **My apps**

## Step 9: Mobile Optimization

### 9.1 Responsive Design
1. Use **Screen.Width** and **Screen.Height** for responsive layouts
2. Set controls to adjust based on screen size

### 9.2 Touch-Friendly UI
1. Buttons: minimum 40px height
2. Input fields: minimum 30px height
3. Gallery items: minimum 50px height

### 9.3 Performance Optimization
1. Lazy load data (load on demand)
2. Implement search filters
3. Use collections for caching

## Troubleshooting

### Connection Issues
**Problem**: Cannot connect to Supabase
- **Solution**: Verify API URL and Anon Key are correct
- Check Supabase project is active
- Verify network connectivity

### Authentication Failures
**Problem**: Login not working
- **Solution**: Check email/password combination
- Verify user exists in Supabase
- Check RLS policies allow user access

### Data Not Loading
**Problem**: Collections are empty
- **Solution**: Verify API keys have correct permissions
- Check RLS policies for the tables
- Test API endpoints directly in browser

### Performance Slow
**Problem**: App loading takes too long
- **Solution**: Implement pagination
- Add search filters
- Use cached collections
- Optimize formulas

## Related Documentation
- [ARCHITECTURE.md](../docs/ARCHITECTURE.md) - System design
- [DATABASE.md](../docs/DATABASE.md) - Database schema
- [API.md](../docs/API.md) - API reference
- [SUPABASE_SETUP.md](./SUPABASE_SETUP.md) - Backend configuration
