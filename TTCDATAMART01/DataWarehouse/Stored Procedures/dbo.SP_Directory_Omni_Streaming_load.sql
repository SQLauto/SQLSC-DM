SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Proc [dbo].[SP_Directory_Omni_Streaming_load] @Sourcedir varchar(200) output,@Destdir varchar(200) output
as

begin

set @Sourcedir = '\\File1\groups\Marketing\WebAnalytics\VideoTracking\VideoConsumption\Raw'

set @Destdir = '\\File1\groups\Marketing\WebAnalytics\VideoTracking\VideoConsumption\Raw\Archive'

end
GO
