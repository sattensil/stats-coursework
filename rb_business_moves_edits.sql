

-- Table contains all responses and mql's for US from week 2020-33 for ENT  + campaign exposed responses & MQL's
mci_enterprise_stage.ab_escorecard_signcampaign_enterprise

-- All opportunities + exposed Oppty's created from Week 2020-33 in US for ENT
mci_enterprise_stage.ab_campaign_oppty_ent

-- All opportunities + exposed Oppty's created from Week 2020-33 in US for MM
mci_enterprise_stage.ab_oppty_midmarket


-- all responses and mql's for US from week 2020-33 for MM + campaign exposed responses & MQL's

mci_enterprise_stage.ab_signcampaign_midmarket_pbi_scorecard

-- Visits table with account segments for US from Week 2020-33 + exposed visits

mci_enterprise_stage.ab_web_scorecard_signcampaign_pbi


select * from mci_enterprise_stage.ab_escorecard_signcampaign_enterprise limit 100;

show partitions mci_enterprise_stage.ab_escorecard_signcampaign_enterprise;

select * from mci_enterprise_stage.ab_signcampaign_midmarket_pbi_scorecard limit 100;

select week, sum(resp) from 

select * from gedi_dev.abm_sfdc_campaign_resp_sign
limit 100;

---------


----------------
-- Pull in lead opg into campaign responses
----------------


drop table gedi_dev.rb_sign_campaign_resp_test_2;
create table gedi_dev.rb_sign_campaign_resp_test_2
as
select 
a.*
,b.product_outlook_group__c


from  mci_enterprise.abm_sfdc_campaign_resp a
join sourcedata.sfdc_lead b
on a.campaignid = b.campaign_id__c
and a.leadid = b.id
-- where lower(product_outlook_group__c) in ('echosign')  
and to_date(a.createddate) >= '2020-02-29'
;


-- more accurate
-- select wk, count(*)
-- from gedi_dev.rb_sign_campaign_resp_test_2
-- where product_outlook_group__c = 'ECHOSIGN'
-- and country_code_iso2 = 'US'
-- group by wk
-- ;
-- 
-- less accurate
-- select wk, count(*)
-- from gedi_dev.rb_sign_campaign_resp_test_2
-- where major_opg1 = 'SIGN'
-- and country_code_iso2 = 'US'
-- group by wk
-- order by wk
-- ;

-- Exclude leads with  account base = 'FY20 NA Named '  from echo sign


----------------
-- Filter for sign and set funnel type using each method
----------------


drop table gedi_dev.rb_sign_campaign_resp;
create table gedi_dev.rb_sign_campaign_resp
as
select 
a.id
,a.isdeleted
,a.campaignid
,a.leadid
,a.contactid
,a.status
,a.hasresponded
,a.createddate
,a.createdbyid
,a.lastmodifieddate
,a.lastmodifiedbyid
-- ,a.systemmodstamp
-- ,a.firstrespondeddate
-- ,a.currencyisocode
-- ,a.fromma__c
-- ,a.obu_campaign_member_id__c
-- ,a.s7_campaign_member_id__c
-- ,a.source_system_name
-- ,a.edw_insert_date
-- ,a.edw_update_date
-- ,a.campaignmember_counter
-- ,a.deleted_flag
,a.tap_sub_std_name_key
,a.email
,a.sfdc_account_id
,a.qtr
,a.mon
,a.wk
,a.campaign_offer__c
,a.event_type
,a.geo
,a.market_area
,a.country_code_iso2
-- ,a.dx_persona
-- ,a.dx_persona_group
-- ,a.persona_group
,a.campaign_name
,a.type
,a.subtype
,a.tactic
,a.pmbu
,a.program_mktg
,a.bu_campaign
,a.use_case
,a.method_of_distribution
,a.exclude_from_kpi_reports
,a.bu_campaign_group
,a.offer_type
,a.offer_product_theme
,a.major_opg1
,a.major_opg2
,a.opg
,a.opg_cloud
,a.opg_include
,a.product_outlook_group__c
-- ,b.spenders_c

-- ,case when a.offer_type = 'Trial' then 'Trial'
-- when a.offer_type = 'RFI (Request for Information)' then 'RFI'
-- when b.spenders_c = 'Demand Generation' then 'Demand'
-- when b.spenders_c = 'Field Marketing' then 'Field'
-- else 'Other' end sign_funnel_type

,case 
when lower(campaign_name) like '%trial%' 
-- or lower(campaign_name) like '%appstore%' 
then 'Trial'
when lower(campaign_name) like '%request for information%' or lower(campaign_name) like '%rfi%' or lower(campaign_name) like '%sales phone%' or lower(campaign_name) like '%sales contact us%' then 'RFI'
when lower(campaign_name) like '%demand%' or lower(campaign_name) like '%wbr%' or lower(campaign_name) like '%webinar%' or lower(campaign_name) like '%owd%' or lower(campaign_name) like '%tleadwbr%' then 'Demand'
else 'Field'

-- when lower(campaign_name) like '%trial%'  or lower(campaign_name) like '%appstore%' then 'Trial'
-- when lower(campaign_name) like '%inbound%' or lower(campaign_name) like '%rfi%' or lower(campaign_name) like '%phone%' or lower(campaign_name) like '%chat%' then 'RFI'
-- when campaign_name like '%NA_FY20_Q3_Field%' or campaign_name = 'CID: NA GOV_USDA HQ-RIVERDALE_DME_Q3 FY20' or campaign_name = 'CID: NA GOV_USDA HQ-RIVERDALE_Booth_DME_Q3 FY20' then 'Field'
-- else 'Demand'
end as sign_funnel_type



from  gedi_dev.rb_sign_campaign_resp_test_2 a

-- left join mci_enterprise.uda_sfdc_campaign_std b
-- on a.campaignid=b.id

where lower(a.product_outlook_group__c) = 'echosign'

and lower(campaign_name) <> 'ww-web-trial-14day-susi-form'
and lower(campaign_name) <> 'inbound - contact us rfi'
and lower(campaign_name) <> 'missingsmbtrialcampaignid'
and lower(campaign_name) <> 'ww-partner-become a partner rfi'
and lower(campaign_name) not like '%_ccom_%'


;


select wk, sign_funnel_type, count(*)
from gedi_dev.rb_sign_campaign_resp
where country_code_iso2 = 'US'
and sign_funnel_type <> 'Other'
and wk in ('2020-33','2020-34','2020-35','2020-36','2020-37')
group by wk,sign_funnel_type
order by wk,sign_funnel_type
;



select sfdc_account_id from gedi_dev.rb_sign_campaign_resp where sfdc_account_id is not null limit 100;

-- select id from sourcedata.sfdc_account limit 100; -- 18


--- 
-- Try to Pull in Named Account flags 

drop table gedi_dev.rb_sign_campaign_resp_02;
create table gedi_dev.rb_sign_campaign_resp_02
as 
select a.*
,b.dme_named_account__c
,b.named_account__c
,b.named_account_flag
,b.named_account_flag2__c
,case when c.sub_std_name_key is not null then 1 else 0 end maha_named_account_flag
from gedi_dev.rb_sign_campaign_resp a
left join sourcedata.sfdc_account b
on a.sfdc_account_id = b.id

left join 
(select sub_std_name_key 
	from  mci_enterprise_stage.mn_dme_named_accounts_mod 
	where new_product_group ='sign' 
	and lower(market_area) ='united states'
	group by sub_std_name_key
) c
on a.tap_sub_std_name_key = c.sub_std_name_key
 
where a.country_code_iso2 = 'US'

;


select wk, sign_funnel_type, count(*)
from gedi_dev.rb_sign_campaign_resp_02
where country_code_iso2 = 'US'
and sign_funnel_type <> 'Other'
and maha_named_account_flag = 1
and wk in ('2020-33','2020-34','2020-35','2020-36','2020-37')
group by wk,sign_funnel_type
order by wk,sign_funnel_type
;


select wk, sign_funnel_type_v2, count(*)
from gedi_dev.rb_sign_campaign_resp_02
where country_code_iso2 = 'US'
and sign_funnel_type <> 'Other'
and maha_named_account_flag = 1
and wk in ('2020-33','2020-34','2020-35','2020-36','2020-37')
group by wk,sign_funnel_type_v2
order by wk,sign_funnel_type_v2
;


-- How do we isolate sign responses in corp SFDC?
-- Need to make sure that we deduplicate leads coming in from Corp SFDC with those that we import


-- this user is a batch user that maybe creates all the imported records? not sure
-- batch user: 00530000004pufSAAQ


-- ETL FROM UDA


select *
--count(distinct case when response = 1 then lower(trim(contactemail)) end) response_count
--,sum(response) response_count
--,sum(mql) mql_count
--,count(distinct AccountName) account_count
FROM [UDA_SALES].[dbo].[vw_rpt_SignMetrics]
where 
LeadTitle not LIKE '%Student%'
and LeadTitle not LIKE '%Mom%'
and LeadTitle not LIKE '%Unemployed%'
and LeadTitle not LIKE '%Retired%'
and LeadTitle not LIKE '%Housewife%'
and LeadTitle not LIKE '%House wife%'
and LeadTitle not LIKE '%Homemaker%'
and LeadSource2 NOT LIKE '%Harte Hanks%'
and LeadSource2 NOT LIKE 'WW-Web-Trial-Developer API Accounts'
and firstrespondeddate is not null
and transactiondate >= '2020-02-29'
and [AccountBase] in ( 'NA Territory'
, 'NA SMB'
,'EMEA Medium Business'
, 'EMEA SMB'
) 
--and campaign_derived = 'NA_FY20_Q3_Demand_CS_Integrate_NonNamed_SignWhyBuy'
--and upper(Region_Derived) = 'NORTH AMERICA'
and country in ('US'
,'GB'
,'United Kingdom'
,'UK'
)

and MarketingorSales_Derived  ='Marketing'


;



select count(*) from gedi_raw.uda_rpt_signmetrics_import_rb;

-- 
-- drop table gedi_raw.uda_rpt_signmetrics_import_rb purge;
-- create table gedi_raw.uda_rpt_signmetrics_import_rb (
-- 
-- AMQL string
-- ,ARR string
-- ,AccountBase string
-- ,AccountName string
-- ,AccountOwner string
-- ,AccountType string
-- ,Account_sk string
-- ,AcquisitionAsset string
-- ,AcquisitionProgram string
-- ,ActivationStage string
-- ,AdobeSFDCSync string
-- ,AgreementsSent string
-- ,AnnualRevenue string
-- ,AriaOpportunityType string
-- ,AssetChannelSource string
-- ,AssetChannelSourceOriginal string
-- ,BillingCountry string
-- ,Campaign string
-- ,CampaignAllocation string
-- ,CampaignId string
-- ,CampaignMemberName string
-- ,CampaignMemberResponded string
-- ,CampaignMemberStatus string
-- ,CampaignMemberType string
-- ,CampaignMember_sk string
-- ,CampaignName string
-- ,CampaignSpenders string
-- ,CampaignStatus string
-- ,CampaignType string
-- ,Campaign_sk string
-- ,ChannelSource string
-- ,OppCloseDate string
-- ,CommissionM1 string
-- ,CommissionM2 string
-- ,Commitment string
-- ,CompanySegment string
-- ,CompanySize string
-- ,CompanyType string
-- ,ContactEmail string
-- ,ContactFirstName string
-- ,ContactFullName string
-- ,ContactLastName string
-- ,ContactTitle string
-- ,Contact_sk string
-- ,ConvertedDate string
-- ,ConvertedOpportunityID string
-- ,Country string
-- ,CreatedBy string
-- ,OppCreatedDate string
-- ,DQOwnerName string
-- ,DQ_Date string
-- ,DQ_Reason string
-- ,DQ_Team string
-- ,DateOfActivation string
-- ,DaysSinceLastActivity string
-- ,DaysInActivation string
-- ,DealRegistrationID string
-- ,EmailOptOut string
-- ,EmailPermission string
-- ,EmployeeRange string
-- ,Employees string
-- ,EstimatedAmount string
-- ,FirstRespondedDate string
-- ,ForecastCategory string
-- ,FullName string
-- ,FunctionalArea string
-- ,Geo string
-- ,GlobalRegion string
-- ,HendrixQuote string
-- ,IMHistoryID string
-- ,INQ string
-- ,INQDate string
-- ,INQ_Status string
-- ,Industry string
-- ,InquiryManagementProduct string
-- ,IntegrationType string
-- ,JobFunction string
-- ,LastActivity string
-- ,LastActivityIdentifier string
-- ,LeadSourceContact string
-- ,LeadContactID string
-- ,LeadCreatedDate string
-- ,LeadDescription string
-- ,LeadID string
-- ,LeadOwner string
-- ,LeadRouting string
-- ,LeadScore string
-- ,LeadSource string
-- ,LeadSource2 string
-- ,LeadSourceDetail string
-- ,LeadSourceOpportunity string
-- ,LeadStatus string
-- ,LeadTeam string
-- ,LeadTitle string
-- ,Lead_sk string
-- ,LostDetail string
-- ,LostReason string
-- ,MALDate string
-- ,MQL string
-- ,MQLAGE string
-- ,MQLDate string
-- ,OppFunnelType string
-- ,MQLFunnelType string
-- ,OppMarketingOrSalesSourced string
-- ,MQLMarketingOrSalesSourced string
-- ,MarketoSync string
-- ,MemberStatus string
-- ,NewProductFamily string
-- ,NumberOfEmployees string
-- ,NumberOfEmployees1 string
-- ,OfferType string
-- ,OpportunityID string
-- ,OpportunityName string
-- ,OpportunityNumber string
-- ,OpportunityOwner string
-- ,Opportunity_sk string
-- ,OptInPhone string
-- ,OwnerRole string
-- ,Phone string
-- ,PhonePermission string
-- ,PipelineASV string
-- ,PrimaryCampaignSource string
-- ,ProductFamily string
-- ,ProductFamilyID string
-- ,QualifyingAgent string
-- ,OppRegion string
-- ,LeadRegion string
-- ,Response string
-- ,RevenueType string
-- ,SAL string
-- ,SALDate string
-- ,SalesOpsRegionMapping string
-- ,SQL string
-- ,SQLDate string
-- ,SalesUserRoleName string
-- ,ScoreAtMQL string
-- ,ScoreGrade string
-- ,SellableProduct_sk string
-- ,SolutionGroup string
-- ,SpendersMktgCredit string
-- ,Stage string
-- ,STATUS string
-- ,Team string
-- ,TeamUse string
-- ,TotalAgreementsSent string
-- ,TransactionDate string
-- ,FiscalYear string
-- ,FiscalQuarter string
-- ,FiscalWeekInQuarter string
-- ,TrialActivationDate string
-- ,TrialAgreementsSent string
-- ,TrialEmailVerification string
-- ,TrialExpiration string
-- ,TrialExpirationDate string
-- ,TrialExpired string
-- ,TrialLogin string
-- ,Type string
-- ,UDADataSource_sk string
-- ,UDA_DataSource string
-- ,User_sk string
-- ,Website string
-- ,ZoomInfoPhone string
-- ,Region_Derived string
-- ,MarketingOrSales_Derived string
-- ,Funnel_Derived string
-- ,Team_Derived string
-- ,Campaign_derived string
-- ) 
-- ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
-- WITH SERDEPROPERTIES (
--    "separatorChar" = "\t",
--     "quoteChar"     = "'",
--     "escapeChar"    = "\\"
--  )
--  tblproperties ("skip.header.line.count"="1");
-- 
-- 
-- LOAD DATA INPATH '/data/warehouse/mci_enterprise_stage/sign_leads_20200823.txt' 
-- OVERWRITE INTO TABLE gedi_raw.uda_rpt_signmetrics_import_rb;

describe mci_enterprise_stage.uda_rpt_signmetrics_import;

select transactiondate from mci_enterprise_stage.uda_rpt_signmetrics_import  limit 100;

select * from mci_enterprise_stage.ab_signcampaignmql_wk37 limit 1000;





select * from gedi_dev.sign_campaign_resp limit 1000;

-- drop this version
-- select transactiondate from gedi_raw.uda_rpt_signmetrics_import_rb limit 10;

-- select 
-- qtr
-- ,wk
-- ,fiscal_wk_in_qtr
-- ,region_derived
-- ,campaign_derived
-- ,funnel_type
-- ,sum(resp) response_count
-- ,sum(mql) mql_count
-- ,count(distinct account_name) acct_count
-- 
-- from gedi_dev.sign_campaign_resp
-- 
-- where campaign_derived = 'NA_FY20_Q3_Demand_CS_Integrate_NonNamed_SignWhyBuy'
-- in (
-- 'NA_FY20_Q3_Demand_CS_AmericanBanker_Named_FSI_SignWhyBuy'
-- ,'NA_FY20_Q3_Demand_CS_DemandWorks_Named_SignWhyBuy'
-- ,'NA_FY20_Q3_Demand_CS_DemandWorks_NonNamed_SignWhyBuy'
-- ,'NA_FY20_Q3_Demand_CS_IDG_Named_SignWhyBuy'
-- ,'NA_FY20_Q3_Demand_CS_IDG_NonNamed_SignWhyBuy')
-- 
-- and upper(Region_Derived) = 'NORTH AMERICA'
-- and qtr = '2020-Q3'
-- and fiscal_wk_in_qtr = 10
-- 	
-- 
-- group by
-- qtr
-- ,wk
-- ,fiscal_wk_in_qtr
-- ,region_derived
-- ,campaign_derived
-- ,funnel_type
-- ;





create table mci_enterprise_stage.sign_campaign_resp_weekly
(
lead_id string,
resp int,
mql int ,
funnel_type string,
region_derived string,
market_segment string,
exposure string,
)
PARTITIONED BY (week string);




create table mci_enterprise_stage.ab_escorecard_signcampaign_enterprise
(
leadid string,
resp int,
market_qualified int,
mql string ,
email string,
products string,
activity string,
funnel_type string,
lead_market_area__c string,
market_segment string,
exposure string,
)
PARTITIONED BY (week string);



-- 
-- 
-- 
-- select * from  mci_enterprise_stage.sa_camp_view_02 limit 10;
-- select * from mci_enterprise_stage.sa_exposed_leadsource limit 100;
-- 
-- 
-- select * from mci_enterprise_stage.sa_exposed_sf limit 100;
-- 
-- select leadsource from mci_enterprise_stage.sa_exposed_leadsource
-- limit 1000;







-- Account table given by Arthish
select gtm_segment, marekt_area_description, count(*) from mci_enterprise_stage.ab_accounts_list_sign
group by gtm_segment, marekt_area_description 


-- GOV	                United States	469229
-- Enterprise	        United States	1651780
-- CSMB/Unidentified	United States	8191849
-- Mid-Market	        United States	829918

select gtm_segment,market_area_description,count(distinct sub_std_name_key) from  mci_enterprise_stage.ab_accounts_list_sign
where sub_std_name_key <> -1
group by gtm_segment,market_area_description

-- GOV	                United States	6347
-- Enterprise	        United States	11794
-- CSMB/Unidentified	United States	82230
-- Mid-Market	        United States	31715










-- NEW NAMED MQL CODE

SET mapred.job.queue.name=root.adhoc.standard;
set hive.exec.compress.output=true;
set hive.exec.compress.intermediate=true;
set hive.exec.parallel.thread.number=12;
set hive.merge.mapredfiles=true;
set hive.auto.convert.join=ture;
set mapred.compress.map.output=true;
set mapred.output.compress=true;
set hive.auto.convert.join=true;
SET hive.exec.compress.output=true;
SET hive.exec.parallel=true;
SET mapred.output.compression.codec=org.apache.hadoop.io.compress.SnappyCodec;
SET mapred.output.compression.type=BLOCK;
SET mapreduce.map.memory.mb = 8192;
set hive.optimize.insert.dest.volume=true;
set mapreduce.map.java.opts = -Xmx7168m;
set hive.optimize.ppd=true;
set mapreduce.reduce.memory.mb=13312;
set mapreduce.reduce.java.opts = -Xmx7168m;

set hive.exec.dynamic.partition.mode=nonstrict;

drop table mci_enterprise_stage.rb_signcampaignleads;
create table mci_enterprise_stage.rb_signcampaignleads
as 
select
id as leadid
,lead_market_area__c market_area
,product_outlook_group__c as product
,title
,coalesce(a.email,c.email) as email
,contact__c
,leadsource
,industry
,activity_subtype__c as activity
,campaign_id__c 
,case 
when lower(campaign_name__c) like '%trial%' then 'Trial'
when lower(campaign_name__c) like '%request for information%' or lower(campaign_name__c) like '%rfi%' or lower(campaign_name__c) like '%sales phone%' or lower(campaign_name__c) like '%sales contact us%' then 'RFI'
when lower(campaign_name__c) like '%demand%' or lower(campaign_name__c) like '%wbr%' or lower(campaign_name__c) like '%webinar%' or lower(campaign_name__c) like '%owd%' or lower(campaign_name__c) like '%tleadwbr%' then 'Demand'
else 'Field'
end as funnel_type
,split(createddate,' ')[0] as response_date
,d.fiscal_yr_and_wk_desc as week
from
sourcedata.sfdc_lead a

left join warehouse.hana_ccmusage_dim_date d
on split(a.createddate,' ')[0] = d.date_date

-- get email from contact record
left join mci_enterprise.abm_sfdc_contacts_mapped c
on a.contact__c = c.contactid

-- left join (select distinct campaign_code, 'exposed' as exposure from mci_enterprise_stage.sign_bizmoves_campaign_codes where code_type = 'cid') sf
-- on upper(x.campaign_id__c) = upper(sf.campaign_code)
-- 
-- left join (select distinct campaign_code, 'exposed' as exposure from mci_enterprise_stage.sign_bizmoves_campaign_codes where code_type = 'leadsource2') l
-- on upper(x.leadsource) = upper(l.campaign_code)

where 
a.lead_market_area__c = 'United States'

and lower(a.product_outlook_group__c) in ('echosign')

and d.fiscal_yr_and_wk_desc = '2020-33'

;

describe formatted  mci_enterprise_stage.okui_lvt_profile_sample;

-------------------------------------------------------------------------------------------------------------
--STEP 1 - Create weekly table for leads(responses)  ENTERPRISE
----------------------------------------------------------------------------------------------------------

drop table mci_enterprise_stage.rb_signcampaignleads_exp;
create table mci_enterprise_stage.rb_signcampaignleads_exp
as select 
a.*
,coalesce(sf.exposure, l.exposure, 'Not-exposed') as exposure 

from mci_enterprise_stage.rb_signcampaignleads a

left join (select distinct campaign_code, 'exposed' as exposure from mci_enterprise_stage.sign_bizmoves_campaign_codes where code_type = 'cid') sf
on upper(a.campaign_id__c) = upper(sf.campaign_code)

left join (select distinct campaign_code, 'exposed' as exposure from mci_enterprise_stage.sign_bizmoves_campaign_codes where code_type = 'leadsource2') l
on upper(a.leadsource) = upper(l.campaign_code)

-- left join mci_enterprise_stage.sa_exposed_sf sf
-- on UPPER(sf.sfdc_tag) = UPPER(x.campaign_id__c)
-- 
-- left join mci_enterprise_stage.sa_exposed_leadsource l
-- on UPPER(x.leadsource) = UPPER(l.leadsource)
;


drop table mci_enterprise_stage.rb_signcampaignleads_exp_v2;
create table mci_enterprise_stage.rb_signcampaignleads_exp_v2
as select 
a.*
,coalesce(v.exposure, sf.exposure, l.exposure, 'Not-exposed') as exposure 

from mci_enterprise_stage.rb_signcampaignleads a

left join mci_enterprise_stage.sa_camp_view_02 v
on trim(lower(a.email)) = trim(lower(v.email))

left join (select distinct campaign_code, 'exposed' as exposure from mci_enterprise_stage.sign_bizmoves_campaign_codes where code_type = 'cid') sf
on upper(a.campaign_id__c) = upper(sf.campaign_code)

left join (select distinct campaign_code, 'exposed' as exposure from mci_enterprise_stage.sign_bizmoves_campaign_codes where code_type = 'leadsource2') l
on upper(a.leadsource) = upper(l.campaign_code)

-- left join mci_enterprise_stage.sa_exposed_sf sf
-- on UPPER(sf.sfdc_tag) = UPPER(x.campaign_id__c)
-- 
-- left join mci_enterprise_stage.sa_exposed_leadsource l
-- on UPPER(x.leadsource) = UPPER(l.leadsource)
;


/*MQL*/ -- Using Thomas Skinners Logic to Pull MQL

-------------------------------------------------------------------------------------------------------------
-- Inquiry Management records for Sign
-- Pull MQL data for Sign
----------------------------------------------------------------------------------------------------------

create table mci_enterprise_stage.rb_signcampaignmql_all_step1 
as 
select 
id,
contact__c,
product__c
from 
mdpd_temp.sfdc_inquiry_management__c 
where
lower(product__c) in ('sign')
;


create table mci_enterprise_stage.rb_signcampaignmql_all_step2
as
select 
a.contact__c,
a.product__c, 
c.parentid,
c.mql_timestamp
from
mci_enterprise_stage.rb_signcampaignmql_all_step1 a
left join
(
select 
parentid, field, split(newvalue,' ')[0] as mql_timestamp
from
sourcedata.sfdc_inquiry_management__history  
where
field = 'MQL_Timestamp__c'
) c
on 
a.id = c.parentid
where 
mql_timestamp >= '2020-07-11'
;

-----  get the lead id so we can join back up to the response object

create table mci_enterprise_stage.rb_signcampaignmql_all
as
select
b.id leadid,
-- is this necessary? It's always 1.
case when coalesce(a.contact__c,b.contact__c) is not null then 1 else 0 end as mql

from mci_enterprise_stage.rb_signcampaignmql_all_step2 a 

left join
sourcedata.sfdc_lead b
on a.contact__c = b.contact__c

where
lower(b.product_outlook_group__c) in ('echosign') 
and b.lead_market_area__c = 'United States'
and b.createddate >= '2020-07-11'

;
        

describe formatted mci_enterprise_stage.okui_lvt_profile_sample;



select mql, count(*) from mci_enterprise_stage.rb_signcampaignmql_all group by mql;






