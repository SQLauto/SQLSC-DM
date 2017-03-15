CREATE TABLE [dbo].[BestSellers_Export]
(
[course_id] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[guest_bestsellers_rank] [float] NULL,
[authenticated_bestsellers_rank] [float] NULL,
[website] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
