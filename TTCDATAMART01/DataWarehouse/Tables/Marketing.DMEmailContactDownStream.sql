CREATE TABLE [Marketing].[DMEmailContactDownStream]
(
[customerid] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IntlPurchaseDate] [date] NULL,
[DS1moEmailContacts] [int] NULL,
[DS2moEmailContacts] [int] NULL,
[DS3moEmailContacts] [int] NULL,
[DS6moEmailContacts] [int] NULL,
[DS12moEmailContacts] [int] NULL,
[DS18moEmailContacts] [int] NULL,
[DS24moEmailContacts] [int] NULL
) ON [PRIMARY]
GO
