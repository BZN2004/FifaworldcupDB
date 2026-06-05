# FIFA 2026 World Cup Database Management System 

A comprehensive relational database designed in T-SQL to manage the core operations of the upcoming FIFA 2026 World Cup. This system handles tournament logistics ranging from match scheduling and stadium capacity to player statistics and secure ticket booking.

##  Group Members
* Andile Mahlangu
* Muzomuhle Manaka
* Rian Puth
* Bandile Ndlangamndla

## Technical Highlights
This project goes beyond basic CRUD operations and showcases advanced SQL Server capabilities:
* **Role-Based Access Control (RBAC):** Custom logins and database roles (SystemAdmin, Operator, Analyst, Auditor, Fans) with specific permissions.
* **Data Security & Encryption:** Implemented Transparent Data Encryption (TDE) for the database and AES_256 column-level encryption for sensitive fan contact information.
* **Advanced Querying:** Utilizes Common Table Expressions (CTEs), Subqueries, and complex JOINs for analytical reporting (e.g., tracking top goal scorers and discipline statuses).
* **Stored Procedures:** Encapsulated business logic for registering teams, adding players, scheduling matches, updating stats, and handling ticket bookings/cancellations.
* **Triggers:** Automated validation, such as preventing stadium overbooking and generating notifications for match updates.
* **Views & Functions:** Created dynamic views for match details and user-defined functions for calculating dynamic ticket pricing based on purchase dates.

## Database Schema Overview
The database (`Fifa2026_WorldCupDB`) consists of 9 normalized tables:
1. **Countries & Teams:** National team representations.
2. **Players & PlayerStats:** Player profiles and match-by-match performance tracking.
3. **Staff:** Coaching and analytical staff assignments.
4. **Stadiums & Matches:** Venues across North America and detailed match scheduling.
5. **Fans & Tickets:** Fan profiles (with encrypted contact info) and a dynamic ticket booking system.

## How to Run the Project

### Prerequisites
* Microsoft SQL Server Management Studio (SSMS) installed.

### Setup Instructions
1. Clone or download this repository.
2. Open `MainQuery2.sql` in SSMS.
3. **Important:** Before executing the script, locate the `CREATE DATABASE` section and update the `FILENAME` file paths to match your local SQL Server installation directory. 
4. Execute the script. It will automatically:
   * Drop any existing versions of the database to prevent conflicts.
   * Create the schema, roles, and encryption keys.
   * Populate the tables with sample data (teams, players, stadiums, fans, matches).
   * Set up all procedures, views, functions, and triggers.

##  Repository Contents
* `MainQuery2.sql`: The primary T-SQL script containing all DDL, DML, and programmable objects.
* `Fifa2026WorldCupBackup.bak`: A full binary backup of the initialized database for quick restoration.
