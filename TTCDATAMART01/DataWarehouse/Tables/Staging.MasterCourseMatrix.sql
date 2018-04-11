CREATE TABLE [Staging].[MasterCourseMatrix]
(
[Courseid] [int] NULL,
[PC] [int] NULL,
[PD] [int] NULL,
[PT] [int] NULL,
[DA] [int] NULL,
[DV] [int] NULL,
[DT] [int] NULL,
[Clearance] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Rebrand] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OMNI] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Parts] [int] NULL,
[Exception] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BookPages] [int] NULL,
[DMLastupdated] [datetime] NULL CONSTRAINT [DF__MasterCou__DMLas__390247C0] DEFAULT (getdate())
) ON [PRIMARY]
GO
