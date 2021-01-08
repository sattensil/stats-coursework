--------------------------------------------------------
--VISITS all desired pages
--------------------------------------------------------
drop table mci_enterprise_stage.sa_taxonomy;
create table mci_enterprise_stage.sa_00_taxonomy_20200831 as
select distinct
post_pagename
from mcietl.web_visits_detailed  v 
		where v.report_suite='adbadobenonacdcprod' 
		and mcvisid <> '00000000000000000000000000000000000000'
		and v.click_date >= '2020-07-01'
		and v.session_id is not null
        and(v.post_pagename like '%acrobat.adobe.com:sign%'
                   or v.post_pagename like 'acrobat.adobe.com:documents:%'
                   or v.post_pagename like 'landing.adobe.com:products:echosign%'
                   or v.post_pagename like 'echosign.acrobat.com%'
                   or v.post_pagename like 'echosign.adobe.com%'
                   or v.post_pagename like 'adobesigndemo%'
                   or v.post_pagename like 'acrobat.adobe.com:sign:use-cases%'
                   or v.post_pagename = 'acrobat.adobe.com:business:integrations:dropbox:pricing'
                   or v.post_pagename like '%adobe.com%landing:sign:%')
        and not(v.post_pagename like 'adobesigndemoaccount%'
                or v.post_pagename = 'acrobat.adobe.com:sign:free-trial-global-form-a'
                or v.post_pagename= 'acrobat.adobe.com:sign:free-trial-global-form-b');
				
				
				(coalesce(pagename,post_pagename,custom_link_page_name) like '%acrobat.adobe.com:sign%'
       or coalesce(pagename,post_pagename,custom_link_page_name) like 'acrobat.adobe.com:documents:%'
       or coalesce(pagename,post_pagename,custom_link_page_name) like 'landing.adobe.com:products:echosign%'
       or coalesce(pagename,post_pagename,custom_link_page_name) like 'echosign.acrobat.com%'
       or coalesce(pagename,post_pagename,custom_link_page_name) like 'echosign.adobe.com%'
       or coalesce(pagename,post_pagename,custom_link_page_name) like 'adobesigndemo%'
       or coalesce(pagename,post_pagename,custom_link_page_name) like 'acrobat.adobe.com:sign:use-cases%'
       or coalesce(pagename,post_pagename,custom_link_page_name) = 'acrobat.adobe.com:business:integrations:dropbox:pricing'
       or coalesce(pagename,post_pagename,custom_link_page_name) like '%adobe.com%landing:sign:%')
       and not(coalesce(pagename,post_pagename,custom_link_page_name) like 'adobesigndemoaccount%'
            or coalesce(pagename,post_pagename,custom_link_page_name) = 'acrobat.adobe.com:sign:free-trial-global-form-a'
            or coalesce(pagename,post_pagename,custom_link_page_name) = 'acrobat.adobe.com:sign:free-trial-global-form-b'
           )
--------------------------------------------------------
--VISITS extract data from web_visits_detailed 
--------------------------------------------------------
drop table mci_enterprise_stage.sa_00;
create table mci_enterprise_stage.sa_00_20200827 --rows: 78,198	distinct mcvisid: 55,690 email rows: 463	distinct emails: 183
as select z.*
,case when s.campaign_code is not null
			or c.campaign_code is not null
			or l.campaign_code is not null
			or l2.campaign_code is not null then 'exposed' else null end as exposure from (
	select v.*
	,upper(trim(coalesce(case when v.cgen_campaign like '7011%' then NULL else v.cgen_campaign end
		,case when v.sdid like '7011%' then NULL else v.sdid end
		,case when v.tracking_id like '7011%' then NULL else substr(v.tracking_id,1,8) end
		))) as cgen_tag
	,case when url_sfdc is not null then url_sfdc
		when v.sfdc_campaign like '7011%' and length(v.sfdc_campaign) = 18  then v.sfdc_campaign
		when v.rtid like '7011%' and length(v.rtid) = 18  then v.rtid
		when v.s_cid like '7011%' and length(v.s_cid) = 18  then v.s_cid
		when v.tracking_id like '7011%' and length(v.tracking_id) = 18  then v.tracking_id else null end as sfdc_tag
		
	,substr(v2.faas_submission_id,22,34) as mch_cookie
	,v2.faas_submission_id
	,v2.email
	,v2.sfdc_id
	,v2.tap_sub_std_name_key
	,v2.market_area_code
	from (select
			cast(v.click_date as date) as click_date 
			,v.visid
			,v.mcvisid
			,v.session_id
			,concat(substr(v.fiscal_yr_and_qtr,1,4),'-0',substr(v.fiscal_yr_and_qtr,5,1)) as qtr
			,v.fiscal_wk_in_yr as week
			,v.page_url
			,coalesce(v.pagename,v.post_pagename,v.custom_link_page_name) post_pagename
			,v.custom_link_details
	--cgen
			,case when v.campaign like '7011%' then null else v.campaign end as cgen_campaign
			,substr(parse_url(v.page_url, 'QUERY', 'sdid'),1, 8) as sdid
			,substr(parse_url(v.page_url, 'QUERY', 'tracking_id'),1,18) as tracking_id
			,lower(coalesce(parse_url(v.page_url, 'QUERY', 'mv'), v.cgen_marketing_vehicle)) as mv
	--sfdc
			,case when v.campaign like '7011%' then UPPER(v.campaign) else null end as sfdc_campaign
			,UPPER(substr(parse_url(v.page_url, 'QUERY', 'rtid'),1,18 )) as rtid
			,UPPER(substr(parse_url(v.page_url, 'QUERY', 's_cid'),1,18 )) as s_cid
			,case when lower(v.page_url) = lower('https://esign.adobe.com/Adobe-451-Workforce-Productivity-Reg.html?ref=linkedin') then '7011O000002UQXKQAU'
			 when lower(v.page_url) = lower('https://esign.adobe.com/Adobe-451-Workforce-Productivity-Reg.html?ref=techtarget')  then '7011O000002URVSQA2' else null end as url_sfdc
	--leadsource
			,lower(parse_url(v.page_url, 'QUERY', 'leadsource')) as leadsource
				,lower(parse_url(v.page_url, 'QUERY', 'leadsource2')) as leadsource2
		from mcietl.web_visits_detailed  v 
		inner join mci_enterprise_stage.sa_00_taxonomy_20200823 t
		    on coalesce(v.pagename,v.post_pagename,v.custom_link_page_name)= t.post_pagename
		where v.report_suite='adbadobenonacdcprod' 
			and mcvisid <> '00000000000000000000000000000000000000'
			and v.click_date >= '2020-07-01'
			and v.session_id is not null
	)v 
	left join mcietl.web_visitor_base_v2  v2
		on v2.mcvisid = v.mcvisid
		and v2.visit_key = v.session_id
		and v2.visid = v.visid
		and v2.click_date = v.click_date
		and v2.click_date >= '2020-07-01'
		and coalesce(v2.pagename,v2.post_pagename,v2.custom_link_page_name) = v.post_pagename
		and v2.market_area_code IN ('US','UK')
	)z 
		left join mci_enterprise_stage.sign_bizmoves_campaign_codes s
			on UPPER(z.sfdc_tag)  = s.campaign_code
			and s.code_type ='cid'
			left join mci_enterprise_stage.sign_bizmoves_campaign_codes l
			on UPPER(z.leadsource) = UPPER(l.campaign_code)
		    and l.code_type = 'leadsource2'
		left join mci_enterprise_stage.sign_bizmoves_campaign_codes l2
			on UPPER(z.leadsource2) = UPPER(l2.campaign_code)
		    and l2.code_type = 'leadsource2'
		left join mci_enterprise_stage.sign_bizmoves_campaign_codes c
			on z.cgen_tag = c.campaign_code
			and c.code_type ='cgen'
where (s.campaign_code is not null
			or c.campaign_code is not null
			or l.campaign_code is not null
			or l2.campaign_code is not null)
--------------------------------------------------------
--VISITS fill in identifiers
--------------------------------------------------------
drop table mci_enterprise_stage.sa_01_v;-- this creates duplicates with any email or guid associated with the click row 
create table mci_enterprise_stage.sa_01_v  --rows: 	distinct mcvisid:  email rows: distinct emails: 
as select 'web visits' as source
			,v.click_date	
			,v.visid	
			,v.mcvisid	
			,v.session_id	
			,v.tap_sub_std_name_key
			,NULL as inq_management_id
			,ui.guid
			,coalesce(v.mch_cookie,i.mch_cookie) as mch_cookie
			,v.faas_submission_id
			,coalesce(v.email,i.email) as email	
			,coalesce(v.sfdc_id,i.contact_id) as contact_id
			,v.qtr	
			,v.week	
			,v.page_url	
			,v.post_pagename
			,v.cgen_tag	
			,UPPER(v.sfdc_tag) as sfdc_tag
			,v.leadsource
			,v.leadsource2
			,v.exposure
			,v.market_area_code
		from mci_enterprise_stage.sa_20200831 v
		left join mci_enterprise_stage.sa_email_guid_final i 
			on v.mcvisid = i.mcvisid
);
--------------------------------------------------------
--Responses to stack with Campaign Touches
--------------------------------------------------------
drop table mci_enterprise_stage.sa_01_r; 
create table mci_enterprise_stage.sa_01_r  --rows: 	distinct mcvisid:  email rows: distinct emails: 
as select distinct * from (
	select --join on contact id
	'response' as source
	,coalesce(r.lastmodifieddate,r.createddate) as click_date 	
	,null as visid
	,i.mcvisid
	,null session_id
	,null as tap_sub_std_name_key
	,r.id as inq_management_id
	,i.guid
	,i.mch_cookie
	,NULL as faas_submission_id
	,coalesce(r.email,i.email) as email	
	,r.contact__c as contact_id
	,case when month(coalesce(r.lastmodifieddate,r.createddate))  =12 then concat(year(coalesce(r.lastmodifieddate,r.createddate))+1,'-Q1') 
			when month(coalesce(r.lastmodifieddate,r.createddate))<3 then concat(year(coalesce(r.lastmodifieddate,r.createddate)),'-Q1') 
			when month(coalesce(r.lastmodifieddate,r.createddate)) <6 then concat(year(coalesce(r.lastmodifieddate,r.createddate)),'-Q2') 
			when month(coalesce(r.lastmodifieddate,r.createddate))<9 then concat(year(coalesce(r.lastmodifieddate,r.createddate)),'-Q3') 
			else concat(year(coalesce(r.lastmodifieddate,r.createddate)),'-Q4')  end as qtr	
	,case when month(coalesce(r.lastmodifieddate,r.createddate)) = 12 then concat(year(coalesce(r.lastmodifieddate,r.createddate))+1,'-'
			,lpad(weekofyear(coalesce(r.lastmodifieddate,r.createddate))-weekofyear(cast(concat(year(coalesce(r.lastmodifieddate,r.createddate)),'-12-01') as date)) +1,2,'0'))
			else concat(year(coalesce(r.lastmodifieddate,r.createddate)),'-',lpad(weekofyear(coalesce(r.lastmodifieddate,r.createddate))+52-weekofyear(cast(concat(year(coalesce(r.lastmodifieddate,r.createddate))-1,'-12-01') as date)),2,'0')) end as week
	,NULL as page_url	
	,NULL as post_pagename
	,NULL as cgen_tag
	,UPPER(r.campaign_id__c) as sfdc_tag
	,r.leadsource as leadsource
	,NULL as leadsource2
	,case when coalesce(sf.campaign_code,l.campaign_code) is not null then 'exposed' else null end as exposure
	,case when r.lead_market_area__c = 'United Kingdom' then 'UK'  when r.lead_market_area__c ='United States' then 'US' else null end as market_area_code
	from (select * from mci_enterprise_stage.ab_lead_wk_37
			union all select * from mci_enterprise_stage.ab_lead_wk_36
			union all select * from mci_enterprise_stage.ab_lead_wk_35
			union all select * from mci_enterprise_stage.ab_lead_wk_34 )  r
	left join mci_enterprise_stage.sign_bizmoves_campaign_codes sf
		on UPPER(r.campaign_id__c)  = sf.campaign_code
		and sf.code_type ='cid'
	left join mci_enterprise_stage.sign_bizmoves_campaign_codes l
		on UPPER(r.leadsource) = UPPER(l.campaign_code)
		and l.code_type = 'leadsource2'
	left join (select * from mci_enterprise_stage.sa_email_guid_final where email is not null) i
		on r.contact__c = i.contact_id
	where coalesce(r.lastmodifieddate,r.createddate) >= '2020-07-01'
		and lower(r.product_outlook_group__c) in ('echosign','acrobat')
		and r.lead_market_area__c in ('United Kingdom','United States')
union all 
	select --join on email
	'response' as source
	,coalesce(r.lastmodifieddate,r.createddate) as click_date 	
	,null as visid
	,i.mcvisid
	,null session_id
	,null as tap_sub_std_name_key
	,r.id as inq_management_id
	,i.guid
	,i.mch_cookie
	,NULL as faas_submission_id
	,r.email
	,coalesce(r.contact__c,i.contact_id) as contact_id
	,case when month(coalesce(r.lastmodifieddate,r.createddate))  =12 then concat(year(coalesce(r.lastmodifieddate,r.createddate))+1,'-Q1') 
			when month(coalesce(r.lastmodifieddate,r.createddate))<3 then concat(year(coalesce(r.lastmodifieddate,r.createddate)),'-Q1') 
			when month(coalesce(r.lastmodifieddate,r.createddate)) <6 then concat(year(coalesce(r.lastmodifieddate,r.createddate)),'-Q2') 
			when month(coalesce(r.lastmodifieddate,r.createddate))<9 then concat(year(coalesce(r.lastmodifieddate,r.createddate)),'-Q3') 
			else concat(year(coalesce(r.lastmodifieddate,r.createddate)),'-Q4')  end as qtr	
	,case when month(coalesce(r.lastmodifieddate,r.createddate)) = 12 then concat(year(coalesce(r.lastmodifieddate,r.createddate))+1,'-'
			,lpad(weekofyear(coalesce(r.lastmodifieddate,r.createddate))-weekofyear(cast(concat(year(coalesce(r.lastmodifieddate,r.createddate)),'-12-01') as date)) +1,2,'0'))
			else concat(year(coalesce(r.lastmodifieddate,r.createddate)),'-',lpad(weekofyear(coalesce(r.lastmodifieddate,r.createddate))+52-weekofyear(cast(concat(year(coalesce(r.lastmodifieddate,r.createddate))-1,'-12-01') as date)),2,'0')) end as week
	,NULL as page_url	
	,NULL as post_pagename
	,NULL as cgen_tag
	,UPPER(r.campaign_id__c) as sfdc_tag
	,r.leadsource as leadsource
	,NULL as leadsource2
	,case when coalesce(sf.campaign_code,l.campaign_code) is not null then 'exposed' else null end as exposure
	,case when r.lead_market_area__c = 'United Kingdom' then 'UK'  when r.lead_market_area__c ='United States' then 'US' else null end as market_area_code
	from (select * from mci_enterprise_stage.ab_lead_wk_37
			union all select * from mci_enterprise_stage.ab_lead_wk_36
			union all select * from mci_enterprise_stage.ab_lead_wk_35
			union all select * from mci_enterprise_stage.ab_lead_wk_34 )  r
	left join mci_enterprise_stage.sign_bizmoves_campaign_codes sf
		on UPPER(r.campaign_id__c)  = sf.campaign_code
		and sf.code_type ='cid'
	left join mci_enterprise_stage.sign_bizmoves_campaign_codes l
		on UPPER(r.leadsource) = UPPER(l.campaign_code)
		and l.code_type = 'leadsource2'
	left join (select * from mci_enterprise_stage.sa_email_guid_final where email is not null) i
		on r.contact__c = i.contact_id
	where coalesce(r.lastmodifieddate,r.createddate) >= '2020-07-01'
		and lower(r.product_outlook_group__c) in ('echosign','acrobat')
		and r.lead_market_area__c in ('United Kingdom','United States')
)z;
--------------------------------------------------------
--CSTACK - DISPLAY and EMAIL extract and append
--------------------------------------------------------	
--Grabs the MCVISID that visited a Sign page
--6,192,458
CREATE TABLE mci_enterprise.cd_sign_mcvisid
STORED AS ORC tblproperties( "orc.compress" = "SNAPPY", "serialization.null.format" = "") AS
SELECT mcvisid
FROM mci_enterprise.cd_web_visitor_base_sign_subset
GROUP BY mcvisid
;
--Builds the Flashtalking bridge - limited to the MCVISID that visited a Sign page to make the table not as large
--62,798,477
CREATE TABLE mci_enterprise.cd_sign_spots
STORED AS ORC tblproperties ("orc.compress"="SNAPPY","serialization.null.format"='') AS
SELECT user_id
   ,max(concat(time,'~', u3)) mcid_last
   ,u3 as mcvisid
   ,spot_group_id
   ,spot_id
   ,u1 as guid
   ,u2 as faas
   ,u4 as pagename
FROM sourcedata.ft_spots a
   INNER JOIN mci_enterprise.cd_sign_mcvisid b on a.u3 = b.mcvisid
WHERE user_id <> "99999999999999"
  and user_id is not null
  and u3 <> ""
  and u3 is not null
  and u3 <> "1"
  and year >= substr(date_sub(current_date,364), 0, 4)
;
--This pulls the MCVISIDs that we can associate from the BizMove C-Stack campaign
drop table mci_enterprise_stage.sa_01_c 
create table mci_enterprise_stage.sa_01_c as --rows:251,516	distinct mcvisid:40,884  email rows: distinct emails: 
select
s.original_source_id
,s.path_id 
,s.first_exposure_date	
,s.market_area_code
,case when month(first_exposure_timestamp)  =12 then concat(year(first_exposure_timestamp)+1,'-Q1') 
	when month(first_exposure_timestamp)<3 then concat(year(first_exposure_timestamp),'-Q1') 
	when month(first_exposure_timestamp) <6 then concat(year(first_exposure_timestamp),'-Q2') 
	when month(first_exposure_timestamp)<9 then concat(year(first_exposure_timestamp),'-Q3') 
	else concat(year(first_exposure_timestamp),'-Q4')  end as qtr	
,case when month(first_exposure_timestamp) = 12 then concat(year(first_exposure_timestamp)+1,'-'
	,lpad(weekofyear(first_exposure_timestamp)-weekofyear(cast(concat(year(first_exposure_timestamp),'-12-01') as date)) +1,2,'0'))
	else concat(year(first_exposure_timestamp),'-',lpad(weekofyear(first_exposure_timestamp)+52-weekofyear(cast(concat(year(first_exposure_timestamp)-1,'-12-01') as date)),2,'0')) end as week
,campaign_link
,b.mcvisid
,b.guid
,b.faas
,b.pagename
from cstack.campaign_channel_exposure_status s
inner join cstack.dim_campaign c
    on s.campaign_id=c.campaign_id
left JOIN cstack.dim_channel h
    on s.campaign_id=h.campaign_id	
inner join mci_enterprise.cd_sign_spots b 
	on s.original_source_id = b.user_id
WHERE s.first_exposure_date >= '2020-07-01'
    and lower(c.campaign_business_key) = 'business-moves-fy20'
;
   
--format to stack with other activity data
create table mci_enterprise_stage.sa_02_c as  --rows: 	distinct mcvisid:  email rows: distinct emails: 
select distinct * from (
select --join on guid
'cstack' as source
,s.first_exposure_date as click_date 	
,null as visid
,s.mcvisid
,null as session_id
,NULL as tap_sub_std_name_key
,NULL as inq_management_id
,s.guid
,coalesce(substr(s.faas,22,34),i2.mch_cookie) as mch_cookie
,s.faas as faas_submission_id
,i2.email	
,i2.contact_id
,s.qtr	
,s.week
,campaign_link as page_url
,s.pagename as post_pagename
,null as cgen_tag	
,NULL as sfdc_tag
,NULL as leadsource
,NULL as leadsource2
,'exposed' as exposure
,s.market_area_code
from mci_enterprise_stage.sa_01_c s
left join (select * from mci_enterprise_stage.sa_email_guid_final where email is not null) i2
	on upper(s.guid) = i2.guid
union all
select --join on mcvisid
'cstack' as source
,s.first_exposure_date as click_date 	
,null as visid
,s.mcvisid
,null as session_id
,NULL as tap_sub_std_name_key
,NULL as inq_management_id
,coalesce(s.guid,i.guid) as guid
,coalesce(substr(s.faas,22,34),i.mch_cookie) as mch_cookie
,s.faas as faas_submission_id
,i.email
,i.contact_id
,s.qtr	
,s.week
,campaign_link as page_url
,s.pagename as post_pagename
,null as cgen_tag	
,NULL as sfdc_tag
,NULL as leadsource
,NULL as leadsource2
,'exposed' as exposure
,s.market_area_code
from mci_enterprise_stage.sa_01_c s
left join (select * from mci_enterprise_stage.sa_email_guid_final where email is not null) i 
	on s.mcvisid = i.mcvisid
)z;
--------------------------------------------------------
--Merge datasets
--------------------------------------------------------
drop table mci_enterprise_stage.sa_02; 
create table mci_enterprise_stage.sa_02 --
as select * from mci_enterprise_stage.sa_01_v
	union all
select * from mci_enterprise_stage.sa_02_c
	union all
select * from mci_enterprise_stage.sa_01_r
;

--------------------------------------------------------
--append identifiers -- add rows for all tap_sub_std_name_key
--------------------------------------------------------
drop table mci_enterprise_stage.sa_camp_view_01_a;
create table mci_enterprise_stage.sa_camp_view_01_a --
as 
	select 
	v.source
	,v.click_date 	
	,v.visid
	,v.mcvisid	
	,v.session_id
	,v.tap_sub_std_name_key
	,v.inq_management_id
	,v.guid
	,v.mch_cookie
	,v.faas_submission_id
	,v.email	
	,v.contact_id
	,v.qtr	
	,v.week
	,v.page_url
	,v.post_pagename
	,v.cgen_tag	
	,v.sfdc_tag
	,v.leadsource
	,v.leadsource2
	,v.exposure
	,v.market_area_code
	from mci_enterprise_stage.sa_02 v
;
drop table mci_enterprise_stage.sa_camp_view_01_b;
create table mci_enterprise_stage.sa_camp_view_01_b --
as 
	select 
	v.source
	,v.click_date 	
	,v.visid
	,v.mcvisid	
	,v.session_id
	,f.tap_sub_std_name_key
	,v.inq_management_id
	,v.guid
	,v.mch_cookie
	,v.faas_submission_id
	,v.email	
	,v.contact_id
	,v.qtr	
	,v.week
	,v.page_url
	,v.post_pagename
	,v.cgen_tag	
	,v.sfdc_tag
	,v.leadsource
	,v.leadsource2
	,v.exposure
	,v.market_area_code
	from mci_enterprise_stage.sa_02 v
	inner join mci_enterprise.wv_ecp_id_domain_data d
		on UPPER(split(v.email,'[\@]')[1]) = UPPER(d.domain)
	inner join mci_enterprise_stage.sa_ceo_tap f
		on f.sf_account_id = d.sfdc_act_id 
;
drop table mci_enterprise_stage.sa_camp_view_01_c;
create table mci_enterprise_stage.sa_camp_view_01_c --
as 
	select 
	v.source
	,v.click_date 	
	,v.visid
	,v.mcvisid	
	,v.session_id
	,c1.tap_sub_std_name_key
	,v.inq_management_id
	,v.guid
	,v.mch_cookie
	,v.faas_submission_id
	,v.email	
	,v.contact_id
	,v.qtr	
	,v.week
	,v.page_url
	,v.post_pagename
	,v.cgen_tag	
	,v.sfdc_tag
	,v.leadsource
	,v.leadsource2
	,v.exposure
	,v.market_area_code
	from mci_enterprise_stage.sa_02  v
	inner join (select distinct email, tap_sub_std_name_key from mci_enterprise_stage.abm_sfdc_contacts_mapped where email is not null and tap_sub_std_name_key is not null) c1
		on UPPER(v.email) = UPPER(c1.email)

drop table mci_enterprise_stage.sa_camp_view_01_d;
create table mci_enterprise_stage.sa_camp_view_01_d --
as 
	select 
	v.source
	,v.click_date 	
	,v.visid
	,v.mcvisid	
	,v.session_id
	,c2.tap_sub_std_name_key
	,v.inq_management_id
	,v.guid
	,v.mch_cookie
	,v.faas_submission_id
	,v.email	
	,v.contact_id
	,v.qtr	
	,v.week
	,v.page_url
	,v.post_pagename
	,v.cgen_tag	
	,v.sfdc_tag
	,v.leadsource
	,v.leadsource2
	,v.exposure
	,v.market_area_code
	from mci_enterprise_stage.sa_02 v
	inner join (select distinct contactid, tap_sub_std_name_key from mci_enterprise_stage.abm_sfdc_contacts_mapped where contactid is not null and tap_sub_std_name_key is not null) c2
		on UPPER(v.contact_id) = UPPER(c2.contactid)
		
		
drop table mci_enterprise_stage.sa_camp_view_01; 
create table mci_enterprise_stage.sa_camp_view_01 --
as select distinct * from (
select * from mci_enterprise_stage.sa_camp_view_01_a
union all
select * from mci_enterprise_stage.sa_camp_view_01_b
union all 
select * from mci_enterprise_stage.sa_camp_view_01_c
union all
select * from mci_enterprise_stage.sa_camp_view_01_d
)z;
--------------------------------------------------------
-- backfill missing identifiers based on visid
--------------------------------------------------------
drop table mci_enterprise_stage.sa_t;
create table mci_enterprise_stage.sa_t --
as select *, row_number() over (partition by mcvisid order by cnt desc) as rnk from (
select 
v.tap_sub_std_name_key
,v.mcvisid
,count(*) as cnt
from mci_enterprise_stage.sa_camp_view_01 v
where v.tap_sub_std_name_key is not null and v.mcvisid is not null
group by
v.tap_sub_std_name_key
,v.mcvisid )z
;

drop table mci_enterprise_stage.sa_e;
create table mci_enterprise_stage.sa_e --
as select *, row_number() over (partition by mcvisid order by cnt desc) as rnk from (
select 
v.email
,v.mcvisid
,count(*) as cnt
from mci_enterprise_stage.sa_camp_view_01 v
where v.email is not null
group by
v.email
,v.mcvisid
) z;

drop table mci_enterprise_stage.sa_camp_view_02;
create table mci_enterprise_stage.sa_camp_view_02 --
as select distinct * from (select
v.source
,v.click_date 	
,v.visid
,v.mcvisid	
,v.session_id
,coalesce(v.tap_sub_std_name_key,t.tap_sub_std_name_key) as tap_sub_std_name_key
,v.inq_management_id
,v.guid
,v.mch_cookie
,v.faas_submission_id
,coalesce(v.email,em.email) as email
,v.contact_id
,v.qtr	
,v.week
,v.page_url
,v.post_pagename
,v.cgen_tag	
,v.sfdc_tag
,v.leadsource
,v.leadsource2
,v.exposure
,v.market_area_code
from mci_enterprise_stage.sa_camp_view_01 v
left join mci_enterprise_stage.sa_t t
     on t.visid = v.visid
     and t.rnk = 1
left join mci_enterprise_stage.sa_e em
     on em.visid = v.visid
     and em.rnk = 1
)z;
--look at duplicates
select mcvisid, click_date, count(*) as cnt from mci_enterprise_stage.sa_camp_view_02 where email is not null group by mcvisid, click_date order by cnt desc limit 1000000
--------------------------------------------------------
-- summarize exposed responses 
--------------------------------------------------------
drop table mci_enterprise_stage.sa_exposed_responses;
create table mci_enterprise_stage.sa_exposed_responses as
select r.id
,max(case when v.exposure = 'exposed' and r.createddate <= v.click_date then 1 else 0 end) as exposed
from (select * from mci_enterprise_stage.ab_lead_wk_37
		union all select * from mci_enterprise_stage.ab_lead_wk_36
		union all select * from mci_enterprise_stage.ab_lead_wk_35
		union all select * from mci_enterprise_stage.ab_lead_wk_34 )  r
left join mci_enterprise_stage.sa_camp_view_02 v 
	on upper(trim(r.email)) = upper(trim(v.email))
group by r.id
;
--------------------------------------------------------
-- summarize responses by campaign exposure
--------------------------------------------------------
drop table mci_enterprise_stage.sa_exposed_responses_tags_00;
create table mci_enterprise_stage.sa_exposed_responses_tags_00 as
select distinct
r.id
,v.mcvisid
,v.visid
,v.inq_management_id
,v.cgen_tag	
,v.sfdc_tag
,v.leadsource
,v.leadsource2
,v.exposure
,v.click_date
,v.source
from mci_enterprise_stage.sa_camp_view_02 v 
inner join (select * from mci_enterprise_stage.ab_lead_wk_37
		union all select * from mci_enterprise_stage.ab_lead_wk_36
		union all select * from mci_enterprise_stage.ab_lead_wk_35
		union all select * from mci_enterprise_stage.ab_lead_wk_34 )  r
on upper(trim(r.email)) = upper(trim(v.email))
where r.createddate <= v.click_date
;

drop table mci_enterprise_stage.sa_exposed_responses_tags_01;
create table mci_enterprise_stage.sa_exposed_responses_tags_01 as --20,278
	select 
	v.id
	,v.cgen_tag	as tag
	,'cgen' as tag_type
	,max(case when v.exposure = 'exposed' then 1 else 0 end) as exposed
	,min(click_date) as first_exposure
	,max(click_date) as last_exposure
	,count(distinct case when source = 'web visits' then mcvisid else null end) as web_visit_exposures
	,count(distinct case when source = 'response' then inq_management_id else null end) as response_exposures
	,count(distinct case when source = 'cstack' then visid else null end) as cstack_exposures
	from mci_enterprise_stage.sa_exposed_responses_tags_00 v
	where v.cgen_tag is not null
	group by v.id,v.cgen_tag
union all 
	select 
	v.id
	,sfdc_tag as tag
	,'cid' as tag_type
	,max(case when v.exposure = 'exposed' then 1 else 0 end) as exposed
	,min(click_date) as first_exposure
	,max(click_date) as last_exposure
	,count(distinct case when source = 'web visits' then mcvisid else null end) as web_visit_exposures
	,count(distinct case when source = 'response' then inq_management_id else null end) as response_exposures
	,count(distinct case when source = 'cstack' then visid else null end) as cstack_exposures
	from mci_enterprise_stage.sa_exposed_responses_tags_00 v
	where sfdc_tag is not null
	group by v.id,sfdc_tag
union all 
	select 
	v.id
	,v.leadsource as tag
	,'leadsource' as tag_type
	,max(case when v.exposure = 'exposed' then 1 else 0 end) as exposed
	,min(click_date) as first_exposure
	,max(click_date) as last_exposure
	,count(distinct case when source = 'web visits' then mcvisid else null end) as web_visit_exposures
	,count(distinct case when source = 'response' then inq_management_id else null end) as response_exposures
	,count(distinct case when source = 'cstack' then visid else null end) as cstack_exposures
	from mci_enterprise_stage.sa_exposed_responses_tags_00 v
	where v.leadsource is not null
	group by v.id,v.leadsource
union all 
	select 
	v.id
	,v.leadsource2	as tag
	,'leadsource2' as tag_type
	,max(case when v.exposure = 'exposed' then 1 else 0 end) as exposed
	,min(click_date) as first_exposure
	,max(click_date) as last_exposure
	,count(distinct case when source = 'web visits' then mcvisid else null end) as web_visit_exposures
	,count(distinct case when source = 'response' then inq_management_id else null end) as response_exposures
	,count(distinct case when source = 'cstack' then visid else null end) as cstack_exposures
	from mci_enterprise_stage.sa_exposed_responses_tags_00 v
	where v.leadsource2 is not null
	group by v.id,v.leadsource2
;
--------------------------------------------------------
-- counts for qa
--------------------------------------------------------
drop table mci_enterprise_stage.sa_camp_view_counts;
create table mci_enterprise_stage.sa_camp_view_count as
select '1_mci_enterprise_stage.sa_00_taxonomy_20200823' as table, count(*) as rows, null as emails,null as distinct_emails, null as tap_sub_std_name_keys, null as distinct_tap_sub_std_name_keys from mci_enterprise_stage.sa_00_taxonomy_20200823 union all
select '2_mci_enterprise_stage.sa_email_guid_final' as table, count(*) as rows, null as emails,null as distinct_emails, null as tap_sub_std_name_keys, null as distinct_tap_sub_std_name_keys  from mci_enterprise_stage.sa_email_guid_final union all
select '3_mci_enterprise_stage.sa_00_20200823' as table, count(*) as rows, count(email) as emails, count(distinct email) as distinct_emails, count(tap_sub_std_name_key) as tap_sub_std_name_keys, count(distinct tap_sub_std_name_key) as distinct_tap_sub_std_name_keys from  mci_enterprise_stage.sa_00_20200823  union all
select '4_mci_enterprise_stage.sa_01_v' as table, count(*) as rows, count(email) as emails, count(distinct email) as distinct_emails, count(tap_sub_std_name_key) as tap_sub_std_name_keys, count(distinct tap_sub_std_name_key) as distinct_tap_sub_std_name_keys from  mci_enterprise_stage.sa_01_v union all
select '5_mci_enterprise_stage.sa_01_r' as table, count(*) as rows, count(email) as emails, count(distinct email) as distinct_emails, count(tap_sub_std_name_key) as tap_sub_std_name_keys, count(distinct tap_sub_std_name_key) as distinct_tap_sub_std_name_keys from  mci_enterprise_stage.sa_01_r union all
select '6_mci_enterprise_stage.sa_01_c' as table, count(*) as rows, null as emails,null as distinct_emails, null as tap_sub_std_name_keys, null as distinct_tap_sub_std_name_keys from  mci_enterprise_stage.sa_01_c union all
select '7_ mci_enterprise_stage.sa_02_c' as table, count(*) as rows, count(email) as emails, count(distinct email) as distinct_emails, count(tap_sub_std_name_key) as tap_sub_std_name_keys, count(distinct tap_sub_std_name_key) as distinct_tap_sub_std_name_keys from  mci_enterprise_stage.sa_02_c union all
select '8_mci_enterprise_stage.sa_01' as table, count(*) as rows, count(email) as emails, count(distinct email) as distinct_emails, count(tap_sub_std_name_key) as tap_sub_std_name_keys, count(distinct tap_sub_std_name_key) as distinct_tap_sub_std_name_keys from   mci_enterprise_stage.sa_01 union all
select '9_mci_enterprise_stage.sa_t' as table, count(*) as rows, null as emails,null as distinct_emails, null as tap_sub_std_name_keys, null as distinct_tap_sub_std_name_keys from  mci_enterprise_stage.sa_t union all 
select '10_mci_enterprise_stage.sa_e' as table, count(*) as rows, null as emails,null as distinct_emails, null as tap_sub_std_name_keys, null as distinct_tap_sub_std_name_keys  from  mci_enterprise_stage.sa_e  union all
select '11_mci_enterprise_stage.sa_camp_view_00' as table, count(*) as rows, null as emails,null as distinct_emails, null as tap_sub_std_name_keys, null as distinct_tap_sub_std_name_keys  from  mci_enterprise_stage.sa_camp_view_00
select '12_mci_enterprise_stage.sa_camp_view_01' as table, count(*) as rows, null as emails,null as distinct_emails, null as tap_sub_std_name_keys, null as distinct_tap_sub_std_name_keys  from  mci_enterprise_stage.sa_camp_view_01
select '13_mci_enterprise_stage.sa_camp_view_02' as table, count(*) as rows, null as emails,null as distinct_emails, null as tap_sub_std_name_keys, null as distinct_tap_sub_std_name_keys  from  mci_enterprise_stage.sa_camp_view_02
;

select * from mci_enterprise_stage.sa_camp_view_02 inner join (select * from mci_enterprise_stage.ab_lead_wk_37
		union all select * from mci_enterprise_stage.ab_lead_wk_36
		union all select * from mci_enterprise_stage.ab_lead_wk_35
		union all select * from mci_enterprise_stage.ab_lead_wk_34 )  r
on upper(trim(r.email)) = upper(trim(v.email))
and r.createddate <= v.click_date
