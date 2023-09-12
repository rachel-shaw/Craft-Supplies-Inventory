#connect to database
#CREATE DATABASE Craft_Supplies_Database;
USE Craft_Supplies_Database;

#create tables
CREATE TABLE Inventory (
	Craft VARCHAR(20),
    Category VARCHAR(20),
    Item_ID VARCHAR(10) PRIMARY KEY,
    Item VARCHAR(50),
    Brand VARCHAR(20),
    Vendor VARCHAR(30),
    Location VARCHAR(30),
    Quantity INT,
    Unit_Cost DECIMAL(6, 2),
    Min_Stock INT,
    Order_Alert VARCHAR(20)
);

CREATE TABLE Sales (
	Sale_ID VARCHAR(10) PRIMARY KEY,
    Customer_ID VARCHAR(10),
    Purchase_Date DATE,
    Month VARCHAR(10),
    Year INT,
    Season VARCHAR(10),
    Method VARCHAR(15)
);

CREATE TABLE Orders (
	Sale_ID VARCHAR(10),
    Order_ID VARCHAR(10) PRIMARY KEY,
	Item_ID VARCHAR(10),
    Quantity INT
);


CREATE TABLE Customer (
	Customer_ID VARCHAR(10) PRIMARY KEY,
    First_Name VARCHAR(20), 
    Last_Name VARCHAR(20), 
    DOB DATE,
    Age INT,
    Gender VARCHAR(1),
    Phone_Number VARCHAR(12),
    Street_Address VARCHAR(50),
    City VARCHAR(50),
    State VARCHAR(2),
    Zip INT,
    Latitude INT,
    Longitude INT
);

#import data via import wizard

#view tables
SELECT * FROM Inventory;
SELECT * FROM Customer;
SELECT * FROM Sales;
SELECT * FROM Orders;

#add foreign keys
ALTER TABLE Orders
ADD FOREIGN KEY(Item_ID)
REFERENCES Inventory(Item_ID)
ON DELETE SET NULL;

ALTER TABLE Sales
ADD FOREIGN KEY(Customer_ID)
REFERENCES Customer(Customer_ID)
ON DELETE SET NULL;

ALTER TABLE Orders
ADD FOREIGN KEY(Sale_ID)
REFERENCES Sales(Sales_ID)
ON DELETE SET NULL;


#test queries
#test inventory table - okay
SELECT Item as Item, Unit_Cost as Unit_Cost, Quantity as Quantity, Vendor as Vendor
FROM Inventory
WHERE Vendor = "Michael's Craft Store"
ORDER BY Unit_Cost DESC, Quantity DESC
LIMIT 10;

#test sales table - okay
SELECT Customer_ID as Customer_ID, 
        Purchase_Date as PurchaseDate,
		Sale_ID as Sale_ID 
FROM Sales
WHERE Customer_ID = "CUST-050"
LIMIT 20;

#test link between sales, orders, customer and inventory tables - okay
SELECT  Sales.Customer_ID as Customer_ID, 
        Purchase_Date as PurchaseDate,
		Orders.Item_ID as Item_ID, 
        Item as Item,
        Orders.Quantity as QuantitySold,
        First_Name as Name
FROM Orders
INNER JOIN Inventory On Orders.Item_ID = Inventory.Item_ID
INNER JOIN Sales on Sales.Sale_ID = Orders.Sale_ID
INNER JOIN Customer on Customer.Customer_ID = Sales.Customer_ID
WHERE Sales.Customer_ID = "CUST-050";











#Questions to answer on dashboard
#What are the total profit (in dollars) of all items sold?
SELECT ROUND(SUM(TotalProfit), 2)
FROM (
		SELECT Orders.Item_ID,
        Orders.Quantity as QuantitySold, 
        Inventory.Unit_Cost,
        Inventory.Unit_Cost*1.75 as Purchase_Price,
        (Unit_Cost*1.75)-Unit_Cost as Unit_Profit,
        ((Unit_Cost*1.75)-Unit_Cost)*Orders.Quantity as TotalProfit
		FROM Orders
		INNER JOIN Inventory On Orders.Item_ID = Inventory.Item_ID
		ORDER BY TotalProfit DESC) AS TotalProfit_Table;
#total profit = $51,328.67

#What are the total revenue/gross sales (in dollars) all items sold?
SELECT ROUND(SUM(Total_Cost), 2)
FROM (
		SELECT  Orders.Item_ID,
        Orders.Quantity as QuantitySold, 
        Inventory.Unit_Cost,
        Inventory.Unit_Cost*Orders.Quantity AS Total_Cost
		FROM Orders
		INNER JOIN Inventory On Orders.Item_ID = Inventory.Item_ID
		ORDER BY Inventory.Unit_Cost*Orders.Quantity DESC) AS TotalSales_Table;
#total profit = $68,438.22

#What are the total revenue/gross sales (in dollars) all items sold?
SELECT ROUND(SUM(Total_Revenue), 2)
FROM (
		SELECT  Orders.Item_ID,
        Orders.Quantity as QuantitySold, 
        Inventory.Unit_Cost*1.75 AS Purchase_Price,
        (Inventory.Unit_Cost*1.75)*Orders.Quantity AS Total_Revenue
		FROM Orders
		INNER JOIN Inventory On Orders.Item_ID = Inventory.Item_ID
		ORDER BY Inventory.Unit_Cost*Orders.Quantity DESC) AS TotalSales_Table;
#total profit = $68,438.22


#What are the total cost of spent in supplies in stock (in dollars)? (overhead for supplies)
SELECT ROUND(SUM(Total_Cost), 2)
FROM (
		SELECT  Item_ID,
        Quantity as QuantityStocked, 
        Unit_Cost,
        Inventory.Unit_Cost*Inventory.Quantity AS Total_Cost
		FROM Inventory
		ORDER BY Inventory.Unit_Cost*Inventory.Quantity DESC) AS TotalInventory_Table;
#total profit = $4127.09


#What is the average sale value? 
SELECT AVG(Sale_Cost)
FROM (
	SELECT Sale_ID, SUM(Order_Cost) AS Sale_Cost
	FROM (
		SELECT Orders.Sale_ID,
				Order_ID, 
				Orders.Item_ID, 
				Orders.Quantity,
				Inventory.Unit_Cost*1.75 AS Purchase_Price,
				(Inventory.Unit_Cost*1.75)*Orders.Quantity as Order_Cost
		FROM Orders
		INNER JOIN Inventory ON Inventory.Item_ID = Orders.Item_ID
		INNER JOIN Sales on Sales.Sale_ID = Orders.Sale_ID) AS OrderCost_Table
	GROUP BY Sale_ID) AS SalesCost_Table;
#averge sale cost = $119.89

#Median sale value?
	SELECT Sale_ID, SUM(Order_Cost) as Sale_Cost
	FROM (
		SELECT Orders.Sale_ID,
				Order_ID, 
				Orders.Item_ID, 
				Orders.Quantity,
				Inventory.Unit_Cost*1.75 AS Purchase_Price,
				(Inventory.Unit_Cost*1.75)*Orders.Quantity as Order_Cost
		FROM Orders
		INNER JOIN Inventory ON Inventory.Item_ID = Orders.Item_ID
		INNER JOIN Sales on Sales.Sale_ID = Orders.Sale_ID
		ORDER BY Order_Cost DESC) AS OrderCost_Table
	GROUP BY Sale_ID
	ORDER BY SUM(Order_Cost) DESC
	LIMIT 1 OFFSET 499;
#median sale cost = $73.13


#Sales per Year
SELECT Year, 
		COUNT(Year), 
		SUM(Revenue) AS Total_Revenue, 
        SUM(Profit) AS Total_Profit,
		AVG(Revenue) AS Avg_Revenue, 
        AVG(Profit) AS Avg_Profit
FROM (
	SELECT Orders.Order_ID, 
			Orders.Item_ID, 
            Inventory.Item, 
            Orders.Quantity, 
            Year,
            Orders.Quantity*(Inventory.Unit_Cost*1.75) AS Revenue,
			((Unit_Cost*1.75)-Unit_Cost)*Orders.Quantity as Profit
	FROM Orders
	INNER JOIN Inventory ON Inventory.Item_ID = Orders.Item_ID
    INNER JOIN Sales ON Sales.Sale_ID = Orders.Sale_ID) AS SeasonTable
GROUP BY Year
ORDER BY COUNT(Year) DESC;
#2021, 2020, 2022, 2023


#Sales per Season
SELECT Season, 
		COUNT(Season), 
		SUM(Revenue) AS Total_Revenue, 
        SUM(Profit) AS Total_Profit,
		AVG(Revenue) AS Avg_Revenue, 
        AVG(Profit) AS Avg_Profit
FROM (
	SELECT Orders.Order_ID,
			Orders.Item_ID, 
            Inventory.Item, 
            Orders.Quantity, 
            Sales.Season,
            Orders.Quantity*(Inventory.Unit_Cost*1.75) AS Revenue,
			((Unit_Cost*1.75)-Unit_Cost)*Orders.Quantity as Profit
	FROM Orders
	INNER JOIN Inventory ON Inventory.Item_ID = Orders.Item_ID
    INNER JOIN Sales ON Sales.Sale_ID = Orders.Sale_ID) AS SeasonTable
GROUP BY Season
ORDER BY COUNT(Season) DESC;
#summer, autumn, winter, spring

##Sales per category
SELECT Category, 
		COUNT(Category), 
		SUM(Revenue) AS Total_Revenue, 
        SUM(Profit) AS Total_Profit,
		AVG(Revenue) AS Avg_Revenue, 
        AVG(Profit) AS Avg_Profit
FROM (
	SELECT Orders.Order_ID, 
			Orders.Item_ID, 
            Inventory.Item, 
            Orders.Quantity, 
            Category,
            Orders.Quantity*(Inventory.Unit_Cost*1.75) AS Revenue,
			((Unit_Cost*1.75)-Unit_Cost)*Orders.Quantity as Profit
	FROM Orders
	INNER JOIN Inventory ON Inventory.Item_ID = Orders.Item_ID) AS CategoryTable
GROUP BY Category
ORDER BY COUNT(Category) DESC;
#craft tools = 576, paint = 446, vinyl = 415, yarn = 273

##Sales per craft
SELECT Craft, 
		COUNT(Craft), 
        SUM(Revenue) AS Total_Revenue, 
        SUM(Profit) AS Total_Profit,
		AVG(Revenue) AS Avg_Revenue, 
        AVG(Profit) AS Avg_Profit
FROM (
	SELECT Orders.Order_ID, 
			Orders.Item_ID, 
            Inventory.Item, 
            Orders.Quantity, 
            Craft,
			Orders.Quantity*(Inventory.Unit_Cost*1.75) AS Revenue,
			((Unit_Cost*1.75)-Unit_Cost)*Orders.Quantity as Profit
	FROM Orders
	INNER JOIN Inventory ON Inventory.Item_ID = Orders.Item_ID) AS CraftTable
GROUP BY Craft
ORDER BY COUNT(Craft) DESC;
#crocheting = 690, cricuting = 518, painting = 502

#top 5 selling items?
SELECT Orders.Item_ID, 
		Item, 
        SUM(Orders.Quantity) AS QuantitySold,
		SUM(Orders.Quantity*(Inventory.Unit_Cost*1.75)) AS Total_Revenue,
		SUM(((Unit_Cost*1.75)-Unit_Cost)*Orders.Quantity) as Total_Profit,
		AVG(Orders.Quantity*(Inventory.Unit_Cost*1.75)) AS Avg_Revenue,
		AVG(((Unit_Cost*1.75)-Unit_Cost)*Orders.Quantity) as Avg_Profit
FROM Orders
INNER JOIN Inventory ON Inventory.Item_ID = Orders.Item_ID
GROUP BY Orders.Item_ID
ORDER BY SUM(Orders.Quantity) DESC
LIMIT 5;
#black vinyl roll, crochet hook 3mm, vinyl blue roll, yarn maroon, vinyl pink roll

#bottom 5?
SELECT Orders.Item_ID, Item, SUM(Orders.Quantity) AS QuantitySold
FROM Orders
INNER JOIN Inventory ON Inventory.Item_ID = Orders.Item_ID
GROUP BY Orders.Item_ID
ORDER BY SUM(Orders.Quantity) ASC
LIMIT 5;
#vinyl light green square, vinyl orange square, paint acrylic red, yarn black, vinyl white square


#Orders by location
Select City, 
		SUM(Orders.Quantity) AS QuantitySold,
		SUM(Orders.Quantity*(Inventory.Unit_Cost*1.75)) AS Total_Revenue,
		SUM(((Unit_Cost*1.75)-Unit_Cost)*Orders.Quantity) as Total_Profit,
		AVG(Orders.Quantity*(Inventory.Unit_Cost*1.75)) AS Avg_Revenue,
		AVG(((Unit_Cost*1.75)-Unit_Cost)*Orders.Quantity) as Avg_Profit
FROM Customer
INNER JOIN Sales ON Sales.Customer_ID = Customer.Customer_ID
INNER JOIN Orders ON Orders.Sale_ID = Sales.Sale_ID
INNER JOIN Inventory ON Inventory.Item_ID = Orders.Item_ID
GROUP BY City
ORDER BY QuantitySold DESC;
#top 5: Colorado Springs, Boulder, Denver, Greeley, Pueblo (put all on map)


#Orders by order method
Select Method, 
		SUM(Orders.Quantity) AS QuantitySold,
		SUM(Orders.Quantity*(Inventory.Unit_Cost*1.75)) AS Total_Revenue,
		SUM(((Unit_Cost*1.75)-Unit_Cost)*Orders.Quantity) as Total_Profit,
		AVG(Orders.Quantity*(Inventory.Unit_Cost*1.75)) AS Avg_Revenue,
		AVG(((Unit_Cost*1.75)-Unit_Cost)*Orders.Quantity) as Avg_Profit
FROM Customer
INNER JOIN Sales ON Sales.Customer_ID = Customer.Customer_ID
INNER JOIN Orders ON Orders.Sale_ID = Sales.Sale_ID
INNER JOIN Inventory ON Inventory.Item_ID = Orders.Item_ID
GROUP BY Method
ORDER BY QuantitySold DESC;
#in store = 4285, online = 3831, local pick up = 1659



#Demographics Panel
#What gender orders most frequently?
SELECT Gender, 
		COUNT(Gender), 
        SUM(Revenue), 
        SUM(Profit), 
        Avg(Revenue), 
        AVG(Profit)
FROM (
	SELECT Sales.Sale_ID, 
			Sales.Customer_ID, 
            Sales.Purchase_Date, 
            Gender,
            SUM(Orders.Quantity*(Inventory.Unit_Cost*1.75)) AS Revenue,
			SUM(((Unit_Cost*1.75)-Unit_Cost)*Orders.Quantity) as Profit
	FROM Sales
	INNER JOIN Customer ON Customer.Customer_ID = Sales.Customer_ID
    INNER JOIN Orders ON Orders.Sale_ID = Sales.Sale_ID
    INNER JOIN Inventory ON Inventory.Item_ID = Orders.Item_ID
    GROUP BY Sales.Sale_ID) AS GenderSales_Table
GROUP BY Gender;
#Females ordered 514 times, Males ordered 485 times

#What is the average sale amount per gender?
SELECT Gender, AVG(Sale_Cost)
FROM (
    SELECT Sale_ID, SUM(Order_Cost) AS Sale_Cost, Gender
    FROM (
        SELECT Orders.Sale_ID,
				(Inventory.Unit_Cost*1.75)*Orders.Quantity as Order_Cost,
                Gender
		FROM Orders
		INNER JOIN Inventory ON Inventory.Item_ID = Orders.Item_ID
		INNER JOIN Sales on Sales.Sale_ID = Orders.Sale_ID
		INNER JOIN Customer ON Customer.Customer_ID = Sales.Customer_ID) AS OrderCost_Table
	GROUP BY Sale_ID) AS SaleCost_Table
GROUP BY Gender;
#Female averge sale cost = $117.41, Male average sale cost = $122.52

#What age orders most frequently? least?
SELECT Age, COUNT(Age)
FROM (
	SELECT Sales.Sale_ID, Sales.Customer_ID, Sales.Purchase_Date, Age
	FROM Sales
	INNER JOIN Customer ON Customer.Customer_ID = Sales.Customer_ID) AS GenderSales_Table
GROUP BY Age
ORDER BY COUNT(Age) DESC;
#54 year olds order most (55 times); 58 year olds order least

##What age range orders most frequently? least?
SELECT age_range, 
		COUNT(age_range),
		SUM(Revenue) AS TotalRevenue,
		SUM(Profit) AS TotalProfit,
		AVG(Revenue) AS AvgRevenue,
		AVG(Profit) AS AvgProfit
FROM (
	SELECT Sales.Sale_ID, 
			Sales.Customer_ID, 
            Sales.Purchase_Date, 
            AgeRangeSales_Table.Age, 
            AgeRangeSales_Table.age_range,
            SUM(Orders.Quantity*(Inventory.Unit_Cost*1.75)) AS Revenue,
			SUM(((Unit_Cost*1.75)-Unit_Cost)*Orders.Quantity) as Profit
	FROM(
		SELECT *,
			CASE
				WHEN AGE < 13 THEN 'Child'
				WHEN AGE < 20 THEN 'Teen'
				WHEN AGE < 30 THEN 'Twenties'
				WHEN AGE < 40 THEN 'Thirties'
				WHEN AGE < 50 THEN 'Fourties'
				WHEN AGE < 60 THEN 'Fifties'
				WHEN AGE < 70 THEN 'Sixties'
				WHEN AGE < 80 THEN 'Seventies'
				WHEN AGE < 30 THEN 'Eighties'
				WHEN AGE < 30 THEN 'Ninties'
				ELSE 'Older than 90'
			END AS age_range
		FROM Customer) AS AgeRangeSales_Table
	INNER JOIN Sales ON Sales.Customer_ID = AgeRangeSales_Table.Customer_ID
	INNER JOIN Orders ON Orders.Sale_ID = Sales.Sale_ID
	INNER JOIN Inventory ON Inventory.Item_ID = Orders.Item_ID
    GROUP BY Sales.Sale_ID) AS Sales_Table
GROUP BY age_range
ORDER BY COUNT(age_range) DESC;
#70s and 20s purchase the most, teen and 90+ least





##Inventory Panel
#how many items do we carry?
SELECT COUNT(Item_ID)
FROM Inventory;
#114 items carried

#How many are in fully stock?
SELECT COUNT(Item_ID)
FROM Inventory
WHERE Order_Alert = "In-Stock";
#87 fully in stock

#how many are completely out of stock?
SELECT COUNT(Item_ID)
FROM Inventory
WHERE Quantity = 0;
#10 out of stock

#how many are low stock?
SELECT COUNT(Item_ID)
FROM Inventory
WHERE Quantity != 0 AND Order_Alert = "Need to Order";
#17 in lock stock

#add list stock status
SELECT *,
	CASE
		WHEN Quantity = 0 THEN "Out of Stock"
		WHEN Quantity != 0 AND Order_Alert = "Need to Order" THEN "Low Stock"
		WHEN Order_Alert = "In-Stock" Then "In Stock"
    END AS Stock_Status
FROM Inventory;


#What needs to be re-ordered?
SELECT Item_ID, Item, Quantity AS Quantity_Stocked, Min_Stock-Quantity AS Min_Need_to_Order
FROM Inventory
WHERE Order_Alert = "Need to Order"
ORDER BY Quantity, Min_Stock-Quantity DESC;
