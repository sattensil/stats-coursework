
--------------------------------------------------------
--Focused Exposed Campaign List
--------------------------------------------------------
--SFDC Tags
drop TABLE mci_enterprise_stage.sa_exposed_sf;
CREATE TABLE mci_enterprise_stage.sa_exposed_sf
    (sfdc_tag string
	,exposure string)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',';

LOAD DATA INPATH '/data/warehouse/mci_enterprise_stage/sfdc_exposure.csv' 
OVERWRITE INTO TABLE mci_enterprise_stage.sa_exposed_sf;
select count(*) from  mci_enterprise_stage.sa_exposed_sf; --23

--CGEN Tags
drop TABLE mci_enterprise_stage.sa_exposed_cgen2;
CREATE TABLE mci_enterprise_stage.sa_exposed_cgen2 --757
    (cgen_tag string
	,exposure string)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',';

LOAD DATA INPATH '/data/warehouse/mci_enterprise_stage/cgen_exposure.csv' 
OVERWRITE INTO TABLE mci_enterprise_stage.sa_exposed_cgen2;
select count(*) from  mci_enterprise_stage.sa_exposed_cgen2; --

--Leadsource
drop TABLE mci_enterprise_stage.sa_exposed_leadsource;
CREATE TABLE mci_enterprise_stage.sa_exposed_leadsource --18
    (leadsource string
	,exposure string)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',';

LOAD DATA INPATH '/data/warehouse/mci_enterprise_stage/leadsource_exposure.csv' 
OVERWRITE INTO TABLE mci_enterprise_stage.sa_exposed_leadsource;
select count(*) from  mci_enterprise_stage.sa_exposed_leadsource; --

--------------------------------------------------------
--VISITS extract data from web_visits_detailed 
--------------------------------------------------------
drop table mci_enterprise_stage.sa_00;
create table mci_enterprise_stage.sa_00 --24,580,062,788
as select * from (
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
	,v2.marketing_channel
	from (select
			cast(v.click_date as date) as click_date 
			,v.visid
			,v.mcvisid
			,v.session_id
			,concat(substr(v.fiscal_yr_and_qtr,1,4),'-0',substr(v.fiscal_yr_and_qtr,5,1)) as qtr
			,v.fiscal_wk_in_yr as week
			,v.page_url
			,v.post_pagename
			,v.custom_link_details
			,v.last_touch_marketing_channel
	--cgen
			,case when v.campaign like '7011%' then null else v.campaign end as cgen_campaign
			,substr(parse_url(v.page_url, 'QUERY', 'sdid'),1, 8) as sdid
			,substr(parse_url(v.page_url, 'QUERY', 'tracking_id'),1,18) as tracking_id
			,lower(coalesce(parse_url(v.page_url, 'QUERY', 'mv'), v.cgen_marketing_vehicle)) as mv
	--sfdc
			,case when v.campaign like '7011%' then UPPER(v.campaign) else null end as sfdc_campaign
			,UPPER(substr(parse_url(v.page_url, 'QUERY', 'rtid'),1,18 )) as rtid
			,UPPER(substr(parse_url(v.page_url, 'QUERY', 's_cid'),1,18 )) as s_cid
			,lower(parse_url(v.page_url, 'QUERY', 'productname')) as productname
			,case when lower(v.page_url) = lower('https://esign.adobe.com/Adobe-451-Workforce-Productivity-Reg.html?ref=linkedin') then '7011O000002UQXKQAU'
			 when lower(v.page_url) = lower('https://esign.adobe.com/Adobe-451-Workforce-Productivity-Reg.html?ref=techtarget')  then '7011O000002URVSQA2' else null end as url_sfdc
	--leadsource
			,lower(parse_url(v.page_url, 'QUERY', 'leadsource')) as leadsource
				,lower(parse_url(v.page_url, 'QUERY', 'leadsource2')) as leadsource2
		from mcietl.web_visits_detailed  v 
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
		and v2.post_pagename = v.post_pagename
	)z 
left join mci_enterprise_stage.ab_big_sign_campaign_taxonomy a
			on post_pagename = a.pagename
		left join mci_enterprise_stage.sa_exposed_sf s
			on UPPER(v.sfdc_tag) = UPPER(s.sfdc_tag)
		left join mci_enterprise_stage.sa_exposed_leadsource l
			on UPPER(v.leadsource) = UPPER(l.leadsource)
		left join mci_enterprise_stage.sa_exposed_leadsource l2
			on UPPER(v.leadsource2) = UPPER(l2.leadsource)
		left join mci_enterprise_stage.sa_exposed_cgen2 c
			on v.cgen_tag = c.cgen_tag
		left join mci_enterprise_stage.sa_email_guid_final i
			on v.mcvisid = i.mcvisid
where (s.sfdc_tag is not null
			or c.cgen_tag is not null
			or l.leadsource is not null
			or l2.leadsource is not null
			or a.pagename is not null) 

--------------------------------------------------------
--VISITS clean up tags convert guids and drop missing tags
--------------------------------------------------------
drop table mci_enterprise_stage.sa_01_v;
create table mci_enterprise_stage.sa_01_v --49,753	3,316	76
as select distinct * from (
	select 
			v.click_date	
			,v.visid	
			,v.mcvisid	
			,v.session_id	
			,v.tap_sub_std_name_key
			,NULL as inq_management_id
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
			,v.leadsource
			,v.leadsource2
		,coalesce(s.exposure,c.exposure,l.exposure,l2.exposure) as exposure
		--marketing channels
		,coalesce(v.marketing_channel,v.last_touch_marketing_channel) as marketing_channel
		,v.mv 
		--product names
		,a.products
		,productname
		from mci_enterprise_stage.sa_00 v
		left join mci_enterprise_stage.ab_big_sign_campaign_taxonomy a
			on post_pagename = a.pagename
		left join mci_enterprise_stage.sa_exposed_sf s
			on UPPER(v.sfdc_tag) = UPPER(s.sfdc_tag)
		left join mci_enterprise_stage.sa_exposed_leadsource l
			on UPPER(v.leadsource) = UPPER(l.leadsource)
		left join mci_enterprise_stage.sa_exposed_leadsource l2
			on UPPER(v.leadsource2) = UPPER(l2.leadsource)
		left join mci_enterprise_stage.sa_exposed_cgen2 c
			on v.cgen_tag = c.cgen_tag
		left join mci_enterprise_stage.sa_email_guid_final i
		on v.mcvisid = i.mcvisid

;

drop table mci_enterprise_stage.sa_02_v;
create table mci_enterprise_stage.sa_02_v -- --33,840	151	 76
as select distinct
'web_visits' as source
,v.click_date	
,v.visid	
,v.mcvisid	
,v.session_id	
,v.tap_sub_std_name_key
,v.inq_management_id
,v.guid
,v.mch_cookie
,v.faas_submission_id
,coalesce(v.email,v.email_i) email
,coalesce(v.sfdc_id,v.contact_id_i)contact_id
,v.qtr	
,v.week	
,v.page_url	
,v.post_pagename
,v.cgen_tag	
,v.sfdc_tag	
,v.leadsource
,v.leadsource2
,v.coalesce(v.exposure_s,v.exposure_c,v.exposure_l,v.exposure_l2) exposure
,case when v.sfdc_tag is not null and v.cgen_tag is not null and v.leadsource is not null then 'SFDC, Leadsource and CGEN' 
							when v.sfdc_tag is not null and v.cgen_tag is not null and v.leadsource is null then 'SFDC and CGEN'  
							when v.sfdc_tag is not null and v.cgen_tag is null and v.leadsource is not null then 'SFDC and Leadsource'  
							when v.sfdc_tag is null and v.cgen_tag is not null and v.leadsource is not null then 'Leadsource and CGEN'  
							when v.sfdc_tag is not null and v.cgen_tag is null and v.leadsource is null then 'SFDC Only'  
							when v.sfdc_tag is null and v.cgen_tag is null and v.leadsource is not null then 'Leadsource Only'  
							else 'CGEN Only' end as url_tag_types 
,coalesce(case when v.marketing_channel in ('Affiliate','Display','Email') then v.marketing_channel
				when v.marketing_channel like '%Referring Domains%' then 'Other'
				when v.marketing_channel like '%Internal Referrer%' then 'Other'
				when v.marketing_channel like '%Product%' then 'In-Product'
				when v.marketing_channel like '%Search Natural%' then 'Search: Natural'
				when v.marketing_channel like '%Search Paid%' then 'Search: Paid'
				when v.marketing_channel like '%Typed/Bookmarked%' then 'Social: Organic'
				when v.marketing_channel like '%Organic Social%' then 'Social: Owned'
				when v.marketing_channel like '%Owned Social%' then 'Social: Owned'
				when v.marketing_channel like '%Paid Social%' then 'Social: Paid'
				else NULL
				,case when v.mv like '%email%' then 'Email'
				when v.mv like '%affiliate%' then 'Affiliate'
				when v.mv like '%search%' then 'Search: Paid'
				when v.mv like '%display%' then 'Display'
				when v.mv like '%social%' then 'Social: Paid'
				when v.mv like '%in%' then 'In-Product'
				when v.mv like '%product%' then 'In-Product'
				when v.mv like '%promoid%' then 'In-Product'
				when v.mv is not null then 'Other'
				else NULL end) as marketing_channel --from detailed, then base, then url
,coalesce(case when v.products  = 'Adobe Sign: Sign' then 'Sign'
			when v.products  = 'DC: Acrobat' then 'Acrobat'
			when v.products  = 'DC: Document Cloud' then 'DC'
			when v.products  = 'Other Adobe: Connect' then 'Other'
			when v.products  = 'X-Product' then 'Other'
			else 'Other' end,case when v.productname like '%acrobat%' then 'Acrobat'
				when (v.productname like '%sign%' and v.productname not like '%design%' and v.productname not like '%assign%') then 'Sign'
				when v.productname like '%stock%' then 'Stock'
				when v.productname like '%creative%' then 'CC'
				when v.productname like '%after%' then 'CC'
				when v.productname like '%effects%' then 'CC'
				when v.productname like '%animate%' then 'CC'
				when v.productname like '%audition%' then 'CC'
				when v.productname like '%aviary%' then 'CC'
				when v.productname like '%bridge%' then 'CC'
				when v.productname like '%brush%' then 'CC'
				when v.productname like '%camera%' then 'CC'
				when v.productname like '%raw%' then 'CC'
				when v.productname like '%capture%' then 'CC'
				when v.productname like '%character%' then 'CC'
				when v.productname like '%animator%' then 'CC'
				when v.productname like '%clip%' then 'CC'
				when v.productname like '%color%' then 'CC'
				when v.productname like '%comp%' then 'CC'
				when v.productname like '%creative cloud%' then 'CC'
				when v.productname like '%dimension%' then 'CC'
				when v.productname like '%draw%' then 'CC'
				when v.productname like '%dreamweaver%' then 'CC'
				when v.productname like '%edge%' then 'CC'
				when v.productname like '%elements%' then 'CC'
				when v.productname like '%organizer%' then 'CC'
				when v.productname like '%encore%' then 'CC'
				when v.productname like '%express%' then 'CC'
				when v.productname like '%extendscript%' then 'CC'
				when v.productname like '%toolkit%' then 'CC'
				when v.productname like '%extension manager%' then 'CC'
				when v.productname like '%felix%' then 'CC'
				when v.productname like '%fireworks%' then 'CC'
				when v.productname like '%fix%' then 'CC'
				when v.productname like '%flash%' then 'CC'
				when v.productname like '%pro%' then 'CC'
				when v.productname like '%fresco%' then 'CC'
				when v.productname like '%fuse%' then 'CC'
				when v.productname like '%gaming sdk%' then 'CC'
				when v.productname like '%hue%' then 'CC'
				when v.productname like '%illustrator%' then 'CC'
				when v.productname like '%incopy%' then 'CC'
				when v.productname like '%indesign%' then 'CC'
				when v.productname like '%ink & slide%' then 'CC'
				when v.productname like '%lightroom%' then 'CC'
				when v.productname like '%line%' then 'CC'
				when v.productname like '%media encoder%' then 'CC'
				when v.productname like '%mix%' then 'CC'
				when v.productname like '%muse%' then 'CC'
				when v.productname like '%phonegap%' then 'CC'
				when v.productname like '%photography%' then 'CC'
				when v.productname like '%photoshop%' then 'CC'
				when v.productname like '%portfolio%' then 'CC'
				when v.productname like '%prelude%' then 'CC'
				when v.productname like '%premiere pro%' then 'CC'
				when v.productname like '%preview%' then 'CC'
				when v.productname like '%revel%' then 'CC'
				when v.productname like '%rush%' then 'CC'
				when v.productname like '%scan%' then 'CC'
				when v.productname like '%scout%' then 'CC'
				when v.productname like '%sdk%' then 'CC'
				when v.productname like '%shape%' then 'CC'
				when v.productname like '%sketch%' then 'CC'
				when v.productname like '%speedgrade%' then 'CC'
				when v.productname like '%story%' then 'CC'
				when v.productname like '%xd%' then 'CC'
				when v.productname is not null then 'Other' end) as product --from ab pagename taxonomy then url
from mci_enterprise_stage.sa_01_v v
where v.exposure is not null or v.pagename is not null
--********************************************************************************************************************************	
----------------------------------------------------------------------------------------------------------------------------------
--Responses to stack with Campaign Touches
----------------------------------------------------------------------------------------------------------------------------------	
--********************************************************************************************************************************	
drop table mci_enterprise_stage.sa_01_r; 
create table mci_enterprise_stage.sa_01_r -- 28,728 	28,728	8,905
as select distinct
'response' as source
,coalesce(r.lastmodifieddate,r.createddate) as click_date 	
,coalesce(i.visid,i2.visid) as visid
,coalesce(i.mcvisid,i2.mcvisid) as mcvisid
,coalesce(i.session_id,i2.session_id) as session_id
,c.tap_sub_std_name_key
,r.id as inq_management_id
,coalesce(i.guid,i2.guid) as guid
,coalesce(i.mch_cookie,i2.mch_cookie) as mch_cookie
,NULL as faas_submission_id
,coalesce(r.email, c.email,i2.email) as email	
,coalesce(r.contact__c,i.contact_id) as contact_id
,case when month(coalesce(r.lastmodifieddate,r.createddate))  =12 then concat(year(coalesce(r.lastmodifieddate,r.createddate))+1,'-Q1') 
		when month(coalesce(r.lastmodifieddate,r.createddate))<3 then concat(year(coalesce(r.lastmodifieddate,r.createddate)),'-Q1') 
		when month(coalesce(r.lastmodifieddate,r.createddate)) <6 then concat(year(coalesce(r.lastmodifieddate,r.createddate)),'-Q2') 
		when month(coalesce(r.lastmodifieddate,r.createddate))<9 then concat(year(coalesce(r.lastmodifieddate,r.createddate)),'-Q3') 
		else concat(year(coalesce(r.lastmodifieddate,r.createddate)),'-Q4')  end as qtr	
,case when month(coalesce(r.lastmodifieddate,r.createddate)) = 12 then concat(year(coalesce(r.lastmodifieddate,r.createddate))+1,'-'
		,lpad(weekofyear(coalesce(r.lastmodifieddate,r.createddate))-weekofyear(cast(concat(year(coalesce(r.lastmodifieddate,r.createddate)),'-12-01') as date)) +1,2,'0'))
		else concat(year(coalesce(r.lastmodifieddate,r.createddate)),'-',lpad(weekofyear(coalesce(r.lastmodifieddate,r.createddate))+52-weekofyear(cast(concat(year(coalesce(r.lastmodifieddate,r.createddate))-1,'-12-01') as date)),2,'0')) end as week
	,website as page_url	
,NULL as post_pagename
,NULL as cgen_tag
,UPPER(r.campaign_id__c) as sfdc_tag
,r.leadsource as leadsource
,NULL as leadsource2
,coalesce(sf.exposure,l.exposure) exposure
,'SFDC Only' as url_tag_types
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
		else 'Other' end as marketing_channel
,case when r.product_outlook_group__c = 'ECHOSIGN' then 'Sign' else initcap(r.product_outlook_group__c) end as product
from (select * from mci_enterprise_stage.ab_lead_wk_37
		union all select * from mci_enterprise_stage.ab_lead_wk_36
		union all select * from mci_enterprise_stage.ab_lead_wk_35
		union all select * from mci_enterprise_stage.ab_lead_wk_34 )  r
left join mci_enterprise.abm_sfdc_contacts_mapped c
    on r.contact__c = c.contactid
left join mci_enterprise_stage.ab_sfdc_lead_sample s
	on r.contact__c = s.contact__c
left join mci_enterprise_stage.sa_exposed_sf sf
	on UPPER(sf.sfdc_tag) = UPPER(r.campaign_id__c)
left join mci_enterprise_stage.sa_exposed_leadsource l
	on UPPER(r.leadsource) = UPPER(l.leadsource)
left join mci_enterprise_stage.sa_email_guid_final i
	on coalesce(r.email, c.email) = i.email
left join mci_enterprise_stage.sa_email_guid_final i2
	on r.contact__c = i2.contact_id
where coalesce(r.lastmodifieddate,r.createddate) >= '2020-07-01'
	and lower(r.product_outlook_group__c) in ('echosign','acrobat')
	and r.lead_market_area__c in ('Aus and New Zealand','Germany','United Kingdom','Japan','United States','France','Canada')

--------------------------------------------------------
--CSTACK - DISPLAY and EMAIL extract and append
--------------------------------------------------------
--extract all relevant tags to limit cstack activity
drop table mci_enterprise_stage.sa_big_sign_tags;
create table mci_enterprise_stage.sa_big_sign_tags
as select tag
		,exposure
		,post_pagename from (select
						tag
						,exposure
						,post_pagename
						,row_number() over (partition by tag order by ct desc) as rnk
						from (select 
								cgen_tag as tag
								,exposure
								,post_pagename
								,count(*) as ct 
								from mci_enterprise_stage.sa_02_v where cgen_tag is not null
								group by
								cgen_tag
								,exposure
								,post_pagename
							)z
						)z where rnk = 1
--append campign identifier to join to cstack (hopefully we can find another bridge)

drop table mci_enterprise_stage.sa_cstack_tags;
create table mci_enterprise_stage.sa_cstack_tags as --253
select distinct
a.tag as cgen_tag
,a.exposure
,a.post_pagename 
,b.campaign_identifier	
,b.campaign_start_date	
,b.channel 
from mci_enterprise_stage.sa_big_sign_tags a
inner join (
		select * from cstack_af.stg_ctags_cgen_20200404
		union all select * from cstack_af.stg_ctags_cgen_20200410 where media_type = 'CGEN'
		union all select * from cstack_af.stg_ctags_cgen_20200411 where media_type = 'CGEN'
		union all select * from cstack_af.stg_ctags_cgen_20200420 where media_type = 'CGEN'
		union all select * from cstack_af.stg_ctags_cgen_20200425 where media_type = 'CGEN'
		union all select * from cstack_af.stg_ctags_cgen_20200503 where media_type = 'CGEN'
		union all select * from cstack_af.stg_ctags_cgen_20200510 where media_type = 'CGEN'
		union all select * from cstack_af.stg_ctags_cgen_20200511 where media_type = 'CGEN'
		union all select * from cstack_af.stg_ctags_cgen_20200517 where media_type = 'CGEN'
		union all select * from cstack_af.stg_ctags_cgen_20200524 where media_type = 'CGEN'
		union all select * from cstack_af.stg_ctags_cgen_20200531 where media_type = 'CGEN'
		union all select * from cstack_af.stg_ctags_cgen_20200607 where media_type = 'CGEN'
		union all select * from cstack_af.stg_ctags_cgen_20200614 where media_type = 'CGEN'
		union all select * from cstack_af.stg_ctags_cgen_20200621 where media_type = 'CGEN'
		union all select * from cstack_af.stg_ctags_cgen_20200628 where media_type = 'CGEN'
		union all select * from cstack_af.stg_ctags_cgen_20200705 where media_type = 'CGEN'
		union all select * from cstack_af.stg_ctags_cgen_20200708 where media_type = 'CGEN'
		union all select * from cstack_af.stg_ctags_cgen_20200712 where media_type = 'CGEN'
		union all select * from cstack_af.stg_ctags_cgen_20200719 where media_type = 'CGEN'
		union all select * from cstack_af.stg_ctags_cgen_20200726 where media_type = 'CGEN'
		union all select * from cstack_af.stg_ctags_cgen_202007802 where media_type = 'CGEN'
		--union all select * from cstack.stg_ctags_cgen where media_type = 'CGEN'
		) b
on a.tag = b.campaign_tag

drop table mci_enterprise_stage.sa_01_c
create table mci_enterprise_stage.sa_01_c as --51,676,796
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
,t.post_pagename
,t.cgen_tag	
,t.exposure
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
left join mci_enterprise_stage.sa_cstack_tags t
    on t.campaign_identifier = 	c.campaign_business_key
    and t.campaign_start_date = c.campaign_start_dt
    and t.channel = h.channel

			or t.campaign_identifier is not null)
;

drop table mci_enterprise_stage.sa_02_c;
create table mci_enterprise_stage.sa_02_c as --15,556,788	1859,304	85,693 rows; rows with emails
select distinct
'cstack' as source
,s.first_exposure_date as click_date 	
,coalesce(hr.visid,i2.visid) as visid
,coalesce(i.mcvisid,i2.mcvisid) as mcvisid	
,coalesce(i.session_id,i2.session_id) as session_id
,NULL as tap_sub_std_name_key
,NULL as inq_management_id
,case when trim(hr.post_evar12) = '' then null else coalesce(trim(hr.post_evar12),i.guid) end as guid
,coalesce(i.mch_cookie,i2.mch_cookie) as mch_cookie
,NULL as faas_submission_id
,coalesce(i.email,i2.email) as email	
,coalesce(i.contact_id,i2.contact_id) as contact_id
,s.qtr	
,s.week
,campaign_link as page_url
,s.post_pagename
,s.cgen_tag	
,NULL as sfdc_tag
,NULL as leadsource
,NULL as leadsource2
,s.exposure
,'CGEN Only' as url_tag_types 
,s.marketing_channel
,'Sign' as product
from mci_enterprise_stage.sa_01_c s
left join cstack.traffic_sc_visitor_click_history_stitched hs
	on s.original_source_id = hs.original_source_id
	and s.path_id = hs.path_id
	and hs.event_date >= '2020-07-01'
left join cstack.traffic_sc_visitor_click_history_raw hr
	on hs.visit_num_detail = hr.visit_num_detail
	and hs.event_date = hr.event_date
	and hr.event_date >= '2020-07-01'
left join mci_enterprise_stage.ab_big_sign_campaign_taxonomy a
	on s.post_pagename = a.pagen
	ame
left join mci_enterprise_stage.sa_email_guid_final i
	on hr.visid = i.visid
left join mci_enterprise_stage.sa_email_guid_final i2
	on coalesce(trim(hr.post_evar12)) = i2.guid
	and trim(hr.post_evar12) <> ''

--Merge datasets
drop table mci_enterprise_stage.sa_01; --15,619,356	1,888,183	94,663	

create table mci_enterprise_stage.sa_01
as select * 
,case when sfdc_tag is not null then 'SFDC' else 'CGEN' end as table_tag_type
from (select * from mci_enterprise_stage.sa_02_v
union all
select * from mci_enterprise_stage.sa_02_c
union all
select * from mci_enterprise_stage.sa_01_r
)z;

--********************************************************************************************************************************	
--------------------------------------------------------
--CAMPAIGN SFDC - extract, format, filter to desired campaigns
--------------------------------------------------------
--********************************************************************************************************************************	
drop table mci_enterprise_stage.sa_camp_00s; --155,831
create table mci_enterprise_stage.sa_camp_00s
as 
select distinct
	UPPER(s.id) as id 
    ,trim(regexp_replace(s.name,'[\|\n\r]',' ')) as sfdc_campaign_name
	,case when s.subtype__c in ('3rd Party Email'
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
							,'Website Direct') then 'In-Product'
		when s.subtype__c in ('Search (SEO)') then 'Search: Natural'
		when s.subtype__c like 'Social%' then 'Social: Ads'
		when s.subtype__c like 'Webin%' then 'Webinar'
		when s.subtype__c in ('E-Seminar Event') then 'Webinar'
		when s.subtype__c like 'White%' then 'Whitepaper'
		when s.subtype__c in ('Success Story (Case Study)','Success story','Research Paper') then 'Whitepaper'
		else 'Other' end as sfdc_channel
	,case when s.region__c like 'EMEA%' then 'EMEA'
		when s.region__c in ('Americas - North America','Central','Northern','Southwest') then 'US'
		when s.region__c in ('APAC','Japan') then s.region__c 
		when s.region__c in ('Americas - Latin America','Americas - South America','Other (Global)') then 'Worldwide' 
	else null end sfdc_region
    ,trim(regexp_replace(s.program_mktg__c,'[\|\n\r]',' ')) as sfdc_program
    ,trim(regexp_replace(s.bu_campaign__c,'[\|\n\r]',' ')) as bu_campaign__c
    ,trim(regexp_replace(s.bu_group__c,'[\|\n\r]',' ')) as bu_group__c
	,coalesce(year(s.startdate),lpad(month(s.startdate),2,'0')) as sfdc_campaign_start_month
	,s.subtype__c 
from mci_enterprise_stage.okui_sfdc_campaign s
where isdeleted = 'false'
	and trim(regexp_replace(s.bu_campaign__c,'[\|\n\r]',' ')) not like '%AEC%'
	and trim(regexp_replace(s.bu_campaign__c,'[\|\n\r]',' ')) not like '%DX%'
	and trim(regexp_replace(s.bu_group__c,'[\|\n\r]',' ')) <> 'CC Opt Meacham 2016'
--------------------------------------------------------
--CAMPAIGN CGEN - extract, format, filter to desired campaigns
--------------------------------------------------------
drop table mci_enterprise_stage.sa_camp_00c; -- 302,198
create table mci_enterprise_stage.sa_camp_00c
as select * from (
select distinct
	t.tag_id
	,case when lower(a.product_promoted) like '%acrobat%' then 'Acrobat'
		when a.product_promoted in ('Document Cloud','ExportPDF') then 'Acrobat'
		when lower(a.product_promoted) like '%stock%' then 'Stock'
		when lower(a.product_promoted) like '%sign%' then 'Sign'
		when lower(a.product_promoted) like '%creative%' then 'CC'
		when lower(a.product_promoted)like '%creative%' then 'CC'
		when lower(a.product_promoted)like '%photoshop%' then 'CC'
		when lower(a.product_promoted)like '%cc%' then 'CC'
		when a.product_promoted in ('Premiere Rush') then 'CC'
		else 'Other' end as product_promoted
	,case when a.region in ('Latin America','ROW','World Wide') then 'Worldwide'
		when a.region in ('North America') then 'US' else  a.region end as cgen_region
    ,case when lower(a.business_owner) like '%enterprise%' then 'ENT' else 'Other' end  as cgen_business 
    ,trim(regexp_replace(p.campaign_name,'[\|\n\r]',' ')) as cgen_campaign_name
    ,trim(regexp_replace(a.activity_name,'[\|\n\r]',' ')) as activity_name
	,concat(coalesce(trim(regexp_replace(a.activity_name,'[\|\n\r]',' ')),''),' - ',coalesce(trim(regexp_replace(t.tag_name,'[\|\n\r]',' ')),'')) as tag_name
    ,coalesce(year(p.date_start),lpad(month(p.date_start),2,'0')) as cgen_campaign_start_month
    ,case when p.date_end <= current_timestamp() then 'Ended' else 'Ongoing' end as cgen_campaign_status
from mioops.cgen_tags t
left join mioops.cgen_activities a
    on a.activity_id = t.activity_id
left join mioops.cgen_programs p
    on p.campaign_id = a.campaign_id
where year(p.date_start) >= 2019
	and a.product_promoted not in ('Analytics','Campaign','ColdFusion','Experience Manager',
	'Magento Commerce','Marketo Engage','Marketo Engagement Platform','Target')
	and trim(regexp_replace(t.tag_name,'[\|\n\r]',' ')) not like '%AEC%'
	and trim(regexp_replace(t.tag_name,'[\|\n\r]',' ')) not like '%DX%'
	and trim(regexp_replace(p.campaign_name,'[\|\n\r]',' ')) <> 'CC Opt Meacham 2016'
)z where tag_name <>''
--------------------------------------------------------
--CAMPAIGN  - append all campaign details
--------------------------------------------------------
drop table mci_enterprise_stage.sa_02;
create table mci_enterprise_stage.sa_02 as --15,619,220	1,888,047	94,663
	select distinct
	v.source
	,v.click_date 	
	,v.visid
	,v.mcvisid	
	,v.session_id
	,v.tap_sub_std_name_key
	,v.inq_management_id
	,case when lower(guid) in ('unknown','cc','create_together','dc','edit-payment') then null else trim(v.guid) end as guid
	,v.mch_cookie
	,v.faas_submission_id
	,coalesce(v.email,cc.email,cg.email,p.pers_email) email	
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
	,v.url_tag_types 
	,coalesce(v.marketing_channel,sfdc_channel) as marketing_channel
	,coalesce(v.product,c.product_promoted) as product
	,coalesce(v.sfdc_tag,leadsource,v.cgen_tag) as tag
	,coalesce(s.sfdc_region,c.cgen_region) as region
	,coalesce(s.sfdc_program,v.leadsource,c.cgen_campaign_name) as program_campaign
	,coalesce(s.bu_group__c,v.leadsource,c.cgen_campaign_name) as group_campaign
	,coalesce(s.sfdc_campaign_name,v.leadsource2,c.tag_name) as campaign_tag
	,s.sfdc_campaign_name
	,s.sfdc_program
	,c.tag_name
	,c.cgen_campaign_name
	,coalesce(sfdc_campaign_start_month,c.cgen_campaign_start_month) as start_month
	,c.cgen_business 
	,c.activity_name
	,c.cgen_campaign_status
	,s.bu_campaign__c
	,s.subtype__c 
	,v.table_tag_type
	from  mci_enterprise_stage.sa_01 v	
	left join mci_enterprise_stage.sa_camp_00c c
		on c.tag_id = v.cgen_tag
	left join mci_enterprise_stage.sa_camp_00s s
		on s.id  = v.sfdc_tag
	left join mci_enterprise_stage.okui_lvt_profile_sample p --warehouse.dim_user_lvt_profile 
		on upper(c.event_guid) =  upper(v.guid)
	left join mci_enterprise_stage.abm_enterprise_contact cc
		on upper(cc.sf_contact_id) = upper(v.contact_id);
	left join mci_enterprise_stage.abm_enterprise_contact cg
		on upper(c.user_guid) = upper(guid)
;
--------------------------------------------------------
-- VISITS backfill missing identifiers based on visid
--------------------------------------------------------
select 
count(distinct v.tap_sub_std_name_key) as tap_sub_std_name_key
,count(v.tap_sub_std_name_key) as all_tap_sub_std_name_key
,count(distinct v.visid) as visid
,count(v.visid) as all_visid
,count(distinct v.faas_submission_id) as faas_submission_id
,count(v.faas_submission_id) as all_faas_submission_id
,count(distinct v.email) as email
,count(v.email) as all_email
,count(distinct v.contact_id) as contact_id
,count(v.contact_id) as all_contact_id
,count(distinct v.guid) as guid
,count(v.guid) as all_guid
from mci_enterprise_stage.sa_02 v

/*
tap_sub_std_name_key		6,244
all_tap_sub_std_name_key	57,860
visid						49,132
all_visid					15,610,033
faas_submission_id			15	
all_faas_submission_id		31
email						94,663
all_email					1,887,980
sfdc_id						9,844
all_sfdc_id					83,062
guid						1,948
all_guid					22,269

tap_sub_std_name_key		6,244
all_tap_sub_std_name_key	57,860
visid						49,132
all_visid					15,610,033
faas_submission_id			15
all_faas_submission_id		31
email						94,663
all_email					1,887,980
sfdc_id						9,844
all_sfdc_id					83,062
guid						1,948
all_guid					22,269
*/
drop table mci_enterprise_stage.sa_g;
create table mci_enterprise_stage.sa_g -- 46,643
as select *, row_number() over (partition by visid order by cnt desc) as rnk from (
select 
v.guid
,v.visid
,count(*) as cnt
from mci_enterprise_stage.sa_02 v
where v.guid is not null
group by
v.guid
,v.visid )z
;

drop table mci_enterprise_stage.sa_t;
create table mci_enterprise_stage.sa_t --77,189
as select *, row_number() over (partition by visid order by cnt desc) as rnk from (
select 
v.tap_sub_std_name_key
,v.visid
,count(*) as cnt
from mci_enterprise_stage.sa_02 v
where v.tap_sub_std_name_key is not null
group by
v.tap_sub_std_name_key
,v.visid )z
;

drop table mci_enterprise_stage.sa_f;
create table mci_enterprise_stage.sa_f --
as select *, row_number() over (partition by visid order by cnt desc) as rnk from (
select 
v.faas_submission_id
,v.visid
,count(*) as cnt
from mci_enterprise_stage.sa_02 v
where v.faas_submission_id is not null
group by
v.faas_submission_id
,v.visid
) z;

drop table mci_enterprise_stage.sa_e;
create table mci_enterprise_stage.sa_e --
as select *, row_number() over (partition by visid order by cnt desc) as rnk from (
select 
v.email
,v.visid
,count(*) as cnt
from mci_enterprise_stage.sa_02 v
where v.email is not null
group by
v.email
,v.visid
) z;

drop table mci_enterprise_stage.sa_s;
create table mci_enterprise_stage.sa_s --
as select *, row_number() over (partition by visid order by cnt desc) as rnk from (
select 
v.contact_id 
,v.visid
,count(*) as cnt
from mci_enterprise_stage.sa_02 v
where v.contact_id is not null
group by
v.contact_id 
,v.visid
) z;

--append identifiers and account data
drop table mci_enterprise_stage.sa_camp_view_01;
create table mci_enterprise_stage.sa_camp_view_01 --32,418
as select distinct
case when v.source = 'web_visits' then 'Click Data' 
		when v.source = 'cstack' then 'CStack Data'
		when v.source = 'response' then 'Responses'
		else null end as source
,v.click_date 	
,v.visid
,v.mcvisid	
,v.session_id
,coalesce(v.tap_sub_std_name_key,t.tap_sub_std_name_key) as tap_sub_std_name_key
,v.inq_management_id
,coalesce(v.guid,g.guid) as guid
,coalesce(v.mch_cookie,substr(f.faas_submission_id,22,34)) as mch_cookie
,coalesce(v.faas_submission_id,f.faas_submission_id) as faas_submission_id
,coalesce(v.email,em.email) as email
,coalesce(v.contact_id,s.contact_id) as contact_id
,v.qtr	
,v.week
,v.page_url
,v.post_pagename
,v.cgen_tag	
,v.sfdc_tag
,v.leadsource
,v.leadsource2
,v.exposure
,v.url_tag_types 
,v.marketing_channel as channel
,v.product
,v.tag
,v.region
,v.program_campaign
,v.group_campaign
,v.campaign_tag
,v.sfdc_campaign_name
,v.sfdc_program
,v.tag_name
,v.cgen_campaign_name
,v.start_month
,v.cgen_business 
,v.activity_name
,v.cgen_campaign_status
,v.table_tag_type
from mci_enterprise_stage.sa_02 v
left join mci_enterprise_stage.sa_g g
      on g.visid = v.visid
      and g.rnk = 1
left join mci_enterprise_stage.sa_t t
     on t.visid = v.visid
     and t.rnk = 1
left join mci_enterprise_stage.sa_f f
     on f.visid = v.visid
     and f.rnk = 1
left join mci_enterprise_stage.sa_e em
     on em.visid = v.visid
     and em.rnk = 1
left join mci_enterprise_stage.sa_s s
      on s.visid = v.visid
      and s.rnk = 1

select 
count(distinct v.tap_sub_std_name_key) as tap_sub_std_name_key
,count(v.tap_sub_std_name_key) as all_tap_sub_std_name_key
,count(distinct v.visid) as visid
,count(v.visid) as all_visid
,count(distinct v.faas_submission_id) as faas_submission_id
,count(v.faas_submission_id) as all_faas_submission_id
,count(distinct v.email) as email
,count(v.email) as all_email
,count(distinct v.sfdc_id) as sfdc_id
,count(v.sfdc_id) as all_sfdc_id
,count(distinct v.guid) as guid
,count(v.guid) as all_guid
from mci_enterprise_stage.sa_camp_view_01 v


drop table mci_enterprise_stage.sa_camp_view_02;
create table mci_enterprise_stage.sa_camp_view_02 as 
select * 
, row_number() over () as click_row
, case when lower(v.campaign_tag) like '%trial%' then 'Y'
		when lower(v.program_campaign) like '%trial%' then 'Y'
		when lower(v.group_campaign) like '%trial%' then 'Y'
		when lower(v.activity_name) like '%trial%' then 'Y' else 'N' end as Trial
,concat(coalesce(v.source,0)
			,coalesce(v.channel,0)
			,coalesce(v.product,0)
			,coalesce(v.region,0)
			,coalesce(v.cgen_business,0)
			,coalesce(v.campaign_tag,0)
			,coalesce(v.program_campaign,0)
			,coalesce(v.group_campaign,0)
			,coalesce(v.activity_name,0)
			,coalesce(v.start_month,0)
			,coalesce(v.table_tag_type,0)
			,coalesce(v.exposure,0)
			,coalesce(v.source,0)
			) as summary_group
from mci_enterprise_stage.sa_camp_view_01 v
;
--********************************************************************************************************************************	
----------------------------------------------------------------------------------------------------------------------------------
--RESULTS - Responses
----------------------------------------------------------------------------------------------------------------------------------	
--********************************************************************************************************************************	
drop table mci_enterprise_stage.sa_resp_camp_view; --8,348
create table mci_enterprise_stage.sa_resp_camp_view
as select distinct
case when month(coalesce(r.lastmodifieddate,r.createddate))  =12 then concat(year(coalesce(r.lastmodifieddate,r.createddate))+1,'-Q1') 
		when month(coalesce(r.lastmodifieddate,r.createddate))<3 then concat(year(coalesce(r.lastmodifieddate,r.createddate)),'-Q1') 
		when month(coalesce(r.lastmodifieddate,r.createddate)) <6 then concat(year(coalesce(r.lastmodifieddate,r.createddate) ),'-Q2') 
		when month(coalesce(r.lastmodifieddate,r.createddate))<9 then concat(year(coalesce(r.lastmodifieddate,r.createddate)),'-Q3') 
		else concat(year(coalesce(r.lastmodifieddate,r.createddate)),'-Q4')  end as resp_qtr
,case when month(coalesce(r.lastmodifieddate,r.createddate)) = 12 then concat(year(coalesce(r.lastmodifieddate,r.createddate))+1,'-'
        ,lpad(weekofyear(coalesce(r.lastmodifieddate,r.createddate))-weekofyear(cast(concat(year(coalesce(r.lastmodifieddate,r.createddate)),'-12-01') as date)) +1,2,'0'))
		else concat(year(coalesce(r.lastmodifieddate,r.createddate)),'-',lpad(weekofyear(coalesce(r.lastmodifieddate,r.createddate))+52-weekofyear(cast(concat(year(coalesce(r.lastmodifieddate,r.createddate))-1,'-12-01') as date)),2,'0'))
		end as resp_wk
,case when month(r.time_stamp_mql__c)  =12 then concat(year(r.time_stamp_mql__c)+1,'-Q1') 
		when month(r.time_stamp_mql__c)<3 then concat(year(r.time_stamp_mql__c),'-Q1') 
		when month(r.time_stamp_mql__c) <6 then concat(year(r.time_stamp_mql__c),'-Q2') 
		when month(r.time_stamp_mql__c)<9 then concat(year(r.time_stamp_mql__c),'-Q3') 
		else concat(year(r.time_stamp_mql__c),'-Q4')  end as mql_qtr 
,case when month(r.time_stamp_mql__c) = 12 then concat(year(r.time_stamp_mql__c)+1,'-',lpad(weekofyear(r.time_stamp_mql__c)-weekofyear(cast(concat(year(r.time_stamp_mql__c),'-12-01') as date)) +1,2,'0'))
		else concat(year(r.time_stamp_mql__c),'-',lpad(weekofyear(r.time_stamp_mql__c)+52-weekofyear(cast(concat(year(r.time_stamp_mql__c)-1,'-12-01') as date)),2,'0')) end as mql_wk
		,r.id
		,r.contact__c as contact_id
		,coalesce(r.email,c.email) as email	
		,c.tap_sub_std_name_key
		,coalesce(r.account__c,c.sfdc_accountid) as sfdc_accountid
		,n.prnt_name
		,initcap(case when r.market_segment__c like 'EDUCA%' then 'EDUCATION'
			WHEN r.market_segment__c like 'NON%' then NULL else r.market_segment__c end) as market_segment
		,r.time_stamp_mql__c as latest_mql_date
		,case when coalesce(r.activity_subtype__c,s.activity_subtype__c) like 'White%' then 'Whitepapers' 
			when coalesce(r.activity_subtype__c,s.activity_subtype__c) like 'Webinar%' then 'Webinar Reg' 
			when coalesce(r.activity_subtype__c,s.activity_subtype__c) like 'RFI%' 
				then 'RFI' else coalesce(r.activity_subtype__c,s.activity_subtype__c) end as activity_subtype__c
		,coalesce(r.lastmodifieddate,r.createddate) as createddate
		,date_add(r.createddate,-365) as response_lookback
		,date_add(r.time_stamp_mql__c,-365) as mql_lookback
		,case when r.product_outlook_group__c = 'ECHOSIGN' then 'Sign' else initcap(r.product_outlook_group__c) end as resp_product	
from (select * from mci_enterprise_stage.ab_lead_wk_36
		union all select * from mci_enterprise_stage.ab_lead_wk_35
		union all select * from mci_enterprise_stage.ab_lead_wk_34 )  r
left join mci_enterprise.abm_sfdc_contacts_mapped c
    on r.contact__c = c.contactid
left join mci_enterprise_stage.ab_sfdc_lead_sample s
	on r.contact__c = s.contact__c
left join mci_enterprise.dme_named_accounts n
	on c.tap_sub_std_name_key = n.sub_std_name_key
where coalesce(r.lastmodifieddate,r.createddate) >= '2020-07-13'
	and lower(r.product_outlook_group__c) in ('echosign','acrobat')
	and r.lead_market_area__c in ('Aus and New Zealand','Germany','United Kingdom','Japan','United States','France','Canada')
--and (s.activity_subtype__c = 'Trial' or s.activity_subtype__c like 'White%'or s.activity_subtype__c like 'Webinar%' or s.activity_subtype__c like 'RFI%')

;


		from mci_enterprise.uda_sfdc_inquiry_management_history_std m
		left join mdpd_temp.sfdc_inquiry_management__c c XXX
			on c.id = m.parentid
		left join sourcedata.sfdc_contact c2 XXX
			on c.contact__c = c2.id
		left join warehouse.hana_ccmusage_dim_date c XXX
			ON m.mql_timestamp = c.date_date
		where lower(b.product_outlook_group__c) = ]'echosign'
			and lead_market_area__c = 'United States';
			
			
		from sourcedata.sfdc_lead r XXX
		left join warehouse.hana_ccmusage_dim_date c XXX
			on r.response_date = c.date_date;
		where r.lead_market_area__c in ('Aus and New Zealand','Germany','United Kingdom','Japan','United States','France','Canada')
			and r.createddate >= '2020-07-13'
			and lower(r.product_outlook_group__c) in ('echosign','acrobat')
--********************************************************************************************************************************	
----------------------------------------------------------------------------------------------------------------------------------
--RESULTS- Opptys
----------------------------------------------------------------------------------------------------------------------------------	
--********************************************************************************************************************************	
drop table mci_enterprise_stage.sa_opp_camp_view;
create table mci_enterprise_stage.sa_opp_camp_view --1,647
as 
select distinct
		o.opp_created_qtr
		,o.opp_created_wk
		,o.opp_id
		,o.sub_std_name_key
		,n.prnt_name
		,o.opp_name
		,case when month(o.opp_created_date)  =12 then concat(year(o.opp_created_date)+1,'-Q1') 
			when month(o.opp_created_date)<3 then concat(year(o.opp_created_date),'-Q1') 
			when month(o.opp_created_date) <6 then concat(year(o.opp_created_date),'-Q2') 
			when month(o.opp_created_date)<9 then concat(year(o.opp_created_date),'-Q3') 
			else concat(year(o.opp_created_date),'-Q4')  end as opp_created_date
		,case when month(o.opp_close_date)  =12 then concat(year(o.opp_close_date)+1,'-Q1') 
			when month(o.opp_close_date)<3 then concat(year(o.opp_close_date),'-Q1') 
			when month(o.opp_close_date) <6 then concat(year(o.opp_close_date),'-Q2') 
			when month(o.opp_close_date)<9 then concat(year(o.opp_close_date),'-Q3') 
			else concat(year(o.opp_close_date),'-Q4')  end as opp_close_date
		,initcap(coalesce(o.opp_opg,'Unknown')) as opp_product
		,o.opp_gross_asv
		,opp_adjusted_commitment
		,case when opp_adjusted_commitment ='Won' then 'Won' else o.opp_highest_stage_number end as opp_highest_stage_number
		,case when a.employee_count < 10 then 'Micro-business' 
			 when a.employee_count < 100 then 'Small-business' 
			 when a.employee_count < 1000 then 'Mid-Market'
			 when a.employee_count >= 1000 then 'Enterprise'
			 else 'Unidentified' 
    end as employee_segment
		,initcap(CASE 
		--Americas
				when o.rep_global_region = 'AMERICAS' and sfdc_account_country in ('United States','North America') then 'UNITED STATES'
				when o.rep_global_region = 'AMERICAS' and sfdc_account_country like '%US-%' then 'UNITED STATES'
				when o.rep_global_region = 'AMERICAS' and sfdc_account_country like '%CA-%' then 'CANADA'
				when o.rep_global_region = 'AMERICAS' and sfdc_account_country = 'Canada' then 'CANADA'
				when o.rep_global_region = 'AMERICAS' and sfdc_account_country = 'Brazil' then 'BRAZIL'
				when o.rep_global_region = 'AMERICAS' and sfdc_account_country like '%Mexico%' then 'MEXICO'
				when o.rep_global_region = 'AMERICAS' and sfdc_account_country in ('Chile','LATAM: excl Brazil') then 'STRAT. LATIN AMERICA'
				when o.rep_global_region = 'AMERICAS' and sfdc_account_country like '%South America%' then 'STRAT. LATIN AMERICA'
		--EMEA
				when o.rep_global_region = 'EMEA' and sfdc_account_country in ('Belgium','Belux','Netherlands') then 'BENELUX'
				when o.rep_global_region = 'EMEA' and sfdc_account_country like '%UK%' then 'UNITED KINGDOM'  ----Changed here: UK -> UNITED KINGDOM 
				when o.rep_global_region = 'EMEA' and sfdc_account_country in ('Ireland','Great Britain') then 'UNITED KINGDOM'  ----Changed here: UK -> UNITED KINGDOM 
				when o.rep_global_region = 'EMEA' and sfdc_account_country like '%France%' then 'FRANCE'
				when o.rep_global_region = 'EMEA' and sfdc_account_country like '%Germany%' then 'GERMANY'
				when o.rep_global_region = 'EMEA' and sfdc_account_country like '%Italy%' then 'ITALY'
				when o.rep_global_region = 'EMEA' and sfdc_account_country = 'Iberica' then 'IBERICA'
				when o.rep_global_region = 'EMEA' and sfdc_account_country like '%Sweden%' then 'NORDIC'
				when o.rep_global_region = 'EMEA' and sfdc_account_country like '%Denmark%' then 'NORDIC'
				when o.rep_global_region = 'EMEA' and sfdc_account_country like '%Finland%' then 'NORDIC'
				when o.rep_global_region = 'EMEA' and sfdc_account_country like '%Norway%' then 'NORDIC'
				when o.rep_global_region = 'EMEA' and sfdc_account_country like '%Nordics%' then 'NORDIC'
				when o.rep_global_region = 'EMEA' and sfdc_account_country = 'Israel' then 'SSA & ISRAEL'
				when o.rep_global_region = 'EMEA' and sfdc_account_country like '%Russia%' then 'RUSSIA & CIS'
				when o.rep_global_region = 'EMEA' and sfdc_account_country like '%RCIS%' then 'RUSSIA & CIS'
				when o.rep_global_region = 'EMEA' and sfdc_account_country like '%Switzerland%' then 'SWITZERLAND'
				when o.rep_global_region = 'EMEA' and sfdc_account_country = 'Central Europe' then 'SWITZERLAND'
				when o.rep_global_region = 'EMEA' and sfdc_account_country = 'Eastern Europe' then 'EASTERN EUROPE'
		--JAPAC   
				when o.rep_global_region = 'APAC' and sfdc_account_country in ('ANZ','Australia','New South Wales + Northern Territory + Queensland') then 'ANZ'
				when o.rep_global_region = 'APAC' and sfdc_account_country like '%AU-%' then 'ANZ'
				when o.rep_global_region = 'APAC' and sfdc_account_country like '%China%' then 'CHINA'
				when o.rep_global_region = 'APAC' and sfdc_account_country like '%India%' then 'INDIA'
				when o.rep_global_region = 'APAC' and sfdc_account_country like '%Korea%' then 'KOREA'
				when o.rep_global_region = 'APAC' and sfdc_account_country like '%Hong Kong%' then 'HONG KONG & TAIWAN'
				when o.rep_global_region = 'APAC' and sfdc_account_country in ('Pacific','SEA','Singapore') then 'SEA'
				when o.rep_global_region = 'JAPAN' then 'JAPAN'
			else 'OTHER' end) market_area
		,initcap(case when o.rep_global_region = 'AGS AMERICAS' then 'Americas'
				when o.rep_global_region = 'AMERICAS' then 'Americas'
				when o.rep_global_region = 'AMERICAS MARKETO' then 'Americas'
				when o.rep_global_region = 'APAC' then 'APAC'
				when o.rep_global_region = 'APAC MARKETO' then 'APAC'
				when o.rep_global_region = 'C&B  LATAM' then 'Americas'
				when o.rep_global_region = 'C&B AMERICAS' then 'Americas'
				when o.rep_global_region = 'C&B APAC' then 'APAC'
				when o.rep_global_region = 'C&B EMEA' then 'EMEA'
				when o.rep_global_region = 'CHANNEL EMEA' then 'EMEA'
				when o.rep_global_region = 'CHANNEL JAPAN' then 'Japan'
				when o.rep_global_region = 'EMEA' then 'EMEA'
				when o.rep_global_region = 'JAPAN' then 'Japan'
				when o.rep_global_region = 'JAPAN MARKETO' then 'Japan'
				when o.rep_global_region = 'WORLDWIDE' then 'Worldwide'
				when o.rep_global_region = 'WW' then 'Worldwide'
				when o.rep_global_region = 'WW SALES OPS TA PAT' then 'Worldwide' else 'Unknown' end) as result_region
		,o.opp_pipeline_creator_group
		,o.account_segmentation
		,a.sub_name
		,a.industry
		,a.employee_count
		,date_add(o.opp_created_date,-365) as oppty_lookback
		,case when opp_adjusted_commitment ='Won' then concat(o.opp_name, ' ( Won | $',format_number(o.opp_gross_asv,0),')') 
			else concat(o.opp_name, ' ( SS',opp_highest_stage_number,' | $',format_number(o.opp_gross_asv,0),')') end as opp_concat_name
		,row_number() over (partition by o.opp_id order by opp_gross_asv desc) as row_num
from mci_enterprise.abm_account_oppty_all_p2s o
left join mci_enterprise.abm_enterprise_account a
	on o.sub_std_name_key = a.sub_std_name_key
	--and o.market_area=a.maket_area
left join mci_enterprise.dme_named_accounts n
	on o.sub_std_name_key = n.sub_std_name_key
where o.opp_created_date >= '2020-07-13'
	and o.sub_std_name_key>0
	--and opp_created_qtr  = '2020-Q2'
	and opp_opg in ('ACROBAT','SIGN','DCE')
	and lower(sfdc_account_market_area) in ('anz','germany','united kingdom','japan','united states')
	--and o.opp_gross_asv > 1
;
--********************************************************************************************************************************	
----------------------------------------------------------------------------------------------------------------------------------
--RESULTS - Exports
----------------------------------------------------------------------------------------------------------------------------------	
--********************************************************************************************************************************	
--responses opportunites and views join and coalesce
drop table mci_enterprise_stage.sa_camp_view
create table mci_enterprise_stage.sa_camp_view as 
select distinct * from (
select 
v.*
,o.*
,coalesce(r.resp_qtr,r2.resp_qtr) resp_qtr
,coalesce(r.resp_wk,r2.resp_wk) resp_wk
,coalesce(r.id,r2.id) as inq_management_id
,coalesce(r.market_segment,r2.market_segment) market_segment
,coalesce(r.latest_mql_date,r2.latest_mql_date) latest_mql_date
,coalesce(r.activity_subtype__c,r2.activity_subtype__c) activity_subtype__c
,coalesce(r.createddate,r2.createddate) createddate
,coalesce(r.response_lookback,r2.response_lookback) response_lookback
,coalesce(r.mql_qtr,r2.mql_qtr) mql_qtr
,coalesce(r.mql_wk,r2.mql_wk) mql_wk
,coalesce(r.mql_lookback,r2.mql_lookback) mql_lookback
,coalesce(r.resp_product,r2.resp_product) resp_product
,coalesce(r.prnt_name,r2.prnt_name) resp_prnt_name

,case when coalesce(r.response_lookback,r2.response_lookback) <= v.click_date 
        and coalesce(r.createddate,r2.createddate)  >= v.click_date 
        and coalesce(r.createddate,r2.createddate)  >= '2020-07-13' then 'Yes' else 'No' end as in_lkbk_resp
,case when coalesce(r.mql_lookback,r2.mql_lookback) <= v.click_date	
        and coalesce(r.latest_mql_date,r2.latest_mql_date)  >= v.click_date 
        and coalesce(r.latest_mql_date,r2.latest_mql_date)  >= '2020-07-13' then 'Yes' else 'No' end as in_lkbk_mql
,case when o.oppty_lookback <= v.click_date and o.opp_created_date >= v.click_date then 'Yes' else 'No' end as in_lkbk_oppty
from mci_enterprise_stage.sa_camp_view_02 v

left join mci_enterprise_stage.sa_resp_camp_view r	
	on v.sfdc_id = r.contact_id
left join mci_enterprise_stage.sa_resp_camp_view r2
    	on trim(lower(v.email))	= trim(lower(r2.email))
left join  mci_enterprise_stage.sa_opp_camp_view o
	on v.tap_sub_std_name_key = o.sub_std_name_key
	and o.row_num = 1
where coalesce(v.tap_sub_std_name_key,v.faas_submission_id,v.email,v.sfdc_id) is not null
) z

--Account view and channel touches table
drop table mci_enterprise_stage.sa_opp_account_view
create table mci_enterprise_stage.sa_opp_account_view as --985
select 
o.opp_id
,o.sub_std_name_key
,o.prnt_name
,o.opp_name
,o.opp_created_date
,o.opp_close_date
,o.opp_product
,o.employee_segment
,o.result_region
,o.opp_pipeline_creator_group
,o.account_segmentation
,o.sub_name
,o.industry
,o.in_lkbk_oppty
,o.in_lkbk_mql
,o.in_lkbk_resp
,o.market_segment
,o.exposure
,o.source
,o.opp_highest_stage_number
,sum(case when seq_num_opp = 1 then o.opp_gross_asv else 0 end) as opp_gross_asv
,sum(case when seq_num_acct = 1 then o.opp_gross_asv else 0 end) as opp_gross_asv_acct
,o.opp_adjusted_commitment
,o.channel 
,o.inq_management_id
,o.latest_mql_date
,o.activity_subtype__c
,o.createddate
,o.response_lookback
,o.mql_lookback
,o.resp_product
,o.product
,case when o.prnt_name is null then 'Unnamed' else 'Named' end as named_acct
,o.seq_num_acct
,o.seq_num_opp
,sum(case when seq_num_acct = 1 and channel = 'Affiliate' then 1 else 0 end) Affiliate
,sum(case when seq_num_acct = 1 and channel = 'Display' then 1 else 0 end) Display
,sum(case when seq_num_acct = 1 and channel = 'Email' then 1 else 0 end) Email
,sum(case when seq_num_acct = 1 and channel = 'Other' then 1 else 0 end) Other
,sum(case when seq_num_acct = 1 and channel = 'In-Product' then 1 else 0 end) In_Product
,sum(case when seq_num_acct = 1 and channel = 'Search: Natural' then 1 else 0 end) Search_Natural
,sum(case when seq_num_acct = 1 and channel = 'Search: Paid' then 1 else 0 end) Search_Paid
,sum(case when seq_num_acct = 1 and channel = 'Social: Organic' then 1 else 0 end) Social_Organic
,sum(case when seq_num_acct = 1 and channel = 'Social: Owned' then 1 else 0 end) Social_Owned
,sum(case when seq_num_acct = 1 and channel = 'Social: Paid' then 1 else 0 end) Social_Paid
,sum(case when seq_num_acct = 1 then 1 else 0 end) Total

,sum(case when channel = 'Affiliate' then 1 else 0 end) Affiliate_opp
,sum(case when seq_num_opp = 1 and channel = 'Display' then 1 else 0 end) Display_opp
,sum(case when seq_num_opp = 1 and channel = 'Email' then 1 else 0 end) Email_opp
,sum(case when seq_num_opp = 1 and channel = 'Other' then 1 else 0 end) Other_opp
,sum(case when seq_num_opp = 1 and channel = 'In-Product' then 1 else 0 end) In_Product_opp
,sum(case when seq_num_opp = 1 and channel = 'Search: Natural' then 1 else 0 end) Search_Natural_opp
,sum(case when seq_num_opp = 1 and channel = 'Search: Paid' then 1 else 0 end) Search_Paid_opp
,sum(case when seq_num_opp = 1 and channel = 'Social: Organic' then 1 else 0 end) Social_Organic_opp
,sum(case when seq_num_opp = 1 and channel = 'Social: Owned' then 1 else 0 end) Social_Owned_opp
,sum(case when seq_num_opp = 1 and channel = 'Social: Paid' then 1 else 0 end) Social_Paid_opp
,sum(case when seq_num_opp = 1 then 1 else 0 end) Total_opp

from (
    select *
		,row_number() over (partition by row_num, sub_name, channel) as seq_num_acct
		,row_number() over (partition by sub_name, channel order by click_date) as channel_touches
		,row_number() over (partition by row_num, opp_id) as seq_num_opp
		from mci_enterprise_stage.sa_camp_view) o 
group by
o.opp_id
,o.sub_std_name_key
,o.prnt_name
,o.opp_name
,o.opp_created_date
,o.opp_close_date
,o.opp_product
,o.employee_segment
,o.result_region
,o.opp_pipeline_creator_group
,o.account_segmentation
,o.sub_name
,o.industry
,o.in_lkbk_oppty
,o.in_lkbk_mql
,o.in_lkbk_resp
,o.market_segment
,o.exposure
,o.source
,o.opp_highest_stage_number
,o.opp_gross_asv
,o.opp_adjusted_commitment
,o.channel 
,o.inq_management_id
,o.latest_mql_date
,o.activity_subtype__c
,o.createddate
,o.response_lookback
,o.mql_lookback
,o.resp_product
,o.product
,o.seq_num_acct
,o.seq_num_opp
--Time series of accumulated channel touches
drop table mci_enterprise_stage.sa_camp_view3;
create table mci_enterprise_stage.sa_camp_view3 as 
select *
,row_number() over (partition by sub_name, channel order by click_date) as channel_touches
from (select distinct row_num, click_date, sub_name, channel 
            from mci_enterprise_stage.sa_camp_view where sub_name is not null) z
			
--------------------------------------------------------
--RESULTS - Summarize RESP influenced
--------------------------------------------------------
drop table mci_enterprise_stage.sa_sum_camp_resp_infl;
create table mci_enterprise_stage.sa_sum_camp_resp_infl
as select
	 summary_group
	,resp_qtr as results_qtr
	,resp_wk as results_wk
	,resp_product as result_product
	,result_region
	,count(distinct inq_management_id) as resp_infl
from mci_enterprise_stage.sa_camp_view
where in_lkbk_resp = 'Yes' 
group by	
	summary_group
	,resp_qtr
	,resp_wk
	,resp_product
	,result_region
;				
--------------------------------------------------------
--RESULTS - Summarize MQL influenced   
--------------------------------------------------------			
drop table mci_enterprise_stage.sa_sum_camp_mql_infl;
create table mci_enterprise_stage.sa_sum_camp_mql_infl
as select
	 summary_group
	,mql_qtr as results_qtr
	,mql_wk as results_wk
	,resp_product as result_product
	,result_region
	,count(distinct inq_management_id) as mql_infl
from mci_enterprise_stage.sa_camp_view
where in_lkbk_mql = 'Yes' 
group by	
	summary_group
	,mql_qtr
	,mql_wk
	,resp_product
	,result_region
;	
--------------------------------------------------------
--RESULTS - Summarize OPPTY influenced
--------------------------------------------------------
drop table mci_enterprise_stage.sa_sum_camp_opp_infl;
create table mci_enterprise_stage.sa_sum_camp_opp_infl
as select
	 summary_group
	,opp_created_qtr as results_qtr
	,opp_created_wk as results_wk
	,resp_product as result_product
	,result_region
	,count(distinct opp_id) as oppty_infl
	,sum(case when row_num =1 then opp_gross_asv else 0 end) as asv_infl
from mci_enterprise_stage.sa_camp_view
where in_lkbk_oppty = 'Yes' 
group by	
	summary_group
	,opp_created_qtr
	,opp_created_wk
	,resp_product
	,result_region
;	
--********************************************************************************************************************************	
--------------------------------------------------------
--VISITS summarize click count
--------------------------------------------------------
--********************************************************************************************************************************	
drop table mci_enterprise_stage.sa_sum_00;
create table mci_enterprise_stage.sa_sum_00 --
as select	
		--filters
	concat(substr(v.qtr,1,5),'Q',substr(v.qtr,7,1)) as qtr
	,concat(substr(v.qtr,1,5),lpad(v.week,2,'0')) as week
	,v.summary_group
	,count(distinct click_row) as clicks
from mci_enterprise_stage.sa_camp_view_02 v
group by 
	--filters
	concat(substr(v.qtr,1,5),'Q',substr(v.qtr,7,1))
	,concat(substr(v.qtr,1,5),lpad(v.week,2,'0'))
	,v.summary_group
;
--------------------------------------------------------
--VISITS details
--------------------------------------------------------
drop table mci_enterprise_stage.sa_sum_01;
create table mci_enterprise_stage.sa_sum_01 --
as select	distinct
	v.source
	,v.channel 
	,v.product
	,v.region
	,v.cgen_business 
	--table data
	,campaign_tag
	,v.program_campaign
	,v.group_campaign
	--other details
	,v.tag_types
	,v.table_tag_type
	,v.summary_group
	,v.exposure
	,v.start_month
from mci_enterprise_stage.sa_camp_view_02 v
;
--------------------------------------------------------
--All dates and campaigns
--------------------------------------------------------
drop table mci_enterprise_stage.sa_sum_02;
create table mci_enterprise_stage.sa_sum_02 as --
select distinct * from (
	select results_qtr as qtr, results_wk as week, result_product, result_region, summary_group from
	mci_enterprise_stage.sa_sum_camp_resp_infl 
union all
	select results_qtr as qtr, results_wk as week, result_product, result_region, summary_group from		
	mci_enterprise_stage.sa_sum_camp_mql_infl 
union all
	select results_qtr as qtr, results_wk as week, result_product, result_region, summary_group from		
	mci_enterprise_stage.sa_sum_camp_opp_infl 
	) z
;
-------------------------------------------------------
--VISITS join
--------------------------------------------------------
drop table mci_enterprise_stage.sa_sum_03;
create table mci_enterprise_stage.sa_sum_03 --
as select
v2.qtr
,v2.week
,v2.result_product
,v2.result_region
,v.*
,coalesce(v1.clicks,0) as clicks
,coalesce(oi.oppty_infl,0) as oppty_infl
,coalesce(oi.asv_infl,0) as asv_infl
,coalesce(ri.resp_infl,0) as resp_infl
,coalesce(mi.mql_infl,0) as mql_infl
from mci_enterprise_stage.sa_sum_02 v2
left join mci_enterprise_stage.sa_sum_00 v1 
	on v2.summary_group = v1.summary_group
	and v2.qtr = v1.qtr 
	and v2.week = v1.week
left join mci_enterprise_stage.sa_sum_01 v
	on v2.summary_group =  v.summary_group
left join mci_enterprise_stage.sa_sum_camp_opp_infl oi
	on v2.summary_group = oi.summary_group
	and v2.qtr = oi.results_qtr
	and v2.week = oi.results_wk
	and v2.result_product = oi.result_product 
	and v2.result_region = oi.result_region 
left join mci_enterprise_stage.sa_sum_camp_resp_infl ri
	on v2.summary_group = ri.summary_group
	and v2.qtr = ri.results_qtr
	and v2.week = ri.results_wk
	and v2.result_product = ri.result_product 
	and v2.result_region = ri.result_region 
left join mci_enterprise_stage.sa_sum_camp_mql_infl mi
	on v2.summary_group = mi.summary_group
	and v2.qtr = mi.results_qtr
	and v2.week = mi.results_wk
	and v2.result_product = mi.result_product 
	and v2.result_region = mi.result_region 
where (mql_infl > 0 or resp_infl >0 or oppty_infl >0)


select * from mci_enterprise_stage.sa_opp_account_view
select * from mci_enterprise_stage.sa_sum_03
select * from mci_enterprise_stage.sa_camp_view3


drop table mci_enterprise_stage.sa_totals;
create table mci_enterprise_stage.sa_totals as select * from (
select '01-mci_enterprise_stage.sa_exposed_leadsource' as table, count(*) from mci_enterprise_stage.sa_exposed_leadsource group by 'mci_enterprise_stage.sa_exposed_leadsource'
union all select '02-mci_enterprise_stage.sa_00' as table, count(*) from mci_enterprise_stage.sa_00 group by 'mci_enterprise_stage.sa_00'
union all select '03-mci_enterprise_stage.sa_01_v' as table, count(*) from mci_enterprise_stage.sa_01_v group by 'mci_enterprise_stage.sa_01_v'
union all select '04-mci_enterprise_stage.sa_01_r' as table, count(*) from mci_enterprise_stage.sa_01_r group by 'mci_enterprise_stage.sa_01_r'
union all select '05-mci_enterprise_stage.sa_big_sign_tags' as table, count(*) from mci_enterprise_stage.sa_big_sign_tags group by 'mci_enterprise_stage.sa_big_sign_tags'
union all select '06-mci_enterprise_stage.sa_cstack_tags' as table, count(*) from mci_enterprise_stage.sa_cstack_tags group by 'mci_enterprise_stage.sa_cstack_tags'
union all select '07-mci_enterprise_stage.sa_01_c' as table, count(*) from mci_enterprise_stage.sa_01_c group by 'mci_enterprise_stage.sa_01_c'
union all select '08-mci_enterprise_stage.sa_01' as table, count(*) from mci_enterprise_stage.sa_01 group by 'mci_enterprise_stage.sa_01'
union all select '09-mci_enterprise_stage.sa_camp_00s' as table, count(*) from mci_enterprise_stage.sa_camp_00s group by 'mci_enterprise_stage.sa_camp_00s'
union all select '10-mci_enterprise_stage.sa_camp_00c' as table, count(*) from mci_enterprise_stage.sa_camp_00c group by 'mci_enterprise_stage.sa_camp_00c'
union all select '11-mci_enterprise_stage.sa_camp_01' as table, count(*) from mci_enterprise_stage.sa_camp_01 group by 'mci_enterprise_stage.sa_camp_01'
union all select '12-mci_enterprise_stage.sa_camp_02' as table, count(*) from mci_enterprise_stage.sa_camp_02 group by 'mci_enterprise_stage.sa_camp_02'
union all select '13-mci_enterprise_stage.sa_camp_03' as table, count(*) from mci_enterprise_stage.sa_camp_03 group by 'mci_enterprise_stage.sa_camp_03'
union all select '14-mci_enterprise_stage.sa_camp_04' as table, count(*) from mci_enterprise_stage.sa_camp_04 group by 'mci_enterprise_stage.sa_camp_04'
union all select '15-mci_enterprise_stage.sa_camp_05' as table, count(*) from mci_enterprise_stage.sa_camp_05 group by 'mci_enterprise_stage.sa_camp_05'
union all select '16-mci_enterprise_stage.sa_02' as table, count(*) from mci_enterprise_stage.sa_02 group by 'mci_enterprise_stage.sa_02'
union all select '17-mci_enterprise_stage.sa_03' as table, count(*) from mci_enterprise_stage.sa_03 group by 'mci_enterprise_stage.sa_03'
union all select '18-mci_enterprise_stage.sa_04' as table, count(*) from mci_enterprise_stage.sa_04 group by 'mci_enterprise_stage.sa_04'
union all select '19-mci_enterprise_stage.sa_g' as table, count(*) from mci_enterprise_stage.sa_g group by 'mci_enterprise_stage.sa_g'
union all select '20-mci_enterprise_stage.sa_c' as table, count(*) from mci_enterprise_stage.sa_c group by 'mci_enterprise_stage.sa_c'
union all select '21-mci_enterprise_stage.sa_t' as table, count(*) from mci_enterprise_stage.sa_t group by 'mci_enterprise_stage.sa_t'
union all select '22-mci_enterprise_stage.sa_f' as table, count(*) from mci_enterprise_stage.sa_f group by 'mci_enterprise_stage.sa_f'
union all select '23-mci_enterprise_stage.sa_e' as table, count(*) from mci_enterprise_stage.sa_e group by 'mci_enterprise_stage.sa_e'
union all select '24-mci_enterprise_stage.sa_s' as table, count(*) from mci_enterprise_stage.sa_s group by 'mci_enterprise_stage.sa_s'
union all select '25-mci_enterprise_stage.sa_camp_view_01' as table, count(*) from mci_enterprise_stage.sa_camp_view_01 group by 'mci_enterprise_stage.sa_camp_view_01'
union all select '26-mci_enterprise_stage.sa_camp_view_02' as table, count(*) from mci_enterprise_stage.sa_camp_view_02 group by 'mci_enterprise_stage.sa_camp_view_02'
union all select '27-mci_enterprise_stage.sa_resp_camp_view' as table, count(*) from mci_enterprise_stage.sa_resp_camp_view group by 'mci_enterprise_stage.sa_resp_camp_view'
union all select '28-mci_enterprise_stage.sa_opp_camp_view' as table, count(*) from mci_enterprise_stage.sa_opp_camp_view group by 'mci_enterprise_stage.sa_opp_camp_view'
union all select '29-mci_enterprise_stage.sa_opp_account_view' as table, count(*) from mci_enterprise_stage.sa_opp_account_view group by 'mci_enterprise_stage.sa_opp_account_view'
union all select '30-mci_enterprise_stage.sa_sum_camp_resp_infl' as table, count(*) from mci_enterprise_stage.sa_sum_camp_resp_infl group by 'mci_enterprise_stage.sa_sum_camp_resp_infl'
union all select '31-mci_enterprise_stage.sa_sum_camp_mql_infl' as table, count(*) from mci_enterprise_stage.sa_sum_camp_mql_infl group by 'mci_enterprise_stage.sa_sum_camp_mql_infl'
union all select '32-mci_enterprise_stage.sa_sum_camp_opp_infl' as table, count(*) from mci_enterprise_stage.sa_sum_camp_opp_infl group by 'mci_enterprise_stage.sa_sum_camp_opp_infl'
union all select '33-mci_enterprise_stage.sa_sum_00' as table, count(*) from  mci_enterprise_stage.sa_sum_00 group by ' mci_enterprise_stage.sa_sum_00'
union all select '34-mci_enterprise_stage.sa_sum_01' as table, count(*) from mci_enterprise_stage.sa_sum_01 group by 'mci_enterprise_stage.sa_sum_01'
union all select '35-mci_enterprise_stage.sa_sum_02' as table, count(*) from mci_enterprise_stage.sa_sum_02 group by 'mci_enterprise_stage.sa_sum_02'
union all select '35-mci_enterprise_stage.sa_sum_03' as table, count(*) from mci_enterprise_stage.sa_sum_03 group by 'mci_enterprise_stage.sa_sum_03')z order by table limit 300
;



select *
from mci_enterprise_stage.ab_signcamp_preview_wk34 a
join mci_enterprise_stage.sa_camp_view_02  b
on trim(lower(a.email)) = trim(lower(b.email))
