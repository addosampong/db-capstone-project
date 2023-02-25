use littlelemondb;
PREPARE GetOrderDetail FROM
'SELECT OrderID as `Order ID`, Quantity, (BillAmount * Quantity) as `Cost`
FROM Orders
Where OrderID = ?';

SET @orderid = 1;

EXECUTE GetOrderDetail USING @orderid;
