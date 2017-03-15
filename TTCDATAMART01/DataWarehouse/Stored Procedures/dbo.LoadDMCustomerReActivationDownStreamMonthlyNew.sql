SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  
CREATE PROCEDURE [dbo].[LoadDMCustomerReActivationDownStreamMonthlyNew]  
as  
begin  
 set nocount on  
  
If OBJECT_ID('Marketing.DMCustomerReActivationDownStreamMonthlyNew') is not null   
drop table Marketing.DMCustomerReActivationDownStreamMonthlyNew  
   
 Select DMO.Customerkey,  
        DS1moSales = sum(case when DOwnStreamDays < 30  
            AND SequenceNum > 1 AND FinalSales < 1500 then FinalSales else 0 end),  
        DS2moSales = sum(case when DOwnStreamDays < 60  
            AND SequenceNum > 1 AND FinalSales < 1500 then FinalSales else 0 end),  
        DS3moSales = sum(case when DOwnStreamDays < 90  
            AND SequenceNum > 1 AND FinalSales < 1500 then FinalSales else 0 end),  
        DS4moSales = sum(case when DOwnStreamDays < 120  
            AND SequenceNum > 1 AND FinalSales < 1500 then FinalSales else 0 end),  
        DS5moSales = sum(case when DOwnStreamDays < 150  
            AND SequenceNum > 1 AND FinalSales < 1500 then FinalSales else 0 end),  
        DS6moSales = sum(case when DOwnStreamDays < 180  
            AND SequenceNum > 1 AND FinalSales < 1500 then FinalSales else 0 end),  
        DS7moSales = sum(case when DOwnStreamDays < 210  
            AND SequenceNum > 1 AND FinalSales < 1500 then FinalSales else 0 end),  
        DS8moSales = sum(case when DOwnStreamDays < 240  
            AND SequenceNum > 1 AND FinalSales < 1500 then FinalSales else 0 end),  
        DS9moSales = sum(case when DOwnStreamDays < 270  
            AND SequenceNum > 1 AND FinalSales < 1500 then FinalSales else 0 end),  
        DS10moSales = sum(case when DOwnStreamDays < 300  
            AND SequenceNum > 1 AND FinalSales < 1500 then FinalSales else 0 end),  
        DS11moSales = sum(case when DOwnStreamDays < 330  
            AND SequenceNum > 1 AND FinalSales < 1500 then FinalSales else 0 end),  
        DS12moSales = sum(case when DOwnStreamDays < 360  
            AND SequenceNum > 1 AND FinalSales < 1500 then FinalSales else 0 end),  
        DS24moSales = sum(case when DOwnStreamDays < 730  
            AND SequenceNum > 1 AND FinalSales < 1500 then FinalSales else 0 end),  
        DS36moSales = sum(case when DOwnStreamDays < 1095  
            AND SequenceNum > 1 AND FinalSales < 1500 then FinalSales else 0 end),  
        DS48moSales = sum(case when DOwnStreamDays < 1460  
            AND SequenceNum > 1 AND FinalSales < 1500 then FinalSales else 0 end),  
        DS60moSales = sum(case when DOwnStreamDays < 1825  
            AND SequenceNum > 1 AND FinalSales < 1500 then FinalSales else 0 end),  
        DS72moSales = sum(case when DOwnStreamDays < 2190  
            AND SequenceNum > 1 AND FinalSales < 1500 then FinalSales else 0 end),  
        DS84moSales = sum(case when DOwnStreamDays < 2555  
            AND SequenceNum > 1 AND FinalSales < 1500 then FinalSales else 0 end),  
        DS96moSales = sum(case when DOwnStreamDays < 2920  
            AND SequenceNum > 1 AND FinalSales < 1500 then FinalSales else 0 end),  
        DS108moSales = sum(case when DOwnStreamDays < 3285  
            AND SequenceNum > 1 AND FinalSales < 1500 then FinalSales else 0 end),  
        DS120moSales = sum(case when DOwnStreamDays < 3650  
            AND SequenceNum > 1 AND FinalSales < 1500 then FinalSales else 0 end),  
        DS132moSales = sum(case when DOwnStreamDays < 4015  
            AND SequenceNum > 1 AND FinalSales < 1500 then FinalSales else 0 end),  
        DS144moSales = sum(case when DOwnStreamDays < 4380  
            AND SequenceNum > 1 AND FinalSales < 1500 then FinalSales else 0 end),  
        DS156moSales = sum(case when DOwnStreamDays < 4745  
            AND SequenceNum > 1 AND FinalSales < 1500 then FinalSales else 0 end),  
        DS168moSales = sum(case when DOwnStreamDays < 5110  
            AND SequenceNum > 1 AND FinalSales < 1500 then FinalSales else 0 end),  
        DS180moSales = sum(case when DOwnStreamDays < 5475  
            AND SequenceNum > 1 AND FinalSales < 1500 then FinalSales else 0 end),  
        DS1moOrders = sum(case when DOwnStreamDays < 30  
            AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),  
        DS2moOrders = sum(case when DOwnStreamDays < 60  
            AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),  
        DS3moOrders = sum(case when DOwnStreamDays < 90  
            AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),  
        DS4moOrders = sum(case when DOwnStreamDays < 120  
            AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),  
        DS5moOrders = sum(case when DOwnStreamDays < 150  
            AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),  
        DS6moOrders = sum(case when DOwnStreamDays < 180  
            AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),  
        DS7moOrders = sum(case when DOwnStreamDays < 210  
            AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),  
        DS8moOrders = sum(case when DOwnStreamDays < 240  
            AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),  
        DS9moOrders = sum(case when DOwnStreamDays < 270  
            AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),  
        DS10moOrders = sum(case when DOwnStreamDays < 300  
            AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),  
        DS11moOrders = sum(case when DOwnStreamDays < 330  
            AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),  
        DS12moOrders = sum(case when DOwnStreamDays < 360  
            AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),  
        DS24moOrders = sum(case when DOwnStreamDays < 730  
            AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),  
        DS36moOrders = sum(case when DOwnStreamDays < 1095  
            AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),  
        DS48moOrders = sum(case when DOwnStreamDays < 1460  
            AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),  
        DS60moOrders = sum(case when DOwnStreamDays < 1825  
            AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),  
        DS72moOrders = sum(case when DOwnStreamDays < 2190  
            AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),  
        DS84moOrders = sum(case when DOwnStreamDays < 2555  
            AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),  
        DS96moOrders = sum(case when DOwnStreamDays < 2920  
            AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),  
        DS108moOrders = sum(case when DOwnStreamDays < 3285  
            AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),  
        DS120moOrders = sum(case when DOwnStreamDays < 3650  
            AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),  
        DS132moOrders = sum(case when DOwnStreamDays < 4015  
            AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),  
        DS144moOrders = sum(case when DOwnStreamDays < 4380  
            AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),  
        DS156moOrders = sum(case when DOwnStreamDays < 4745  
            AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),  
        DS168moOrders = sum(case when DOwnStreamDays < 5110  
            AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),  
        DS180moOrders = sum(case when DOwnStreamDays < 5475  
            AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),  
        DS1moFlagRepeatByr = max(case when DOwnStreamDays < 30  
            AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),    
        DS2moFlagRepeatByr = max(case when DOwnStreamDays < 60  
            AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),  
        DS3moFlagRepeatByr = max(case when DOwnStreamDays < 90  
            AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),  
        DS4moFlagRepeatByr = max(case when DOwnStreamDays < 120  
            AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),  
        DS5moFlagRepeatByr = max(case when DOwnStreamDays < 150  
            AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),  
        DS6moFlagRepeatByr = max(case when DOwnStreamDays < 180  
            AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),  
        DS7moFlagRepeatByr = max(case when DOwnStreamDays < 210  
            AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),  
        DS8moFlagRepeatByr = max(case when DOwnStreamDays < 240  
            AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),  
        DS9moFlagRepeatByr = max(case when DOwnStreamDays < 270  
            AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),  
        DS10moFlagRepeatByr = max(case when DOwnStreamDays < 300  
            AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),  
        DS11moFlagRepeatByr = max(case when DOwnStreamDays < 330  
            AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),  
        DS12moFlagRepeatByr = max(case when DOwnStreamDays < 360  
            AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),  
        DS24moFlagRepeatByr = max(case when DOwnStreamDays < 730  
            AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),  
        DS36moFlagRepeatByr = max(case when DOwnStreamDays < 1095  
            AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),  
        DS48moFlagRepeatByr = max(case when DOwnStreamDays < 1460  
            AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),  
        DS60moFlagRepeatByr = max(case when DOwnStreamDays < 1825  
            AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),  
        DS72moFlagRepeatByr = max(case when DOwnStreamDays < 2190  
            AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),  
        DS84moFlagRepeatByr = max(case when DOwnStreamDays < 2555  
            AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),  
        DS96moFlagRepeatByr = max(case when DOwnStreamDays < 2920  
            AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),  
        DS108moFlagRepeatByr = max(case when DOwnStreamDays < 3285  
            AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),  
        DS120moFlagRepeatByr = max(case when DOwnStreamDays < 3650  
            AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),  
        DS132moFlagRepeatByr = max(case when DOwnStreamDays < 4015  
            AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),  
        DS144moFlagRepeatByr = max(case when DOwnStreamDays < 4380  
            AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),  
        DS156moFlagRepeatByr = max(case when DOwnStreamDays < 4745  
            AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),  
        DS168moFlagRepeatByr = max(case when DOwnStreamDays < 5110  
            AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),  
        DS180moFlagRepeatByr = max(case when DOwnStreamDays < 5475  
            AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),  
        DS1moOrderUnits = sum(case when DOwnStreamDays < 30  
            AND SequenceNum > 1 AND FinalSales < 1500 AND TotalCourseQuantity > 0 then TotalCourseQuantity else 0 end),  
        DS2moOrderUnits = sum(case when DOwnStreamDays < 60  
            AND SequenceNum > 1 AND FinalSales < 1500 AND TotalCourseQuantity > 0 then TotalCourseQuantity else 0 end),  
        DS3moOrderUnits = sum(case when DOwnStreamDays < 90  
            AND SequenceNum > 1 AND FinalSales < 1500 AND TotalCourseQuantity > 0 then TotalCourseQuantity else 0 end),  
        DS4moOrderUnits = sum(case when DOwnStreamDays < 120  
            AND SequenceNum > 1 AND FinalSales < 1500 AND TotalCourseQuantity > 0 then TotalCourseQuantity else 0 end),  
        DS5moOrderUnits = sum(case when DOwnStreamDays < 150  
            AND SequenceNum > 1 AND FinalSales < 1500 AND TotalCourseQuantity > 0 then TotalCourseQuantity else 0 end),  
        DS6moOrderUnits = sum(case when DOwnStreamDays < 180  
            AND SequenceNum > 1 AND FinalSales < 1500 AND TotalCourseQuantity > 0 then TotalCourseQuantity else 0 end),  
        DS7moOrderUnits = sum(case when DOwnStreamDays < 210  
            AND SequenceNum > 1 AND FinalSales < 1500 AND TotalCourseQuantity > 0 then TotalCourseQuantity else 0 end),  
        DS8moOrderUnits = sum(case when DOwnStreamDays < 240  
            AND SequenceNum > 1 AND FinalSales < 1500 AND TotalCourseQuantity > 0 then TotalCourseQuantity else 0 end),  
        DS9moOrderUnits = sum(case when DOwnStreamDays < 270  
            AND SequenceNum > 1 AND FinalSales < 1500 AND TotalCourseQuantity > 0 then TotalCourseQuantity else 0 end),  
        DS10moOrderUnits = sum(case when DOwnStreamDays < 300  
            AND SequenceNum > 1 AND FinalSales < 1500 AND TotalCourseQuantity > 0 then TotalCourseQuantity else 0 end),  
        DS11moOrderUnits = sum(case when DOwnStreamDays < 330  
            AND SequenceNum > 1 AND FinalSales < 1500 AND TotalCourseQuantity > 0 then TotalCourseQuantity else 0 end),  
        DS12moOrderUnits = sum(case when DOwnStreamDays < 360  
            AND SequenceNum > 1 AND FinalSales < 1500 AND TotalCourseQuantity > 0 then TotalCourseQuantity else 0 end),  
        DS24moOrderUnits = sum(case when DOwnStreamDays < 730  
            AND SequenceNum > 1 AND FinalSales < 1500 AND TotalCourseQuantity > 0 then TotalCourseQuantity else 0 end),  
        DS36moOrderUnits = sum(case when DOwnStreamDays < 1095  
            AND SequenceNum > 1 AND FinalSales < 1500 AND TotalCourseQuantity > 0 then TotalCourseQuantity else 0 end),  
        DS48moOrderUnits = sum(case when DOwnStreamDays < 1460  
            AND SequenceNum > 1 AND FinalSales < 1500 AND TotalCourseQuantity > 0 then TotalCourseQuantity else 0 end),  
        DS60moOrderUnits = sum(case when DOwnStreamDays < 1825  
            AND SequenceNum > 1 AND FinalSales < 1500 AND TotalCourseQuantity > 0 then TotalCourseQuantity else 0 end),  
        DS72moOrderUnits = sum(case when DOwnStreamDays < 2190  
            AND SequenceNum > 1 AND FinalSales < 1500 AND TotalCourseQuantity > 0 then TotalCourseQuantity else 0 end),  
        DS84moOrderUnits = sum(case when DOwnStreamDays < 2555  
            AND SequenceNum > 1 AND FinalSales < 1500 AND TotalCourseQuantity > 0 then TotalCourseQuantity else 0 end),  
        DS96moOrderUnits = sum(case when DOwnStreamDays < 2920  
            AND SequenceNum > 1 AND FinalSales < 1500 AND TotalCourseQuantity > 0 then TotalCourseQuantity else 0 end),  
        DS108moOrderUnits = sum(case when DOwnStreamDays < 3285  
            AND SequenceNum > 1 AND FinalSales < 1500 AND TotalCourseQuantity > 0 then TotalCourseQuantity else 0 end),  
        DS120moOrderUnits = sum(case when DOwnStreamDays < 3650  
            AND SequenceNum > 1 AND FinalSales < 1500 AND TotalCourseQuantity > 0 then TotalCourseQuantity else 0 end),  
        DS132moOrderUnits = sum(case when DOwnStreamDays < 4015  
            AND SequenceNum > 1 AND FinalSales < 1500 AND TotalCourseQuantity > 0 then TotalCourseQuantity else 0 end),  
        DS144moOrderUnits = sum(case when DOwnStreamDays < 4380  
            AND SequenceNum > 1 AND FinalSales < 1500 AND TotalCourseQuantity > 0 then TotalCourseQuantity else 0 end),  
        DS156moOrderUnits = sum(case when DOwnStreamDays < 4745  
            AND SequenceNum > 1 AND FinalSales < 1500 AND TotalCourseQuantity > 0 then TotalCourseQuantity else 0 end),  
        DS168moOrderUnits = sum(case when DOwnStreamDays < 5110  
            AND SequenceNum > 1 AND FinalSales < 1500 AND TotalCourseQuantity > 0 then TotalCourseQuantity else 0 end),  
        DS180moOrderUnits = sum(case when DOwnStreamDays < 5475  
            AND SequenceNum > 1 AND FinalSales < 1500 AND TotalCourseQuantity > 0 then TotalCourseQuantity else 0 end),  
  isnull(max(Email.DS1moEmailContacts),0) as DS1moEmailContacts,   
  isnull(max(Email.DS2moEmailContacts),0) as DS2moEmailContacts,   
  isnull(max(Email.DS3moEmailContacts),0) as DS3moEmailContacts,   
  isnull(max(Email.DS6moEmailContacts),0) as DS6moEmailContacts,   
  isnull(max(Email.DS12moEmailContacts),0) as DS12moEmailContacts,   
  isnull(max(Email.DS18moEmailContacts),0) as DS18moEmailContacts,   
  isnull(max(Email.DS24moEmailContacts),0) as DS24moEmailContacts,  
  isnull(max(Mail.DS1momailContacts),0) as DS1momailContacts,   
  isnull(max(Mail.DS2momailContacts),0) as DS2momailContacts,   
  isnull(max(Mail.DS3momailContacts),0) as DS3momailContacts,   
  isnull(max(Mail.DS6momailContacts),0) as DS6momailContacts,   
  isnull(max(Mail.DS12momailContacts),0) as DS12momailContacts,   
  isnull(max(Mail.DS18momailContacts),0) as DS18momailContacts,   
  isnull(max(Mail.DS24momailContacts),0) as DS24momailContacts              
 Into Marketing.DMCustomerReActivationDownStreamMonthlyNew    
    from DataWarehouse.Marketing.DMCustomerReActivationOrders DMO (nolock)  
    left join DataWarehouse.Marketing.DMEmailCustomerReActivationContactDownStream Email (nolock)  
    on DMO.Customerkey = Email.Customerkey  
    left join DataWarehouse.Marketing.DMmailCustomerReActivationContactDownStream Mail (nolock)  
    on DMO.Customerkey = Mail.Customerkey  
    group by DMO.Customerkey      
      
end  
  
  
  
  
GO
