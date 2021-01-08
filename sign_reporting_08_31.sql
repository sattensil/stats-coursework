


******************************************************************************************************************************************
----------------------------------------------------------------------------------------------------------------------------
--DISCOVER
----------------------------------------------------------------------------------------------------------------------------\

--NOTE: Replace Enterprise as Named (Enterprise,Mid-market,CSMB/Unidentified, GOV)
-- Has 4 distinct Market segments: EDU, GOV, COM and UNKNOWN
drop table mci_enterprise_stage.ab_discover_visits_cd
create table mci_enterprise_stage.ab_discover_visits_cd
as
select 
count(distinct a.visit_key) as total_visits,
d.fiscal_yr_and_qtr_desc,
d.fiscal_yr_and_wk_desc,
a.market_area_description,
c.geo_code,
a.gtm_segment, 
a.sign_trial_page,
e.exposure,
coalesce(a.sub_std_name_key,b.sub_std_name_key)  as unique_business_1,
case when gtm_segment not in ('Mid-Market','Enterprise') 
        and (a.sub_std_name_key >=1 or a.demandbase_sid is not null) then 'All B2B'
    when gtm_segment = 'Enterprise' then 'Named'
     else gtm_segment
end as new_account_segment,
case when industry_group = 'COM' then 'Commercial'
     when industry_group = 'GOV' then 'Government'
     when industry_group = 'EDU' then 'Education'
     else industry_group
end as market_segment,
case 
    when coalesce(a.sub_std_name_key,cast(b.sub_std_name_key as double)) is not null 
    or a.demandbase_sid is not null 
then coalesce(a.sub_std_name_key,cast(b.sub_std_name_key as double),cast(a.demandbase_sid as double)) end as unique_business_2,
CONCAT(d.fiscal_yr_and_qtr_desc,c.geo_code,a.market_area_description,a.gtm_segment,a.industry_group) as join_key
from 
    mci_enterprise.cd_sign_web_data_raw a 
left join 
    ecp.hana_tap_an_rv_td_sub b
	on a.sub_std_name_key = b.sub_std_name_key
	and lower(a.market_area_description) = lower(b.market_area_description)
inner join 
    gedi_dev.sign_web_exposure e 
on a.visit_key=e.visit_key
and a.mcvisid = e.mcvisid
and a.click_date = e.click_date
inner join  
    warehouse.country c 
    on lower(a.market_area_description) = lower(c.market_area_description)
INNER JOIN sourcedata.dim_date d
on cast(a.click_date as date) = cast(d.date_date as date)
group by 
d.fiscal_yr_and_qtr_desc,
d.fiscal_yr_and_wk_desc,
a.market_area_description,
c.geo_code,
a.gtm_segment, 
a.sign_trial_page,
e.exposure,
coalesce(a.sub_std_name_key,b.sub_std_name_key) ,
case when gtm_segment not in ('Mid-Market','Enterprise') 
        and (a.sub_std_name_key >=1 or a.demandbase_sid is not null) then 'All B2B'
    when gtm_segment = 'Enterprise' then 'Named'
     else gtm_segment
end,
case when industry_group = 'COM' then 'Commercial'
     when industry_group = 'GOV' then 'Government'
     when industry_group = 'EDU' then 'Education'
     else industry_group
end,
case 
    when coalesce(a.sub_std_name_key,cast(b.sub_std_name_key as double)) is not null 
    or a.demandbase_sid is not null 
then coalesce(a.sub_std_name_key,cast(b.sub_std_name_key as double),cast(a.demandbase_sid as double)) end,
CONCAT(d.fiscal_yr_and_qtr_desc,c.geo_code,a.market_area_description,a.gtm_segment,a.industry_group);

----------------------------------------------------------------------------------------------------------------------------
--EXPLORE
----------------------------------------------------------------------------------------------------------------------------\

drop table mci_enterprise_stage.ab_explore_responsetype_ryan;
create table mci_enterprise_stage.ab_explore_responsetype_ryan
as
select 
a.fiscal_qtr
,a.fiscal_mon
,a.fiscal_wk
,a.fiscal_wk_in_qtr
,a.funnel_type
,a.market_area
,a.country
,b.geo_code
,a.market_segment
,a.exposure
,a.leadid
,a.email
,split(a.email,'@')[2] as domain     
,a.resp
,a.mql
,case when a.account_segment = ''
,CONCAT(a.fiscal_qtr,b.geo_code,a.market_area,a.account_segment,a.market_segment) as join_key
from gedi_dev.sign_campaign_resp_weekly a 
inner join  
    warehouse.country b
    on lower(a.market_area) = lower(b.market_area_description);
    

----------------------------------------------------------------------------------------------------------------------------
--EVALUATE
----------------------------------------------------------------------------------------------------------------------------\
--opp_created_wk from 2020-31


create table mci_enterprise_stage.ab_evaluate_named_opportunity_ryan
select 
opp_id
,opp_stage_number
,market_area
,rep_global_region
,opp_created_wk
,opp_created_qtr
,opp_pipeline_creator_group
,opp_adjusted_commitment
,market_segment
,exposure
,opp_reached_ss3_y_n_flag
,sum(opp_pipeline_asv) as gross_asv
,sum(opp_bookings_won) as won_gross_asv
from 
    gedi_dev.sign_enterprise_opportunities a 
group by 
opp_id
,opp_stage_number
,market_area
,rep_global_region
,opp_created_wk
,opp_created_qtr
,opp_pipeline_creator_group
,opp_adjusted_commitment
,market_segment
,exposure
,opp_reached_ss3_y_n_flag    


***************************************************************************************************************************************