--********************************************************************************************************************************	
----------------------------------------------------------------------------------------------------------------------------------
--Responses
----------------------------------------------------------------------------------------------------------------------------------	
--********************************************************************************************************************************	

drop table mci_enterprise_stage.sa_cstack_000; 
create table mci_enterprise_stage.sa_cstack_000
as select distinct
	r.inq_management_id --aFc1O0000003xC4SAI
	,c.contactid as contact_id --00314000028Uf2tAAC
	,c.email	
	,c.tap_sub_std_name_key
	,c.sfdc_accountid --0011400001YlG1h
	,coalesce(r.latest_inq_date,r.createddate) as createddate
	,country_code_iso2
	,case when s.activity_subtype__c in ('3rd Party Email'
								,'Appt. Setting 3rd Party'
								,'Partner Co-Marketing'
								,'Partner Enablement'
								,'Partner With'
								,'Partner-Led Marketing') then 'Affiliate'
		when s.activity_subtype__c in ('Display','Display Ads','TextAd') then 'Display'
		when s.activity_subtype__c in ('E-Mail','E-Mail Production','Email') then 'Email'
		when s.activity_subtype__c in ('A','B','C','D','H','S','T','W','N/A') then NULL
		when s.activity_subtype__c in ('Product Overview'
							,'Site Content'
							,'Video'
							,'Video (Featured Demo)'
							,'Video (Product Tour)'
							,'Video - Other'
							,'Website Direct') then 'Product'
		when s.activity_subtype__c in ('Search (SEO)') then 'Search: Natural'
		when s.activity_subtype__c like 'Social%' then 'Social: Ads'
		when s.activity_subtype__c like 'Webin%' then 'Webinar'
		when s.activity_subtype__c in ('E-Seminar Event') then 'Webinar'
		when s.activity_subtype__c like 'White%' then 'Whitepaper'
		when s.activity_subtype__c in ('Success Story (Case Study)','Success story','Research Paper') then 'Whitepaper'
		else 'Other' 
	end as channel
from mci_enterprise_stage.abm_contact_activity_inq_mql_sal_final r
left join mci_enterprise.abm_sfdc_contacts_mapped c
    on r.contact_id = c.contactid
left join mci_enterprise_stage.ab_sfdc_lead_sample s
	on r.contact_id = s.contact__c

--********************************************************************************************************************************	
----------------------------------------------------------------------------------------------------------------------------------
--Visits
----------------------------------------------------------------------------------------------------------------------------------	
--********************************************************************************************************************************	
drop table mci_enterprise_stage.sa_cstack_00;
create table mci_enterprise_stage.sa_cstack_00 as
select
	v.visid
	,v.mcvisid
	,concat(v.visid_high,'$',v.visid_low) as visid_high_low
	,v.member_guid --0001b44bb822ad20855358419eb35a1b0529909b0ac6d5626b606e6b676a6164
	,v.member_guid_in_session
	,v2.user_guid
	,v.session_id
	,v2.visit_key
	,v2.click_date
	,v.date_time
	,coalesce(v.geo_country,v2.geo_country) as country
	,coalesce(v.pagename,v.post_pagename,v2.pagename,v2.post_pagename) as pagename
	,v2.faas_submission_id
	,upper(substr(v2.faas_submission_id,2,36)) as faas_id
	,v2.sfdc_id
	,v2.tap_sub_std_name_key
	,v2.email
	,lower(coalesce(v2.marketing_channel
			,v.last_touch_marketing_channel
			,parse_url(v.page_url, 'QUERY', 'mv')
			,v.cgen_marketing_vehicle)) as marketing_channel
	,v.page_url
	,case when v.campaign like '7011%' then v.campaign else null end as sfdc_campaign
    ,substr(parse_url(v.page_url, 'QUERY', 'rtid'),1,8 ) as rtid
    ,substr(parse_url(v.page_url, 'QUERY', 's_cid'),1,8 ) as s_cid
	,substr(parse_url(v.page_url, 'QUERY', 'tracking_id'),1, 8) as tracking_id
from mcietl.web_visits_detailed  v 
inner join  mcietl.web_visitor_base_v2 v2
	on v.session_id = v2.visit_key
	and v.pagename  = v2.pagename 
	and v.custom_link_details = v2.custom_link_details
	and cast(v.click_date as date)  = v2.click_date	
where v.report_suite='adbadobenonacdcprod' 
	and v.mcvisid <> '00000000000000000000000000000000000000'
	and v.click_date >= '2020-05-01'
	and (v.campaign like '7011%' 
		or parse_url(v.page_url, 'QUERY', 'rtid') like '7011%' 
		or parse_url(v.page_url, 'QUERY', 's_cid') like '7011%' 
		or parse_url(v.page_url, 'QUERY', 'tracking_id') like '7011%' )
;

drop table mci_enterprise_stage.sa_cstack_01;
create table mci_enterprise_stage.sa_cstack_01 as
select distinct
	v.visid
	,v.mcvisid
	,v.visid_high_low
	,v.member_guid 
	,v.member_guid_in_session
	,v.user_guid
	,v.session_id
	,v.visit_key
	,coalesce(v.click_date,cast(coalesce(c1.createddate,c2.createddate,c3.createddate) as date)) as exposure_date
	,v.date_time
	,coalesce(v.country,c1.country_code_iso2,c2.country_code_iso2,c3.country_code_iso2) as country
	,v.pagename
	,v.faas_submission_id
	,v.faas_id
	,coalesce(v.sfdc_id,c1.contact_id,c2.contact_id,c3.contact_id)  as sfdc_id --0031400002dCUEBAA4
	,coalesce(v.tap_sub_std_name_key,c1.tap_sub_std_name_key,c2.tap_sub_std_name_key,c3.tap_sub_std_name_key)  as tap_sub_std_name_key
	,coalesce(v.email,c1.email,c2.email,c3.email) as email
	,case when initcap(v.marketing_channel) in ('Affiliate','Display','Email','Product') then initcap(v.marketing_channel)
		when initcap(v.marketing_channel) like '%Referring Domains%' then 'Other'
		when initcap(v.marketing_channel) like '%Internal Referrer%' then 'Other'
		when initcap(v.marketing_channel) like '%Product - Acrobat%' then 'Product'
		when initcap(v.marketing_channel) like '%Product - Reader%' then 'Product'
		when initcap(v.marketing_channel) like '%Search Natural%' then 'Search: Natural'
		when initcap(v.marketing_channel) like '%Search Paid%' then 'Search: Paid'
		when initcap(v.marketing_channel) like '%Typed/Bookmarked%' then 'Social: Organic'
		when initcap(v.marketing_channel) like '%Organic Social%' then 'Social: Owned'
		when initcap(v.marketing_channel) like '%Owned Social%' then 'Social: Owned'
		when initcap(v.marketing_channel) like '%Paid Social%' then 'Social: Paid'
		else coalesce(c1.channel,c2.channel,c3.channel)  end as channel
	,v.page_url
	,upper(trim(coalesce(v.sfdc_campaign,v.rtid,v.s_cid,v.tracking_id))) as sfdc_tag
from mci_enterprise_stage.sa_cstack_00  v 
left join mci_enterprise_stage.sa_cstack_000 c1
	on c1.contact_id =v.sfdc_id 
left join mci_enterprise_stage.sa_cstack_000 c2
	on c2.email =v.email
left join mci_enterprise_stage.sa_cstack_000 c3
	on c3.tap_sub_std_name_key =v.tap_sub_std_name_key
;
select * from warehouse.dim_user_lvt_profile !
--backfill guid
drop table mci_enterprise_stage.sa_cstack_02;
create table mci_enterprise_stage.sa_cstack_03 as
	select
	g.guid
	,v.visid_high_low 
	,v.email
	,case when length(v.country) = 3 then c.country_code_iso2 else upper(v.country) end as country
	,coalesce(channel,case when s.subtype__c in ('3rd Party Email'
		,'Appt. Setting 3rd Party'
		,'Partner Co-Marketing'
		,'Partner Enablement'
		,'Partner With'
		,'Partner-Led Marketing') then 'Affiliate'
		when s.subtype__c in ('Display','Display Ads','TextAd') then 'Display'
		when s.subtype__c in ('E-Mail','E-Mail Production','Email') then 'Email'
		when s.subtype__c in ('A','B','C','D','H','S','T','W','N/A') then NULL
		when s.subtype__c in ('Product Overview'
		,'Site Content'
		,'Video'
		,'Video (Featured Demo)'
		,'Video (Product Tour)'
		,'Video - Other'
		,'Website Direct') then 'Product'
		when s.subtype__c in ('Search (SEO)') then 'Search: Natural'
		when s.subtype__c like 'Social%' then 'Social: Ads'
		when s.subtype__c like 'Webin%' then 'Webinar'
		when s.subtype__c in ('E-Seminar Event') then 'Webinar'
		when s.subtype__c like 'White%' then 'Whitepaper'
		when s.subtype__c in ('Success Story (Case Study)','Success story','Research Paper') then 'Whitepaper' else 'Other' end) as channel				
	,v.sfdc_tag
	,trim(regexp_replace(s.name,'[\|\n\r]',' ')) as sfdc_campaign_name
	,s.startdate
	,min(exposure_date) as first_exposure_date
	,min(date_time) as first_exposure_timestamp
	,count(*) as times_exposed
from mci_enterprise_stage.sa_cstack_01 v
inner join mci_enterprise_stage.sa_cstack_02 g --only populated guids
	on v.mcvisid = g.mcvisid
left join mci_enterprise_stage.okui_sfdc_campaign s
    on s.id  = v.sfdc_tag
left join mci_enterprise_stage.okui_ocf_country c
    on v.country = lower(c.country_code_iso3)
group by 
	g.guid
	,v.visid_high_low 
	,v.email
	,case when length(v.country) = 3 then c.country_code_iso2 else upper(v.country) end
	,coalesce(channel,case when s.subtype__c in ('3rd Party Email'
		,'Appt. Setting 3rd Party'
		,'Partner Co-Marketing'
		,'Partner Enablement'
		,'Partner With'
		,'Partner-Led Marketing') then 'Affiliate'
		when s.subtype__c in ('Display','Display Ads','TextAd') then 'Display'
		when s.subtype__c in ('E-Mail','E-Mail Production','Email') then 'Email'
		when s.subtype__c in ('A','B','C','D','H','S','T','W','N/A') then NULL
		when s.subtype__c in ('Product Overview'
		,'Site Content'
		,'Video'
		,'Video (Featured Demo)'
		,'Video (Product Tour)'
		,'Video - Other'
		,'Website Direct') then 'Product'
		when s.subtype__c in ('Search (SEO)') then 'Search: Natural'
		when s.subtype__c like 'Social%' then 'Social: Ads'
		when s.subtype__c like 'Webin%' then 'Webinar'
		when s.subtype__c in ('E-Seminar Event') then 'Webinar'
		when s.subtype__c like 'White%' then 'Whitepaper'
		when s.subtype__c in ('Success Story (Case Study)','Success story','Research Paper') then 'Whitepaper' else 'Other' end)			
	,v.sfdc_tag
	,trim(regexp_replace(s.name,'[\|\n\r]',' '))
	,s.startdate
;

