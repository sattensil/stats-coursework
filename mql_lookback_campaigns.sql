
-------------------------------------------------------------------------------------------------------------------------------------
--collecting all MQL's for month of jan and also 12 month look back window
-------------------------------------------------------------------------------------------------------------------------------------

drop table mci_enterprise_stage.ab_skinner_logic_step1;
create table mci_enterprise_stage.ab_skinner_logic_step1
as
select 	
	contact__c, mql_timestamp, date_sub(d.mql_timestamp, 365) as 12_mnth_wndw
from 
(
select
   a.* ,split(mql_timestamp__c,' ')[0] as mql_timestamp
from
   mdpd_temp.sfdc_inquiry_management__c a 
)d
where mql_timestamp > '2020-01-01'  and mql_timestamp < '2020-01-31' and mql_timestamp <> 'null';

-------------------------------------------------------------------------------------------------------------------------------------
-- Retrieving lead id's using contact ID
-------------------------------------------------------------------------------------------------------------------------------------

create table mci_enterprise_stage.ab_skinner_logic_step2 
as 
select
	a.*, b.id 
from 
	mci_enterprise_stage.ab_skinner_logic_step1 a 
 join
	sourcedata.sfdc_lead b 
on
	a.contact__c = b.contact__c;
	
-------------------------------------------------------------------------------------------------------------------------------------
-- Adding campaignid, firstrespondeddate to corresponding MQL and lead
-------------------------------------------------------------------------------------------------------------------------------------

create table mci_enterprise_stage.ab_skinner_logic_step3
as
select a.*, b.campaignid,b.contactid,b.firstrespondeddate
from 
    mci_enterprise_stage.ab_skinner_logic_step2 a 
join
    sourcedata.sfdc_campaignmember b
on a.id = b.leadid;

-------------------------------------------------------------------------------------------------------------------------------------
-- Exracting for firstrespondeddate between the 12 month look back window
-------------------------------------------------------------------------------------------------------------------------------------

create table mci_enterprise_stage.ab_skinner_logic_step4
as
select *
from mci_enterprise_stage.ab_skinner_logic_step3
where firstrespondeddate between 12_mnth_wndw and mql_timestamp;