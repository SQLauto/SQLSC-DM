CREATE PARTITION FUNCTION [YearQtrRangePF] ([datetime]) 
AS RANGE RIGHT 
FOR VALUES (N'2010-01-01 00:00:00.000', N'2010-04-01 00:00:00.000', N'2010-07-01 00:00:00.000', N'2010-10-01 00:00:00.000', N'2011-01-01 00:00:00.000', N'2011-04-01 00:00:00.000', N'2011-07-01 00:00:00.000', N'2011-10-01 00:00:00.000', N'2012-01-01 00:00:00.000', N'2012-04-01 00:00:00.000', N'2012-07-01 00:00:00.000', N'2012-10-01 00:00:00.000', N'2013-01-01 00:00:00.000', N'2013-04-01 00:00:00.000', N'2013-07-01 00:00:00.000', N'2013-10-01 00:00:00.000', N'2014-01-01 00:00:00.000', N'2014-04-01 00:00:00.000', N'2014-07-01 00:00:00.000', N'2014-10-01 00:00:00.000', N'2015-01-01 00:00:00.000', N'2015-04-01 00:00:00.000', N'2015-07-01 00:00:00.000', N'2015-10-01 00:00:00.000', N'2016-01-01 00:00:00.000', N'2016-04-01 00:00:00.000', N'2016-07-01 00:00:00.000', N'2016-10-01 00:00:00.000', N'2017-01-01 00:00:00.000', N'2017-04-01 00:00:00.000', N'2017-07-01 00:00:00.000', N'2017-10-01 00:00:00.000', N'2018-01-01 00:00:00.000', N'2018-04-01 00:00:00.000', N'2018-07-01 00:00:00.000', N'2018-10-01 00:00:00.000', N'2019-01-01 00:00:00.000', N'2019-04-01 00:00:00.000', N'2019-07-01 00:00:00.000', N'2019-10-01 00:00:00.000', N'2020-01-01 00:00:00.000', N'2020-04-01 00:00:00.000', N'2020-07-01 00:00:00.000', N'2020-10-01 00:00:00.000')
GO