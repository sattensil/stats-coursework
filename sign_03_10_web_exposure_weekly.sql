
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


--------------------------------------------------------
--VISITS all desired pages
--------------------------------------------------------
drop table mci_enterprise_stage.sa_00_taxonomy;
create table mci_enterprise_stage.sa_00_taxonomy --
STORED AS ORC tblproperties( "orc.compress" = "SNAPPY", "serialization.null.format" = "") AS
select distinct
coalesce(pagename,post_pagename,custom_link_page_name) post_pagename
from mcietl.web_visits_detailed  v 
	where v.report_suite='adbadobenonacdcprod' 
	and v.click_date >= '2020-07-01'
	and	(coalesce(pagename,post_pagename,custom_link_page_name) like '%acrobat.adobe.com:sign%'
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
;

--------------------------------------------------------
--VISITS extract data from web_visits_detailed 
--------------------------------------------------------


drop table mci_enterprise_stage.sa_00;
create table mci_enterprise_stage.sa_00 --rows: 78,198	distinct mcvisid: 55,690 email rows: 463	distinct emails: 183
STORED AS ORC tblproperties( "orc.compress" = "SNAPPY", "serialization.null.format" = "") AS
select z.*
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
		when v.sfdc_campaign like '7011%' and (length(v.sfdc_campaign) = 18 or length(v.sfdc_campaign) = 15)  then v.sfdc_campaign
		when v.rtid like '7011%' and (length(v.rtid) = 18 or length(v.rtid) = 15)    then v.rtid
		when v.s_cid like '7011%' and (length(v.s_cid) = 18 or length(v.s_cid) = 15)    then v.s_cid
		when v.tracking_id like '7011%' and (length(v.tracking_id) = 18 or length(v.tracking_id) = 15)    then v.tracking_id else null end as sfdc_tag
		
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
			,substr(parse_url(v.page_url, 'QUERY', 'tracking_id'),1,8) as tracking_id
			,lower(coalesce(parse_url(v.page_url, 'QUERY', 'mv'), v.cgen_marketing_vehicle)) as mv
	--sfdc
			,case when v.campaign like '7011%' then UPPER(v.campaign) else null end as sfdc_campaign
			,UPPER(substr(parse_url(v.page_url, 'QUERY', 'rtid'),1,18 )) as rtid
			,UPPER(substr(parse_url(v.page_url, 'QUERY', 's_cid'),1,18 )) as s_cid
			,case when lower(v.page_url) = lower('https://esign.adobe.com/Adobe-451-Workforce-Productivity-Reg.html?ref=linkedin') then '7011O000002UQXKQAU'
			 when lower(v.page_url) = lower('https://esign.adobe.com/Adobe-451-Workforce-Productivity-Reg.html?ref=techtarget')  then '7011O000002URVSQA2' else null end as url_sfdc
	--leadsource
			,lower(parse_url(v.page_url, 'QUERY', 'leadsource2')) as leadsource2
		from mcietl.web_visits_detailed  v 
		inner join mci_enterprise_stage.sa_00_taxonomy t
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
;
	
--------------------------------------------------------
--VISITS fill in identifiers
-- Pulls from sa_email_guid_final, which is built in sign_00_20_person_bridge
--------------------------------------------------------



drop table mci_enterprise_stage.sa_01_v;-- this creates duplicates with any email or guid associated with the click row 
create table mci_enterprise_stage.sa_01_v as  --rows: 	distinct mcvisid:  email rows: distinct emails: 
select 'web visits' as source
			,v.click_date	
			,v.visid	
			,v.mcvisid	
			,v.session_id	
			,v.tap_sub_std_name_key
			,i.guid
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
			,v.leadsource2
			,v.exposure
			,v.market_area_code
		from mci_enterprise_stage.sa_00 v
		left join mci_enterprise_stage.sa_email_guid_final i 
			on v.mcvisid = i.mcvisid

;

--------------------------------------------------------
--CSTACK - DISPLAY and EMAIL extract and append
--------------------------------------------------------	

--This pulls the MCVISIDs that we can associate from the BizMove C-Stack campaign
drop table mci_enterprise_stage.sa_01_c ;
create table mci_enterprise_stage.sa_01_c as --rows:251,516	distinct mcvisid:40,884  email rows: distinct emails: 
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
,b.mcvisid
,b.guid
,b.faas
,b.pagename
,s.market_area_code
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

--format to stack with other activity data
drop table mci_enterprise_stage.sa_02_c;
create table mci_enterprise_stage.sa_02_c as 
select distinct * from (
select --join on guid
'cstack' as source
,s.first_exposure_date as click_date 	
,null as visid
,s.mcvisid
,null as session_id
,NULL as tap_sub_std_name_key
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
,NULL as leadsource2
,'exposed' as exposure
,s.market_area_code
from mci_enterprise_stage.sa_01_c s
left join (select * from mci_enterprise_stage.sa_email_guid_final where email is not null) i2
on upper(coalesce(trim(s.guid))) = i2.guid
	
union all

select --join on mcvisid
'cstack' as source
,s.first_exposure_date as click_date 	
,null as visid
,s.mcvisid
,null as session_id
,NULL as tap_sub_std_name_key
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
,NULL as leadsource2
,'exposed' as exposure
,s.market_area_code
from mci_enterprise_stage.sa_01_c s
left join (select * from mci_enterprise_stage.sa_email_guid_final where email is not null) i 
on s.mcvisid = i.mcvisid
where upper(coalesce(trim(s.guid))) <> i2.guid
)z

--------------------------------------------------------
--Merge datasets
--------------------------------------------------------

drop table mci_enterprise_stage.sa_02; 
create table mci_enterprise_stage.sa_02
as select * from mci_enterprise_stage.sa_01_v
	union all
select * from mci_enterprise_stage.sa_02_c
-- 	union all
-- select * from mci_enterprise_stage.sa_01_r
;

--------------------------------------------------------
-- append identifiers -- add rows for all tap_sub_std_name_key
-- Matching based on Domain
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
	,v.leadsource2
	,v.exposure
	,v.market_area_code
	from mci_enterprise_stage.sa_02 v
	inner join (select distinct contactid, tap_sub_std_name_key from mci_enterprise_stage.abm_sfdc_contacts_mapped where contactid is not null and tap_sub_std_name_key is not null) c2
		on UPPER(v.contact_id) = UPPER(c2.contactid)
	where on UPPER(v.email) <> UPPER(c1.email)
		
		
drop table mci_enterprise_stage.sa_camp_view_01; 
create table mci_enterprise_stage.sa_camp_view_01 --
as select distinct * from (
select * from (
	select * from mci_enterprise_stage.sa_camp_view_01_a
	union all
	select * from mci_enterprise_stage.sa_camp_view_01_b) z
union all 
	select * from (select * from mci_enterprise_stage.sa_camp_view_01_c
	union all
	select * from mci_enterprise_stage.sa_camp_view_01_d) z
)z;

--------------------------------------------------------
-- backfill missing identifiers based on visid
--------------------------------------------------------

drop table mci_enterprise_stage.sa_t;
create table mci_enterprise_stage.sa_t
STORED AS ORC tblproperties( "orc.compress" = "SNAPPY", "serialization.null.format" = "") AS
select *, row_number() over (partition by mcvisid order by cnt desc) as rnk from (
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
create table mci_enterprise_stage.sa_e 
STORED AS ORC tblproperties( "orc.compress" = "SNAPPY", "serialization.null.format" = "") AS
select *, row_number() over (partition by mcvisid order by cnt desc) as rnk from (
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
create table mci_enterprise_stage.sa_camp_view_02
STORED AS ORC tblproperties( "orc.compress" = "SNAPPY", "serialization.null.format" = "") AS
select distinct
v.source
,v.click_date 	
,v.visid
,v.mcvisid	
,v.session_id
,coalesce(v.tap_sub_std_name_key,t.tap_sub_std_name_key) as tap_sub_std_name_key
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
,v.leadsource2
,v.exposure
from mci_enterprise_stage.sa_camp_view_01 v
left join mci_enterprise_stage.sa_t t
     on t.mcvisid = v.mcvisid
left join mci_enterprise_stage.sa_e em
     on em.mcvisid = v.mcvisid
;

-------------------------------------------------------------------------------------------------------------
-- Take the raw web data and apply exposure flags to the visit (joining on mcvisid with Scarlett's table)
----------------------------------------------------------------------------------------------------------

-- describe gedi_dev.sign_web_data_raw;
-- add demandbase sid

drop table gedi_dev.sign_web_exposure;
create table gedi_dev.sign_web_exposure
STORED AS ORC tblproperties( "orc.compress" = "SNAPPY", "serialization.null.format" = "") AS
select distinct
a.visit_key
,a.mcvisid
,a.demandbase_sid
,a.sub_std_name_key
,case when a.market_area_description = 'United Kingdom' then 'UNITED KINGDOM' 
when a.market_area_description = 'United States' then 'UNITED STATES'
end as market_area
,case when a.gtm_segment in ('Enterprise','GOV') then 'NAMED'
when a.gtm_segment = 'Mid-Market' then 'MID-MARKET'
when a.gtm_segment = 'CSMB/Unidentified' then 'CSMB'
else 'OTHER'
end account_segment
,case 
when a.industry_group = 'EDU' then 'EDUCATION'
when a.industry_group = 'GOV' then 'GOVERNMENT'
when a.industry_group = 'COM' then 'COMMERCIAL'
else 'UNKNOWN' end market_segment
,case when c.mcvisid is not null then 'exposed' else 'Not-exposed' end as exposure
,case when c.mcvisid is not null then 1 else 0 end as exposed_flag
,a.sign_trial_page
,a.click_date
,a.fiscal_yr_and_wk_desc

from gedi_dev.sign_web_data_raw a 

left join 
(
    select distinct mcvisid from mci_enterprise_stage.sa_camp_view_02 b
    where exposure = 'exposed'
) c
on a.mcvisid = c.mcvisid

;


--------------
-- Dashboard Table
-- Previously mci_enterprise_stage.ab_discover_visits_cd


drop table gedi_dev.sign_web_exposure_dash;
create table gedi_dev.sign_web_exposure_dash
as
select 
count(distinct a.visit_key) as visits ,
d.fiscal_yr_and_qtr_desc,
a.market_area as market_area_description,
c.geo_code,
'null' as gtm_segment,
a.sign_trial_page,
a.exposure,
coalesce(a.sub_std_name_key,b.sub_std_name_key)  as unique_business_1,
a.account_segment as gtm_segment_new,
a.market_segment,
case 
    when coalesce(a.sub_std_name_key,cast(b.sub_std_name_key as double)) is not null 
   then coalesce(a.sub_std_name_key,cast(b.sub_std_name_key as double)) end as unique_business_2,
CONCAT(d.fiscal_yr_and_qtr_desc,c.geo_code,a.market_area,a.account_segment,a.market_segment) as join_key
,a.fiscal_yr_and_wk_desc

from (select visit_key, 
			max(market_area) as market_area,
			max(sign_trial_page) sign_trial_page,
			max(sub_std_name_key) as sub_std_name_key,
			max(account_segment) as account_segment,
			max(market_segment) as market_segment,
			max(mcvisid) as mcvisid,
			max(exposure) as exposure,
			max(click_date) as click_date,
			max(fiscal_yr_and_wk_desc) as fiscal_yr_and_wk_desc 
			from 
			gedi_dev.sign_web_exposure  
			group by 
			visit_key
	 )a

left join 
    ecp.hana_tap_an_rv_td_sub b
	on a.sub_std_name_key = b.sub_std_name_key
	and lower(a.market_area) = lower(b.market_area_description)
left JOIN sourcedata.dim_date d
    on cast(a.click_date as date) = cast(d.date_date as date)
left join  
    warehouse.country c 
    on lower(a.market_area) = lower(c.market_area_description)
group by 
d.fiscal_yr_and_qtr_desc,
a.market_area,
c.geo_code,
a.sign_trial_page,
a.exposure,
coalesce(a.sub_std_name_key,b.sub_std_name_key),
a.account_segment,
a.market_segment,
case 
    when coalesce(a.sub_std_name_key,cast(b.sub_std_name_key as double)) is not null 
    then coalesce(a.sub_std_name_key,cast(b.sub_std_name_key as double)) end,
CONCAT(d.fiscal_yr_and_qtr_desc,c.geo_code,a.market_area,a.account_segment,a.market_segment)
,a.fiscal_yr_and_wk_desc

;


drop view mci_enterprise_stage.ab_discover_visits_cd;
create view mci_enterprise_stage.ab_discover_visits_cd
as select * from gedi_dev.sign_web_exposure_dash;



