SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[SP_TTCDATAMART01_FreeSpace_Alert]
as
Begin
/*Proc to send out email alerts when the free disk space is below a threshold*/

create table #FreeSpace(
 Drive char(1), 
 MB_Free int)

insert into #FreeSpace exec xp_fixeddrives
declare @MB_Free int,@servername varchar(200)=@@servername, @PSubject varchar(200),@Pbody varchar(200)

-- Free Space on C drive Less than Threshold
select @MB_Free = MB_Free from #FreeSpace where Drive = 'C'
set @PSubject = @servername + ' - Free Space Issue on C System Drive'
set @Pbody = 'Free space on C Drive has dropped below 50 gig and currently at '+ cast( @MB_Free as varchar(10)) + ' MB'
if @MB_Free < 51200
  EXEC msdb.dbo.sp_send_dbmail
     @recipients ='~dldatamartalerts@TEACHCO.com',
     @subject = @PSubject,
     @body = @Pbody,
	 @importance = 'High'

-- Free Space on L drive Less than Threshold
select @MB_Free = MB_Free from #FreeSpace where Drive = 'L'
set @PSubject = @servername + ' - Free Space Issue on L Log Drive'
set @Pbody = 'Free space on L Drive has dropped below 50 gig and currently at '+ cast( @MB_Free as varchar(10)) + ' MB'
if @MB_Free < 51200
  EXEC msdb.dbo.sp_send_dbmail
     @recipients ='~dldatamartalerts@TEACHCO.com',
     @subject = @PSubject,
     @body = @Pbody,
	 @importance = 'High'

-- Free Space on D drive Less than Threshold
select @MB_Free = MB_Free from #FreeSpace where Drive = 'D'
set @PSubject = @servername + ' - Free Space Issue on D Data Drive'
set @Pbody = 'Free space on D Drive has dropped below 50 gig and currently at '+ cast( @MB_Free as varchar(10)) + ' MB'
if @MB_Free < 51200 
   EXEC msdb.dbo.sp_send_dbmail
     @recipients ='~dldatamartalerts@TEACHCO.com',
     @subject = @PSubject,
     @body = @Pbody,
	 @importance = 'High'

-- Free Space on R drive Less than Threshold
select @MB_Free = MB_Free from #FreeSpace where Drive = 'R'
set @PSubject = @servername + ' - Free Space Issue on R Archive Drive'
set @Pbody = 'Free space on R Drive has dropped below 20 gig and currently at '+ cast( @MB_Free as varchar(10)) + ' MB'
 if @MB_Free < 20480 
   EXEC msdb.dbo.sp_send_dbmail
     @recipients ='~dldatamartalerts@TEACHCO.com',
     @subject = @PSubject,
     @body = @Pbody,
	 @importance = 'High'

drop table #FreeSpace

End

GO
