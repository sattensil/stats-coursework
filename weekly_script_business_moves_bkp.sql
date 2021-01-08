

--Currently reporting for US only

***************************************************WEB VISITS**************************************************************


------------------------------------------------------------------------------------------------------------
-- Creating base table for Visits from Week 2020-33
----------------------------------------------------------------------------------------------------------

-- drop table mci_enterprise_stage.ab_weekly_webbase;
-- CREATE TABLE mci_enterprise_stage.ab_weekly_webbase
-- STORED AS ORC tblproperties( "orc.compress" = "SNAPPY", "serialization.null.format" = "") AS
-- SELECT a.click_date
--    ,coalesce(pagename,post_pagename,custom_link_page_name) pagename	
--    ,visit_key
--    ,tap_sub_std_name_key sub_std_name_key
--    ,b.fiscal_yr_and_wk_desc
--    ,c.market_area_description
-- FROM 
-- 	mcietl.web_visitor_base_v2 a
-- INNER JOIN sourcedata.dim_date b
-- 	 on a.click_date = b.date_date
-- join warehouse.country c
-- 	on lower(a.market_area_code) = lower(c.market_area_code)
-- WHERE click_date >= '2020-07-15'
--    and click_date <= '2020-08-14' 
--    and market_area_code ='US'
-- 
-- select count(*),count(distinct visit_key) from mci_enterprise_stage.ab_weekly_webbase
--2,260,022,848        	576,709,441

-- RB - new version that pulls pages based on page name.

select * from mci_enterprise_stage.sign_bizmoves_campaign_codes;

-- drop table gedi_dev.gtm_dc_adobe_sign_business_moves_campaigns;
-- create table gedi_dev.gtm_dc_adobe_sign_business_moves_campaigns 
-- STORED AS ORC tblproperties ("orc.compress"="SNAPPY") as
-- select * from sourcedata.sfdc_campaign
-- where
-- id in 
-- ('7011O000002uRoMQAU','7011O000002uTfqQAE','7011O000002uRlDQAU','7011O000002uRl8QAE','7011O000002uQcMQAU'
-- ,'7011O000002uQcHQAU','7011O000002uQbJQAU','7011O000002uQbEQAU','7011O000002uQbYQAU','7011O000002uQbdQAE'
-- ,'7011O000002uRlIQAU','7011O000002uRlSQAU','7011O000001z7agQAA','7011O000001z7alQAA','7011O000002uTfgQAE'
-- ,'7011O000002uTfMQAU','7011O000002uTfbQAE','7011O000002uQI9QAM','7011O000002uQxKQAU','7011O000002uRVSQA2'
-- ,'7011O000002uViCQAU','7011O000002dtpoQAA','7011O000002uVpcQAE','7011O000002uVoKQAU','7011O000002dtyUQAQ','7011O000002uVoAQAU')
-- ;

drop table gedi_dev.gtm_dc_adobe_sign_web_pages;
CREATE TABLE gedi_dev.gtm_dc_adobe_sign_web_pages
STORED AS ORC tblproperties( "orc.compress" = "SNAPPY", "serialization.null.format" = "") AS
--with (format = 'ORC') as
SELECT
coalesce(pagename,post_pagename,custom_link_page_name) pagename	
FROM 
	mcietl.web_visitor_base_v2 a

---Sign pages defined by the web team (8/21/2020)
WHERE (coalesce(pagename,post_pagename,custom_link_page_name) like '%acrobat.adobe.com:sign%'
   or coalesce(pagename,post_pagename,custom_link_page_name) like 'acrobat.adobe.com:documents:%'
   or coalesce(pagename,post_pagename,custom_link_page_name) like 'landing.adobe.com:products:echosign%'
   or coalesce(pagename,post_pagename,custom_link_page_name) like 'echosign.acrobat.com%'
   or coalesce(pagename,post_pagename,custom_link_page_name) like 'echosign.adobe.com%'
   or coalesce(pagename,post_pagename,custom_link_page_name) like 'adobesigndemo%'
   or coalesce(pagename,post_pagename,custom_link_page_name) like 'acrobat.adobe.com:sign:use-cases%'
   or coalesce(pagename,post_pagename,custom_link_page_name) = 'acrobat.adobe.com:business:integrations:dropbox:pricing'
   or coalesce(pagename,post_pagename,custom_link_page_name) like '%adobe.com%landing:sign:%'
   )
   and not(coalesce(pagename,post_pagename,custom_link_page_name) like 'adobesigndemoaccount%'
        or coalesce(pagename,post_pagename,custom_link_page_name) = 'acrobat.adobe.com:sign:free-trial-global-form-a'
        or coalesce(pagename,post_pagename,custom_link_page_name) = 'acrobat.adobe.com:sign:free-trial-global-form-b'
        )
;


select * from mci_enterprise.cd_sign_web_data_raw
limit 10;

----
-- ABHINAV/ARTHISH - TODO: Build table that contains subsidiary key, market_area, dme_sign_named, ecp_db_emp_range, demandbase_industry_std, etc etc
-- upstream one from Cathy's table

-- This will let us join in and restrict to enterprise when pulling in oppty data etc

---


drop table gedi_dev.gtm_dc_adobe_sign_web_base;

-- THIS WAS NEVER BUILT - STALLED, canceled after 3 hrs
-- drop table gedi_dev.gtm_dc_adobe_sign_web_base_v2;
-- create table gedi_dev.gtm_dc_adobe_sign_web_base_v2
-- with (format = 'ORC') as
-- 
-- select 
-- a.click_date
-- ,d.pagename	
-- ,a.visit_key
-- ,a.tap_sub_std_name_key sub_std_name_key
-- ,b.fiscal_yr_and_wk_desc
-- ,c.market_area_description
-- 
-- from mcietl.web_visitor_base_v2 a
-- 
-- inner join sourcedata.dim_date b
-- on cast(a.click_date as date) = cast(b.date_date as date)
-- 	 
-- inner join warehouse.country c
-- on lower(a.market_area_code) = lower(c.market_area_code)
-- 	
-- inner join gedi_dev.gtm_dc_adobe_sign_web_pages d
-- on coalesce(a.pagename,a.post_pagename,a.custom_link_page_name) = d.pagename
--        
-- where cast(a.click_date as date) >= date '2020-02-29'
-- 
-- ;


-- CREATE TABLE mci_enterprise_stage.ab_weekly_webbase_taxonomy
-- STORED AS ORC tblproperties( "orc.compress" = "SNAPPY", "serialization.null.format" = "") AS
-- select 
-- a.*,
-- case  
-- 	when products in  ('Adobe Sign: Sign','DC: Adobe Sign') then 'Sign' else 'Others' 
-- end as products,
-- (
-- select * from mci_enterprise.stage.ab_weekly_webbase
-- ) a 
-- join mci_enterprise_stage.ab_big_sign_campaign_taxonomy b
-- on lower(a.pagename) = lower(b.pagename)
-- ;

-- select count(*),count(distinct visit_key) from mci_enterprise_stage.ab_weekly_webbase
--5,908,205          	4,306,337
------------------------------------------------------------------------------------------------------------
-- Creating the account segmentation and pulling in Industry for Market segment 
----------------------------------------------------------------------------------------------------------

-- TODO: Switch this to use mci_enterprise.cd_sign_web_data_raw

drop table mci_enterprise_stage.ab_weekly_webbase_account_segmentation;
CREATE TABLE mci_enterprise_stage.ab_weekly_webbase_account_segmentation
STORED AS ORC tblproperties( "orc.compress" = "SNAPPY", "serialization.null.format" = "") AS
select A.*,D.tap_industry
,case when B.sub_std_name_key is not null then 'Named'
      when B.sub_std_name_key is null and C.sub_std_name_key is not null then 'MM'
	  else  'CSMB'
	  end as account_segment
from  
(select visit_key,mcvisid,market_area_description,sub_std_name_key,fiscal_yr_and_wk_desc from gedi_dev.sign_weekly_web_base -- RB Changed 8/22
	group by visit_key,mcvisid,market_area_description,sub_std_name_key,fiscal_yr_and_wk_desc)A
left join
(select sub_std_name_key 
	from  mci_enterprise_stage.mn_dme_named_accounts_mod 
	where new_product_group ='sign' 
	and lower(market_area) ='united states'
	group by sub_std_name_key
)B
 on A.sub_std_name_key = B.sub_std_name_key
left join
(select sub_std_name_key 
	from  mci_enterprise_stage.mn_dme_not_named_ecp 
	where new_product_group ='sign' 
	and lower(market_area_description)  = 'united states'
	group by sub_std_name_key
)C
 on A.sub_std_name_key = C.sub_std_name_key
 left join 
 (select sub_std_name_key, tap_industry
 	from ecp.hana_tap_an_rv_td_sub 
	 where lower(market_area_description)  = 'united states'
	 group by sub_std_name_key, tap_industry
) D
on A.sub_std_name_key = D.sub_std_name_key




-------------------------------------------------------------------------------------------------------------
--creating a table to show Market Segment
----------------------------------------------------------------------------------------------------------

-- This should be able to be pulled from industry_group, with some modification

create table mci_enterprise_stage.ab_sign_campaign_web_prefinal
as 
select a.*, 
    
    case when lower(tap_industry) like '%educa%' then 'EDUCATION'
             when lower(tap_industry) like '%gov%' then 'GOVERNMENT'
             else 'COMMERCIAL'
      end as market_segment
from
     mci_enterprise_stage.ab_weekly_webbase_account_segmentation a 

-------------------------------------------------------------------------------------------------------------
-- Joining with Scarlett's data 
----------------------------------------------------------------------------------------------------------
drop table mci_enterprise_stage.ab_sa_datajoin;
create table mci_enterprise_stage.ab_sa_datajoin
as
select 
visit_key,
a.mcvisid,
a.sub_std_name_key,
market_area_description ,
account_segment,
market_segment ,
case when a.mcvisid = c.mcvisid then 'exposed' else 'Not-exposed'
end as exposure,
fiscal_yr_and_wk_desc
from mci_enterprise_stage.ab_sign_campaign_web_prefinal a 
left join 
(
    select * from mci_enterprise_stage.sa_camp_view_02 b 
    where exposure = 'exposed'
) c
on a.mcvisid = c.mcvisid
GROUP by  
visit_key,
a.mcvisid,
a.sub_std_name_key,
market_area_description ,
account_segment,
market_segment ,
case when a.mcvisid = c.mcvisid then 'exposed' else 'Not-exposed'
end,
fiscal_yr_and_wk_desc


-----------------------------------------------------------------------------------------------------------
-- PBI table for holding historical Web data from Week 2020-33 (jul-15)
----------------------------------------------------------------------------------------------------------


--FOR WEB visits and account detection
drop table mci_enterprise_stage.ab_web_scorecard_signcampaign_pbi;
create table mci_enterprise_stage.ab_web_scorecard_signcampaign_pbi
(
visit_key string,
mcvisid string,
sub_std_name_key bigint,
market_area_description string,
account_flag string,
market_segment string,
exposure string
)
Partitioned By (fiscal_yr_and_wk_desc string) 

-------------------------------------------------------------------------------------------------------------
-- Inserting into PBI table 
----------------------------------------------------------------------------------------------------------

sset hive.exec.dynamic.partition.mode=nonstrict;
insert overwrite table mci_enterprise_stage.ab_web_scorecard_signcampaign_pbi
PARTITION(fiscal_yr_and_wk_desc)
select
visit_key ,
mcvisid ,
sub_std_name_key ,
market_area_description ,
account_segment ,
market_segment ,
exposure ,
fiscal_yr_and_wk_desc
from  mci_enterprise_stage.ab_sa_datajoin
--where fiscal_yr_and_wk_desc = '2020-37'    --change weekly

********************************************* RESPONSE, MQL AND OPPORTUNITY FOR ENT AND MM ****************************************

/*RESPONSES*/

-------------------------------------------------------------------------------------------------------------
--STEP 1 - Create weekly table for leads(responses)  ENTERPRISE
----------------------------------------------------------------------------------------------------------


create table mci_enterprise_stage.ab_signcampaignleads_all
as 
select 
id as leadid,
'null' as resp,
'null' as market_qualified,
'null' as mql,
x.title,
coalesce(x.email,c.email) as email,
product_outlook_group__c  as products,
activity_subtype__c as activity,
funnel_type,
lead_market_area__c,
case when lower(industry) like '%educa%' then 'EDUCATION'
when lower(industry) like '%gov%' then 'GOVERNMENT'
else 'COMMERCIAL'
end as market_segment,
case when coalesce(sf.exposure,l.exposure) = 'exposed' then 'exposed'
else 'Not-exposed'
end as exposure,  
d.fiscal_yr_and_wk_desc as week
from 

(select
  id,
  lead_market_area__c,
  product_outlook_group__c, 
  email,
  title,
  contact__c,
  leadsource,
  industry,
  activity_subtype__c, 
  campaign_id__c 
  
,case 
when lower(campaign_name__c) like '%trial%' 
-- or lower(campaign_name) like '%appstore%' 
then 'Trial'
when lower(campaign_name__c) like '%request for information%' or lower(campaign_name__c) like '%rfi%' or lower(campaign_name__c) like '%sales phone%' or lower(campaign_name__c) like '%sales contact us%' then 'RFI'
when lower(campaign_name__c) like '%demand%' or lower(campaign_name__c) like '%wbr%' or lower(campaign_name__c) like '%webinar%' or lower(campaign_name__c) like '%owd%' or lower(campaign_name__c) like '%tleadwbr%' then 'Demand'
else 'Field'
end as funnel_type,
split(createddate,' ')[0] as response_date
from
sourcedata.sfdc_lead 
where 
lead_market_area__c = 'United States'
and 
createddate >= '2020-07-11'
and 
lower(product_outlook_group__c) in ('echosign')  
  

)x 

left join  
warehouse.hana_ccmusage_dim_date d
on x.response_date = d.date_date

left join mci_enterprise.abm_sfdc_contacts_mapped c
on x.contact__c = c.contactid
left join mci_enterprise_stage.sa_exposed_sf sf
on UPPER(sf.sfdc_tag) = UPPER(x.campaign_id__c)
left join mci_enterprise_stage.sa_exposed_leadsource l
on UPPER(x.leadsource) = UPPER(l.leadsource)
;







/*MQL*/ -- Using Thomas Skinners Logic to Pull MQL

-------------------------------------------------------------------------------------------------------------
--STEP 2 - Pulling all contacts for Acrobat and Sign
----------------------------------------------------------------------------------------------------------

create table mci_enterprise_stage.ab_signcampaignmql_all_step1 
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


-- select count(*) from mci_enterprise_stage.ab_signcampaignmql_wk37_step1 
--290,572

-------------------------------------------------------------------------------------------------------------
--STEP 3 - Pulling MQL contacts for current week
----------------------------------------------------------------------------------------------------------

create table mci_enterprise_stage.ab_signcampaignmql_all_step2
as
select 
    a.contact__c,
    a.product__c, 
    c.parentid,
    c.mql_timestamp
from
    mci_enterprise_stage.ab_signcampaignmql_all_step1 a
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

-- select count(*) from mci_enterprise_stage.ab_signcampaignmql_wk37_step2_test 
-- where product__c = 'Sign'
--652

-------------------------------------------------------------------------------------------------------------
--STEP 4 - Joining with Contact table to get one-to-one mapping 
----------------------------------------------------------------------------------------------------------

-- create table mci_enterprise_stage.ab_signcampaignmql_wk37__step3
-- as
-- select a.*, b.id as contactid
-- from
--     mci_enterprise_stage.ab_signcampaignmql_wk37_step2 a
-- left join
--     sourcedata.sfdc_contact b
-- on a.contact__c = b.id
-- 
-- 
-- select count(*) from mci_enterprise_stage.ab_signcampaignmql_wk37__step3 
-- where product__c = 'Sign'
--652

-------------------------------------------------------------------------------------------------------------
--STEP 5 - MQLs (Joining with SFDC lead table) to get emails and corresponding campaign
----------------------------------------------------------------------------------------------------------

create table mci_enterprise_stage.ab_signcampaignmql_all
as
select
        'null' as leadid,
        'null' as resp,
        'null' as market_qualified,
        coalesce(a.contact__c,c.contactid) as mql,
        b.title,
        b.email as email,
        a.product__c as products,
        activity_type__c as activity
        
,case 
when lower(campaign_name__c) like '%trial%' 
-- or lower(campaign_name) like '%appstore%' 
then 'Trial'
when lower(campaign_name__c) like '%request for information%' or lower(campaign_name__c) like '%rfi%' or lower(campaign_name__c) like '%sales phone%' or lower(campaign_name__c) like '%sales contact us%' then 'RFI'
when lower(campaign_name__c) like '%demand%' or lower(campaign_name__c) like '%wbr%' or lower(campaign_name__c) like '%webinar%' or lower(campaign_name__c) like '%owd%' or lower(campaign_name__c) like '%tleadwbr%' then 'Demand'
else 'Field'
end as funnel_type,

--         case 
--             when lower(campaign_name__c) like '%trial%' or lower(campaign_name__c) like '%appstore%' then 'Trial'
--             when lower(campaign_name__c) like '%inbound%' or lower(campaign_name__c) like '%rfi%' 
--                     or lower(campaign_name__c) like '%phone%' or lower(campaign_name__c) like '%chat%' then 'RFI'
--             when campaign_name__c like '%NA_FY20_Q3_Field%'
--                  or campaign_name__c = 'CID: NA GOV_USDA HQ-RIVERDALE_DME_Q3 FY20'
--                 or campaign_name__c = 'CID: NA GOV_USDA HQ-RIVERDALE_Booth_DME_Q3 FY20'   then 'Field'
--              else 'Demand'
--         end as funnel_type,
        lead_market_area__c,
        case when lower(industry) like '%educa%' then 'EDUCATION'
             when lower(industry) like '%gov%' then 'GOVERNMENT'
             else 'COMMERCIAL'
        end as market_segment,
        coalesce(sf.exposure,l.exposure) as exposure,
        d.fiscal_yr_and_wk_desc as week
    from
        mci_enterprise_stage.ab_signcampaignmql_all_step2 a 

left join
        sourcedata.sfdc_lead b
    on
        a.contactid = b.contact__c

left join  
    warehouse.hana_ccmusage_dim_date d
    ON     a.mql_timestamp = d.date_date

left join mci_enterprise.abm_sfdc_contacts_mapped c
    on b.contact__c = c.contactid
left join mci_enterprise_stage.sa_exposed_sf sf
	on UPPER(sf.sfdc_tag) = UPPER(b.campaign_id__c)
left join mci_enterprise_stage.sa_exposed_leadsource l
	on UPPER(b.leadsource) = UPPER(l.leadsource)
where
        lower(product_outlook_group__c) in ('echosign') 
and 
            lead_market_area__c = 'United States'
and 
        createddate >= '2020-07-11'
GROUP by 
        coalesce(a.contact__c,c.contactid),
        b.email,
        b.title,
        a.product__c,
        activity_type__c ,
,case 
when lower(campaign_name__c) like '%trial%' 
-- or lower(campaign_name) like '%appstore%' 
then 'Trial'
when lower(campaign_name__c) like '%request for information%' or lower(campaign_name__c) like '%rfi%' or lower(campaign_name__c) like '%sales phone%' or lower(campaign_name__c) like '%sales contact us%' then 'RFI'
when lower(campaign_name__c) like '%demand%' or lower(campaign_name__c) like '%wbr%' or lower(campaign_name__c) like '%webinar%' or lower(campaign_name__c) like '%owd%' or lower(campaign_name__c) like '%tleadwbr%' then 'Demand'
else 'Field'
end,
        lead_market_area__c,
        case when lower(industry) like '%educa%' then 'EDUCATION'
             when lower(industry) like '%gov%' then 'GOVERNMENT'
             else 'COMMERCIAL'
        end,
        coalesce(sf.exposure,l.exposure),
        d.fiscal_yr_and_wk_desc;
        


-- select count(distinct mql) from mci_enterprise_stage.ab_signcampaignmql_wk37 
-- where products = 'Sign'
--517


-------------------------------------------------------------------------------------------------------------
--STEP 6 - Reponses and MQLs for UK (enterprise) Using  Devi's Logic 
----------------------------------------------------------------------------------------------------------

-- select 
--      Leadid 
-- 	 ,response as resp
--      ,mql as market_qualified ,
-- 	 'null' as mql
--      ,leadtitle
--      ,contactemail as email,
-- 	 NULL as products,
-- 	 NULL as activity,
-- 	 funnel_derived as funnel_type,
-- 	 case when country  = 'GB' then 'United Kingdom'
--       end as lead_market_area__c,
--      case when lower(industry) like '%educa%' then 'EDUCATION'
--            when lower(industry) like '%gov%' then 'GOVERNMENT'
--            else 'COMMERCIAL'
--       end as market_segment
--      ,case when CampaignName  in ('EMEA_FY20_Q3_Demand_CS_Leadscale_All_Sign',
-- 								   'EMEA_NO_FY20_Q3_Demand_eDM_InfoG_LondonResearch_Survey_All_Sign',
-- 								   'EMEA_NO_FY20_Q3_Demand_eDM_NewsArticle_LondonResearch_Survey_All_Sign',
-- 								   'EMEA_NO_FY20_Q3_Demand_eDM_FreeTrial_LondonResearch_Survey_All_Sign',
-- 								   'EMEA_CT_FY20_Q3_Demand_eDM_InfoG_Remote_Working_Survey_ALL_SIGN',
-- 								   'EMEA_CT_FY20_Q3_Demand_eDM_FreeTrial_Remote_Working_Survey_ALL_SIGN',
-- 								   'EMEA_CT_FY20_Q3_Demand_eDM_Business_Continuity_Overview_All_Sign',
-- 								   'EMEA_CT_FY20_Q3_Demand_eDM_Business_Continuity_Webinar_All_Sign',
-- 								   'EMEA_CT_FY20_Q3_Demand_eDM_Business_Continuity_Tutorial_All_Sign',
--                                    'EMEA_NO_FY20_Q3_Demand_CS_TechTarget_MSFT_CoSell_UK_All_Sign',
--                                    'EMEA_NO_FY20_Q3_Demand_CS_TechTarget_MSFT_HQL_CoSell_UK_All_Sign',
--                                    'EMEA_CT_FY20_Q3_Demand_CS_LeadCrunch_MSFT_PDC_DE_All_Sign',
--                                    'EMEA_NO_FY20_Q3_Demand_CS_LeadCrunch_MSFT_PDC_SE_All_Sign',
--                                    'EMEA_NO_FY20_Q3_Demand_CS_LeadCrunch_MSFT_PDC_UK_All_Sign'
-- 								  ) 
-- 		then 'Exposed'  
-- 	end as exposure,
-- 	case when FiscalWeekInQuarter = 11 then '2020-37'
-- 	end as week
-- from 
--     UDA_SALES.[dbo].vw_rpt_SignMetrics
-- where 
--     country in ('GB','United Kingdom','UK')
-- and 
--     AccountBase in ('EMEA Enterprise' , 'EMEA Enterprise Named')
-- and
--     transactiondate between '2020-08-08' and '2020-08-14';



-------------------------------------------------------------------------------------------------------------
--STEP 7 - Create table to transfer data from CSV to hadoop table 
----------------------------------------------------------------------------------------------------------

-- drop table mci_enterprise_stage.ab_signcampaign_uk_ent;
-- create table mci_enterprise_stage.ab_signcampaign_uk_ent
-- (
-- leadid string,
-- resp int,
-- market_qualified int,
-- mql string,
-- title string,
-- email string,
-- products string,
-- activity string,
-- funnel_type string,
-- lead_market_area__c string,
-- market_segment string,
-- exposure string,
-- week string
-- )
-- ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
-- 	tblproperties ("skip.header.line.count"="1");

-- Loading CSV into Hadoop
--load data inpath '/user/hive/warehouse/mci_enterprise_stage.db/sign_uk_ent_wk1437.csv' into table mci_enterprise_stage.ab_signcampaign_uk_ent;



-------------------------------------------------------------------------------------------------------------
--STEP 8 - Combining responses table and mql 
----------------------------------------------------------------------------------------------------------

-- create table mci_enterprise_stage.ab_signcampaign_wk37
-- as 
-- select * from mci_enterprise_stage.ab_signcampaignleads_wk37
-- union all
-- select * from mci_enterprise_stage.ab_signcampaignmql_wk37
-- union all 
-- select * from mci_enterprise_stage.ab_signcampaign_uk_ent;  -- from csv loaded table 
-- 
-- select count(*) from mci_enterprise_stage.ab_signcampaign_wk37 
--8621

----------

-- Named Sign Responses


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


drop table gedi_dev.sign_campaign_resp_named;
create table gedi_dev.sign_campaign_resp_named
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

,coalesce(v.exposure,sf.exposure) as exposure

from  gedi_dev.rb_sign_campaign_resp_test_2 a

left join mci_enterprise_stage.ab_signcampaignmql_all b
on a.



left join mci_enterprise_stage.sa_camp_view_02 v
on trim(lower(a.email)) = trim(lower(v.email))

left join mci_enterprise_stage.sa_exposed_sf sf
on upper(a.campaignid) = upper(sf.sfdc_tag)
	
left join mci_enterprise_stage.sa_exposed_leadsource l
on upper(a.campaign_name) = upper(l.leadsource)


where lower(a.product_outlook_group__c) = 'echosign'

and lower(campaign_name) <> 'ww-web-trial-14day-susi-form'
and lower(campaign_name) <> 'inbound - contact us rfi'
and lower(campaign_name) <> 'missingsmbtrialcampaignid'
and lower(campaign_name) <> 'ww-partner-become a partner rfi'
and lower(campaign_name) not like '%_ccom_%'


;


------------

-- NEW UDA Sourced lead/mql data


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

drop table gedi_dev.sign_campaign_resp_midmarket;
create table gedi_dev.sign_campaign_resp_midmarket
as select
d.fiscal_yr_and_qtr_desc as qtr
,d.fiscal_yr_and_per_desc as mon
,d.fiscal_yr_and_wk_desc as wk
,d.fiscal_wk_in_qtr as fiscal_wk_in_qtr
,cast(TO_DATE(from_unixtime(UNIX_TIMESTAMP(substr(a.transactiondate,0,10), 'yyyy-MM-dd'))) as date) response_date
,a.accountbase account_base
,a.accountname account_name

,case when lower(a.accountbase) in 
('na territory'
,'na smb'
,'emea medium business'
,'emea smb') then 'MID-MARKET'
when lower(a.accountbase) in ('fy20 na named'
,'fy20 na named gov'
,'fy20 na named highed') then 'NAMED'
else 'OTHER' end account_segment

,a.region_derived region_derived
,a.team_derived

,case when a.campaign_derived like '%NA_FY20_Q3_Field%' or a.campaign_derived in ('CID: NA GOV_USDA HQ-RIVERDALE_DME_Q3 FY20','CID: NA GOV_USDA HQ-RIVERDALE_Booth_DME_Q3 FY20') then 'Field' else a.funnel_derived end funnel_type

-- devi's logic monday
,case 
when lower(campaignname) like '%trial%' then 'Trial'
when lower(campaignname) like '%request for information%' or lower(campaignname) like '%rfi%' or lower(campaignname) like '%sales phone%' or lower(campaignname) like '%sales contact us%' then 'RFI'
when lower(campaignname) like '%demand%' or lower(campaignname) like '%wbr%' or lower(campaignname) like '%webinar%' or lower(campaignname) like '%owd%' or lower(campaignname) like '%tleadwbr%' then 'Demand'
else 'Field' end funnel_type_v2

,a.campaign_derived
,a.campaignid campaign_id
,case when a.country in ('GB','United Kingdom','UK') then 'UK' else a.country end country
,a.leadid lead_id
,a.leadtitle title
,a.leadsource lead_source
,a.leadsource2 lead_source_2
,lower(trim(a.contactemail)) email
,a.response as resp
,a.mql
,a.industry
,case when lower(a.industry) like '%educa%' then 'EDUCATION'
when lower(a.industry) like '%gov%' then 'GOVERNMENT'
else 'COMMERCIAL'
end as market_segment
,coalesce(v.exposure,sf.exposure,l.exposure) as exposure

from mci_enterprise_stage.uda_rpt_signmetrics_import a
-- from gedi_raw.uda_rpt_signmetrics_import_rb a

--and campaign_derived = 'NA_FY20_Q3_Demand_CS_Integrate_NonNamed_SignWhyBuy'
--and upper(Region_Derived) = 'NORTH AMERICA'

-- TODO: Duplicate leads removal  - If there exists more than one lead with same email   then consider the lead record  with latest created date 


inner join warehouse.hana_ccmusage_dim_date d
on to_date(a.transactiondate) = d.date_date

left join mci_enterprise_stage.sa_camp_view_02 v
on trim(lower(a.contactemail)) = trim(lower(v.email))

left join mci_enterprise_stage.sa_exposed_sf sf
on upper(a.campaignid) = upper(sf.sfdc_tag)
	
left join mci_enterprise_stage.sa_exposed_leadsource l
on upper(a.leadsource2) = upper(l.leadsource)

-- filters to match Devi's logic
where 

lower(a.leadtitle) not like '%student%'
and lower(a.leadtitle) not like '%mom%'
and lower(a.leadtitle) not like '%unemployed%'
and lower(a.leadtitle) not like '%retired%'
and lower(a.leadtitle) not like '%housewife%'
and lower(a.leadtitle) not like '%house wife%'
and lower(a.leadtitle) not like '%homemaker%'
and lower(a.leadsource2) not like '%harte hanks%'
and lower(a.leadsource2) not like 'ww-web-trial-developer api accounts'
and a.firstrespondeddate is not null
and lower(a.accountbase) in 
('na territory'
,'na smb'
,'emea medium business'
,'emea smb'
--,'fy20 na named'
-- removing unless we hear from Devi that we should include
-- ,'fy20 na named gov'
-- ,'fy20 na named highed'
) 

and a.country in ('US','GB','United Kingdom','UK')

and a.marketingorsales_derived = 'Marketing'

-- change this to be dynamic
-- and cast(TO_DATE(from_unixtime(UNIX_TIMESTAMP(substr(a.transactiondate,0,10), 'yyyy-MM-dd'))) as date) >= '2020-02-29'
and cast(TO_DATE(from_unixtime(UNIX_TIMESTAMP(substr(a.transactiondate,0,10), 'yyyy-MM-dd'))) as date) >= '2020-07-11'

-- and lower(campaignname) <> 'ww-web-trial-14day-susi-form'
-- and lower(campaignname) <> 'inbound - contact us rfi'
-- and lower(campaignname) <> 'missingsmbtrialcampaignid'
-- and lower(campaignname) <> 'ww-partner-become a partner rfi'
-- and lower(campaignname) not like '%_ccom_%'


;



-- TODO: MAKE SURE THIS DATA ALIGNS WITH DEVI

select count(*) from mci_enterprise_stage.uda_rpt_signmetrics_import;

-- 
-- select 
-- count(distinct case when response = 1 then lower(trim(contactemail)) end) response_count
-- ,sum(mql) mql_count
-- ,count(distinct AccountName) account_count
--   FROM [UDA_SALES].[dbo].[vw_rpt_SignMetrics]
--   where 
--    LeadTitle not LIKE '%Student%'
--   and LeadTitle not LIKE '%Mom%'
--   and LeadTitle not LIKE '%Unemployed%'
--   and LeadTitle not LIKE '%Retired%'
--   and LeadTitle not LIKE '%Housewife%'
--   and LeadTitle not LIKE '%House wife%'
--   and LeadTitle not LIKE '%Homemaker%'
-- 	and LeadSource2 NOT LIKE '%Harte Hanks%'
-- 	and LeadSource2 NOT LIKE 'WW-Web-Trial-Developer API Accounts'
-- 	and firstrespondeddate is not null
-- 	and transactiondate >= '2020-02-29'
-- 	and [AccountBase] in ( 'NA Territory'
-- 	, 'NA SMB'
-- 	,'EMEA Medium Business'
-- 	, 'EMEA SMB'
-- 	) 
-- 	and campaign_derived = 'NA_FY20_Q3_Demand_CS_Integrate_NonNamed_SignWhyBuy'
-- 	and upper(Region_Derived) = 'NORTH AMERICA'
-- 	and country in ('US'
-- 	,'GB'
-- 	,'United Kingdom'
-- 	,'UK'
-- 	)
-- 
-- 	and MarketingorSales_Derived  ='Marketing'
-- 	and fiscalweekinquarter = 10
-- 
-- ;

drop table mci_enterprise_stage.sign_campaign_resp_weekly;
create table mci_enterprise_stage.sign_campaign_resp_weekly
as 
select 
wk week
,sign_funnel_type funnel_type
,country_code_iso2 as lead_market_area_c

,case when lower(b.industry) like '%educa%' then 'EDUCATION'
when lower(b.industry) like '%gov%' then 'GOVERNMENT'
else 'COMMERCIAL'
end as market_segment

,exposure
,leadid
,email
,resp
,mql

from gedi_dev.sign_campaign_resp_named a
left join mci_enterprise.abm_enterprise_account b
on a.tap_sub_std_name_key = b.sub_std_name_key

left join (select distinct leadid, case when mql <> 'null' or mql is not null then 1 else 0 end mql) mci_enterprise_stage.ab_escorecard_signcampaign_enterprise c
on a.leadid = c.leadid

union all
select
wk week
,funnel_type_v2 funnel_type
,country as lead_market_area_c
,market_segment
,exposure
,lead_id leadid
,email
,resp
,mql

from gedi_dev.sign_campaign_resp_midmarket

;

select * from sign_campaign_resp_midmarket limit 10;

-- TESTING

select * from gedi_dev.sign_campaign_resp_named limit 1000;

-- drop this version
-- select transactiondate from gedi_raw.uda_rpt_signmetrics_import_rb limit 10;

select 
qtr
,wk
,fiscal_wk_in_qtr
,region_derived
,campaign_derived
,account_base
,funnel_type
,sum(resp) response_count
,count(distinct case when resp = 1 then lower(trim(email)) end) response_count_uniq
,sum(mql) mql_count
,count(distinct account_name) acct_count

from gedi_dev.sign_campaign_resp

where campaign_derived = 'NA_FY20_Q3_Demand_CS_Integrate_NonNamed_SignWhyBuy'
-- in (
-- 'NA_FY20_Q3_Demand_CS_AmericanBanker_Named_FSI_SignWhyBuy'
-- ,'NA_FY20_Q3_Demand_CS_DemandWorks_Named_SignWhyBuy'
-- ,'NA_FY20_Q3_Demand_CS_DemandWorks_NonNamed_SignWhyBuy'
-- ,'NA_FY20_Q3_Demand_CS_IDG_Named_SignWhyBuy'
-- ,'NA_FY20_Q3_Demand_CS_IDG_NonNamed_SignWhyBuy')

and upper(Region_Derived) = 'NORTH AMERICA'
and qtr = '2020-Q3'
and fiscal_wk_in_qtr = 10

	

group by
qtr
,wk
,fiscal_wk_in_qtr
,region_derived
,campaign_derived
,account_base
,funnel_type
;


select 
sum(resp) response_count
,count(distinct case when resp = 1 then lower(trim(email)) end) response_count_uniq
,sum(mql) mql_count
,count(distinct account_name) acct_count

from gedi_dev.sign_campaign_resp

where campaign_derived = 'NA_FY20_Q3_Demand_CS_Integrate_NonNamed_SignWhyBuy'

and upper(Region_Derived) = 'NORTH AMERICA'
and qtr = '2020-Q3'
and fiscal_wk_in_qtr = 10
;

select 
account_segment
,sum(resp) response_count
,count(distinct case when resp = 1 then lower(trim(email)) end) response_count_uniq
,sum(mql) mql_count
,count(distinct account_name) acct_count

from gedi_dev.sign_campaign_resp

where campaign_derived = 'NA_FY20_Q3_Demand_CS_Integrate_NonNamed_SignWhyBuy'

and upper(Region_Derived) = 'NORTH AMERICA'
and qtr = '2020-Q3'
and fiscal_wk_in_qtr = 10
group by account_segment
;

named - 736 230 575
mid - 1594 338 1502


na named 725 227 564
named gov 10 3 10
named hied 1 0 1



1594 resp count uniq
338
1502

-- DEVI:
-- week 10
-- Midmarket: 
1600 Resp
339 MQL

named:
682
198
547

-- This is what we expect to see

MM:
AccountBase	response_count	response_count	mql_count
NA SMB	7	7	0
NA Territory	1587	1596	337


-- AccountBase	response_count	mql_count

FY20 NA Named	732	212
FY20 NA Named Gov	10	3
FY20 NA Named HighEd	1	0
NA SMB	6	0
NA Territory	1576	318




select 
account_base
,sum(resp) response_count
,count(distinct case when resp = 1 then lower(trim(email)) end) response_count_uniq
,sum(mql) mql_count
,count(distinct account_name) acct_count

from gedi_dev.sign_campaign_resp

where campaign_derived = 'NA_FY20_Q3_Demand_CS_Integrate_NonNamed_SignWhyBuy'
and account_segment = 'NAMED'
and upper(Region_Derived) = 'NORTH AMERICA'
and qtr = '2020-Q3'
and fiscal_wk_in_qtr = 10
group by account_base
;



rb_sign_campaign_resp_named

rb_sign_campaign_resp_midmarket





-------------------------------------------------------------------------------------------------------------
--STEP 9 Creating table for PBI [Will contain all historical data] 
----------------------------------------------------------------------------------------------------------

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


-------------------------------------------------------------------------------------------------------------
--STEP 10 - Inserting ENT Responses and MQL's to PBI (Also joining with Scarlett's table to account for exposure)
----------------------------------------------------------------------------------------------------------


/* merging with scarlett table here */   
-- set hive.exec.dynamic.partition.mode=nonstrict;
-- insert overwrite table mci_enterprise_stage.ab_escorecard_signcampaign_enterprise
-- PARTITION (week)
-- select
-- leadid ,
-- resp,
-- market_qualified,
-- mql ,
-- email ,
-- products ,
-- activity ,
-- funnel_type ,
-- lead_market_area__c,
-- market_segment ,
-- coalesce(v.exposure,a.exposure) as exposure ,
-- a.week 
-- from mci_enterprise_stage.ab_signcampaign_wk37 a 
-- left join 
--     mci_enterprise_stage.sa_camp_view_02 v
--  on trim(lower(a.email)) = trim(lower(v.email))
-- where a.week is not null;
-- 
-- select * from mci_enterprise_stage.ab_signcampaign_wk37 limit 10;

------------------------------------------------------------------------------------------------------------
--STEP 11 - Opportunity (ENTERPRISE)
----------------------------------------------------------------------------------------------------------


--Step 1  Getting all exposed accounts 

CREATE TABLE mci_enterprise_stage.ab_exposure_camp
as SELECT tap_sub_std_name_key, region, min(click_date) as first_touch_date
FROM mci_enterprise_stage.sa_camp_view_02 
WHERE exposure = 'exposed' 
GROUP BY tap_sub_std_name_key, region

-- drop table mci_enterprise_stage.ab_campaign_oppty_ent_3337;
-- create table mci_enterprise_stage.ab_campaign_oppty_ent_3337



-----------------------------------------------------------------------------------------------------------------
-- The account list which has all the segmets 
-----------------------------------------------------------------------------------------------------------------
create table gedi_dev.abh_account_list_sign as 
select a.* from 
(select sub_std_name_key, market_area_description, dme_sign_named, ecp_db_emp_range,demandbase_industry_std,
demandbase_employee_range_std,abx_industry,industry_group, sign_active, gtm_segment
from mci_enterprise_stage.ab_accounts_list_sign
where sub_std_name_key <> -1
group by sub_std_name_key, market_area_description, dme_sign_named, ecp_db_emp_range,demandbase_industry_std,
demandbase_employee_range_std,abx_industry,industry_group, sign_active, gtm_segment) a


-- GOV	                N	11009
-- CSMB/Unidentified	Y	563
-- Enterprise	        N	36931
-- Enterprise	        Y	2832
-- GOV	                Y	1374
-- CSMB/Unidentified	N	105474
-- Mid-Market	        N	39902
-- Mid-Market	        Y	243

------------------------------------------------------------------------------------------------------------
--STEP 12 - Final table for Opportunity Populating the dashboard
----------------------------------------------------------------------------------------------------------

-- select * from mci_enterprise.dme_named_accounts limit 1000;
-- 
-- select * from mci_enterprise_stage.ab_exposure_camp limit 10;

-- ABHINAV - focus on this

drop table mci_enterprise_stage.ab_campaign_oppty_ent;
create table mci_enterprise_stage.ab_campaign_oppty_ent
as
select 
opp_id,
sub_std_name_key,
opp_stage_number,
sfdc_account_market_area,
opp_created_date,
opp_created_yr,	
opp_created_qtr,		
opp_created_mon,		
opp_created_wk,	
opp_opg,
opp_pipeline_creator_group,
opp_adjusted_commitment,
case when  opp_name like '%- Sign Target%' then 'Shell Opportunity(Sign)'
     when  opp_name like '%- Acrobat Target%' then 'Shell Opportunity(Acrobat)'
else 'Others'
end as shell_opp_flag,

case when b.tap_sub_std_name_key is not null then 'Exposed' else 'Not-exposed'  end as exposure
,case when opp_stage_number>= 3 or opp_adjusted_commitment = 'Won' then 1 else 0 end opp_reached_ss3  
-- ,case when opp_adjusted_commitment = 'Won' then 1 else 0 end opp_closed_won 

-- totoal opportunitites which  are created in between 2020-33 till current week
-- Total opps created in this period and are in ss3 or above and are not won and stc cq+4q 
-- Total opps creard in 2020-33 and current wk and won

-- add flags/asv for deals created in the time period and which are now won

-- ,sum(case when opp_stage_number>= 3 or opp_adjusted_commitment = 'Won' then opp_gross_asv else 0 end) total_asv
  
from mci_enterprise.abm_account_oppty_all_p2s a

left join
(select 
distinct 
tap_sub_std_name_key
,region
,first_touch_date
from mci_enterprise_stage.ab_exposure_camp 
WHERE region = 'US'
)b

on a.sub_std_name_key = b.tap_sub_std_name_key
and b.first_touch_date < b.opp_created_date

-- pull campaign responses for this sub in this market area for business moves campaigns
-- any response time prior to oppty opening
left join
(select 


from mci_enterprise_stage.sign_bizmoves_campaign_codes 
) d
on a.sub_std_name_key = d.sub_std_name_key
and b.first_touch_date < b.opp_created_date



join mci_enterprise.dme_account_status_sign c
on a.sub_std_name_key = b.sub_std_name_key
and a.market_area = 'UNITED STATES'


where a.sub_std_name_key>0 
and sfdc_account_market_area in  ('UNITED STATES')
and lower(opp_opg) in ('sign')
and opp_created_date >= '2020-07-15'



group by
opp_id,
sub_std_name_key,
opp_stage_number,
sfdc_account_market_area,
opp_created_date,
opp_created_yr,	
opp_created_qtr,		
opp_created_mon,		
opp_created_wk,	
opp_opg,
opp_pipeline_creator_group,
opp_adjusted_commitment,
case when  opp_name like '%- Sign Target%' then 'Shell Opportunity(Sign)'
     when  opp_name like '%- Acrobat Target%' then 'Shell Opportunity(Acrobat)'
else 'Others'
end
,case when b.tap_sub_std_name_key is not null then 'Exposed' else 'Not-exposed'  end


;



-- Abhinavs version
create table gedi_dev.abh_sign_enterpise_opportunities as 
SELECT
a.opp_id
,a.sub_std_name_key
,a.opp_stage_number
,a.sfdc_account_market_area
,a.opp_created_date
,a.opp_created_yr
,a.opp_created_mon
,a.opp_created_wk
,a.opp_close_date
,a.opp_close_yr
,a.opp_close_mon
,a.opp_close_wk
,a.opp_opg
,a.opp_pipeline_creator_group
,a.opp_adjusted_commitment
,d.industry
,case when lower(d.industry) like '%educa%' then 'EDUCATION'
when lower(d.industry) like '%gov%' then 'GOVERNMENT'
else 'COMMERCIAL'
end as market_segment
--,b.dme_sign_named
--,b.ecp_db_emp_range
--,b.demandbase_industry_std
--,b.demandbase_employee_range_std
--,b.abx_industry
--,b.industry_group
--,b.gtm_segment
,case when a.opp_name like '%- Sign Target%' then 'Shell Opportunity(Sign)'
     when  a.opp_name like '%- Acrobat Target%' then 'Shell Opportunity(Acrobat)'
else 'Others'
end as shell_opp_flag
,case when c.tap_sub_std_name_key is not null then 'Exposed' else 'Not-exposed' end as exposure
,case when a.opp_created_date > c.first_touch_date and a.opp_stage_number>= 3 or a.opp_adjusted_commitment = 'Won' then 'Y' else 'N' end opp_reached_ss3_y_n_flag
,case when a.opp_created_date > c.first_touch_date and a.opp_adjusted_commitment = 'Won' then 'Y' else 'N' end as opp_booking_y_n_flag
,sum(case when a.opp_created_date > c.first_touch_date and (a.opp_stage_number>= 3 or a.opp_adjusted_commitment = 'Won') then a.opp_gross_asv else 0 end) total_asv
from mci_enterprise.abm_account_oppty_all_p2s a
join 
(select * from mci_enterprise.dme_account_status_sign
where market_area = 'UNITED STATES'
) b 
on a.sub_std_name_key = b.sub_std_name_key
and lower(trim(a.sfdc_account_market_area)) = lower(trim(b.market_area))

left join
(select 
distinct 
tap_sub_std_name_key
,region
,first_touch_date
from mci_enterprise_stage.ab_exposure_camp 
WHERE region = 'US'
) c
on a.sub_std_name_key = c.tap_sub_std_name_key

left join mci_enterprise.abm_enterprise_account d 
on a.sub_std_name_key = d.sub_std_name_key 
and lower(trim(a.sfdc_account_market_area)) = lower(trim(d.hq_market_area))

where a.sub_std_name_key > 0 
and lower(opp_opg) in ('sign')
and opp_created_date >= '2020-07-15'

group by 
a.opp_id
,a.sub_std_name_key
,a.opp_stage_number
,a.sfdc_account_market_area
,a.opp_created_date
,a.opp_created_yr
,a.opp_created_mon
,a.opp_created_wk
,a.opp_close_date
,a.opp_close_yr
,a.opp_close_mon
,a.opp_close_wk
,a.opp_opg
,a.opp_pipeline_creator_group
,a.opp_adjusted_commitment
,d.industry
,case when lower(d.industry) like '%educa%' then 'EDUCATION'
when lower(d.industry) like '%gov%' then 'GOVERNMENT'
else 'COMMERCIAL'
end
--,b.dme_sign_named
--,b.ecp_db_emp_range
--,b.demandbase_industry_std
--,b.demandbase_employee_range_std
--,b.abx_industry
--,b.industry_group
--,b.gtm_segment
,case when a.opp_name like '%- Sign Target%' then 'Shell Opportunity(Sign)'
     when  a.opp_name like '%- Acrobat Target%' then 'Shell Opportunity(Acrobat)'
else 'Others'
end
,case when c.tap_sub_std_name_key is not null then 'Exposed' else 'Not-exposed' end
,case when a.opp_created_date > c.first_touch_date and a.opp_stage_number>= 3 or a.opp_adjusted_commitment = 'Won' then 'Y' else 'N' end
,case when a.opp_created_date > c.first_touch_date and a.opp_adjusted_commitment = 'Won' then 'Y' else 'N' end
;

select * from gedi_dev.abh_sign_enterrpise_opportunities limit 100;



-- Datasource : UDA
/* MID-MARKET */
-------------------------------------------------------------------------------------------------------------
--STEP 13 - Reponses and MQLs for MM (US and UK) (Using Devi's logic)
----------------------------------------------------------------------------------------------------------

select Leadid
     ,accountbase
	 ,response
     ,mql
     ,leadtitle
     ,contactemail
     ,'Sign' as Products
     ,case when lower(industry) like '%educa%' then 'EDUCATION'
           when lower(industry) like '%gov%' then 'GOVERNMENT'
           else 'COMMERCIAL'
      end as market_segment
     ,case when FiscalWeekInQuarter = 11 then '2020-37'
			end as week
     ,leadsource2
     ,leadtitle
     ,funnel_derived
	 ,case when country = 'US' then 'United States'
           when country  = 'GB' then 'United Kingdom'
      end as market_area,
	  case when LeadSource2  in ('NA-Demand-Email-Nurture-Prospect Nurture',
								  'NA_FY20_Q3_Demand_CS_AmericanBanker_Named_FSI_SignWhyBuy',
								  'NA_FY20_Q3_Demand_CS_ODW451Research_CBSi_BusinessMoves',
								  'NA_FY20_Q3_Demand_CS_Demandworks_Named_SignWhyBuy',
								  'NA_FY20_Q2_Demand_CS_Demandworks_NonNamed_SignWhyBuy',
								  'NA_FY20_Q3_Demand_CS_IDG_Named_SignWhyBuy',
								  'NA_FY20_Q3_Demand_CS_IDG_NonNamed_SignWhyBuy',
								  'NA_FY20_Q3_Demand_CS_Integrate_Named_SignWhyBuy',
								  'NA_FY20_Q3_Demand_CS_Integrate_NonNamed_SignWhyBuy',
								  'NA_FY20_Q3_Demand_CS_MadisonLogic_Named_SignWhyBuy',
								  'NA_FY20_Q3_Demand_CS_MadisonLogic_NonNamed_SignWhyBuy',
								  'NA_FY20_Q3_Demand_CS_PureB2b_Named_SignWhyBuy',
								  'NA_FY20_Q3_Demand_CS_PureB2b_NonNamed_SignWhyBuy',
								  'NA_FY20_Q3_Demand_CS_TechTarget_Named_SignWhyBuy',
								  'NA_FY20_Q3_Demand_CS_TechTarget_NonNamed_SignWhyBuy',
								  'NA_FY20_Q3_Demand_CS_ODW451Research_MadisonLogic_Named_BusinessMoves',
								  'NA_FY20_Q3_Demand_CS_ODW451Research_TechTarget_BusinessMoves',
								  'NA_FY20_Q3_Demand_CS_ODWCovid19RethiningBusiness_TechTarget_BusinessMoves',
                                  'NA_FY20_Q3_Field_TLeadWbr_451Research_LinkedIn_July14_All_Sign',
                                  'NA_FY20_Q3_Field_TleadWbr_451Research_TechTarget_July14_All_Sign',
                                  'EMEA_FY20_Q3_Demand_CS_Leadscale_All_Sign',
								   'EMEA_NO_FY20_Q3_Demand_eDM_InfoG_LondonResearch_Survey_All_Sign',
								   'EMEA_NO_FY20_Q3_Demand_eDM_NewsArticle_LondonResearch_Survey_All_Sign',
								   'EMEA_NO_FY20_Q3_Demand_eDM_FreeTrial_LondonResearch_Survey_All_Sign',
								   'EMEA_CT_FY20_Q3_Demand_eDM_InfoG_Remote_Working_Survey_ALL_SIGN',
								   'EMEA_CT_FY20_Q3_Demand_eDM_FreeTrial_Remote_Working_Survey_ALL_SIGN',
								   'EMEA_CT_FY20_Q3_Demand_eDM_Business_Continuity_Overview_All_Sign',
								   'EMEA_CT_FY20_Q3_Demand_eDM_Business_Continuity_Webinar_All_Sign',
								   'EMEA_CT_FY20_Q3_Demand_eDM_Business_Continuity_Tutorial_All_Sign',
                                   'EMEA_NO_FY20_Q3_Demand_CS_TechTarget_MSFT_CoSell_UK_All_Sign',
                                   'EMEA_NO_FY20_Q3_Demand_CS_TechTarget_MSFT_HQL_CoSell_UK_All_Sign',
                                   'EMEA_CT_FY20_Q3_Demand_CS_LeadCrunch_MSFT_PDC_DE_All_Sign',
                                   'EMEA_NO_FY20_Q3_Demand_CS_LeadCrunch_MSFT_PDC_SE_All_Sign',
                                   'EMEA_NO_FY20_Q3_Demand_CS_LeadCrunch_MSFT_PDC_UK_All_Sign')
    then 'exposed'
	else 'not-exposed'
end as exposure
from   uda_sales.dbo.vw_rpt_SignMetrics
where AccountBase in ('NA Territory', 'NA SMB','EMEA Medium Business', 'EMEA SMB')
and country in ('US','GB')
and fiscalquarter = 'Q3'
and transactiondate between '2020-08-08' and '2020-08-14'
and fiscalyear = '2020'
and MarketingorSales_Derived  ='Marketing'



-------------------------------------------------------------------------------------------------------------
--STEP 14 - Create table to transfer data from CSV to hadoop table 
----------------------------------------------------------------------------------------------------------

--holds US and UK (new table is created for every week)
drop table mci_enterprise_stage.ab_signcampaign_midmarket
create table mci_enterprise_stage.ab_signcampaign_midmarket
(
leadid string,
account_base string,
response_lead int,
mql_lead int ,
email string,
product string,
market_segment string,
leadsource2 string,
job_title string,
funnel_type string,
market_area string,
exposure string,
week string
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
	tblproperties ("skip.header.line.count"="1");

--CHECKS for week 2020-37
--Responses
select count(distinct leadid)
from mci_enterprise_stage.ab_signcampaign_midmarket 
where response_lead =1
and market_area = 'United States'
--8,483

--MQL
select count(distinct leadid)
from mci_enterprise_stage.ab_signcampaign_midmarket 
where mql_lead =1
and market_area = 'United States'
--1,443


---------------------------------------------------------------------------------------------------------------------------
Loading CSV into Hadoop

[hdpprod@or1hdp006 ~]$
[hdpprod@or1hdp006 ~]$su lat30054
Password:
[lat30054@or1hdp006 /user/hdpprod]$hive -e"load data inpath '/user/hive/warehouse/mci_enterprise_stage.db/us_uk_mm_signcampaign_v1.csv' into table mci_enterprise_stage.ab_signcampaign_midmarket;"

--load data inpath '/user/hive/warehouse/mci_enterprise_stage.db/us_uk_mm_signcampaign_v1.csv' into table mci_enterprise_stage.ab_signcampaign_midmarket;

-------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------
--STEP 15  - Create table to push weekly data for PBI  [Contains historic data starting from week 2020-33]
----------------------------------------------------------------------------------------------------------

create table mci_enterprise_stage.ab_signcampaign_midmarket_pbi_scorecard
(
leadid string,
account_base string,
response_lead int,
mql_lead int ,
email string,
product string,
market_segment string,
leadsource2 string,
job_title string,
funnel_type string,
market_area string,
exposure string
)
PARTITIONED BY (week string);

-- Inserting Weekly data into PBI table 

set hive.exec.dynamic.partition.mode=nonstrict;
insert overwrite table mci_enterprise_stage.ab_signcampaign_midmarket_pbi_scorecard
PARTITION (week)
select 
leadid, 
account_base ,
response_lead ,
mql_lead ,
email ,
product ,
market_segment ,
leadsource2 ,
job_title ,
funnel_type ,
market_area ,
coalesce(v.exposure,a.exposure) as exposure ,
week 
from mci_enterprise_stage.ab_signcampaign_midmarket a 
left join 
    mci_enterprise_stage.sa_camp_view_02 v
 on trim(lower(a.email)) = trim(lower(v.email));


/*
To find responses and mqls,
--For response, Reponse_lead = 1 
--For MQLs , mql_lead = 1
*/


-------------------------------------------------------------------------------------------------------------
--STEP 16 - Opportunity Numbers for MidMarket and also using campaign name to check for campaign exposure
----------------------------------------------------------------------------------------------------------


select 
    OpportunityID,
	ForecastCategory,
	Stage,
    country,
    case when FiscalWeekInQuarter = 11 then '2020-37'
         end as fiscal_wk,
	   case when lower(industry) like '%educa%' then 'EDUCATION'
           when lower(industry) like '%gov%' then 'GOVERNMENT'
           else 'COMMERCIAL'
      end as market_segment,
	case when CampaignName  in ('NA-Demand-Email-Nurture-Prospect Nurture',
								  'NA_FY20_Q3_Demand_CS_AmericanBanker_Named_FSI_SignWhyBuy',
								  'NA_FY20_Q3_Demand_CS_ODW451Research_CBSi_BusinessMoves',
								  'NA_FY20_Q3_Demand_CS_Demandworks_Named_SignWhyBuy',
								  'NA_FY20_Q2_Demand_CS_Demandworks_NonNamed_SignWhyBuy',
								  'NA_FY20_Q3_Demand_CS_IDG_Named_SignWhyBuy',
								  'NA_FY20_Q3_Demand_CS_IDG_NonNamed_SignWhyBuy',
								  'NA_FY20_Q3_Demand_CS_Integrate_Named_SignWhyBuy',
								  'NA_FY20_Q3_Demand_CS_Integrate_NonNamed_SignWhyBuy',
								  'NA_FY20_Q3_Demand_CS_MadisonLogic_Named_SignWhyBuy',
								  'NA_FY20_Q3_Demand_CS_MadisonLogic_NonNamed_SignWhyBuy',
								  'NA_FY20_Q3_Demand_CS_PureB2b_Named_SignWhyBuy',
								  'NA_FY20_Q3_Demand_CS_PureB2b_NonNamed_SignWhyBuy',
								  'NA_FY20_Q3_Demand_CS_TechTarget_Named_SignWhyBuy',
								  'NA_FY20_Q3_Demand_CS_TechTarget_NonNamed_SignWhyBuy',
								  'NA_FY20_Q3_Demand_CS_ODW451Research_MadisonLogic_Named_BusinessMoves',
								  'NA_FY20_Q3_Demand_CS_ODW451Research_TechTarget_BusinessMoves',
								  'NA_FY20_Q3_Demand_CS_ODWCovid19RethiningBusiness_TechTarget_BusinessMoves',
                                  'NA_FY20_Q3_Field_TLeadWbr_451Research_LinkedIn_July14_All_Sign',
                                  'NA_FY20_Q3_Field_TleadWbr_451Research_TechTarget_July14_All_Sign',
                                  'EMEA_FY20_Q3_Demand_CS_Leadscale_All_Sign',
								   'EMEA_NO_FY20_Q3_Demand_eDM_InfoG_LondonResearch_Survey_All_Sign',
								   'EMEA_NO_FY20_Q3_Demand_eDM_NewsArticle_LondonResearch_Survey_All_Sign',
								   'EMEA_NO_FY20_Q3_Demand_eDM_FreeTrial_LondonResearch_Survey_All_Sign',
								   'EMEA_CT_FY20_Q3_Demand_eDM_InfoG_Remote_Working_Survey_ALL_SIGN',
								   'EMEA_CT_FY20_Q3_Demand_eDM_FreeTrial_Remote_Working_Survey_ALL_SIGN',
								   'EMEA_CT_FY20_Q3_Demand_eDM_Business_Continuity_Overview_All_Sign',
								   'EMEA_CT_FY20_Q3_Demand_eDM_Business_Continuity_Webinar_All_Sign',
								   'EMEA_CT_FY20_Q3_Demand_eDM_Business_Continuity_Tutorial_All_Sign',
                                   'EMEA_NO_FY20_Q3_Demand_CS_TechTarget_MSFT_CoSell_UK_All_Sign','
                                   EMEA_NO_FY20_Q3_Demand_CS_TechTarget_MSFT_HQL_CoSell_UK_All_Sign',
                                   'EMEA_CT_FY20_Q3_Demand_CS_LeadCrunch_MSFT_PDC_DE_All_Sign',
                                   'EMEA_NO_FY20_Q3_Demand_CS_LeadCrunch_MSFT_PDC_SE_All_Sign',
                                   'EMEA_NO_FY20_Q3_Demand_CS_LeadCrunch_MSFT_PDC_UK_All_Sign') 
		then 'Exposed'
		else 'Not-exposed'
	end as exposure,
	sum(pipelineASV) as pipe
from 
uda_sales.dbo.vw_rpt_SignMetrics
where AccountBase in ('NA Territory', 'NA SMB','EMEA Medium Business', 'EMEA SMB')
and country in ('US','GB')
and fiscalquarter = 'Q3'
and OppCreatedDate between '2020-08-08' and '2020-08-14'
and fiscalyear = '2020'
group by 
    OpportunityID,
	ForecastCategory,
	stage,
    country,
    case when FiscalWeekInQuarter = 11 then '2020-37'
        end,
	   case when lower(industry) like '%educa%' then 'EDUCATION'
           when lower(industry) like '%gov%' then 'GOVERNMENT'
           else 'COMMERCIAL'
      end,
	case when CampaignName  in ('NA-Demand-Email-Nurture-Prospect Nurture',
								  'NA_FY20_Q3_Demand_CS_AmericanBanker_Named_FSI_SignWhyBuy',
								  'NA_FY20_Q3_Demand_CS_ODW451Research_CBSi_BusinessMoves',
								  'NA_FY20_Q3_Demand_CS_Demandworks_Named_SignWhyBuy',
								  'NA_FY20_Q2_Demand_CS_Demandworks_NonNamed_SignWhyBuy',
								  'NA_FY20_Q3_Demand_CS_IDG_Named_SignWhyBuy',
								  'NA_FY20_Q3_Demand_CS_IDG_NonNamed_SignWhyBuy',
								  'NA_FY20_Q3_Demand_CS_Integrate_Named_SignWhyBuy',
								  'NA_FY20_Q3_Demand_CS_Integrate_NonNamed_SignWhyBuy',
								  'NA_FY20_Q3_Demand_CS_MadisonLogic_Named_SignWhyBuy',
								  'NA_FY20_Q3_Demand_CS_MadisonLogic_NonNamed_SignWhyBuy',
								  'NA_FY20_Q3_Demand_CS_PureB2b_Named_SignWhyBuy',
								  'NA_FY20_Q3_Demand_CS_PureB2b_NonNamed_SignWhyBuy',
								  'NA_FY20_Q3_Demand_CS_TechTarget_Named_SignWhyBuy',
								  'NA_FY20_Q3_Demand_CS_TechTarget_NonNamed_SignWhyBuy',
								  'NA_FY20_Q3_Demand_CS_ODW451Research_MadisonLogic_Named_BusinessMoves',
								  'NA_FY20_Q3_Demand_CS_ODW451Research_TechTarget_BusinessMoves',
								  'NA_FY20_Q3_Demand_CS_ODWCovid19RethiningBusiness_TechTarget_BusinessMoves',
                                  'NA_FY20_Q3_Field_TLeadWbr_451Research_LinkedIn_July14_All_Sign',
                                  'NA_FY20_Q3_Field_TleadWbr_451Research_TechTarget_July14_All_Sign',
                                  'EMEA_FY20_Q3_Demand_CS_Leadscale_All_Sign',
								   'EMEA_NO_FY20_Q3_Demand_eDM_InfoG_LondonResearch_Survey_All_Sign',
								   'EMEA_NO_FY20_Q3_Demand_eDM_NewsArticle_LondonResearch_Survey_All_Sign',
								   'EMEA_NO_FY20_Q3_Demand_eDM_FreeTrial_LondonResearch_Survey_All_Sign',
								   'EMEA_CT_FY20_Q3_Demand_eDM_InfoG_Remote_Working_Survey_ALL_SIGN',
								   'EMEA_CT_FY20_Q3_Demand_eDM_FreeTrial_Remote_Working_Survey_ALL_SIGN',
								   'EMEA_CT_FY20_Q3_Demand_eDM_Business_Continuity_Overview_All_Sign',
								   'EMEA_CT_FY20_Q3_Demand_eDM_Business_Continuity_Webinar_All_Sign',
								   'EMEA_CT_FY20_Q3_Demand_eDM_Business_Continuity_Tutorial_All_Sign',
                                   'EMEA_NO_FY20_Q3_Demand_CS_TechTarget_MSFT_CoSell_UK_All_Sign','
                                   EMEA_NO_FY20_Q3_Demand_CS_TechTarget_MSFT_HQL_CoSell_UK_All_Sign',
                                   'EMEA_CT_FY20_Q3_Demand_CS_LeadCrunch_MSFT_PDC_DE_All_Sign',
                                   'EMEA_NO_FY20_Q3_Demand_CS_LeadCrunch_MSFT_PDC_SE_All_Sign',
                                   'EMEA_NO_FY20_Q3_Demand_CS_LeadCrunch_MSFT_PDC_UK_All_Sign')  
		then 'Exposed'
		else 'Not-exposed'
	end;

-----------------------------------------------------------------------------------------------------------
--STEP 17 Create table to transfer data from CSV to hadoop table 
----------------------------------------------------------------------------------------------------------

-- Same Table is dropped and created weekly
drop table mci_enterprise_stage.ab_oppty_midmarket;
create table mci_enterprise_stage.ab_oppty_midmarket
(
    opportunityID string,
	ForecastCategory string,
	Stage string,
    country string,
    market_segment string,
    exposure string,
    pipe bigint,
    fiscal_wk string
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
	tblproperties ("skip.header.line.count"="1");


Loading data into Hadoop
--load data inpath '/user/hive/warehouse/mci_enterprise_stage.db/wk3337_mm_oppty_na.csv' into table mci_enterprise_stage.ab_oppty_midmarket;

-------------------------------------------------------------------------------------------------------------
--STEP 18  - Create table to push weekly data for PBI  [Contains historic data starting from week 2020-33]
----------------------------------------------------------------------------------------------------------

create table mci_enterprise_stage.ab_signcampaign_midmarketoppty_pbi_scorecard
(
    opportunityID string,
	ForecastCategory string,
	Stage string,
    country string,
    market_segment string,
    exposure string,
    pipe bigint
)
PARTITIONED BY (fiscal_wk string);

--Inserting weekly data into PBI

set hive.exec.dynamic.partition.mode=nonstrict;
insert overwrite table mci_enterprise_stage.ab_signcampaign_midmarketoppty_pbi_scorecard
PARTITION (fiscal_wk)
select 
opportunityID ,
	ForecastCategory ,
	Stage ,
    country ,
    market_segment ,
    exposure ,
    pipe,
    fiscal_wk
from mci_enterprise_stage.ab_oppty_midmarket


-----------------------------------------------------------------------------------------------------------------
-- Final collated table containing all Enterprise and Midmarket (except opportunity) 
-----------------------------------------------------------------------------------------------------------------
**************Note: THIS TABLE DOES NOT POPULATE THE DASHBOARD*******************
--ONLY FOR SQL QUERIES AND CHECKS

create table mci_enterprise_stage.ab_final_leadmql_wk33_37 
as
select
leadid, 
resp as response_lead,
market_qualified,
mql ,
email ,
products as product ,
market_segment ,
funnel_type ,
title,
lead_market_area__c,
exposure ,
week,
'Enterprise' as segment 
from mci_enterprise_stage.ab_escorecard_signcampaign_enterprise a
union all 
select
leadid, 
response_lead ,
mql_lead  as market_qualified,
case when mql_lead = 1 then leadid end as mql,
email ,
product ,
market_segment ,
funnel_type ,
market_area  as lead_market_area__c,
exposure ,
week ,
'mid-market' as segment
from mci_enterprise_stage.ab_signcampaign_midmarket_pbi_scorecard b


describe mci_enterprise_stage.ab_final_leadmql_wk33_37 ;

********************************************************************END***************************************************************************
