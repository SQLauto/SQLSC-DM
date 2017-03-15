CREATE TABLE [Mapping].[WPCoupons]
(
[WeekOfMailing] [date] NULL,
[CouponCode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExpirationPrintedDate] [date] NULL,
[EmailType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AcquisitionWeek] [datetime] NULL
) ON [PRIMARY]
GO
