CREATE TABLE [Marketing].[DMDownStreamMonthly]
(
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DS1moSales] [money] NOT NULL,
[DS2moSales] [money] NOT NULL,
[DS3moSales] [money] NOT NULL,
[DS4moSales] [money] NOT NULL,
[DS5moSales] [money] NOT NULL,
[DS6moSales] [money] NOT NULL,
[DS7moSales] [money] NOT NULL,
[DS8moSales] [money] NOT NULL,
[DS9moSales] [money] NOT NULL,
[DS10moSales] [money] NOT NULL,
[DS11moSales] [money] NOT NULL,
[DS12moSales] [money] NOT NULL,
[DS24moSales] [money] NOT NULL,
[DS36moSales] [money] NOT NULL,
[DS48moSales] [money] NOT NULL,
[DS60moSales] [money] NOT NULL,
[DS72moSales] [money] NOT NULL,
[DS84moSales] [money] NOT NULL,
[DS96moSales] [money] NOT NULL,
[DS108moSales] [money] NOT NULL,
[DS120moSales] [money] NOT NULL,
[DS132moSales] [money] NULL,
[DS144moSales] [money] NULL,
[DS156moSales] [money] NULL,
[DS168moSales] [money] NULL,
[DS180moSales] [money] NULL,
[DS1moOrders] [int] NOT NULL,
[DS2moOrders] [int] NOT NULL,
[DS3moOrders] [int] NOT NULL,
[DS4moOrders] [int] NOT NULL,
[DS5moOrders] [int] NOT NULL,
[DS6moOrders] [int] NOT NULL,
[DS7moOrders] [int] NOT NULL,
[DS8moOrders] [int] NOT NULL,
[DS9moOrders] [int] NOT NULL,
[DS10moOrders] [int] NOT NULL,
[DS11moOrders] [int] NOT NULL,
[DS12moOrders] [int] NOT NULL,
[DS24moOrders] [int] NOT NULL,
[DS36moOrders] [int] NOT NULL,
[DS48moOrders] [int] NOT NULL,
[DS60moOrders] [int] NOT NULL,
[DS72moOrders] [int] NOT NULL,
[DS84moOrders] [int] NOT NULL,
[DS96moOrders] [int] NOT NULL,
[DS108moOrders] [int] NOT NULL,
[DS120moOrders] [int] NOT NULL,
[DS132moOrders] [int] NULL,
[DS144moOrders] [int] NULL,
[DS156moOrders] [int] NULL,
[DS168moOrders] [int] NULL,
[DS180moOrders] [int] NULL,
[DS1moFlagRepeatByr] [tinyint] NOT NULL,
[DS2moFlagRepeatByr] [tinyint] NOT NULL,
[DS3moFlagRepeatByr] [tinyint] NOT NULL,
[DS4moFlagRepeatByr] [tinyint] NOT NULL,
[DS5moFlagRepeatByr] [tinyint] NOT NULL,
[DS6moFlagRepeatByr] [tinyint] NOT NULL,
[DS7moFlagRepeatByr] [tinyint] NOT NULL,
[DS8moFlagRepeatByr] [tinyint] NOT NULL,
[DS9moFlagRepeatByr] [tinyint] NOT NULL,
[DS10moFlagRepeatByr] [tinyint] NOT NULL,
[DS11moFlagRepeatByr] [tinyint] NOT NULL,
[DS12moFlagRepeatByr] [tinyint] NOT NULL,
[DS24moFlagRepeatByr] [tinyint] NOT NULL,
[DS36moFlagRepeatByr] [tinyint] NOT NULL,
[DS48moFlagRepeatByr] [tinyint] NOT NULL,
[DS60moFlagRepeatByr] [tinyint] NOT NULL,
[DS72moFlagRepeatByr] [tinyint] NOT NULL,
[DS84moFlagRepeatByr] [tinyint] NOT NULL,
[DS96moFlagRepeatByr] [tinyint] NOT NULL,
[DS108moFlagRepeatByr] [tinyint] NOT NULL,
[DS120moFlagRepeatByr] [tinyint] NOT NULL,
[DS132moFlagRepeatByr] [tinyint] NULL,
[DS144moFlagRepeatByr] [tinyint] NULL,
[DS156moFlagRepeatByr] [tinyint] NULL,
[DS168moFlagRepeatByr] [tinyint] NULL,
[DS180moFlagRepeatByr] [tinyint] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_DMDownStreamMonthly] ON [Marketing].[DMDownStreamMonthly] ([CustomerID]) ON [PRIMARY]
GO
