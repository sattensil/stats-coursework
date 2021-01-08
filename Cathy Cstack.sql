
create table mci_enterprise_stage.sa_01_cathy as 
select distinct
s.original_source_id
,s.path_id 
,s.first_exposure_date	
,case when month(first_exposure_timestamp)  =12 then concat(year(first_exposure_timestamp)+1,'-Q1') 
	when month(first_exposure_timestamp)<3 then concat(year(first_exposure_timestamp),'-Q1') 
	when month(first_exposure_timestamp) <6 then concat(year(first_exposure_timestamp),'-Q2') 
	when month(first_exposure_timestamp)<9 then concat(year(first_exposure_timestamp),'-Q3') 
	else concat(year(first_exposure_timestamp),'-Q4')  end as qtr	
,case when month(first_exposure_timestamp) = 12 then concat(year(first_exposure_timestamp)+1,'-'
	,lpad(weekofyear(first_exposure_timestamp)-weekofyear(cast(concat(year(first_exposure_timestamp),'-12-01') as date)) +1,2,'0'))
	else concat(year(first_exposure_timestamp),'-',lpad(weekofyear(first_exposure_timestamp)+52-weekofyear(cast(concat(year(first_exposure_timestamp)-1,'-12-01') as date)),2,'0')) end as week
,campaign_link
,s.channel
,c.campaign_name
,case when s.channel = 'App Store Link' then 'In-Product'
	when s.channel = 'Paid Social' then 'Social: Paid'
	when s.channel = 'Adobe Live' then 'In-Product'
	when s.channel = 'Landing Page' then 'Display'		when s.channel = 'Paid Media' then 'Display'
	when s.channel = 'PAID_SEARCH' then 'Search: Paid'
	when s.channel = 'Paid Influencer' then 'Social: Paid'
	when s.channel = 'EMAIL' then 'Email'
	when s.channel = 'In-product' then 'In-Product'
	when s.channel = 'Display' then 'Display'
	when s.channel = 'Cgen contest lp' then 'Other'
	when s.channel = 'Owned Social' then 'Social: Owned'
	when s.channel = 'Paid Search Clicks' then 'Search: Paid'
	when s.channel = 'ADOTCOM' then 'Other'
	when s.channel = 'Cgen a.com' then 'Other'
	when s.channel = 'All' then 'Other'
	when s.channel = 'Social' then 'Social: Organic'
	when s.channel = 'a.com pagename' then 'Other'
	when s.channel = 'Partner' then 'Affiliate' 
	else 'Other' end as marketing_channel
from cstack.campaign_channel_exposure_status s
inner join cstack.dim_campaign c
    on s.campaign_id=c.campaign_id
left JOIN cstack.dim_channel h
    on s.campaign_id=h.campaign_id	
WHERE s.first_exposure_date >= '2020-07-01'
    and lower(c.campaign_business_key) = 'business-moves-fy20'

--previously I did some work to 
create table mci_enterprise_stage.sa_02_cathy as --goal was to associate with identifiers to match with responses; the inner joins below drops the exposure rows above that don't join to identifiers
select distinct * from (
select --JOIN ON GUID TO PULL IN MCVISID EMAIL
'cstack' as source
,s.first_exposure_date as click_date 	
,coalesce(hr.visid,i2.visid) as visid
,i2.mcvisid
,null as session_id
,NULL as tap_sub_std_name_key
,NULL as inq_management_id
,case when upper(trim(hr.post_evar12)) = '' then null else upper(trim(hr.post_evar12)) end as guid
,i2.mch_cookie
,NULL as faas_submission_id
,i2.email	
,i2.contact_id
,s.qtr	
,s.week
,campaign_link as page_url
,null as post_pagename
,null as cgen_tag	
,NULL as sfdc_tag
,NULL as leadsource
,NULL as leadsource2
,'exposed' as exposure
,s.marketing_channel
,s.channel
,s.campaign_name
from mci_enterprise_stage.sa_01_cathy s
inner join cstack.traffic_sc_visitor_click_history_stitched hs --15,962 after join
	on s.original_source_id = hs.original_source_id
	and s.path_id = hs.path_id
	and hs.event_date >= '2020-07-01'
inner join cstack.traffic_sc_visitor_click_history_raw hr
	on hs.visit_num_detail = hr.visit_num_detail
	--and hs.event_date = hr.event_date
	and hr.event_date >= '2020-07-01'
	--and trim(hr.post_evar12) <> ''
left join mci_enterprise_stage.sa_email_guid_final i2
	on upper(coalesce(trim(hr.post_evar12))) = i2.guid
union all
select --JOIN ON VISID TO PULL IN MCVISID AND EMAIL
'cstack' as source
,s.first_exposure_date as click_date 	
,hr.visid
,i.mcvisid
,null as session_id
,NULL as tap_sub_std_name_key
,NULL as inq_management_id
,case when upper(trim(hr.post_evar12)) = '' then null else coalesce(upper(trim(hr.post_evar12)),i.guid) end as guid
,i.mch_cookie
,NULL as faas_submission_id
,i.email
,i.contact_id
,s.qtr	
,s.week
,campaign_link as page_url
,null as post_pagename
,null as cgen_tag	
,NULL as sfdc_tag
,NULL as leadsource
,NULL as leadsource2
,'exposed' as exposure
,s.marketing_channel
,s.channel
,s.campaign_name
from mci_enterprise_stage.sa_01_cathy s
inner join cstack.traffic_sc_visitor_click_history_stitched hs --15,962 rows after join
	on s.original_source_id = hs.original_source_id
	and s.path_id = hs.path_id
	and hs.event_date >= '2020-07-01'
inner join cstack.traffic_sc_visitor_click_history_raw hr
	on hs.visit_num_detail = hr.visit_num_detail
	--and hs.event_date = hr.event_date
	and hr.event_date >= '2020-07-01'
	--and trim(hr.post_evar12) <> ''
left join mci_enterprise_stage.sa_email_guid_final i 
	on hr.visid = i.visid
)z;