ab_dry_run_script_business_moves



--Total campaign Codes = 23

/* WEB DATA */
------------------------------------------------------------------------------------------------------------
-- PBI table for holding historical data
----------------------------------------------------------------------------------------------------------


--FOR ENTERPRISE
drop table mci_enterprise_stage.ab_web_scorecard_signcampaign_pbi;
create table mci_enterprise_stage.ab_web_scorecard_signcampaign_pbi
(
visit_key string,
mcvisid string,
tap_sub_std_name_key bigint,
sub_name string,
pageviews bigint,
email string,
products string,
visit_geo string,
geo_country string,
market_area_description string,
--partition column always goes last
persona string,
dx_persona_group string,
industry string,
employee_range string,
revenue_range string,
account_flag string,
employee_segment string,
market_segment string,
exposure string
)
Partitioned By (fiscal_yr_and_wk_desc string) 

-------------------------------------------------------------------------------------------------------------
--creating a table for showing visits at employee range level
----------------------------------------------------------------------------------------------------------
--leveraging the DME dashboard to extract the visits based on employee size,but need to revise this approach
-- still working on this.

drop table mci_enterprise_stage.ab_sign_campaign_web_wk34;
create table mci_enterprise_stage.ab_sign_campaign_web_wk35
as 
select a.*, 
    case when a.employee_range in ('1-9') then 'Micro-business' 
         when a.employee_range in ('10-99') then 'Small-business' 
         when a.employee_range in ('100-499', '500-999','Under 1K') then 'Mid-Market' (100>)
         when a.employee_range in ('1000-4999','5000','5000+','<10K','> 10K','> 1K','> 3K','> 5K','> 5k',
                '>10K','>10k') then 'Enterprise'
         else 'Unidentified' 
    end as employee_segment,
    case when account_flag = 'Non ECP' then 'CSMB' 
         else account_flag
    end as account_type,
    case when lower(industry) like '%educa%' then 'EDUCATION'
             when lower(industry) like '%gov%' then 'GOVERNMENT'
             else 'COMMERCIAL'
      end as market_segment
from
     mci_enterprise_stage.ab_dmedashboard_summary_prefinal_wk35 a 
    --where  fiscal_yr_and_wk_desc  = '2020-34';

-------------------------------------------------------------------------------------------------------------
-- Joining with Scarlett's data 
----------------------------------------------------------------------------------------------------------
drop table mci_enterprise_stage.ab_sa_datajoin_wk35;
create table mci_enterprise_stage.ab_sa_datajoin_wk35
as
select 
visit_key,
a.mcvisid,
a.tap_sub_std_name_key,
subname,
count(a.pagename) as pageviews,
a.email,
products,
visit_geo,
geo_country ,
market_area_description ,
--partition column always goes last
persona ,
dx_persona_group ,
industry ,
employee_range ,
revenue_range ,
account_type,
employee_segment ,
market_segment ,
case when  a.visid = c.visid then 'Exposed' else 'Not-exposed'
end as exposure,
fiscal_yr_and_wk_desc
from mci_enterprise_stage.ab_sign_campaign_web_wk35 a 
left join 
(
    select * from mci_enterprise_stage.sa_camp_view_02 b 
    where click_date between '2020-07-25' and '2020-07-31'
    and exposure = 'Exposed'
) c
on a.visid = c.visid
GROUP by  
visit_key,a.mcvisid, a.tap_sub_std_name_key,subname,a.email,products,visit_geo,
geo_country ,market_area_description ,persona , dx_persona_group , industry ,
employee_range , revenue_range , account_flag , employee_segment , market_segment ,
case when  a.visid = c.visid then 'Exposed' else 'Not-exposed'
end,
fiscal_yr_and_wk_desc;

-------------------------------------------------------------------------------------------------------------
-- Inserting into PBI table 
----------------------------------------------------------------------------------------------------------

set hive.exec.dynamic.partition.mode=nonstrict;
insert overwrite table mci_enterprise_stage.ab_web_scorecard_signcampaign_pbi
PARTITION(fiscal_yr_and_wk_desc)
select
visit_key,
a.mcvisid,
a.tap_sub_std_name_key,
subname,
pageviews,
a.email,
products,
visit_geo,
geo_country ,
market_area_description ,
--partition column always goes last
persona ,
dx_persona_group ,
industry ,
employee_range ,
revenue_range ,
account_type as account_flag ,
employee_segment ,
market_segment ,
exposure,
fiscal_yr_and_wk_desc
from  mci_enterprise_stage.ab_sa_datajoin_wk35 a 
where fiscal_yr_and_wk_desc = '2020-35'



/*RESPONSES*/

-------------------------------------------------------------------------------------------------------------
--STEP 1 - Create weekly table for leads(responses)
----------------------------------------------------------------------------------------------------------

drop table mci_enterprise_stage.ab_signcampaignleads;
create table mci_enterprise_stage.ab_signcampaignleads_wk33_35
as 
select 
        id as leadid,
        'null' as resp,
        'null' as market_qualified,
        'null' as mql,
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
         contact__c,
         leadsource,
         industry,
         activity_subtype__c, 
         campaign_id__c, 
         case 
        when lower(campaign_name__c) like '%trial%' or lower(campaign_name__c) like '%appstore%' then 'Trial'
        when lower(campaign_name__c) like '%inbound%' or lower(campaign_name__c) like '%rfi%' 
                or lower(campaign_name__c) like '%phone%' or lower(campaign_name__c) like '%chat%' then 'RFI'
        when campaign_name__c like '%NA_FY20_Q3_Field%' 
                or campaign_name__c = 'CID: NA GOV_USDA HQ-RIVERDALE_DME_Q3 FY20'
                or campaign_name__c = 'CID: NA GOV_USDA HQ-RIVERDALE_Booth_DME_Q3 FY20' then 'Field'
    else 'Demand'
    end as funnel_type,
         split(createddate,' ')[0] as response_date
     from
         sourcedata.sfdc_lead 
     where 
         lead_market_area__c  = 'United States'
     and 
        createddate between '2020-07-15' and '2020-07-31'
     and 
        lower(product_outlook_group__c) in ('echosign','acrobat')   --Including acrobat as per requirement
     )x 
--appending fiscal week 
left join  
    warehouse.hana_ccmusage_dim_date d
 on      x.response_date = d.date_date
--filter for campaign exposure
left join mci_enterprise.abm_sfdc_contacts_mapped c
    on x.contact__c = c.contactid
left join mci_enterprise_stage.sa_exposed_sf sf
	on UPPER(sf.sfdc_tag) = UPPER(x.campaign_id__c)
left join mci_enterprise_stage.sa_exposed_leadsource l
	on UPPER(x.leadsource) = UPPER(l.leadsource)
;

-- Count for dates b/w 7/15 to 7/24
--select count(distinct email), count(distinct leadid)
--from mci_enterprise_stage.ab_signcampaignleads
--where products = 'ECHOSIGN'
----867   900


-------------------------------------------------------------------------------------------------------------
--STEP 2 - Pulling all contacts for Acrobat and Sign
----------------------------------------------------------------------------------------------------------
drop table mci_enterprise_stage.ab_signcampaignmql_wk34_step1; 
create table mci_enterprise_stage.ab_signcampaignmql_wk33_35_step1 
as 
select 
    id,
    contact__c,
    product__c
from 
    mdpd_temp.sfdc_inquiry_management__c-- has data until 25th july 
where
     lower(product__c) in ('sign','acrobat');

-- DCE does not exist in this table 

-------------------------------------------------------------------------------------------------------------
--STEP 2 - Pulling MQL contacts for current week
----------------------------------------------------------------------------------------------------------
drop table mci_enterprise_stage.ab_signcampaignmql_wk34_step2;
create table mci_enterprise_stage.ab_signcampaignmql_wk33_35_step2
as
select 
    a.contact__c,
    a.product__c, 
    c.parentid,
    c.mql_timestamp
from
    mci_enterprise_stage.ab_signcampaignmql_wk34_step1 a
left join
    (
        select 
            parentid, field, split(newvalue,' ')[0] as mql_timestamp
        from
            sourcedata.sfdc_inquiry_management__history       --  upto 20th july)
        where
             field = 'MQL_Timestamp__c'
    ) c
on 
    a.id = c.parentid
where 
    mql_timestamp between '2020-07-25' and '2020-07-31';

--select count(distinct contact__c), product__c from mci_enterprise_stage.ab_mql_q2_sign_acrobat group by product__c
sign -
Acrobat - 


-------------------------------------------------------------------------------------------------------------
--STEP 3 - Joining with Contact table to get one-to-one mapping 
----------------------------------------------------------------------------------------------------------

drop table mci_enterprise_stage.ab_signcampaignmql_wk34_step3;
create table mci_enterprise_stage.ab_signcampaignmql_wk33_35_step3
as
select a.*, b.id as contactid
from
    mci_enterprise_stage.ab_signcampaignmql_wk33_35_step2 a
left join
    sourcedata.sfdc_contact b
on a.contact__c = b.id

--select count(distinct id), product__c from mci_enterprise_stage.ab_mql_q2_contactid  group by product__c
sign - 177
Acrobat - 28


-------------------------------------------------------------------------------------------------------------
--STEP 4 - MQLs (Joining with lead table) to get emails and corresponding campaign
----------------------------------------------------------------------------------------------------------
--ab_camp_dryrun_mql_final
drop table mci_enterprise_stage.ab_signcampaignmql_wk34;
drop table mci_enterprise_stage.ab_signcampaignmql_wk35;
create table mci_enterprise_stage.ab_signcampaignmql_wk35
as
select
        'null' as leadid,
        'null' as resp,
        'null' as market_qualified,
        coalesce(a.contact__c,c.contactid) as mql,
        b.email as email,
        a.product__c as products,
        activity_type__c as activity,
        case 
            when lower(campaign_name__c) like '%trial%' or lower(campaign_name__c) like '%appstore%' then 'Trial'
            when lower(campaign_name__c) like '%inbound%' or lower(campaign_name__c) like '%rfi%' 
                    or lower(campaign_name__c) like '%phone%' or lower(campaign_name__c) like '%chat%' then 'RFI'
            when campaign_name__c like '%NA_FY20_Q3_Field%'
                 or campaign_name__c = 'CID: NA GOV_USDA HQ-RIVERDALE_DME_Q3 FY20'
                or campaign_name__c = 'CID: NA GOV_USDA HQ-RIVERDALE_Booth_DME_Q3 FY20'   then 'Field'
             else 'Demand'
        end as funnel_type,
        lead_market_area__c,
        case when lower(industry) like '%educa%' then 'EDUCATION'
             when lower(industry) like '%gov%' then 'GOVERNMENT'
             else 'COMMERCIAL'
        end as market_segment,
        coalesce(sf.exposure,l.exposure) as exposure,
        d.fiscal_yr_and_wk_desc as week
    from
        mci_enterprise_stage.ab_signcampaignmql_wk35_step3 a 
 --appending email,industry,activity and creating funnel types
left join
        sourcedata.sfdc_lead b
    on
        a.contactid = b.contact__c
--appending fiscal week 
left join  
    warehouse.hana_ccmusage_dim_date d
    ON     a.mql_timestamp = d.date_date
    --filter for campaign exposure
left join mci_enterprise.abm_sfdc_contacts_mapped c
    on b.contact__c = c.contactid
left join mci_enterprise_stage.sa_exposed_sf sf
	on UPPER(sf.sfdc_tag) = UPPER(b.campaign_id__c)
left join mci_enterprise_stage.sa_exposed_leadsource l
	on UPPER(b.leadsource) = UPPER(l.leadsource)
where
        lower(product_outlook_group__c) in ('echosign','acrobat') 
and 
            lead_market_area__c = 'United States'
GROUP by 
        coalesce(a.contact__c,c.contactid),
        b.email,
        a.product__c,
        activity_type__c ,
        case 
            when lower(campaign_name__c) like '%trial%' or lower(campaign_name__c) like '%appstore%' then 'Trial'
            when lower(campaign_name__c) like '%inbound%' or lower(campaign_name__c) like '%rfi%' 
                    or lower(campaign_name__c) like '%phone%' or lower(campaign_name__c) like '%chat%' then 'RFI'
            when campaign_name__c like '%NA_FY20_Q3_Field%'
                 or campaign_name__c = 'CID: NA GOV_USDA HQ-RIVERDALE_DME_Q3 FY20'
                or campaign_name__c = 'CID: NA GOV_USDA HQ-RIVERDALE_Booth_DME_Q3 FY20'   then 'Field'
             else 'Demand'
        end ,
        lead_market_area__c,
        case when lower(industry) like '%educa%' then 'EDUCATION'
             when lower(industry) like '%gov%' then 'GOVERNMENT'
             else 'COMMERCIAL'
        end,
        coalesce(sf.exposure,l.exposure),
        d.fiscal_yr_and_wk_desc;


 

 --code is modified to join with responses table in order to have a single table for enterprise Leads

--select count(distinct mql),products  from mci_enterprise_stage.ab_mql_q2_product 
-- group by products

Sign 121
Acrobat 12


-

-------------------------------------------------------------------------------------------------------------
--STEP 5 - Combining responses and mql (to reduce complications in powerbi)
----------------------------------------------------------------------------------------------------------

/* merging with scarlett table here */   line 953 camp_view_02
--ab_camp_dryrun_final
drop table mci_enterprise_stage.ab_signcamp_preview_wk34;
create table mci_enterprise_stage.ab_signcampaign_wk35
as 
select * from mci_enterprise_stage.ab_signcampaignleads_wk35
union all
select * from mci_enterprise_stage.ab_signcampaignmql_wk35
union all 
select * from mci_enterprise_stage.ab_signcampaign_uk_ent;  -- from csv loaded table 



--create table mci_enterprise_stage.ab_signcampaign_uk_ent
--(
--leadid string,
--resp int,
--market_qualified int,
--mql string,
--email string,
--products string,
--activity string,
--funnel_type string,
--lead_market_area__c string,
--market_segment string,
--exposure string,
--week string
--)
--ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
--	tblproperties ("skip.header.line.count"="1");
--
--
--load data inpath '/user/hive/warehouse/mci_enterprise_stage.db/week_35_UK_ent.csv' into table mci_enterprise_stage.ab_signcampaign_uk_ent;


--create table mci_enterprise_stage.ab_escorecard_signcampaign_enterprise
--(
--leadid string,
--resp int,
--market_qualified int,
--mql string ,
--email string,
--products string,
--activity string,
--funnel_type string,
--lead_market_area__c string,
--market_segment string,
--exposure string,
--)
--PARTITIONED BY (week string);

set hive.exec.dynamic.partition.mode=nonstrict;
insert overwrite table mci_enterprise_stage.ab_escorecard_signcampaign_enterprise
PARTITION (week)
select
leadid ,
resp,
market_qualified,
mql ,
email ,
products ,
activity ,
funnel_type ,
lead_market_area__c ,
market_segment ,
exposure ,
week
from 
    mci_enterprise_stage.ab_signcampaign_wk35
where week = '2020-35'
;


------------------------------------------------------------------------------------------------------------
--STEP 6 - Opportunity (ENT)
----------------------------------------------------------------------------------------------------------
/* will be a separate table in PBI */

--created
drop table mci_enterprise_stage.ab_campaign_oppty_wk34;
create table mci_enterprise_stage.ab_campaign_oppty_wk34
as
select opp_id,a.sub_std_name_key,b.opg,a.opp_created_date,opp_pipeline_creator_group,
opp_adjusted_commitment,d.exposure,total_asv,sfdc_account_market_area,opp_stage_number,
x.fiscal_yr_and_wk_desc
from
(
select opp_id,
sub_std_name_key,
opp_stage_number,
sfdc_account_market_area,
opp_created_date,
opp_pipeline_creator_group,
opp_adjusted_commitment,
case when opp_created_date between '2020-07-15' and '2020-07-31'
then sum(opp_gross_asv) else 0 
end as total_asv
from mci_enterprise.abm_account_oppty_all_p2s
where sub_std_name_key>0 
and sfdc_account_market_area in  ('UNITED STATES', 'UNITED KINGDOM')
and lower(opp_opg) in  ('sign','acrobat')
group by
opp_id,
sub_std_name_key,
opp_stage_number,
sfdc_account_market_area,
opp_created_date,
opp_pipeline_creator_group,
opp_adjusted_commitment
) a 
join 
    mci_enterprise_stage.abm_contact_activity_inq_mql_sal_final b 
on a.sub_std_name_key = b.sub_std_name_key
and lower(a.sfdc_account_market_area) = lower(b.market_area)
left join 
    sourcedata.sfdc_lead c 
on 
    b.contact_id = c.contact__c
left join
    mci_enterprise_stage.sa_exposed_sf d 
on 
    upper(c.campaign_id__c) = upper(d.sfdc_tag)
left join 
    warehouse.hana_ccmusage_dim_date x
ON     
    a.opp_created_date = x.date_date
where b.opg in ('SIGN','ACROBAT')
and c.product_outlook_group__c in ('ECHOSIGN','Acrobat')
group by    
opp_id,a.sub_std_name_key,b.opg,a.opp_created_date,opp_pipeline_creator_group,
opp_adjusted_commitment,d.exposure,total_asv,sfdc_account_market_area,opp_stage_number,
x.fiscal_yr_and_wk_desc;

----including all Opp_adjusted_commitment for later requirements
--
--
--
 Datasource : UDA
-------------------------------------------------------------------------------------------------------------
--STEP 7 - Reponses and MQLs for EMEA (enterprise)
----------------------------------------------------------------------------------------------------------

select 
     Leadid 
	 ,response as resp
     ,mql as market_qualified ,
	 'null' as mql
     ,contactemail as email,
	 NULL as products,
	 NULL as activity,
	 funnel_derived as funnel_type,
	 case --when country = 'US' then 'United States'
           when country  = 'GB' then 'United Kingdom'
      end as lead_market_area__c,
     case when lower(industry) like '%educa%' then 'EDUCATION'
           when lower(industry) like '%gov%' then 'GOVERNMENT'
           else 'COMMERCIAL'
      end as market_segment
     ,case when CampaignName  in ('EMEA_FY20_Q3_Demand_CS_Leadscale_All_Sign',
								   'EMEA_NO_FY20_Q3_Demand_eDM_InfoG_LondonResearch_Survey_All_Sign',
								   'EMEA_NO_FY20_Q3_Demand_eDM_NewsArticle_LondonResearch_Survey_All_Sign',
								   'EMEA_NO_FY20_Q3_Demand_eDM_FreeTrial_LondonResearch_Survey_All_Sign',
								   'EMEA_CT_FY20_Q3_Demand_eDM_InfoG_Remote_Working_Survey_ALL_SIGN',
								   'EMEA_CT_FY20_Q3_Demand_eDM_FreeTrial_Remote_Working_Survey_ALL_SIGN',
								   'EMEA_CT_FY20_Q3_Demand_eDM_Business_Continuity_Overview_All_Sign',
								   'EMEA_CT_FY20_Q3_Demand_eDM_Business_Continuity_Webinar_All_Sign',
								   'EMEA_CT_FY20_Q3_Demand_eDM_Business_Continuity_Tutorial_All_Sign'
								  ) 
		then 'Exposed'
	end as exposure,
	case when FiscalWeekInQuarter = 08 then '2020-34'
	end as week
from 
    UDA_SALES.[dbo].vw_rpt_SignMetrics
where 
    country in ('GB','United Kingdom','UK')
and 
    AccountBase in ('EMEA Enterprise' , 'EMEA Enterprise Named')
and
    transactiondate between '2020-07-18' and '2020-07-24'

/* MID-MARKET */
-------------------------------------------------------------------------------------------------------------
--STEP 7 - Reponses and MQLs for MM (US and UK)
----------------------------------------------------------------------------------------------------------


select Leadid
     ,accountbase
	 ,response
     ,mql
     ,contactemail
     ,'Sign' as Products
     ,case when lower(industry) like '%educa%' then 'EDUCATION'
           when lower(industry) like '%gov%' then 'GOVERNMENT'
           else 'COMMERCIAL'
      end as market_segment
     ,case when FiscalWeekInQuarter = 08 then '2020-34'
			else '2020-33'
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
								   'EMEA_CT_FY20_Q3_Demand_eDM_Business_Continuity_Tutorial_All_Sign')
    then 'exposed'
	else 'not-exposed'
end as exposure
from   uda_sales.dbo.vw_rpt_SignMetrics
where AccountBase in ('NA Territory', 'NA SMB','EMEA Medium Business', 'EMEA SMB')
and country in ('US','GB')
and fiscalquarter = 'Q3'
and transactiondate between '2020-07-15' and '2020-07-24'
and fiscalyear = '2020'
and MarketingorSales_Derived  ='Marketing'

--Validation 
--select sum(response),sum(mql)
--from uda_sales.dbo.vw_rpt_SignMetrics
--where AccountBase in ('NA Territory', 'NA SMB')
--and transactiondate between '2020-07-25' and '2020-07-31'
--and country = 'US'
--and funnel_derived = 'Trial'    (change funnel type as per requirement)
-- and MarketingOrSales_derived = 'Marketing'
--and Region_derived = 'North America'
--and leadsource2 <> 'WW-Web-Trial-14Day-SUSI-Form'

--Reponses = 284, mql = 76

-------------------------------------------------------------------------------------------------------------
--STEP  - Create table to transfer data from CSV to hadoop table 
----------------------------------------------------------------------------------------------------------

--holds US and UK as of wk 35
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


---------------------------------------------------------------------------------------------------------------------------
--putty load

[hdpprod@or1hdp006 ~]$
[hdpprod@or1hdp006 ~]$su lat30054
Password:
[lat30054@or1hdp006 /user/hdpprod]$hive -e"load data inpath '/user/hive/warehouse/mci_enterprise_stage.db/us_uk_mm_signcampaign_v1.csv' into table mci_enterprise_stage.ab_signcampaign_midmarket;"

--load data inpath '/user/hive/warehouse/mci_enterprise_stage.db/us_uk_mm_signcampaign_v1.csv' into table mci_enterprise_stage.ab_signcampaign_midmarket;

-------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------
--STEP  - Create table to push weekly data for PBI 
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
exposure ,
week 
from mci_enterprise_stage.ab_signcampaign_midmarket













/*
To find responses and mqls,
--For response, Reponse = 1 
-- For MQLs , MQL = 1
*/


-------------------------------------------------------------------------------------------------------------
--STEP 9 - Opportunity
----------------------------------------------------------------------------------------------------------


select 
    OpportunityID,
	ForecastCategory,
	Stage,
    country,
    case when FiscalWeekInQuarter = 09 then '2020-35'
         when FiscalWeekInQuarter = 08 then '2020-34'
			else '2020-33'
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
								   'EMEA_CT_FY20_Q3_Demand_eDM_Business_Continuity_Tutorial_All_Sign') 
		then 'Exposed'
		else 'Not-exposed'
	end as exposure,
	sum(pipelineASV) as pipe
from 
uda_sales.dbo.vw_rpt_SignMetrics
where AccountBase in ('NA Territory', 'NA SMB','EMEA Medium Business', 'EMEA SMB')
and country in ('US','GB')
and fiscalquarter = 'Q3'
and OppCreatedDate between '2020-07-15' and '2020-07-31'
and fiscalyear = '2020'
group by 
    OpportunityID,
	ForecastCategory,
	stage,
    country,
    case when FiscalWeekInQuarter = 09 then '2020-35'
         when FiscalWeekInQuarter = 08 then '2020-34'
			else '2020-33'
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
								  'NA_FY20_Q3_Demand_CS_ODWCovid19RethiningBusiness_TechTarget_BusinessMoves'
                                  'NA_FY20_Q3_Field_TLeadWbr_451Research_LinkedIn_July14_All_Sign',
                                  'NA_FY20_Q3_Field_TleadWbr_451Research_TechTarget_July14_All_Sign') 
		then 'Exposed'
		else 'Not-exposed'
	end;




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

--load data inpath '/user/hive/warehouse/mci_enterprise_stage.db/mm_oppty.csv' into table mci_enterprise_stage.ab_oppty_midmarket;


drop table mci_enterprise_stage.ab_oppty_midmarket_wk3335;
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



--------------------------Ignore------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
--Test for campaign exposure
-----------------------------------------------------------------------------------------------------------------

drop table mci_enterprise_stage.ab_test_campaign;
create table mci_enterprise_stage.ab_test_campaign
as 
select a.mcvisid,a.visit_key,a.email,a.click_date,a.market_area_code,
        coalesce(
			case when length(split(a.sfdc_campaign_code,'\\|')[4]) < 1 then null else split(a.sfdc_campaign_code,'\\|')[4] END,
			case when length(split(a.sfdc_campaign_code,'\\|')[3]) < 1 then null else split(a.sfdc_campaign_code,'\\|')[3] END,
			case when length(split(a.sfdc_campaign_code,'\\|')[2]) < 1 then null else split(a.sfdc_campaign_code,'\\|')[2] END,
			case when length(split(a.sfdc_campaign_code,'\\|')[1]) < 1 then null else split(a.sfdc_campaign_code,'\\|')[1] END,
			case when length(split(a.sfdc_campaign_code,'\\|')[0]) < 1 then null else split(a.sfdc_campaign_code,'\\|')[0] END
			) as sfdc_campaign_id
from mcietl.web_visitor_base_v2 a 
join 
mci_enterprise_stage.okui_dme_taxonomy_v4 b
	on a.pagename = b.pagename
where click_date between '2020-06-05' and '2020-06-13';


create table mci_enterprise_stage.ab_test_campaign_1 
as 
select 
    id,
    contact__c,
    product__c
from 
    mdpd_temp.sfdc_inquiry_management__c 
where
     lower(product__c) = 'sign';



create table mci_enterprise_stage.ab_test_campaign_2
as
select 
    a.contact__c,
    a.product__c, 
    c.parentid,
    c.mql_timestamp
from
    mci_enterprise_stage.ab_test_campaign_1 a
left join
    (
        select 
            parentid, field, split(newvalue,' ')[0] as mql_timestamp
        from
            mci_enterprise.uda_sfdc_inquiry_management_history_std   
        where
             field = 'MQL_Timestamp__c'
    ) c
on 
    a.id = c.parentid
where 
    mql_timestamp between '2020-06-05' and '2020-06-13';



create table mci_enterprise_stage.ab_test_campaign_3
as
select a.*, b.id
from
    mci_enterprise_stage.ab_test_campaign_2 a
left join
    sourcedata.sfdc_contact b
on a.contact__c = b.id;

drop table mci_enterprise_stage.ab_test_campaign_4
create table mci_enterprise_stage.ab_test_campaign_4
as
select
    'null' as responses,
    a.contact__c as mql, 
    b.email,
    a.product__c as products,
    activity_type__c as activity,
    c.fiscal_yr_and_wk_desc as week, 
    case 
        when lower(campaign_name__c) like '%trial%' or lower(campaign_name__c) like '%appstore%' then 'Trial'
        when lower(campaign_name__c) like '%inbound%' or lower(campaign_name__c) like '%rfi%' 
                or lower(campaign_name__c) like '%phone%' or lower(campaign_name__c) like '%chat%' then 'RFI'
        when campaign_name__c like '%NA_FY20_Q2_Field%' then 'Field'
    else 'Demand'
    end as funnel_type,
    lead_market_area__c
from
    mci_enterprise_stage.ab_test_campaign_3 a 
left join
    sourcedata.sfdc_lead b
on
    a.id = b.contact__c
left join  
    warehouse.hana_ccmusage_dim_date c
ON
    a.mql_timestamp = c.date_date
where
    lower(b.product_outlook_group__c) = 'echosign'
and 
    lead_market_area__c in ('Aus and New Zealand','Germany','United Kingdom','Japan','United States','France','Canada');



drop table mci_enterprise_stage.ab_campaign_leads_1week; 
create table mci_enterprise_stage.ab_campaign_leads_1week
as 
select  id as responses,
        'null' as mql,
        email,
        product_outlook_group__c  as products,
        activity_subtype__c as activity,
        c.fiscal_yr_and_wk_desc as week, 
        funnel_type,
        lead_market_area__c
from 
     (select
         id,
         email,
         lead_market_area__c,
         product_outlook_group__c, 
         activity_subtype__c,  
         case 
        when lower(campaign_name__c) like '%trial%' or lower(campaign_name__c) like '%appstore%' then 'Trial'
        when lower(campaign_name__c) like '%inbound%' or lower(campaign_name__c) like '%rfi%' 
                or lower(campaign_name__c) like '%phone%' or lower(campaign_name__c) like '%chat%' then 'RFI'
        when campaign_name__c like '%NA_FY20_Q2_Field%' then 'Field'
    else 'Demand'
    end as funnel_type,
         split(createddate,' ')[0] as response_date
     from
         sourcedata.sfdc_lead 
     where 
        lead_market_area__c in ('Aus and New Zealand','Germany','United Kingdom','Japan','United States','France','Canada');

     and 
        createddate between '2020-06-05' and '2020-06-13'
     and 
        lower(product_outlook_group__c) = 'echosign'
     )x 
left join  
    warehouse.hana_ccmusage_dim_date c
 on 
     x.response_date = c.date_date;







drop table mci_enterprise_stage.ab_test_campaign_5;
create table mci_enterprise_stage.ab_test_campaign_5
as 
select * from mci_enterprise_stage.ab_campaign_leads_1week
union all
select * from mci_enterprise_stage.ab_test_campaign_4;


drop table mci_enterprise_stage.ab_exposure_campaign;
create table mci_enterprise_stage.ab_exposure_campaign
as
select a.*,
        case when a.email = b.email 
        then 'exposed' else 'unexposed'
        end as campaign_exposure
from  mci_enterprise_stage.ab_test_campaign_5 a 
left join 
mci_enterprise_stage.sa_camp_view_02 b 
on a.email = b.email;

-----------------------------------------------------------------------------------------------------------------






drop table mci_enterprise_stage.ab_tactic_campaign;
create table mci_enterprise_stage.ab_tactic_campaign 
as
select
id
,contact__c
,activity_subtype__c
,case when lower(campaign_name__c) like '%sign%' then 'Sign'
        else 'Others'
end as campaign_type
,campaign_name__c
,split(createddate,' ')[0] as response_date
from sourcedata.sfdc_lead
where createddate between '2020-05-01' and '2020-06-30'
and product_outlook_group__c = 'ECHOSIGN';



select count(*), campaign_type from mci_enterprise_stage.ab_tactic_campaign 
group by campaign_type

--1604	Others
--12773	Sign








