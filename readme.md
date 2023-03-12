# Capstone Project for Meta's Database Engineer Professional Course


## Author: Evans Addo-Sampong

### Project Description: Design a complete database for Little Lemon.
Specifically, the Project aims at designing the following:
- A data model using an Entity Relationship Diagram with relevant relationships to meet the data requirements of Little Lemon using MySQL Workbench
- Create the database schema and tables from the data model designed in point 1 above using MySQL Workbench
- Write MySQL statements to create Views, Stored Procedures, Prepared Statements, etc. to create a menu booking system for Little Lemon, generate sales reports, and automate bookings (add bookings, cancel bookings, update bookings, etc.)

### Organization of the Project
The Project is organized according to Tasks per the weekly schedule of the course. In view of that, the progression of the Project will be outlined in this **README** according to these weekly tasks schedule.

### Week 1

#### Setting up the repo

The repo for the Project was set up in Github with the name **db-capstone-project** during this week. The repo was initialised for subsequent commits from the local machine on which actual development would be done to the remote repo on Github.

#### Creating the MySQL server instance

The MySQL server instance was created and configured for the database user account which would be used for interacting with the database. The connection was successfully tested. All other environment settings and configurations were done at this stage of the Project.

#### Create an ER diagram data model and implement it in MySQL

#### Task 1: Create ER Diagram

We created a normalized ER diagram that adheres to 1NF, 2NF and 3NF with relevant relationships to meet the data requirements of Little Lemon. The tables in the ER diagram and their descriptions are given below:
- Bookings: To store information about booked tables in the restaurant including booking id, date and table number.
- Customers: To store information about the customer names and contact details.
- Employees: To store information about stafff/employees at Little Lemon, including the role and salary of the employees.
- Menu: To store information about cuisines
- MenuItems: To store information about the menu courses.
- Orders: To store information about each order such as order date, quantity and total cost.

The ER diagram was exported and saved as **LittleLemonDM.png** in the repo.
The resulting data model was also exported. It is named as **LittleLemonDM.mwb**.


#### Task 2: Implement the Little Lemon data model inside MySQL server
Using the ER diagram thus created, we then implemented the schema of the database, as well as created the tables specified in the ER diagram. We did this by utilizing the **forward engineer** tool in MySQL Workbench. The resulting database was named **littlelemondb** in the MySQL Workbench. The database was subsequently exported to the Project repo. It is labeled as **littlelemondb.sql**

#### Task 3: Show databases
After setting up the data model and implementing the database with its associated tables, we wrote an SQL query to show all databases in MySQL Workbench. The result shows that our **littlelemondb** database was successfully created. 
A screenshot of the query is saved as **Databses showing the LittleLemonDB.png** in the Project repo.

### Week 2

### Add sales reports

###  Create virtual tables to summarize data

#### Task 1: Create orders_veiw

We created the **orders_veiw** virtual table in MySQL Workbench to extract the OrderID, Quantity and Costs associated with all orders that have order quantities greater than 2 from the Orders table. The SQL statements for the view is shown below:

    USE littlelemonddb;
    CREATE VIEW orders_view AS
        SELECT OrderID AS 'Order ID',
            Quantity AS 'Quantity',
            ROUND((BillAmount * Quantity), 2) AS 'Cost'
        FROM orders
        WHERE (Quantity > 2);

#### Task 2: Create customer_order_view
We created the **customer_order_veiw** virtual table in MySQL Workbench to extract order details of customers with orders that cost more than $150. To do this, we joined about 5 tables. These tables have relationships between one or two of their columns with each other. The SQL statements for this view is shown below:

    USE littlelemonddb;
    CREATE VIEW customer_order_view AS
        SELECT c.CustomerID AS 'Customer ID',
            CONCAT(c.FirstName, ' ', c.LastName) AS 'Customer',
            o.OrderID AS 'Order ID',
            ROUND((o.BillAmount * o.Quantity), 2) AS 'Cost',
            m.Cuisine AS 'Menu Name',
            mi.Name AS 'Course Name'
        FROM customers c
            JOIN bookings b ON c.CustomerID = b.CustomerID
            JOIN orders o ON b.BookingID = o.BookingID
            JOIN menus m ON o.MenuID = m.MenuID
            JOIN menuitems mi ON m.ItemID = mi.ItemID
        WHERE (o.BillAmount * o.Quantity) > 150
        ORDER BY o.BillAmount * o.Quantity;
    
    
**Assumptions made**:
We assume that the cost of an order is calculated by multiplying the order quantity by the bill amount.

Hence, `Cost = BillAmount * Quantity`

#### Task 3: Create menu_quantity_view
We created the **menu_quantity_veiw** virtual table in MySQL Workbench to find all menu items for which more than 2 orders have been placed. 
To get the expected results, we joined 3 tables in the database. These tables have relationships between one or two of their columns with each other. The SQL statements for this view is shown below:

    USE littlelemonddb;
    CREATE VIEW menu_quantity_view AS
        SELECT m.Cuisine AS 'Menu Name',
            mi.Name AS 'Course Name',
            o.Quantity AS 'Quantity'
        FROM menuitems mi
        JOIN menus m ON mi.ItemID = m.ItemID
        JOIN orders o ON m.MenuID = o.MenuID
        WHERE o.Quantity ANY (SELECT orders.Quantity
                FROM orders
                WHERE orders.Quantity > 2)
        ORDER BY o.Quantity;

### Create optimized queries to manage and analyze data

#### Task 1: Create GetMaxQuantity stored procedure

This stored procedure displays the maximum ordered quantity in the Orders table. The SQL statements for the stored proceduer is shown below:

    USE littlelemondb;
    CREATE PROCEDURE 'GetOrderQuantity'()
    BEGIN
        SELECT MAX(Quantity) AS 'Max Quantity in Order'
        FROM Orders;
    END

#### Task 2: Create GetOrderDetail prepared statement

This prepared statement which returns the order id, the quantity and the order cost from the Orders table. 
The prepared statement accepts one input argument, the CustomerID value, from a variable.  
An aribtrary variable called **orderid** with a value of 1 was used to test/execute the prepared statement.
The prepared statement was exported as an SQL script file. It is named as **Prepare Statement to get order detail.sql** in the Project repo. The prepared statement was also converted into a Stored Procedure in the littlelemondb database in the MySQL Workbench.

#### Task 3: Create CancelOrder stored procedure

This procedure will allow Little Lemon to cancel any order by specifying the order id as parameter passed to the procedure. The SQL statements for this procedure is as shown below:

    USE littlelemondb;
    CREATE PROCEDURE CancelOrder (IN id INT)
    BEGIN
        #check Orders table to confirm if Order with OrderID is same id (id specified by Little Lemon), then 
        #delete that order and display the appropriate message
        
        IF (SELECT exists (select 1 FROM Orders where OrderID = id) = 1) THEN
            DELETE FROM Orders
            WHERE OrderID = id;
            SELECT CONCAT("Order with ID ", id, " is cancelled") AS "Confirmation";
        ELSE
            SELECT CONCAT("Order with ID ", id, " is not a valid Order") AS "Confirmation";
        END IF;
    END

### Table booking system

### Create SQL queries to check available bookings based on user input

#### Task 1: Populate Bookings table with data

We used a simple **INSERT** statement to popluate the Bookings table with some sample data. This data can be viewed by running the `SELECT * FROM Bookings` SQL statement from the MySQL Workbench

#### Task 2: Create CheckBooking stored procedure

The **CheckBooking** procedure checks whether a table in the restaurant is already booked. The procedure accepts two input parameters in the form of booking date and table number. The SQL statements for the procedure is shown below:

    USE littlelemondb;
    CREATE PROCEDURE CheckBooking(IN booking_date DATE, IN table_no INT)
    BEGIN
        #check Bookings table to confirm if there is a booking with BookingDate and TableNo same as the 
        #booking_date and table_no parameters supplied by the user, then display the appropriate message
        
        IF (SELECT exists (select 1 FROM Bookings WHERE BookingDate = booking_date) = 1) AND
         (SELECT exists (select 1 FROM Bookings WHERE TableNo = table_no) = 1) THEN
                SELECT CONCAT("Table ", table_no, " is already booked for ", booking_date) AS "Booking Status";
        ELSE
            SELECT CONCAT("Table ", table_no, " is not booked") AS "Booking Status";
        END IF;
    END

#### Task 3: Create AddValidBooking store procedure

This procedure helps Little Lemon to verify a booking and decline any reservations for tables that are already booked under another name. This procedure accepts two input parameters in the form of booking date and table number. Since the there will be a number of statements to be executed in this procedure, which statements include insertions, we wrapped the statements around a `START TRANSACTION` statement and used the `ROLLBACK` and `COMMIT` statements where appropriate. For instance, if there is a booking for the booking date and table no supplied by the user, then the entire operations are rolled back, else the booking is inserted into the Bookings table and committed. The SQL statements for the procedure is as shown below:

    USE littlelemondb;
    CREATE PROCEDURE AddValidBooking(IN booking_date DATE, IN table_no INT)
    BEGIN
        START TRANSACTION;
            #check Bookings table to confirm if there is a booking with BookingDate and TableNo same as the
            #booking_date and table_no parameters supplied by the user, then display the appropriate message
            #and roll back the transaction, else add the booking to the Bookings table and display the 
            #appropriate message

            IF (SELECT exists (select 1 FROM Bookings WHERE BookingDate = booking_date) = 1) AND
                    (SELECT exists (select 1 FROM Bookings WHERE TableNo = table_no) = 1) THEN
                SELECT CONCAT("Table ", table_no, " is already booked - booking cancelled") AS "Booking Status";
                ROLLBACK;
            ELSE
                SET @customer_id = 6, @employee_id = 6;
                INSERT INTO Bookings(TableNo, CustomerID, BookingDate, BookingSlot, EmployeeID)
                VALUES
                (table_no, @customer_id, booking_date, CURRENT_TIME(), @employee_id );
                SELECT CONCAT("Booking made for Table ", table_no) AS "Booking Status";
                COMMIT;
        END IF;

    END

### Create SQL queries to add and update bookings

#### Task 1: Create AddBooking stored procedure

This procedure adds a booking to the Bookings table. The procedure accepts four input parameters in the form of the following bookings parameters: booking id, customer id, booking date and table number. The SQL statements for this procedure is shown below:

    USE littlelemondb;
    CREATE `AddBooking`(IN booking_id INT, IN customer_id INT, IN booking_date DATE, IN table_no INT)
    BEGIN
        START TRANSACTION;
            #check Bookings table to confirm if there is a booking with BookingID, CustomerID, BookingDate and
            #TableNo same as the booking_id, customer_id, booking_date and table_no parameters supplied by the 
            #user. Then display the appropriate message and roll back the transaction, else add the booking to
            #the Bookings table and display the appropriate message

            IF (SELECT exists (select 1 FROM Bookings WHERE BookingDate = booking_date) = 1) AND
                    (SELECT exists (select 1 FROM Bookings WHERE TableNo = table_no) = 1) THEN
                SELECT CONCAT("Table ", table_no, " is already booked - booking not added") AS "Confirmation";
                ROLLBACK;
            ELSE
                #arbirarily set the EmployeeID to 6 (Receptionist) for every new booking
                SET @employee_id = 6;
                INSERT INTO Bookings(TableNo, CustomerID, BookingDate, BookingSlot, EmployeeID)
                VALUES
                (table_no, customer_id, CURRENT_DATE(), CURRENT_TIME(), @employee_id );
                SELECT CONCAT("Booking added for Table ", table_no) AS "Confirmation";
                COMMIT;
        END IF;

    END

**Assumptions made**: We assume that the if the booking will be added after checking the constraints, the current date and time that the booking is going to be added should be the BookingDate and BookingSlot, and these should be part of the data to be inserted into the Bookings table. We also assume that for every new booking, the first employee to receive the order is the Receptionist who has an EmployeeID of 6. 

#### Task 2: Create UpdateBooking stored procedure

The UpdateBooking procedure helps Little Lemon to update existing bookings in the Bookings table. The procedure accepts two input parameters in the form of booking id and booking date. The SQL statements for this procedure is shown below:

    USE littlelemondb;
    CREATE PROCEDURE `UpdateBooking`(IN booking_id INT, IN booking_date DATE)
    BEGIN
        START TRANSACTION;
            #check Bookings table to confirm if there is a booking with BookingID and BookingDate same as the
            #booking_id and booking_date parameters supplied by the user. Then display the appropriate message
            #and roll back the transaction, else update the Bookings table as appropriate and display the
            #appropriate message

            IF (SELECT exists (select 1 FROM littlelemondb.Bookings WHERE BookingID = booking_id) = 1) AND
               (SELECT exists (select 1 FROM littlelemondb.Bookings WHERE BookingDate = booking_date) = 1) THEN
                SELECT CONCAT("No changes made to Booking ", booking_id) AS "Confirmation";
                ROLLBACK;
            ELSE
                UPDATE Bookings
                SET BookingDate = booking_date
                WHERE BookingID = booking_id;
                SELECT CONCAT("Booking ", booking_id, " updated") AS "Confirmation";
                COMMIT;
        END IF;
    END

#### Task 3: Create CancelBooking stored procedure

This procedure helps Little Lemon to cancel or remove a booking from the Bookings table. The procedure accepts one input parameter in the form of booking id. The SQL statements for the procedure is as shown below:

    USE littlelemondb;
    CREATE PROCEDURE `CancelBooking`(IN booking_id INT)
    BEGIN
        START TRANSACTION;
            #check Bookings table to confirm if there is a booking with BookingID same as the booking_id
            #parameter supplied by the user. Then delete the booking from the Bookings table and display
            #the appropriate message, else roll back the transaction

            IF (SELECT exists (select 1 FROM littlelemondb.Bookings WHERE BookingID = booking_id) = 1) THEN
                DELETE FROM Bookings
                WHERE BookingID = booking_id;
                SELECT CONCAT("Booking", booking_id, " cancelled") AS "Confirmation";
                COMMIT;

            ELSE
                SELECT CONCAT("Booking", booking_id, " not found") AS "Confirmation";
                ROLLBACK;
        END IF;
    END

### Week 3

### Data visualization

### Set up the Tableau Workspace for data analysis

#### Task 1: Connect Little Lemon data to Tableau

We loaded the Little Lemon data in Microsoft Excel format inot Tableau. During the data loading process, we filtered out data for all countries leaving only USA for onward analysis. This means that we will be doing the data analysis for only USA customers.

#### Task 2: Create two new data fields

After loading the Little Lemon data into Tableau, we then split the **Customer Name** column into two separate fields. We renamed the two new columns as **First Name** and **Last Name**

#### Task 3: Create Profit column

To get a **Profit** field in the dataset for analysis purposes, we created a **Calculated Field** in Tableau from the **Sales** column. We did this by selecting the **Sales** column and selecting the **Create --> Calculated Field...** option, then calcuted the profit as follows:

    [Sales] - [Cost]

This formula substracts the cost price of every order from the order's sale price to give the profit on that order.
We then renamed the resulting column **Profit**.

### Create interactive dashboard for sales and profits

#### Task 1: Create a bar chart of sales

To create the bar chart of sales greater than or equal to `$70` for each customer, we dropped the **Sales** column on **Rows** at the shelves section of Tableau and the **Customer Name** column on **Columns** at the shelves section. We then filtered **Sales** for sales greater than or equal to `$70` by dropping the **Sales** column on the **Filters** pane of Tableau, then applied a filter of **At least** 70 to get all sales greater than or equal to `$70`.

We also applied a color scheme to the bar chart by dropping the **Sales** column to the **Color** section in the **Marks** pane of Tableau.

We sorted the charts in descending order in order to give an aesthetic appearance of the bar chart.

The **Tooltip** was applied automatically. This has the effect of a pop-up of the customer's name and total sales made by that customer when a user hovers the mouse over the bar chart.

#### Task 2: Create a line chart of profits

To create the line chart of profits trend from 2019 to 2022, we dropped the **Profit** column on **Rows** at the shelves section of Tableau and the **Order Date** column on **Columns** at the shelves section. We filtered out year 2023 from the **Order Date**.

We also applied a color scheme to the line chart by dropping the **Profit** column to the **Color** section in the **Marks** pane of Tableau.

The Tooltip was applied automatically. This has the effect of a pop-up of the year of order date and total profit made in that year when a user hovers the mouse over the line chart.

#### Task 3: Create bubble chart

To create the chart chart of customers and the sales made by them as well as the profits made from them, we dropped the **Sales** column on **Rows** at the shelves section of Tableau and the **Customer Name** column on **Columns** at the shelves section. In the **Marks** pane, we selected **Circle** in order to create the bubbles. In the **Show Me** section of Tableau at the upper right corner, we selected the **packed bubbles** option, then dropped the **Sales** column on the **Size** option in the **Marks** pane.

To display the customers' names on the bubbles, we dropped the **Customer Name** column on the **Label** option in the **Marks** pane.

We also applied a color scheme to the line chart by dropping the **Sales** column to the **Color** section in the **Marks** pane of Tableau.

We also dropped the **Customer Name**, **Sales** and **Profit** columns on the **Tooltip** option in the **Marks** pane in order to apply those information as a tootip on the bubbles. This has the effect of a pop-up of the customer name, sales made by the customer and total profit made from that customer when a user hovers the mouse over the bubble chart.

#### Task 4: Compare sales of 3 different cuisines

To compare the sales and profits of the 3 different cuisines, we dropped the **Cuisine Name** and **Order Date** columns on **Columns** at the shelves section of Tableau and the **Sales** columns on **Rows** at the shelves section. We filtered out years 2019 and 2023 from the **Order Date**.

We applied an appropriate color scheme to the line chart by dropping the **Sales** column to the **Color** section in the **Marks** pane of Tableau. We also sorted the bar charts in derscending order of profits.

To display the profit on each cuisine, we dropped the **Profit** column on the **Label** option in the **Marks** pane.

We also dropped the **Cuisine Name**, **Order Date**, **Sales** and **Profit** columns on the **Tooltip** option in the **Marks** pane in order to apply those information as a tootip on the charts whenever a user hovers the mouse over the charts.

#### Task 5: Create an interactive dashboard

To create the and interactive dashboard of the Customers Sales bar chart and the Sales bubble chart, we selected the **Dashboard** option, then dragged and dropped the **Customers Sales** and **Sales Bubble Chart** worksheets on the Dashboard.

To create an interactive link between the two worksheets, we selected the **Use as filter** option on the **Customers Sales** worksheet. Thus, when a user selects a customer's bar chart on the **Customers Sales** worksheet, the customer's bubble is displayed in the **Sales Bubble Chart** worksheet below.

When a user hovers the mouse over the customer's bubble in the **Sales Bubble Chart** worksheet in the Dashboard, the customer's name, sales made by them and the profit made from them appear as a tooltip.

#### Tableau workbook

The Tableau workbook for all the worksheets and dashboard is saved in the Project repo as **LittleLemon.twbx**


```python

```
