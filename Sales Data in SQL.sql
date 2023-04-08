--Inspecting data 
Select * From sales_data

--Checking unique values
Select Distinct status From sales_data
Select Distinct YEAR_ID From sales_data
Select Distinct PRODUCTLINE From sales_data
Select Distinct COUNTRY From sales_data
Select Distinct DEALSIZE From sales_data
Select Distinct TERRITORY From sales_data

--Analysis

--Let's start by grouping sales by productline, year_id, deal size
Select PRODUCTLINE, SUM(sales) as Revenue
From sales_data
Group by PRODUCTLINE
order by Revenue desc

Select YEAR_ID, SUM(sales) as Revenue
From sales_data
Group by YEAR_ID
order by Revenue desc

Select DEALSIZE, SUM(sales) as Revenue
From sales_data
Group by DEALSIZE
order by Revenue desc

--What was the best month for sales in specific year? How much was earned that month?
Select Top 1 MONTH_ID, SUM(sales) as Revenue
From sales_data
Where YEAR_ID=2003 --Change the year to see the rest 
group by MONTH_ID
order by 2 Desc

--Who is our best customer? (this could be best answerd with RFM)
Drop Table If exists RFM_Table;
;with RFM as 
(
	Select CUSTOMERNAME, 
	Sum(sales) Monetary_Value, 
	Count(orderlinenumber) Frequency, 
	Max(orderdate) Last_Order_Date,
	(select Max(orderdate) from sales_data) as Max_Order_Date,
	DATEDIFF(day,Max(orderdate),(select Max(orderdate) from sales_data)) Recency,
	Avg(sales) Avg_Monetary_Value
	From sales_data
	Group by CUSTOMERNAME
),

RFM_Calc as
(
	Select *,
	NTILE(4) Over(Order by Recency) RFM_Recnecy,
	NTILE(4) Over(Order by Frequency) RFM_Frequency,
	NTILE(4) Over(Order by Monetary_Value) RFM_Monetary_Value
	From RFM R
)
Select *, RFM_Recnecy+RFM_Frequency+RFM_Monetary_Value as RFM_Cell, 
cast(RFM_Recnecy as varchar) + cast(RFM_Frequency as varchar) + cast(RFM_Monetary_Value  as varchar) as RFM_Cell_String
INTO RFM_Table 
From RFM_Calc 
Select * From RFM_Table
Select CUSTOMERNAME, RFM_Recnecy, RFM_Frequency, RFM_Monetary_Value, 
	Case
		When RFM_Cell_String in (111, 112 , 121, 122, 123, 132, 211, 212, 114, 141) Then 'Lost Customers'
		When RFM_Cell_String in (133, 134, 143, 244, 334, 343, 344, 144) Then 'Slipping away, cannot lose' -- (Big spenders who haven’t purchased lately) slipping away
		When RFM_Cell_String in (311, 411, 331) Then 'New Customers'
		When RFM_Cell_String in (222, 223, 233, 322)  Then 'Potential churners'
		When RFM_Cell_String in (323, 333,321, 422, 332, 432) Then 'Active' --(Customers who buy often & recently, but at low price points)
		When RFM_Cell_String in (433, 434, 443, 444) then 'Loyal'
		End RFM_Segment
From RFM_Table



