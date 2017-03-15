CREATE TABLE [Marketing].[DMmailCustomerReactivationContactDownStream]
(
[CustomerKey] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[customerid] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReactivationDate] [date] NULL,
[DS1momailContacts] [int] NULL,
[DS2momailContacts] [int] NULL,
[DS3momailContacts] [int] NULL,
[DS6momailContacts] [int] NULL,
[DS12momailContacts] [int] NULL,
[DS18momailContacts] [int] NULL,
[DS24momailContacts] [int] NULL
) ON [PRIMARY]
GO
