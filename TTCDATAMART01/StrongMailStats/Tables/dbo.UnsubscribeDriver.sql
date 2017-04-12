CREATE TABLE [dbo].[UnsubscribeDriver]
(
[ReportDate] [datetime] NULL
) ON [PRIMARY]
GO
GRANT REFERENCES ON  [dbo].[UnsubscribeDriver] TO [TEACHCO\OLTP_DATA Group]
GO
GRANT SELECT ON  [dbo].[UnsubscribeDriver] TO [TEACHCO\OLTP_DATA Group]
GO
