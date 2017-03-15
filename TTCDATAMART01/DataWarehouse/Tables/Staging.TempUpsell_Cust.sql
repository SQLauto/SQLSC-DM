CREATE TABLE [Staging].[TempUpsell_Cust]
(
[CustomerID] [dbo].[udtCustomerID] NULL,
[CourseID] [int] NULL,
[CourseParts] [dbo].[udtCourseParts] NULL,
[SubjectCategory2] [dbo].[udtSubjectPreference] NULL,
[PreferredCategory2] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sales] [money] NULL,
[CourseSat] [float] NULL
) ON [PRIMARY]
GO
