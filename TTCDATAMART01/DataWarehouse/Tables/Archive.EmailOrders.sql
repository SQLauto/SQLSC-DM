CREATE TABLE [Archive].[EmailOrders]
(
[EmailOrders_id] [bigint] NOT NULL IDENTITY(1, 1),
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Adcode] [int] NULL,
[StartDate] [datetime] NULL,
[FlagHoldOut] [int] NULL,
[ComboID] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PreferredCategory] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmailAddress] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OpenCnt] [int] NULL,
[ClickCnt] [int] NULL,
[OpenDateStamp] [datetime] NULL,
[ClickDateStamp] [datetime] NULL,
[OrderID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateOrdered] [datetime] NULL,
[NetOrderAmount] [money] NULL,
[OrderSource] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagDigitalPhysical] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DMLastupdated] [datetime] NOT NULL CONSTRAINT [DF__EmailOrde__DMLas__0459DD1A] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Archive].[EmailOrders] ADD CONSTRAINT [PK__EmailOrd__28BBBD22F2CE717C] PRIMARY KEY CLUSTERED  ([EmailOrders_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_EmailOrders_Adcode] ON [Archive].[EmailOrders] ([Adcode]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_EmailOrders_Startdate] ON [Archive].[EmailOrders] ([StartDate]) ON [PRIMARY]
GO
