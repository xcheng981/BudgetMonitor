# BudgetMaster

BudgetMaster is a personal finance management app designed to help users track income and expenses, organize transactions, and analyze financial data. The app provides clear visual summaries and intuitive budgeting tools to support informed financial decision-making.

## Features

### 1. Authentication Management
- **Secure Registration and Login**: Email/password login.
- **Password Recovery**: Automated system with strong password enforcement.

### 2. Transaction Management
- **Recording Transactions**:
  - Add detailed income and expense records with customizable categories and notes.
  - Support for date specification and amount input.
- **Editing and Deleting**:
  - Modify existing transactions or delete them individually or in bulk.
  - Safeguards for deletion confirmations.

### 3. Financial Analysis
- **Time-Based Summaries**:
  - Daily, monthly, and annual overviews.
  - Category-wise breakdowns and trend analysis.
- **Visual Analytics**:
  - Interactive charts and graphs for income/expense visualization.
  - Spending trends and category distributions.

### 4. Account Management
- **Profile Customization**:
  - Manage username, profile picture, and authentication credentials.
  - Configure preferred currency and date formats.
- **Data Management**:
  - Set account start date for accurate reporting.
  - Adjust currency settings.

## Screens

### 1. Splash Screen
- Brief logo animation introducing the app.

### 2. Authentication Screens
- **Sign-in**: Login via email/password or social media accounts.
- **Sign-up**: Register a new account with secure credentials.
- **Reset Password**: Recover accounts with strong password enforcement.

### 3. Details Screen
- View, add, edit, and delete transactions.
- Batch deletion and category customization supported.

### 4. Analysis Screen
- Interactive charts summarizing income and expenses.
- Filter by period, transaction type, and category.

### 5. Profile Screen
- Manage account-related information, including currency and start date settings.

## Technologies Used
- **Flutter Framework**: For building a seamless and responsive UI.
- **State Management**: Provider package for efficient data flow.
- **Local Storage**: SQLite integration for transaction and profile data.
- **Security**: Envied package for storing sensitive information securely.

## Limitations
- No offline functionality (internet required for syncing).
- No real-time currency conversion or payment method tracking.

## How to Run the App
1. Clone this repository:
   ```bash
   git clone https://github.com/xcheng981/BudgetMonitor.git
