CREATE TABLE [Marketing].[DMmailContactDownStream]
(
[customerid] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IntlPurchaseDate] [date] NULL,
[DS1momailContacts] [int] NULL,
[DS2momailContacts] [int] NULL,
[DS3momailContacts] [int] NULL,
[DS6momailContacts] [int] NULL,
[DS12momailContacts] [int] NULL,
[DS18momailContacts] [int] NULL,
[DS24momailContacts] [int] NULL,
[DMlastupdated] [datetime] NULL CONSTRAINT [DF__DMmailCon__DMlas__38311AAA] DEFAULT (getdate())
) ON [PRIMARY]
GO
