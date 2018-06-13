SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[SP_TGCPlus_GDPR_CleanUp]  @ChangeUUID varchar(255) ,@ChangeEmail varchar(255) ,@Changecustomerid varchar(255) , @ForgetMe int = 0  
  
as  
  
Begin  
   
 --drop table #Cleanup  
  
 if @ChangeUUID is null   
 begin  
  
 print 'Need to provide tgcplus uuid'  
  
 return 0  
 End  
  
	select * into #Cleanup  
	from mapping.TGCPlus_GDPR_CleanUp  
	where Completed = 0  
 
   --Declare @ChangeUUID varchar(255) = '0000015b-9aae-d241-ab5f-9eff4ee20000',@ChangeEmail varchar(255) = 'Deleted_plus_eu_0000015b-9aae-d241-ab5f-9eff4ee20000@deleted_eu_account.com',@Changecustomerid varchar(255) = '3484613'  
  --  Declare @tablename varchar(255),@uuid varchar(255),@userId varchar(255),@customerid varchar(255),@email varchar(255),@emailaddress varchar(255)  
  --,@userFirstName varchar(255),@userLastName varchar(255),@Firstname varchar(255),@Lastname varchar(255),@FullName varchar(255)  
  --,@line1 varchar(255),@line2 varchar(255),@line3 varchar(255),@Address1 varchar(255),@Address2 varchar(255),@Address3 varchar(255)  
  
   while exists (select top 1 * from #Cleanup where Completed = 0)  
  
   Begin  
  
       Declare @tablename varchar(255)= null, @tablenameloop varchar(255)= null,@uuid varchar(255),@userId varchar(255),@customerid varchar(255),@email varchar(255),@emailaddress varchar(255)  
  ,@userFirstName varchar(255),@userLastName varchar(255),@Firstname varchar(255),@Lastname varchar(255),@FullName varchar(255)  
  ,@line1 varchar(255),@line2 varchar(255),@line3 varchar(255),@Address1 varchar(255),@Address2 varchar(255),@Address3 varchar(255)  
        
   select top 1  @tablename=TableName, @uuid = uuid,@userId= userId,@customerid = customerid,@email =  email ,@emailaddress = emailaddress   
 ,@userFirstName = userFirstName ,@userLastName = userLastName ,@Firstname = Firstname ,@Lastname = Lastname ,@FullName = FullName   
 ,@line1 = line1 ,@line2 = line2 ,@line3 = line3 ,@Address1 = Address1 ,@Address2 = Address2 ,@Address3 = Address3  
  from #Cleanup  
  where Completed = 0  
  order by TableName  
  
  
  set @tablenameloop = @tablename  
  set @tablename = '['+ replace(@tablename,'.','].[') + ']'  
  
  select @tablename as '@tablename',@uuid as '@uuid' ,@userId as '@userId',@customerid as '@customerid',@email as '@email',@emailaddress as '@emailaddress'  
 ,@userFirstName as '@userFirstName',@userLastName as '@userLastName',@Firstname as '@Firstname',@Lastname '@Lastname',@FullName as '@FullName'  
 ,@line1 as '@line1',@line2 as '@line2',@line3 as '@line3',@Address1 as '@Address1',@Address2 as '@Address2',@Address3 as '@Address3'  
  
  Declare @SQL Nvarchar(4000) ,@AuditSQL Nvarchar(4000), @WhereCondition varchar(1000), @UpdateColumns varchar(1000),@SelectColumns varchar(1000)  
    
  set @SQL =   
   '   
    Update <tablename>   
 set <UpdateColumns>  
 Where <WhereFilter>  
 '  
 set @AuditSQL =   
 '  
 Insert into [Archive].[TGCPlus_GDPR_CleanUp_AuditTrail] ( TableName,<InsertColumns> )  
  
 select ''<tablename>'',<SelectColumns>  
 from <tablename>  
 where <WhereFilter>  
 '  
  
  
 /* Replace TableName   */  
 set @SQL = replace(@SQL,'<tablename>',@tablename)  
 set @AuditSQL = replace(@AuditSQL,'<tablename>',@tablename)  
  
  
 select @tablename as '@tablename'  
  
 /* Where Condition / Select column list */  
  
 set @WhereCondition = null  
 set @SelectColumns = null  
  
 if @uuid <> 0   
 begin  
 set @WhereCondition = 'uuid = ''' + @ChangeUUID + ''''  
  set @SelectColumns = isnull(@SelectColumns,'') +' uuid ' + ','  
 end  
  
 if @userId <> 0 and @WhereCondition is null  
 begin  
 set @WhereCondition = 'userId = ''' + @ChangeUUID + ''''  
  set @SelectColumns = isnull(@SelectColumns,'') +' userId ' + ','   
 end  
  
 if @customerid <> 0 and @WhereCondition is null  
 begin  
 set @WhereCondition = 'customerid = ''' + @Changecustomerid + ''''  
  set @SelectColumns = isnull(@SelectColumns,'') +' customerid ' + ','    
 end  
   
  
  
 set @SQL = replace(@SQL,'<WhereFilter>',@WhereCondition)  
 set @AuditSQL = replace(@AuditSQL,'<WhereFilter>',@WhereCondition)  
  
 --print @SelectColumns  
 --print @AuditSQL  
 set @AuditSQL = replace(@AuditSQL,'<SelectColumns>',@SelectColumns + '<SelectColumns>' )   
 set @AuditSQL = replace(@AuditSQL,'<InsertColumns>',@SelectColumns + '<InsertColumns>' )   
 --print @AuditSQL  
   
 --set @AuditSQL = replace(@AuditSQL,'<SelectColumns>',@SelectColumns) + '<SelectColumns>'  
 --set @AuditSQL = replace(@AuditSQL,'<SelectColumns>',@SelectColumns) + '<SelectColumns>'  
 --set @AuditSQL = replace(@AuditSQL,'<InsertColumns>',@SelectColumns) + '<SelectColumns>'  
  
  
  
    
 /* Updating Columns */  
 set @UpdateColumns = Null  
 set @SelectColumns = Null  
 if @email <> 0  
 Begin   
 set @UpdateColumns = isnull(@UpdateColumns,'') +' email = ''' +  @ChangeEmail + ''','  
 set @SelectColumns = isnull(@SelectColumns,'') +' email ' + ','  
 End  
  
 if @emailaddress <> 0  
 Begin  
 set @UpdateColumns = isnull(@UpdateColumns,'') +' emailaddress = ''' +  @ChangeEmail + ''','  
 set @SelectColumns = isnull(@SelectColumns,'') +' emailaddress  ' + ','  
 End  
  
 if @userFirstName <> 0  
 Begin  
 set @UpdateColumns = isnull(@UpdateColumns,'') +' userFirstName = null ' +  ','  
 set @SelectColumns = isnull(@SelectColumns,'') +' userFirstName  ' + ','  
 End  
  
 if @userLastName <> 0  
 Begin  
 set @UpdateColumns = isnull(@UpdateColumns,'') +' userLastName = null ' +  ','  
 set @SelectColumns = isnull(@SelectColumns,'') +' userLastName  ' + ','  
 End  
  
 if @Firstname <> 0  
 Begin  
 set @UpdateColumns = isnull(@UpdateColumns,'') +' Firstname = null ' +  ','  
 set @SelectColumns = isnull(@SelectColumns,'') +' Firstname  ' + ','  
 End  
  
 if @Lastname <> 0  
 Begin  
 set @UpdateColumns = isnull(@UpdateColumns,'') +' Lastname = null ' +  ','  
 set @SelectColumns = isnull(@SelectColumns,'') +' Lastname  ' + ','  
 End  
   
 if @FullName <> 0  
 Begin  
 set @UpdateColumns = isnull(@UpdateColumns,'') +' FullName = null ' +  ','  
 set @SelectColumns = isnull(@SelectColumns,'') +' FullName  ' + ','  
 End  
   
 if @line1 <> 0  
 Begin  
 set @UpdateColumns = isnull(@UpdateColumns,'') +' line1 = null ' +  ','  
 set @SelectColumns = isnull(@SelectColumns,'') +' line1  ' + ','  
 End  
   
 if @line2 <> 0  
 Begin  
 set @UpdateColumns = isnull(@UpdateColumns,'') +' line2 = null ' +  ','  
 set @SelectColumns = isnull(@SelectColumns,'') +' line2  ' + ','  
 End  
  
 if @line3 <> 0  
 Begin  
 set @UpdateColumns = isnull(@UpdateColumns,'') +' line3 = null ' +  ','  
 set @SelectColumns = isnull(@SelectColumns,'') +' line3  ' + ','  
 End  
  
 if @Address1 <> 0  
 Begin  
 set @UpdateColumns = isnull(@UpdateColumns,'') +' Address1 = null ' +  ','  
 set @SelectColumns = isnull(@SelectColumns,'') +' Address1  ' + ','  
 End  
  
 if @Address2 <> 0  
 Begin  
 set @UpdateColumns = isnull(@UpdateColumns,'') +' Address2 = null ' +  ','  
 set @SelectColumns = isnull(@SelectColumns,'') +' Address2  ' + ','  
 End  
  
 if @Address2 <> 0  
 Begin  
 set @UpdateColumns = isnull(@UpdateColumns,'') + ' Address3 = null ' +  ','  
 set @SelectColumns = isnull(@SelectColumns,'') +' Address3  ' + ','  
 End  
  
 set @UpdateColumns = substring(@UpdateColumns,1,len(@UpdateColumns)-1)  
 set @SelectColumns = substring(@SelectColumns,1,len(@SelectColumns)-1)  
 Set @SQL =  Replace(@SQL,'<UpdateColumns>',@UpdateColumns)  
 Set @AuditSQL =  Replace(@AuditSQL,'<SelectColumns>',@SelectColumns)  
 Set @AuditSQL =  Replace(@AuditSQL,'<InsertColumns>',@SelectColumns)  
  
  exec (@AuditSQL)  
 print @auditSQl  
  
 if @ForgetMe = 1  
 begin  
 Print @SQL  
 exec (@SQL)  
  
 End  
  
  Update #Cleanup  
  set Completed = 1  
  where TableName = @tablenameloop  
  
  End  
  
  
--truncate table [Archive].[TGCPlus_GDPR_CleanUp_AuditTrail]  

  update A 
	Set A.DMLastUpdateESTDateTime = getdate(),
		TGCPlusCompleted = 1
  --select * 
  from datawarehouse.archive.TGCPlus_GDPR_ForgetMe_AuditTrail  A
  where A.uuid = @ChangeUUID  

  
END  
  
GO
