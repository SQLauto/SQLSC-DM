CREATE TABLE [Mapping].[Email_WishlistCourses_history]
(
[EmailID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lastupdated] [datetime] NULL CONSTRAINT [DF__Email_Wis__Lastu__3DC3D3B0] DEFAULT (getdate())
) ON [PRIMARY]
GO
