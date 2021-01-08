--------------------------------------------------------
--VISITS extract data from web_visits_detailed 
--------------------------------------------------------
drop table mci_enterprise_stage.sa_000;
create table mci_enterprise_stage.sa_000 
as 
select
    v.click_date 
    ,v.visid
    ,v.mcvisid
    ,v.session_id
    ,v.fiscal_yr_and_qtr
    ,v.fiscal_wk_in_yr
    ,v.page_url
    ,v.pagename
    ,v.post_pagename
    ,v.custom_link_details
	,last_touch_marketing_channel
    ,v.campaign 
    ,v.page_url
    , v.cgen_marketing_vehicle
from mcietl.web_visits_detailed  v 
where v.report_suite='adbadobenonacdcprod' 
	and mcvisid <> '00000000000000000000000000000000000000'
    and v.click_date >= '2018-03-01'
    and v.session_id is not null
;

drop table mci_enterprise_stage.sa_00;
create table mci_enterprise_stage.sa_00 --	53,615,279,307 rows
as 
select
    cast(v.click_date as date) as click_date 
    ,v.visid
    ,v.mcvisid
    ,v.session_id
    ,concat(substr(v.fiscal_yr_and_qtr,1,4),'-0',substr(v.fiscal_yr_and_qtr,5,1)) as qtr
    ,v.fiscal_wk_in_yr as week
    ,v.page_url
    ,coalesce(v.pagename,v.post_pagename) as pagename
    ,v.custom_link_details
	,last_touch_marketing_channel
--cgen
	,case when v.campaign like '7011%' then null else v.campaign end as cgen_campaign
    ,substr(parse_url(v.page_url, 'QUERY', 'sdid'),1, 8) as sdid
    ,substr(parse_url(v.page_url, 'QUERY', 'tracking_id'),1, 8) as tracking_id
    ,lower(coalesce(parse_url(v.page_url, 'QUERY', 'mv'), v.cgen_marketing_vehicle)) as mv
 --sfdc
	,case when v.campaign like '7011%' then v.campaign else null end as sfdc_campaign
    ,substr(parse_url(v.page_url, 'QUERY', 'rtid'),1,8 ) as rtid
    ,substr(parse_url(v.page_url, 'QUERY', 's_cid'),1,8 ) as s_cid
    ,lower(parse_url(v.page_url, 'QUERY', 'productname')) as productname
	,lower(parse_url(v.page_url, 'QUERY', 'leadsource')) as leadsource
	,lower(parse_url(v.page_url, 'QUERY', 'leadsource2')) as leadsource2
from 
(select * from mci_enterprise_stage.sa_000  union all 
	select * from mci_enterprise_stage.sa_0000) v
--------------------------------------------------------
--VISITS clean up tags and drop missing tags
--------------------------------------------------------
drop table mci_enterprise_stage.sa_01;
create table mci_enterprise_stage.sa_01 --	1,873,490,648 rows
as select *, case when sfdc_tag is not null and cgen_tag is not null and leadsource is not null then 'SFDC, Leadsource and CGEN' 
                    when sfdc_tag is not null and cgen_tag is not null and leadsource is null then 'SFDC and CGEN'  
					when sfdc_tag is not null and cgen_tag is null and leadsource is not null then 'SFDC and Leadsource'  
					when sfdc_tag is null and cgen_tag is not null and leadsource is not null then 'Leadsource and CGEN'  
					when sfdc_tag is not null and cgen_tag is null and leadsource is null then 'SFDC Only'  
					when sfdc_tag is null and cgen_tag is null and leadsource is not null then 'Leadsource Only'  
                    else 'CGEN Only' end as url_tag_types 
from (
		select v.*
			,case when coalesce(v.cgen_campaign,v.sdid, v.tracking_id) like '7011%' then NULL 
				when length(coalesce(v.cgen_campaign,v.sdid, v.tracking_id)) = 7 then upper(substr(trim(coalesce(v.cgen_campaign,v.sdid, v.tracking_id)),2,7))
				else upper(trim(coalesce(v.cgen_campaign,v.sdid, v.tracking_id))) end as cgen_tag
			,case when coalesce(v.sfdc_campaign,v.rtid,v.s_cid,v.tracking_id)  like '7011%' and length(coalesce(v.sfdc_campaign,v.rtid,v.s_cid,v.tracking_id)) = 18 then 
				upper(trim(coalesce(v.sfdc_campaign,v.rtid,v.s_cid,v.tracking_id)))  else NULL end as sfdc_tag
			
		from mci_enterprise_stage.sa_00 v
		where 
		  (coalesce(v.cgen_campaign,v.sdid, v.tracking_id) is not null
				and coalesce(v.cgen_campaign,v.sdid, v.tracking_id) not like '7011%')
		  or (coalesce(v.sfdc_campaign,v.rtid,v.s_cid,v.tracking_id) like '7011%' and length(coalesce(v.sfdc_campaign,v.rtid,v.s_cid,v.tracking_id)) = 18)
		  or coalesce(leadsource, leadsource2) is not null
 ) z
--url_tag_types
--SFDC and CGEN	6,236
--CGEN Only	1,335,322,445
--SFDC Only	1,837,778
--********************************************************************************************************************************	
--------------------------------------------------------
--CAMPAIGN SFDC - extract, format, filter to desired campaigns
--------------------------------------------------------
--********************************************************************************************************************************	


select a.campaign_tag ,b.bu_campaign_c from 
mci_enterprise_stage.sa_07 a
left join mci_enterprise.uda_sfdc_campaign_std b
on a.tag = b.campaign_id_c
where table_tag_type = 'SFDC'
and a.campaign_tag <> b.bu_campaign_c


drop table mci_enterprise_stage.sa_camp_00s; -- 1,521,218 rows
create table mci_enterprise_stage.sa_camp_00s
as 
select distinct
	s.id 
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
							,'Website Direct') then 'Product'
		when s.subtype__c in ('Search (SEO)') then 'Search: Natural'
		when s.subtype__c like 'Social%' then 'Social: Ads'
		when s.subtype__c like 'Webin%' then 'Webinar'
		when s.subtype__c in ('E-Seminar Event') then 'Webinar'
		when s.subtype__c like 'White%' then 'Whitepaper'
		when s.subtype__c in ('Success Story (Case Study)','Success story','Research Paper') then 'Whitepaper'
		else 'Other' 
	end as sfdc_channel
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
drop table mci_enterprise_stage.sa_camp_00c; -- 725,633 rows  
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
	/*,case when t.tag_name LIKE 'CTA%' t.tag_name LIKE 'Placeholder%'OR lower(t.tag_name) in (
                              'additional 20% off', 
                              'adobe.com', 
                              'button', 
                              'buy now', 
                              'ccx start - buy now', 
                              'contact', 
							  'contactus',
                              'cp branded trial', 
                              'download now', 
                              'email 1: catalog', 
                              'explore collection', 
                              'explore gallery', 
                              'find out more', 
                              'get offer', 
                              'get started', 
                              'give it a try', 
                              'go', 
                              'help', 
                              'helpx page', 
                              'join now', 
                              'learn more', 
                              'learn more button', 
							  'listennow',
                              'plans', 
                              'plans page', 
                              'privacy', 
                              'reconfirm', 
							  'read',
							  'readnow'
							  'readthereport',
                              'register now', 
							  'registernow',
                              'renew now', 
                              'save 40%', 
                              'save 70% now', 
                              'see tutorials', 
                              'see whats new', 
							  'signupnow',
							  'sign in',
							  'sign in now',
							  'startnow',
                              'toast', 
                              'try it free', 
                              'update your apps',
							  'upgrade',
							  'view report',
                              'view tutorials',
							  'view report',
							  'watchnow',
							  'watch now',
							  'watchthewebinar',
							  'viewnow',
							  'view report',
							  'viewarticle') then trim(regexp_replace(a.activity_name,'[\|\n\r]',' ')) else trim(regexp_replace(t.tag_name,'[\|\n\r]',' ')) end as tag_name*/
	,concat(coalesce(trim(regexp_replace(a.activity_name,'[\|\n\r]',' ')),''),' - ',coalesce(trim(regexp_replace(t.tag_name,'[\|\n\r]',' ')),'') as tag_name
    ,coalesce(year(p.date_start),lpad(month(p.date_start),2,'0')) as cgen_campaign_start_month
    ,case when p.date_end <= current_timestamp() then 'Ended' else 'Ongoing' end as cgen_campaign_status
from mioops.cgen_tags t
left join mioops.cgen_activities a
    on a.activity_id = t.activity_id
left join mioops.cgen_programs p
    on p.campaign_id = a.campaign_id
where year(p.date_start) >= 2015
	and a.product_promoted not in ('Analytics','Campaign','ColdFusion','Experience Manager',
	'Magento Commerce','Marketo Engage','Marketo Engagement Platform','Target')
	and trim(regexp_replace(t.tag_name,'[\|\n\r]',' ')) not like '%AEC%'
	and trim(regexp_replace(t.tag_name,'[\|\n\r]',' ')) not like '%DX%'
	and trim(regexp_replace(p.campaign_name,'[\|\n\r]',' ')) <> 'CC Opt Meacham 2016'
) where tag_name <>''
--------------------------------------------------------
--CAMPAIGN Create a master SFDC/CGEN details table
--------------------------------------------------------	
-- both tags  
drop table mci_enterprise_stage.sa_camp_01; -- 264 distinct sets of tags
create table mci_enterprise_stage.sa_camp_01 as
select v.cgen_tag
	,v.sfdc_tag
	,concat(coalesce(v.sfdc_tag,''),coalesce(v.cgen_tag,'')) as concat_tag  --coalesce because otherwise any null will result in conact null
	,'SFDC' as table_tag_type --to indicate which campaign name is shown
	,'SFDC and CGEN' as tag_types -- actual data available
	,case when s.id is null then concat(' (',v.sfdc_tag,')') else '' end as sfdc_placeholder
	,v.leadsource
	,v.leadsource2
	,count(*) as ct
from mci_enterprise_stage.sa_01 v 
inner join mci_enterprise_stage.sa_camp_00c c --must have both
    on c.tag_id = v.cgen_tag
left join mci_enterprise_stage.sa_camp_00s s 
    on s.id  = v.sfdc_tag
where v.sfdc_tag is not null
group by 
v.cgen_tag
,v.sfdc_tag
,'SFDC'
,'SFDC and CGEN'
,concat(coalesce(v.sfdc_tag,''),coalesce(v.cgen_tag,''))
,case when s.id is null then concat(' (',v.sfdc_tag,')') else '' end
,v.leadsource
,v.leadsource2
;

--CGEN Only
drop table mci_enterprise_stage.sa_camp_02; -- 210,345 distinct tags
create table mci_enterprise_stage.sa_camp_02 as
select 
	v.cgen_tag
	,v.sfdc_tag
	,v.cgen_tag as concat_tag
	,'CGEN' as table_tag_type
	,'CGEN Only' as tag_types
	,'' as sfdc_placeholder
		,v.leadsource
	,v.leadsource2
	,count(*) as ct
from mci_enterprise_stage.sa_01 v 
left join mci_enterprise_stage.sa_camp_01 x
	on x.cgen_tag = v.cgen_tag
left join mci_enterprise_stage.sa_camp_00c c
    on c.tag_id = v.cgen_tag
where 
	x.sfdc_tag is null  --exclude any with both
	and c.tag_id is not null --selected campaigns only
group by 
v.cgen_tag
	,v.sfdc_tag
	,v.cgen_tag
	,'CGEN'
	,'CGEN Only'
	,''
		,v.leadsource
	,v.leadsource2
;

--sfdc only
drop table mci_enterprise_stage.sa_camp_03; --635 distinct tags
create table mci_enterprise_stage.sa_camp_03 as
select 
v.cgen_tag
	,v.sfdc_tag
	,v.sfdc_tag as concat_tag
	,'SFDC' as table_tag_type
	,'SFDC Only' as tag_types
	,case when s.id is null then concat('(',v.sfdc_tag,')') else '' end as sfdc_placeholder
		,v.leadsource
	,v.leadsource2
	,count(*) as ct
from mci_enterprise_stage.sa_01 v 
left join mci_enterprise_stage.sa_camp_01 x 
	on x.sfdc_tag  = v.sfdc_tag
left join mci_enterprise_stage.sa_camp_00s s
    on s.id  = v.sfdc_tag
where 
	x.cgen_tag is null  --exclude any with both
	and s.id is not null  --selected campaigns only
group by 
v.cgen_tag
	,v.sfdc_tag
	,v.sfdc_tag
	,'SFDC'
	,'SFDC Only' 
	,case when s.id is null then concat('(',v.sfdc_tag,')') else '' end 
		,v.leadsource
	,v.leadsource2
;

--union create all tag pairs in data 
drop table mci_enterprise_stage.sa_camp_04; --211,244
create table mci_enterprise_stage.sa_camp_04 as
select distinct * from(
select * from mci_enterprise_stage.sa_camp_01
union all 
select * from mci_enterprise_stage.sa_camp_02
union all
select * from mci_enterprise_stage.sa_camp_03) x;

--append all campaign details
drop table mci_enterprise_stage.sa_camp_05;
create table mci_enterprise_stage.sa_camp_05 as --197,563
	select v.*
	,coalesce(v.sfdc_tag,leadsource,v.cgen_tag) as tag
	,coalesce(s.sfdc_region,c.cgen_region) as region
	,concat(coalesce(s.sfdc_program,v.leadsource,c.cgen_campaign_name),coalesce(sfdc_placeholder,'')) as program_campaign
	,concat(coalesce(s.bu_group__c,v.leadsource,c.cgen_campaign_name),coalesce(sfdc_placeholder,'')) as group_campaign
	,concat(coalesce(s.sfdc_campaign_name,v.leadsource2,c.tag_name),coalesce(sfdc_placeholder,'')) as campaign_tag
	,s.sfdc_campaign_name
	,s.sfdc_program
	,c.tag_name
	,c.cgen_campaign_name
	,coalesce(sfdc_campaign_start_month,c.cgen_campaign_start_month) as start_month
	,c.cgen_business 
	,c.activity_name
	,c.cgen_campaign_status
	,s.bu_campaign__c
	,s.sfdc_channel
	,c.product_promoted
	,s.subtype__c 
	,row_number() over (partition by cgen_tag,tag_types order by ct desc) as cgen_rank
	,row_number() over (partition by sfdc_tag,tag_types order by ct desc) as sfdc_rank
	from mci_enterprise_stage.sa_camp_04 v	
	left join mci_enterprise_stage.sa_camp_00c c
		on c.tag_id = v.cgen_tag
	left join mci_enterprise_stage.sa_camp_00s s
		on s.id  = v.sfdc_tag
	where coalesce(s.sfdc_program,s.bu_group__c,c.cgen_campaign_name,leadsource) is not null
;

--duplicates
select count(*) from  mci_enterprise_stage.sa_camp_05 where (cgen_rank >1 and cgen_tag is not null) or (sfdc_rank>1 and sfdc_tag is not null); --211
select * from (select sfdc_tag,count(*) as cnt from mci_enterprise_stage.sa_camp_05 group by sfdc_tag having count(*) >1)z order by cnt desc limit 1000; --19 with >1 corresponding cgen
	--most are low counts of duplicate pairs this one is high - less relevant duplicate
	select * from mci_enterprise_stage.sa_camp_05 where sfdc_tag= '70114000002CFGJAA0' order by sfdc_rank limit 1000;
select * from (select cgen_tag,count(*) cnt from mci_enterprise_stage.sa_camp_05 group by cgen_tag having count(*) >1 )z order by cnt desc limit 1000; --16 with >1 corresponding sfdc
	--all low counts of duplicate pairs <=10
	select * from mci_enterprise_stage.sa_camp_05 where cgen_tag= '4F569NLM' order by cgen_rank limit 1000; --highest associated much more frequent than the others
--essentially rows with cgen and no sfdc will get tagged with the most frequently associated sfdc to show in the table
--********************************************************************************************************************************	
--------------------------------------------------------
-- VISITS append campaign details
-- if both tags are in the url and selected campaigns, then use the campaign info for each to fill in the campaigns' info
-- if only one is in the url and selected campaigns, populate the missing from the other from... the one with both, with the most, if it exists
--------------------------------------------------------
--********************************************************************************************************************************	
drop table mci_enterprise_stage.sa_02; --426,787,534
create table mci_enterprise_stage.sa_02 as
	select v.*
		,coalesce(c1.concat_tag,c2.concat_tag,c3.concat_tag) as concat_tag
		,case when v.sfdc_tag is null and v.leadsource is not null then 'Leadsource' else coalesce(c1.table_tag_type,c2.table_tag_type,c3.table_tag_type) end as table_tag_type
		,coalesce(c1.tag_types,c2.tag_types,c3.tag_types) as tag_types
		,coalesce(c1.tag,c2.tag,c3.tag) as tag
		,coalesce(c1.region,c2.region,c3.region) as region
		,coalesce(c1.program_campaign,c2.program_campaign,c3.program_campaign) as program_campaign
		,coalesce(c1.group_campaign,c2.group_campaign,c3.group_campaign) as group_campaign
		,coalesce(c1.campaign_tag,c2.campaign_tag,c3.campaign_tag) as campaign_tag
		,coalesce(c1.start_month,c2.start_month,c3.start_month) as start_month
		,coalesce(c1.cgen_business,c2.cgen_business,c3.cgen_business) as cgen_business
		,coalesce(c1.activity_name,c2.activity_name,c3.activity_name) as activity_name
		,coalesce(c1.cgen_campaign_status,c2.cgen_campaign_status,c3.cgen_campaign_status) as cgen_campaign_status
		,coalesce(c1.bu_campaign__c,c2.bu_campaign__c,c3.bu_campaign__c) as bu_campaign__c
		,coalesce(c1.sfdc_channel,c2.sfdc_channel,c3.sfdc_channel) as sfdc_channel
		,coalesce(c1.product_promoted,c2.product_promoted,c3.product_promoted) as product_promoted		
		,coalesce(c1.sfdc_campaign_name,c2.sfdc_campaign_name,c3.sfdc_campaign_name) sfdc_campaign_name
		,coalesce(c1.sfdc_program,c2.sfdc_program,c3.sfdc_program) sfdc_program
		,coalesce(c1.tag_name,c2.tag_name,c3.tag_name) tag_name
		,coalesce(c1.cgen_campaign_name,c2.cgen_campaign_name,c3.cgen_campaign_name) cgen_campaign_name
		,coalesce(c1.subtype__c,c2.subtype__c,c3.subtype__c) subtype__c
	from mci_enterprise_stage.sa_01 v
	left join mci_enterprise_stage.sa_camp_05 c1
		on concat(coalesce(v.sfdc_tag,''),coalesce(v.cgen_tag,'')) = c1.concat_tag
		and c1.concat_tag <> c1.sfdc_tag
		and c1.concat_tag <> c1.cgen_tag
	left join mci_enterprise_stage.sa_camp_05 c2
		on v.sfdc_tag = c2.sfdc_tag
		and c2.sfdc_rank = 1
	left join mci_enterprise_stage.sa_camp_05 c3
		on v.cgen_tag = c3.cgen_tag
		and c3.cgen_rank = 1
	where coalesce(c1.campaign_tag,c2.campaign_tag,c3.campaign_tag) is not null
;
--------------------------------------------------------
-- VISITS clean up fields; get product from pagename
--------------------------------------------------------
drop table mci_enterprise_stage.sa_03; --426,787,534
create table mci_enterprise_stage.sa_03
as 
select
 v.click_date 
,v.visid
,v.mcvisid
,v.session_id
,v.qtr 
,v.week
,v.pagename
,v.custom_link_details
,case when v.last_touch_marketing_channel in ('Affiliate','Display','Email','Product') then v.last_touch_marketing_channel
		when v.last_touch_marketing_channel like '%Referring Domains%' then 'Other'
		when v.last_touch_marketing_channel like '%Internal Referrer%' then 'Other'
		when v.last_touch_marketing_channel like '%Product - Acrobat%' then 'Product'
		when v.last_touch_marketing_channel like '%Product - Reader%' then 'Product'
		when v.last_touch_marketing_channel like '%Search Natural%' then 'Search: Natural'
		when v.last_touch_marketing_channel like '%Search Paid%' then 'Search: Paid'
		when v.last_touch_marketing_channel like '%Typed/Bookmarked%' then 'Social: Organic'
		when v.last_touch_marketing_channel like '%Organic Social%' then 'Social: Owned'
		when v.last_touch_marketing_channel like '%Owned Social%' then 'Social: Owned'
		when v.last_touch_marketing_channel like '%Paid Social%' then 'Social: Paid'
		else NULL end as last_touch_marketing_channel
,v.concat_tag
,v.table_tag_type
,v.tag_types
,v.tag
,v.region
,v.program_campaign
,v.group_campaign
,v.campaign_tag
,v.start_month
,v.cgen_business
,v.activity_name
,v.cgen_campaign_status
,v.bu_campaign__c
,v.sfdc_channel
,v.product_promoted	
,v.leadsource
,v.leadsource2
,v.sfdc_campaign_name
,v.sfdc_program
,v.tag_name
,v.cgen_campaign_name
,v.sfdc_tag
,v.cgen_tag
,v.subtype__c
,case when v.mv like '%email%' then 'Email'
    when v.mv like '%affiliate%' then 'Affiliate'
    when v.mv like '%search%' then 'Search: Paid'
    when v.mv like '%display%' then 'Display'
    when v.mv like '%social%' then 'Social: Paid'
    when v.mv like '%in%' then 'Product'
    when v.mv like '%product%' then 'Product'
    when v.mv like '%promoid%' then 'Product'
    when v.mv is not null then 'Other'
	else NULL end as cgen_mv
,case when t.products like 'CC:%' then 'CC' else t.products end as products
,case when v.productname like '%acrobat%' then 'Acrobat'
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
		when productname like '%character%' then 'CC'
		when productname like '%animator%' then 'CC'
		when productname like '%clip%' then 'CC'
		when productname like '%color%' then 'CC'
		when productname like '%comp%' then 'CC'
		when productname like '%creative cloud%' then 'CC'
		when productname like '%dimension%' then 'CC'
		when productname like '%draw%' then 'CC'
		when productname like '%dreamweaver%' then 'CC'
		when productname like '%edge%' then 'CC'
		when productname like '%elements%' then 'CC'
		when productname like '%organizer%' then 'CC'
		when productname like '%encore%' then 'CC'
		when productname like '%express%' then 'CC'
		when productname like '%extendscript%' then 'CC'
		when productname like '%toolkit%' then 'CC'
		when productname like '%extension manager%' then 'CC'
		when productname like '%felix%' then 'CC'
		when productname like '%fireworks%' then 'CC'
		when productname like '%fix%' then 'CC'
		when productname like '%flash%' then 'CC'
		when productname like '%pro%' then 'CC'
		when productname like '%fresco%' then 'CC'
		when productname like '%fuse%' then 'CC'
		when productname like '%gaming sdk%' then 'CC'
		when productname like '%hue%' then 'CC'
		when productname like '%illustrator%' then 'CC'
		when productname like '%incopy%' then 'CC'
		when productname like '%indesign%' then 'CC'
		when productname like '%ink & slide%' then 'CC'
		when productname like '%lightroom%' then 'CC'
		when productname like '%line%' then 'CC'
		when productname like '%media encoder%' then 'CC'
		when productname like '%mix%' then 'CC'
		when productname like '%muse%' then 'CC'
		when productname like '%phonegap%' then 'CC'
		when productname like '%photography%' then 'CC'
		when productname like '%photoshop%' then 'CC'
		when productname like '%portfolio%' then 'CC'
		when productname like '%prelude%' then 'CC'
		when productname like '%premiere pro%' then 'CC'
		when productname like '%preview%' then 'CC'
		when productname like '%revel%' then 'CC'
		when productname like '%rush%' then 'CC'
		when productname like '%scan%' then 'CC'
		when productname like '%scout%' then 'CC'
		when productname like '%sdk%' then 'CC'
		when productname like '%shape%' then 'CC'
		when productname like '%sketch%' then 'CC'
		when productname like '%speedgrade%' then 'CC'
		when productname like '%story%' then 'CC'
		when productname like '%xd%' then 'CC'
		when productname is not null then 'Other' end as productname
from mci_enterprise_stage.sa_02 v
left join mci_enterprise.adobes_finest_taxonomy t 
	on v.pagename=t.pagename
	and t.cloud = 'DME'
;
--------------------------------------------------------
-- VISITS extract data from web_visitor_base_v2
--------------------------------------------------------
drop table mci_enterprise_stage.sa_04; -- 	52,192,233,083
create table mci_enterprise_stage.sa_04 as
select distinct 
            v2.visit_key
            ,v2.click_date
            ,coalesce(v2.pagename,v2.post_pagename) as pagename
            ,v2.custom_link_details 
            ,v2.faas_submission_id
			,upper(substr(v2.faas_submission_id,2,36)) as faas_id
            ,v2.email
			,v2.sfdc_id
            ,case when v2.tap_sub_std_name_key =-1 then null else v2.tap_sub_std_name_key end as tap_sub_std_name_key
			,case when v2.marketing_channel in ('Affiliate','Display','Email','Product') then v2.marketing_channel
				when v2.marketing_channel like '%Referring Domains%' then 'Other'
				when v2.marketing_channel like '%Internal Referrer%' then 'Other'
				when v2.marketing_channel like '%Product - Acrobat%' then 'Product'
				when v2.marketing_channel like '%Product - Reader%' then 'Product'
				when v2.marketing_channel like '%Search Natural%' then 'Search: Natural'
				when v2.marketing_channel like '%Search Paid%' then 'Search: Paid'
				when v2.marketing_channel like '%Typed/Bookmarked%' then 'Social: Organic'
				when v2.marketing_channel like '%Organic Social%' then 'Social: Owned'
				when v2.marketing_channel like '%Owned Social%' then 'Social: Owned'
				when v2.marketing_channel like '%Paid Social%' then 'Social: Paid'
				else NULL end as marketing_channel
            from mcietl.web_visitor_base_v2 v2
where v2.visit_key is not null
and v2.click_date >= cast('2018-03-01' as date)
;
--------------------------------------------------------
-- VISITS merge data
--------------------------------------------------------
drop table mci_enterprise_stage.sa_05;
create table mci_enterprise_stage.sa_05 --	579,629
select
--identifiers
 v.click_date 
,case when coalesce(v.products,v.productname,v.product_promoted) = 'Sign' then v.tag_types else null end as tag_types --to limit attribution to Sign campaigns
,case when coalesce(v.products,v.productname,v.product_promoted) = 'Sign' then v.table_tag_type else null end as table_tag_type --to limit attribution to Sign campaigns
,v.mcvisid
,v2.faas_submission_id
,v2.faas_id
,v.session_id
,v2.email
,v2.tap_sub_std_name_key
,v2.sfdc_id
--filters
,v.qtr
,v.week
,coalesce(v.last_touch_marketing_channel,v.cgen_mv ,v2.marketing_channel,v.sfdc_channel) as channel 
,coalesce(v.products,v.productname,v.product_promoted) as product
,v.region
,v.cgen_business 
--table data
,v.campaign_tag
,v.program_campaign
,v.group_campaign
--other details
,v.tag
,v.start_month
,v.activity_name
,v.cgen_campaign_status
,v.bu_campaign__c
,v.leadsource
,v.leadsource2
,v.sfdc_campaign_name
,v.sfdc_program
,v.tag_name
,v.cgen_campaign_name
,v.sfdc_tag
,v.cgen_tag
,concat(	case when coalesce(v.products,v.productname,v.product_promoted) = 'Sign' then v.tag_types else null end
			,case when coalesce(v.products,v.productname,v.product_promoted) = 'Sign' then v.table_tag_type else null end
			,coalesce(v.last_touch_marketing_channel,v.cgen_mv ,v2.marketing_channel,v.sfdc_channel,0)
			,coalesce(v.products,v.productname,v.product_promoted,0)
			,coalesce(v.region,0)
			,coalesce(v.cgen_business,0)
			,coalesce(v.campaign_tag,0)
			,coalesce(v.program_campaign,0)
			,coalesce(v.group_campaign,0)
			,coalesce(v.activity_name,0)
			) as summary_group
from mci_enterprise_stage.sa_03 v
left join mci_enterprise_stage.sa_04 v2 
        on v.session_id = v2.visit_key
        and v.pagename  = v2.pagename 
        and v.custom_link_details = v2.custom_link_details
        and v2.click_date = v.click_date
where coalesce(v.products,v.productname,v.product_promoted) = 'Sign'
;
--------------------------------------------------------
-- VISITS append missing identifiers
--------------------------------------------------------
select 
count(distinct v.tap_sub_std_name_key) as tap_sub_std_name_key --5,200
,count(v.tap_sub_std_name_key) as all_tap_sub_std_name_key --9,608
,count(distinct v.mcvisid) as mcvisid --	370,665
,count(v.mcvisid) as all_mcvisid --579,629
,count(distinct v.faas_submission_id) as faas_submission_id --	312
,count(v.faas_submission_id) as all_faas_submission_id --357
,count(distinct v.email) as email --	2,415
,count(v.email) as all_email --3,024
,count(distinct v.sfdc_id) as sfdc_id --319
,count(v.sfdc_id) as all_sfdc_id --433
,count(*) as cnt --579,629
from mci_enterprise_stage.sa_05 v

drop table mci_enterprise_stage.sa_t;
create table mci_enterprise_stage.sa_t --31,968,337
as select *, row_number() over (partition by mcvisid order by cnt desc) as rnk from (
select 
v.tap_sub_std_name_key
,v.mcvisid
,count(*) as cnt
from mci_enterprise_stage.sa_05 v
where v.tap_sub_std_name_key is not null
group by
v.tap_sub_std_name_key
,v.mcvisid )z
;

drop table mci_enterprise_stage.sa_f;
create table mci_enterprise_stage.sa_f --212,321
as select *, row_number() over (partition by mcvisid order by cnt desc) as rnk from (
select 
v.faas_submission_id
,v.mcvisid
,count(*) as cnt
from mci_enterprise_stage.sa_05 v
where v.faas_submission_id is not null
group by
v.faas_submission_id
,v.mcvisid
) z;

drop table mci_enterprise_stage.sa_e;
create table mci_enterprise_stage.sa_e --472,6098
as select *, row_number() over (partition by mcvisid order by cnt desc) as rnk from (
select 
v.email
,v.mcvisid
,count(*) as cnt
from mci_enterprise_stage.sa_05 v
where v.email is not null
group by
v.email
,v.mcvisid
) z;

drop table mci_enterprise_stage.sa_s;
create table mci_enterprise_stage.sa_s --81,916
as select *, row_number() over (partition by mcvisid order by cnt desc) as rnk from (
select 
v.sfdc_id 
,v.mcvisid
,count(*) as cnt
from mci_enterprise_stage.sa_05 v
where v.sfdc_id is not null
group by
v.sfdc_id 
,v.mcvisid
) z;

--append identifiers and account data
drop table mci_enterprise_stage.sa_06;
create table mci_enterprise_stage.sa_06 --579,629
as select 
        v.session_id
        ,v.click_date 
        ,v.tag_types
        --contact
        ,v.mcvisid
        ,coalesce(v.tap_sub_std_name_key,t.tap_sub_std_name_key) as tap_sub_std_name_key
        ,coalesce(v.faas_submission_id,f.faas_submission_id) as faas_submission_id
        ,coalesce(v.email,em.email) as email
        ,coalesce(v.sfdc_id,s.sfdc_id) as sfdc_id
        --filters
        ,v.qtr
        ,v.week
        ,v.channel 
        ,v.product
        ,v.region
        ,v.cgen_business 
        --table data
        ,v.campaign_tag
        ,v.table_tag_type
        ,v.program_campaign
        ,v.group_campaign
        --other details
        ,v.tag
        ,v.start_month
        ,v.activity_name
        ,v.cgen_campaign_status
        ,v.bu_campaign__c
        ,v.summary_group
		,v.leadsource
		,v.leadsource2
		,v.sfdc_campaign_name
		,v.sfdc_program
		,v.tag_name
		,v.cgen_campaign_name
		,v.sfdc_tag
		,v.cgen_tag
		,case when  v.table_tag_type = 'SFDC' and product = 'Sign' and group_campaign <> 'CC Opt Meacham 2016' then 'SFDC Sign'
			when v.table_tag_type is not null and product = 'Sign' and group_campaign <> 'CC Opt Meacham 2016' then 'SFDC and CGEN Sign'
			when group_campaign <> 'CC Opt Meacham 2016' then 'No CC Opt Meacham'
			else 'All' end as attribution_group
      from mci_enterprise_stage.sa_05 v
      left join mci_enterprise_stage.sa_t t
        on t.mcvisid = v.mcvisid
        and t.rnk = 1
      left join mci_enterprise_stage.sa_f f
        on f.mcvisid = v.mcvisid
        and f.rnk = 1
      left join mci_enterprise_stage.sa_e em
        on em.mcvisid = v.mcvisid
        and em.rnk = 1
      left join mci_enterprise_stage.sa_s s
        on s.mcvisid = v.mcvisid
        and s.rnk = 1

select 
count(distinct v.tap_sub_std_name_key) as tap_sub_std_name_key --5,200
,count(v.tap_sub_std_name_key) as all_tap_sub_std_name_key --17,073
,count(distinct v.mcvisid) as mcvisid --370,665
,count(v.mcvisid) as all_mcvisid --579,629
,count(distinct v.faas_submission_id) as faas_submission_id --	312
,count(v.faas_submission_id) as all_faas_submission_id --		607
,count(distinct v.email) as email --2,415
,count(v.email) as all_email --4,909
,count(distinct v.sfdc_id) as sfdc_id --319
,count(v.sfdc_id) as all_sfdc_id --576
,count(*) as cnt --579,629
from mci_enterprise_stage.sa_06 v

--add row numbers
drop table mci_enterprise_stage.sa_07;
create table mci_enterprise_stage.sa_07 as --579,629
select *
,row_number() over (order by v.click_date, v.session_id) as row_num
from mci_enterprise_stage.sa_06 v
;

/*
--add row numbers for larger sets
drop table mci_enterprise_stage.sa_07_0;
create table mci_enterprise_stage.sa_07_0 as --205,267,404
select *, concat(qtr,lpad(row_num0,10,'0')) as row_num
from (select *
,row_number() over (order by v.click_date, v.session_id) as row_num0
from mci_enterprise_stage.sa_06 v
where qtr = '2020-01' )z
;

drop table mci_enterprise_stage.sa_07_1;
create table mci_enterprise_stage.sa_07_1 as -- 186,608,838
select *, concat(qtr,lpad(row_num0,10,'0')) as row_num
from (select *
,row_number() over (order by v.click_date, v.session_id) as row_num0
from mci_enterprise_stage.sa_06 v
where qtr = '2020-02' )z
;
drop table mci_enterprise_stage.sa_07_2;
create table mci_enterprise_stage.sa_07_2 as --143,038,465
select *, concat(qtr,lpad(row_num0,10,'0')) as row_num
from (select *
,row_number() over (order by v.click_date, v.session_id) as row_num0
from mci_enterprise_stage.sa_06 v
where qtr = '2019-01' )z
;
drop table mci_enterprise_stage.sa_07_3;
create table mci_enterprise_stage.sa_07_3 as --163,577,414
select *, concat(qtr,lpad(row_num0,10,'0')) as row_num
from (select *
,row_number() over (order by v.click_date, v.session_id) as row_num0
from mci_enterprise_stage.sa_06 v
where qtr = '2019-02' )z
;
drop table mci_enterprise_stage.sa_07_4;
create table mci_enterprise_stage.sa_07_4 as --145,235,019
select *, concat(qtr,lpad(row_num0,10,'0')) as row_num
from (select *
,row_number() over (order by v.click_date, v.session_id) as row_num0
from mci_enterprise_stage.sa_06 v
where qtr = '2019-03' )z
;
drop table mci_enterprise_stage.sa_07_5;
create table mci_enterprise_stage.sa_07_5 as --192,585,609
select *, concat(qtr,lpad(row_num0,10,'0')) as row_num
from (select *
,row_number() over (order by v.click_date, v.session_id) as row_num0
from mci_enterprise_stage.sa_06 v
where qtr = '2019-04' )z
;
drop table mci_enterprise_stage.sa_07_6;
create table mci_enterprise_stage.sa_07_6 as --40,716,242
select *, concat(qtr,lpad(row_num0,10,'0')) as row_num
from (select *
,row_number() over (order by v.click_date, v.session_id) as row_num0
from mci_enterprise_stage.sa_06 v
where qtr = '2018-02' )z
;
drop table mci_enterprise_stage.sa_07_7;
create table mci_enterprise_stage.sa_07_7 as --111,420,623
select *, concat(qtr,lpad(row_num0,10,'0')) as row_num
from (select *
,row_number() over (order by v.click_date, v.session_id) as row_num0
from mci_enterprise_stage.sa_06 v
where qtr = '2018-03' )z
;
drop table mci_enterprise_stage.sa_07_8;
create table mci_enterprise_stage.sa_07_8 as --148,716,847
select *, concat(qtr,lpad(row_num0,10,'0')) as row_num
from (select *
,row_number() over (order by v.click_date, v.session_id) as row_num0
from mci_enterprise_stage.sa_06 v
where qtr = '2018-04' )z
;

drop table mci_enterprise_stage.sa_07;
create table mci_enterprise_stage.sa_07 as --1,337,166,461
select *
 from (
	select * from mci_enterprise_stage.sa_07_0
	union all select * from mci_enterprise_stage.sa_07_1
	union all select * from mci_enterprise_stage.sa_07_2
	union all select * from mci_enterprise_stage.sa_07_3
	union all select * from mci_enterprise_stage.sa_07_4
	union all select * from mci_enterprise_stage.sa_07_5
	union all select * from mci_enterprise_stage.sa_07_6
	union all select * from mci_enterprise_stage.sa_07_7
	union all select * from mci_enterprise_stage.sa_07_8
)z 

/*
 	attribution_group	_c1
1	SFDC Sign			         52
2	All					948,524,944
3	SFDC and CGEN Sign	    432,268
4	No CC Opt Meacham	388,209,197
*/
--********************************************************************************************************************************	
----------------------------------------------------------------------------------------------------------------------------------
--RESULTS - Responses
----------------------------------------------------------------------------------------------------------------------------------	
--********************************************************************************************************************************	
drop table mci_enterprise_stage.sa_resp_00; --47,993
create table mci_enterprise_stage.sa_resp_00
as select distinct
case when month(coalesce(r.latest_inq_date,r.createddate))  =12 then concat(year(coalesce(r.latest_inq_date,r.createddate))+1,'-Q1') 
		when month(coalesce(r.latest_inq_date,r.createddate))<3 then concat(year(coalesce(r.latest_inq_date,r.createddate)),'-Q1') 
		when month(coalesce(r.latest_inq_date,r.createddate)) <6 then concat(year(coalesce(r.latest_inq_date,r.createddate) ),'-Q2') 
		when month(coalesce(r.latest_inq_date,r.createddate))<9 then concat(year(coalesce(r.latest_inq_date,r.createddate)),'-Q3') 
		else concat(year(coalesce(r.latest_inq_date,r.createddate)),'-Q4')  end as resp_qtr
,case when month(coalesce(r.latest_inq_date,r.createddate)) = 12 then concat(year(coalesce(r.latest_inq_date,r.createddate))+1,'-'
        ,lpad(weekofyear(coalesce(r.latest_inq_date,r.createddate))-weekofyear(cast(concat(year(coalesce(r.latest_inq_date,r.createddate)),'-12-01') as date)) +1,2,'0'))
		else concat(year(coalesce(r.latest_inq_date,r.createddate)),'-',lpad(weekofyear(coalesce(r.latest_inq_date,r.createddate))+52-weekofyear(cast(concat(year(coalesce(r.latest_inq_date,r.createddate))-1,'-12-01') as date)),2,'0'))
		end as resp_wk
,case when month(r.latest_mql_date)  =12 then concat(year(r.latest_mql_date)+1,'-Q1') 
		when month(r.latest_mql_date)<3 then concat(year(r.latest_mql_date),'-Q1') 
		when month(r.latest_mql_date) <6 then concat(year(r.latest_mql_date),'-Q2') 
		when month(r.latest_mql_date)<9 then concat(year(r.latest_mql_date),'-Q3') 
		else concat(year(r.latest_mql_date),'-Q4')  end as mql_qtr 
,case when month(r.latest_mql_date) = 12 then concat(year(r.latest_mql_date)+1,'-',lpad(weekofyear(r.latest_mql_date)-weekofyear(cast(concat(year(r.latest_mql_date),'-12-01') as date)) +1,2,'0'))
		else concat(year(r.latest_mql_date),'-',lpad(weekofyear(r.latest_mql_date)+52-weekofyear(cast(concat(year(r.latest_mql_date)-1,'-12-01') as date)),2,'0')) end as mql_wk
		,c.contactid as contact_id
		,c.email	
		,c.sfdc_accountid	
		,c.sfdc_accountid_18
		,c.tap_sub_std_name_key
		,r.latest_mql_date
		,coalesce(r.product,'Unknown') as result_product
		,'Unknown' as result_region
		,coalesce(r.latest_inq_date,r.createddate) as createddate
		,date_add(r.createddate,-365) as response_lookback
		,date_add(r.latest_mql_date,-365) as mql_lookback
from mci_enterprise_stage.abm_contact_activity_inq_mql_sal_final r
left join mci_enterprise.abm_sfdc_contacts_mapped c
    on r.contact_id = c.contactid
where r.product = 'Sign' and (coalesce(r.latest_inq_date,r.createddate) >= '2019-03-01' or latest_mql_date >= '2019-03-01')
;

drop table mci_enterprise_stage.sa_resp_01;
create table mci_enterprise_stage.sa_resp_01
as select *,row_number() over () as resp_id from (
		select *
		,row_number() over (partition by r.contact_id order by r.latest_mql_date,r.createddate desc) as row_num
		from mci_enterprise_stage.sa_resp_00 r
) z where row_num = 1
;

--calc touches for resp
drop table mci_enterprise_stage.sa_resp_02;
create table mci_enterprise_stage.sa_resp_02 --80,172
as select distinct * from ( select
    r.resp_qtr
	,r.resp_wk
	,r.mql_qtr 
	,r.mql_wk
	,r.contact_id
	,r.email	
	,r.sfdc_accountid	
	,r.sfdc_accountid_18
	,r.tap_sub_std_name_key
	,r.latest_mql_date
	,r.result_product
	,r.result_region
	,r.createddate
	,r.response_lookback
	,r.mql_lookback
	,r.resp_id 
	,v.row_num
	,v.click_date
	,v.attribution_group
	,v.summary_group
    from mci_enterprise_stage.sa_resp_01 r	
    inner join mci_enterprise_stage.sa_07 v	
    	on v.sfdc_id = r.contact_id
    where r.response_lookback <= v.click_date	
	    and r.createddate >= v.click_date
		and r.createddate >= '2019-03-01'
union all 
    select     r.resp_qtr
	,r.resp_wk
	,r.mql_qtr 
	,r.mql_wk
	,r.contact_id
	,r.email	
	,r.sfdc_accountid	
	,r.sfdc_accountid_18
	,r.tap_sub_std_name_key
	,r.latest_mql_date
	,r.result_product
	,r.result_region
	,r.createddate
	,r.response_lookback
	,r.mql_lookback
	,r.resp_id 
	,v.row_num
	,v.click_date
	,v.attribution_group
	,v.summary_group
    from mci_enterprise_stage.sa_resp_01 r	
    inner join mci_enterprise_stage.sa_07 v	
    	on v.email	= r.email
    where r.response_lookback <= v.click_date	
	    and r.createddate >= v.click_date
		and r.createddate >= '2019-03-01'
union all 
    select     r.resp_qtr
	,r.resp_wk
	,r.mql_qtr 
	,r.mql_wk
	,r.contact_id
	,r.email	
	,r.sfdc_accountid	
	,r.sfdc_accountid_18
	,r.tap_sub_std_name_key
	,r.latest_mql_date
	,r.result_product
	,r.result_region
	,r.createddate
	,r.response_lookback
	,r.mql_lookback
	,r.resp_id 
	,v.row_num
	,v.click_date
	,v.attribution_group
	,v.summary_group
    from mci_enterprise_stage.sa_resp_01 r	
    inner join mci_enterprise_stage.sa_07 v	
    	on v.tap_sub_std_name_key = r.tap_sub_std_name_key
    where r.response_lookback <= v.click_date	
	    and r.createddate >= v.click_date
		and r.createddate >= '2019-03-01'
)z;

--one row per response
drop table mci_enterprise_stage.sa_resp_03;
create table mci_enterprise_stage.sa_resp_03 --13,0962
as select 
		r.resp_id
		,r.resp_qtr
		,r.resp_wk
		,r.contact_id
		,r.createddate
		,r.response_lookback
		,r.result_product
		,r.result_region
		,min(case when r.attribution_group = 'SFDC Sign' then r.row_num else null end) as resp_ft_row_num	
		,max(case when r.attribution_group = 'SFDC Sign' then r.row_num else null end) as resp_lt_row_num	
		,1/sum(case when r.attribution_group = 'SFDC Sign' then 1 else 0 end) as resp_rows
		
		,min(case when r.attribution_group in ('SFDC Sign','SFDC and CGEN Sign')  then r.row_num else null end) as both_resp_ft_row_num	
		,max(case when r.attribution_group in ('SFDC Sign','SFDC and CGEN Sign')  then r.row_num else null end) as both_resp_lt_row_num	
		,1/sum(case when r.attribution_group in ('SFDC Sign','SFDC and CGEN Sign')  then 1 else 0 end) as both_resp_rows
		
		/*,min(case when v.attribution_group in ('SFDC Sign','SFDC and CGEN Sign','No CC Opt Meacham')  then v.row_num else null end) as excc_resp_ft_row_num	
		,max(case when v.attribution_group in ('SFDC Sign','SFDC and CGEN Sign','No CC Opt Meacham')  then v.row_num else null end) as excc_resp_lt_row_num	
		,1/count(distinct case when v.attribution_group in ('SFDC Sign','SFDC and CGEN Sign','No CC Opt Meacham')  then v.row_num else null end) as excc_resp_rows
		
		,min(v.row_num) as all_resp_ft_row_num	
		,max(v.row_num) as all_resp_lt_row_num
		,1/count(distinct v.row_num) as all_resp_rows*/	
from mci_enterprise_stage.sa_resp_02 r
group by r.resp_id
		,r.resp_qtr
		,r.resp_wk
		,r.contact_id
		,r.createddate
		,r.response_lookback
		,r.result_product
		,r.result_region
;
--------------------------------------------------------
--RESULTS - Summarize RESP influenced
--------------------------------------------------------
drop table mci_enterprise_stage.sa_sum_resp_infl;
create table mci_enterprise_stage.sa_sum_resp_infl --774,853
as select
	 v.summary_group
	,r.resp_qtr as results_qtr
	,r.resp_wk as results_wk
	,r.result_product
	,r.result_region
	
	/*,coont(distinct v.resp_id ) as resp_infl_all
	,sum(r.all_resp_rows) as resp_at_all */
	
	,count(distinct case when r1.attribution_group = 'SFDC Sign' then r1.resp_id else 0 end) as resp_infl
	,sum(r.resp_rows) as resp_at
	
	,count(distinct case when r1.attribution_group in ('SFDC Sign','SFDC and CGEN Sign')  then r1.resp_id else 0 end) as resp_infl_both
	,sum(r.both_resp_rows) as resp_at_both
	
	/*,count(distinct case when v.attribution_group in ('SFDC Sign','SFDC and CGEN Sign','No CC Opt Meacham')  then v.resp_id  else null end) as resp_infl_excc
	,sum(case when v.attribution_group in ('SFDC Sign','SFDC and CGEN Sign','No CC Opt Meacham')  then r.excc_resp_rows else 0 end) as resp_at_excc*/
	
from mci_enterprise_stage.sa_resp_02 r1
inner join mci_enterprise_stage.sa_resp_03 r
	on r1.resp_id = r.resp_id
inner join mci_enterprise_stage.sa_07 v
	on v.row_num = r1.row_num
group by	
	v.summary_group
	,r.resp_qtr
	,r.resp_wk
	,r.result_product
	,r.result_region
;
--------------------------------------------------------
--RESULTS - Summarize RESP sfdc ft
--------------------------------------------------------	
drop table mci_enterprise_stage.sa_sum_resp_ft; --1,423
create table mci_enterprise_stage.sa_sum_resp_ft
as select	
	v.summary_group
	,rf.resp_qtr as results_qtr
	,rf.resp_wk as results_wk
	,rf.result_product
	,rf.result_region
	,count(distinct rf.resp_id) as resp_ft
from mci_enterprise_stage.sa_07 v
inner join mci_enterprise_stage.sa_resp_03 rf
	on v.row_num = rf.resp_ft_row_num
group by	
	v.summary_group
	,rf.resp_qtr
	,rf.resp_wk
	,rf.result_product
	,rf.result_region
;

--------------------------------------------------------
--RESULTS - Summarize RESP sfdc lt
--------------------------------------------------------	
drop table mci_enterprise_stage.sa_sum_resp_lt;
create table mci_enterprise_stage.sa_sum_resp_lt --1,281
as select	
	v.summary_group
	,rl.resp_qtr as results_qtr
	,rl.resp_wk as results_wk
	,rl.result_product
	,rl.result_region
	,count(distinct rl.resp_id) as resp_lt
from mci_enterprise_stage.sa_07 v
inner join mci_enterprise_stage.sa_resp_03 rl
	on v.row_num = rl.resp_lt_row_num
group by	
	v.summary_group
	,rl.resp_qtr
	,rl.resp_wk
	,rl.result_product
	,rl.result_region
;

select * from (
select sum(resp_infl) from  mci_enterprise_stage.sa_sum_resp_infl
union all 
select sum(resp_ft) from  mci_enterprise_stage.sa_sum_resp_ft
union all 
select sum(resp_lt) from  mci_enterprise_stage.sa_sum_resp_lt
union all
select sum(resp_at) from  mci_enterprise_stage.sa_sum_resp_infl) z
--------------------------------------------------------
--RESULTS - Summarize RESP both ft
--------------------------------------------------------	
drop table mci_enterprise_stage.sa_sum_resp_ft_both;
create table mci_enterprise_stage.sa_sum_resp_ft_both --12,675
as select	
	v.summary_group
	,rfb.resp_qtr as results_qtr
	,rfb.resp_wk as results_wk
	,rfb.result_product
	,rfb.result_region
	,count(distinct rfb.resp_id) as resp_ft_both
from mci_enterprise_stage.sa_07 v
inner join mci_enterprise_stage.sa_resp_03 rfb
	on v.row_num = rfb.both_resp_ft_row_num
group by	
	v.summary_group
	,rfb.resp_qtr
	,rfb.resp_wk
	,rfb.result_product
	,rfb.result_region
;
--------------------------------------------------------
--RESULTS - Summarize RESP both lt
--------------------------------------------------------	
drop table mci_enterprise_stage.sa_sum_resp_lt_both;
create table mci_enterprise_stage.sa_sum_resp_lt_both --12,278
as select	
	v.summary_group
	,rlb.resp_qtr as results_qtr
	,rlb.resp_wk as results_wk
	,rlb.result_product
	,rlb.result_region
	,count(distinct rlb.resp_id) as resp_lt_both
from mci_enterprise_stage.sa_07 v
inner join mci_enterprise_stage.sa_resp_03 rlb
	on v.row_num = rlb.both_resp_lt_row_num
group by	
	v.summary_group
	,rlb.resp_qtr
	,rlb.resp_wk
	,rlb.result_product
	,rlb.result_region
;
select * from (
select sum(resp_infl_both) from  mci_enterprise_stage.sa_sum_resp_inf_both
union all 
select sum(resp_ft_both) from  mci_enterprise_stage.sa_sum_resp_ft_both
union all 
select sum(resp_lt_both) from  mci_enterprise_stage.sa_sum_resp_lt_both
union all
select sum(resp_at_both) from  mci_enterprise_stage.sa_sum_resp_infl) z
--------------------------------------------------------
--RESULTS - Summarize RESP excc ft
--------------------------------------------------------	
drop table mci_enterprise_stage.sa_sum_resp_ft_excc;
create table mci_enterprise_stage.sa_sum_resp_ft_excc --12,675
as select	
	v.summary_group
	,rfe.resp_qtr as results_qtr
	,rfe.resp_wk as results_wk
	,rfe.result_product
	,rfe.result_region
	,count(distinct rfe.resp_id) as resp_ft_excc
from mci_enterprise_stage.sa_07 v
inner join mci_enterprise_stage.sa_resp_03 rfe
	on v.row_num = rfe.excc_resp_ft_row_num
group by	
	v.summary_group
	,rfe.resp_qtr
	,rfe.resp_wk
	,rfe.result_product
	,rfe.result_region
;
--------------------------------------------------------
--RESULTS - Summarize RESP excc lt
--------------------------------------------------------	
drop table mci_enterprise_stage.sa_sum_resp_lt_excc;
create table mci_enterprise_stage.sa_sum_resp_lt_excc --12,278
as select	
	v.summary_group
	,rle.resp_qtr as results_qtr
	,rle.resp_wk as results_wk
	,rle.result_product
	,rle.result_region
	,count(distinct rle.resp_id) as resp_lt_excc
from mci_enterprise_stage.sa_07 v
inner join mci_enterprise_stage.sa_resp_03 rle
	on v.row_num = rle.excc_resp_lt_row_num
group by	
	v.summary_group
	,rle.resp_qtr
	,rle.resp_wk
	,rle.result_product
	,rle.result_region
;
select * from (
select sum(resp_ft_excc) from  mci_enterprise_stage.sa_sum_resp_ft_excc
union all 
select sum(resp_lt_excc) from  mci_enterprise_stage.sa_sum_resp_lt_excc
union all
select sum(resp_at_excc) from  mci_enterprise_stage.sa_sum_resp_infl) z
--------------------------------------------------------
--RESULTS - Summarize RESP all ft
--------------------------------------------------------	
drop table mci_enterprise_stage.sa_sum_resp_ft_all;
create table mci_enterprise_stage.sa_sum_resp_ft_all --6,561
as select	
	v.summary_group
	,rfa.resp_qtr as results_qtr
	,rfa.resp_wk as results_wk
	,rfa.result_product
	,rfa.result_region
	,count(distinct rfa.resp_id) as resp_ft_all
from mci_enterprise_stage.sa_07 v
inner join mci_enterprise_stage.sa_resp_03 rfa
	on v.row_num = rfa.all_resp_ft_row_num
group by	
	v.summary_group
	,rfa.resp_qtr
	,rfa.resp_wk
	,rfa.result_product
	,rfa.result_region
;
--------------------------------------------------------
--RESULTS - Summarize RESP all lt
--------------------------------------------------------	
drop table mci_enterprise_stage.sa_sum_resp_lt_all;
create table mci_enterprise_stage.sa_sum_resp_lt_all --7,932
as select	
	v.summary_group
	,rla.resp_qtr as results_qtr
	,rla.resp_wk as results_wk
	,rla.result_product
	,rla.result_region
	,count(distinct rla.resp_id) as resp_lt_all
from mci_enterprise_stage.sa_07 v
inner join mci_enterprise_stage.sa_resp_03 rla
	on v.row_num = rla.all_resp_lt_row_num
group by	
	v.summary_group
	,rla.resp_qtr
	,rla.resp_wk
	,rla.result_product
	,rla.result_region
;
select * from (
select sum(resp_ft_all) from  mci_enterprise_stage.sa_sum_resp_ft_all
union all 
select sum(resp_lt_all) from  mci_enterprise_stage.sa_sum_resp_lt_all
union all
select sum(resp_at_all) from  mci_enterprise_stage.sa_sum_resp_all) z
--********************************************************************************************************************************	
----------------------------------------------------------------------------------------------------------------------------------
--RESULTS - MQLs
----------------------------------------------------------------------------------------------------------------------------------
--********************************************************************************************************************************	
--calc touches for mql
 drop table mci_enterprise_stage.sa_resp_04;
create table mci_enterprise_stage.sa_resp_04 --133,819,252
as select distinct * from (
    select  r.resp_qtr
	,r.resp_wk
	,r.mql_qtr 
	,r.mql_wk
	,r.contact_id
	,r.email	
	,r.sfdc_accountid	
	,r.sfdc_accountid_18
	,r.tap_sub_std_name_key
	,r.latest_mql_date
	,r.result_product
	,r.result_region
	,r.createddate
	,r.response_lookback
	,r.mql_lookback
	,r.resp_id 
	,v.row_num
	,v.click_date
	,v.attribution_group
	,v.summary_group
    from mci_enterprise_stage.sa_resp_01 r	
    inner join mci_enterprise_stage.sa_07 v	
    	on v.sfdc_id = r.contact_id
    where r.mql_lookback <= v.click_date	
	and r.latest_mql_date >= v.click_date
	and latest_mql_date >= '2019-03-01'
union all 
    select  r.resp_qtr
	,r.resp_wk
	,r.mql_qtr 
	,r.mql_wk
	,r.contact_id
	,r.email	
	,r.sfdc_accountid	
	,r.sfdc_accountid_18
	,r.tap_sub_std_name_key
	,r.latest_mql_date
	,r.result_product
	,r.result_region
	,r.createddate
	,r.response_lookback
	,r.mql_lookback
	,r.resp_id 
	,v.row_num
	,v.click_date
	,v.attribution_group
	,v.summary_group
    from mci_enterprise_stage.sa_resp_01 r	
    inner join mci_enterprise_stage.sa_07 v	
    	on v.email	= r.email
    where r.mql_lookback <= v.click_date	
	and r.latest_mql_date >= v.click_date
	and latest_mql_date >= '2019-03-01'
union all 
    select  r.resp_qtr
	,r.resp_wk
	,r.mql_qtr 
	,r.mql_wk
	,r.contact_id
	,r.email	
	,r.sfdc_accountid	
	,r.sfdc_accountid_18
	,r.tap_sub_std_name_key
	,r.latest_mql_date
	,r.result_product
	,r.result_region
	,r.createddate
	,r.response_lookback
	,r.mql_lookback
	,r.resp_id 
	,v.row_num
	,v.click_date
	,v.attribution_group
	,v.summary_group
    from mci_enterprise_stage.sa_resp_01 r	
    inner join mci_enterprise_stage.sa_07 v	
    	on v.tap_sub_std_name_key = r.tap_sub_std_name_key
    where r.mql_lookback <= v.click_date	
	and r.latest_mql_date >= v.click_date
	and latest_mql_date >= '2019-03-01'
)z;

drop table mci_enterprise_stage.sa_resp_05;
create table mci_enterprise_stage.sa_resp_05 --12,503
as select
		r.mql_qtr
		,r.mql_wk
		,r.contact_id
		,r.latest_mql_date
		,r.mql_lookback
		,r.result_product
		,r.result_region
		,r.resp_id
		,min(case when r.attribution_group = 'SFDC Sign' then r.row_num else null end) as mql_ft_row_num	
		,max(case when r.attribution_group = 'SFDC Sign' then r.row_num else null end) as mql_lt_row_num	
		,1/count(distinct case when r.attribution_group = 'SFDC Sign' then r.row_num else null end) as mql_rows

		,min(case when r.attribution_group in ('SFDC Sign','SFDC and CGEN Sign') then r.row_num else null end) as both_mql_ft_row_num	
		,max(case when r.attribution_group in ('SFDC Sign','SFDC and CGEN Sign') then r.row_num else null end) as both_mql_lt_row_num	
		,1/count(distinct case when r.attribution_group in ('SFDC Sign','SFDC and CGEN Sign') then r.row_num else null end) as both_mql_rows
		
		/*,min(case when v.attribution_group in ('SFDC Sign','SFDC and CGEN Sign','No CC Opt Meacham') then v.row_num else null end) as excc_mql_ft_row_num	
		,max(case when v.attribution_group in ('SFDC Sign','SFDC and CGEN Sign','No CC Opt Meacham') then v.row_num else null end) as excc_mql_lt_row_num	
		,1/count(distinct case when v.attribution_group in ('SFDC Sign','SFDC and CGEN Sign','No CC Opt Meacham') then v.row_num else null end) as excc_mql_rows
		
		,min(v.row_num) as all_mql_ft_row_num	
		,max(v.row_num) as all_mql_lt_row_num	
		,1/count(distinct v.row_num) as all_mql_rows */
from mci_enterprise_stage.sa_resp_04 r
group by r.mql_qtr
		,r.mql_wk
		,r.contact_id
		,r.latest_mql_date
		,r.mql_lookback
		,r.result_product
		,r.result_region
		,r.resp_id
;
--------------------------------------------------------
--RESULTS - Summarize MQL influenced
--------------------------------------------------------
drop table mci_enterprise_stage.sa_sum_mql_infl;
create table mci_enterprise_stage.sa_sum_mql_infl --779,071
as select	
	 v.summary_group
	,m.mql_qtr as results_qtr
	,m.mql_wk as results_wk
	,m.result_product
	,m.result_region
	/*,count(distinct case when m.contact_id is not null then v.row_num else null end) as mql_infl_all
	,sum(m.all_mql_rows) as mql_at_all */
	
	,sum(distinct case when m.contact_id is not null and v.attribution_group = 'SFDC Sign' then v.row_num else null end) as mql_infl
	,sum(case when v.attribution_group = 'SFDC Sign' then m.mql_rows else 0 end) as mql_at
	
	,sum(distinct case when m.contact_id is not null and v.attribution_group in ('SFDC Sign','SFDC and CGEN Sign') then v.row_num else null end) as mql_infl_both
	,sum(case when v.attribution_group in ('SFDC Sign','SFDC and CGEN Sign') then m.both_mql_rows else 0 end) as mql_at_both
	
	/*,count(distinct case when m.contact_id is not null and v.attribution_group in ('SFDC Sign','SFDC and CGEN Sign','No CC Opt Meacham') then v.row_num else null end) as mql_infl_excc
	,sum(case when v.attribution_group in ('SFDC Sign','SFDC and CGEN Sign','No CC Opt Meacham') then m.excc_mql_rows else 0 end) as mql_at_excc */
	
from mci_enterprise_stage.sa_resp_04 r1
inner join mci_enterprise_stage.sa_resp_05 r
	on r1.resp_id = r.resp_id
inner join mci_enterprise_stage.sa_07 v
	on v.row_num = r1.row_num
group by	
	v.summary_group
	,m.mql_qtr
	,m.mql_wk
	,m.result_product
	,m.result_region
;
--------------------------------------------------------	
--RESULTS - Summarize MQL  sfdc ft
--------------------------------------------------------	
drop table mci_enterprise_stage.sa_sum_mql_ft;
create table mci_enterprise_stage.sa_sum_mql_ft --645
as select	
	v.summary_group
	,mf.mql_qtr as results_qtr
	,mf.mql_wk as results_wk
	,mf.result_product
	,mf.result_region
	,count(distinct mf.resp_id) as mql_ft
from mci_enterprise_stage.sa_07 v
inner join mci_enterprise_stage.sa_resp_05 mf
	on v.row_num = mf.mql_ft_row_num
group by	
	v.summary_group
	,mf.mql_qtr
	,mf.mql_wk
	,mf.result_product
	,mf.result_region
;
--------------------------------------------------------
--RESULTS - Summarize MQL  sfdc lt
--------------------------------------------------------	
drop table mci_enterprise_stage.sa_sum_mql_lt;
create table mci_enterprise_stage.sa_sum_mql_lt --555
as select	
	v.summary_group
	,ml.mql_qtr as results_qtr
	,ml.mql_wk as results_wk
	,ml.result_product
	,ml.result_region
	,count(distinct ml.resp_id) as mql_lt
from mci_enterprise_stage.sa_07 v
inner join mci_enterprise_stage.sa_resp_05 ml
	on v.row_num = ml.mql_lt_row_num
group by	
	v.summary_group
	,ml.mql_qtr
	,ml.mql_wk
	,ml.result_product
	,ml.result_region
;
select * from (
select sum(mql_infl) from  mci_enterprise_stage.sa_sum_mql_infl
union all
select sum(mql_ft) from  mci_enterprise_stage.sa_sum_mql_ft
union all 
select sum(mql_lt) from  mci_enterprise_stage.sa_sum_mql_lt
union all
select sum(mql_at) from  mci_enterprise_stage.sa_sum_mql_infl) z
--------------------------------------------------------
--RESULTS - Summarize MQL  both ft
--------------------------------------------------------	
drop table mci_enterprise_stage.sa_sum_mql_ft_both;
create table mci_enterprise_stage.sa_sum_mql_ft_both --5,633
as select	
	v.summary_group
	,mfb.mql_qtr as results_qtr
	,mfb.mql_wk as results_wk
	,mfb.result_product
	,mfb.result_region
	,count(distinct mfb.resp_id) as mql_ft_both
from mci_enterprise_stage.sa_07 v
inner join mci_enterprise_stage.sa_resp_05 mfb
	on v.row_num = mfb.both_mql_ft_row_num
group by	
	v.summary_group
	,mfb.mql_qtr
	,mfb.mql_wk
	,mfb.result_product
	,mfb.result_region
;
--------------------------------------------------------
--RESULTS - Summarize MQL  both lt
--------------------------------------------------------	
drop table mci_enterprise_stage.sa_sum_mql_lt_both;
create table mci_enterprise_stage.sa_sum_mql_lt_both --5,755
as select	
	v.summary_group
	,mlb.mql_qtr as results_qtr
	,mlb.mql_wk as results_wk
	,mlb.result_product
	,mlb.result_region
	,count(distinct mlb.resp_id) as mql_lt_both
from mci_enterprise_stage.sa_07 v
inner join mci_enterprise_stage.sa_resp_05 mlb
	on v.row_num = mlb.both_mql_lt_row_num
group by	
	v.summary_group
	,mlb.mql_qtr
	,mlb.mql_wk
	,mlb.result_product
	,mlb.result_region
;
select * from (
select sum(mql_infl_both) from  mci_enterprise_stage.sa_sum_mql_infl_both
union all
select sum(mql_ft_both) from  mci_enterprise_stage.sa_sum_mql_ft_both
union all 
select sum(mql_lt_both) from  mci_enterprise_stage.sa_sum_mql_lt_both
union all
select sum(mql_at_both) from  mci_enterprise_stage.sa_sum_mql_infl) z
--------------------------------------------------------
--RESULTS - Summarize MQL  excc ft
--------------------------------------------------------	
drop table mci_enterprise_stage.sa_sum_mql_ft_excc;
create table mci_enterprise_stage.sa_sum_mql_ft_excc --5,633
as select	
	v.summary_group
	,mfe.mql_qtr as results_qtr
	,mfe.mql_wk as results_wk
	,mfe.result_product
	,mfe.result_region
	,count(distinct mfe.resp_id) as mql_ft_excc
from mci_enterprise_stage.sa_07 v
inner join mci_enterprise_stage.sa_resp_05 mfe
	on v.row_num = mfe.excc_mql_ft_row_num
group by	
	v.summary_group
	,mfe.mql_qtr
	,mfe.mql_wk
	,mfe.result_product
	,mfe.result_region
;
--------------------------------------------------------
--RESULTS - Summarize MQL  excc lt
--------------------------------------------------------	
drop table mci_enterprise_stage.sa_sum_mql_lt_excc;
create table mci_enterprise_stage.sa_sum_mql_lt_excc --5,755
as select	
	v.summary_group
	,mle.mql_qtr as results_qtr
	,mle.mql_wk as results_wk
	,mle.result_product
	,mle.result_region
	,count(distinct mle.resp_id) as mql_lt_excc
from mci_enterprise_stage.sa_07 v
inner join mci_enterprise_stage.sa_resp_05 mle
	on v.row_num = mle.excc_mql_lt_row_num
group by	
	v.summary_group
	,mle.mql_qtr
	,mle.mql_wk
	,mle.result_product
	,mle.result_region
;
select * from (
select sum(mql_ft_excc) from  mci_enterprise_stage.sa_sum_mql_ft_excc
union all 
select sum(mql_lt_excc) from  mci_enterprise_stage.sa_sum_mql_lt_excc
union all
select sum(mql_at_excc) from  mci_enterprise_stage.sa_sum_mql_infl) z
--------------------------------------------------------
--RESULTS - Summarize MQL  all ft
--------------------------------------------------------	
drop table mci_enterprise_stage.sa_sum_mql_ft_all;
create table mci_enterprise_stage.sa_sum_mql_ft_all --2,934
as select	
	v.summary_group
	,mfa.mql_qtr as results_qtr
	,mfa.mql_wk as results_wk
	,mfa.result_product
	,mfa.result_region
	,count(distinct mfa.contact_id) as mql_ft_all
from mci_enterprise_stage.sa_07 v
inner join mci_enterprise_stage.sa_resp_05 mfa
	on v.row_num = mfa.all_mql_ft_row_num
group by	
	v.summary_group
	,mfa.mql_qtr
	,mfa.mql_wk
	,mfa.result_product
	,mfa.result_region
;
--------------------------------------------------------
--RESULTS - Summarize MQL  all lt
--------------------------------------------------------	
drop table mci_enterprise_stage.sa_sum_mql_lt_all;
create table mci_enterprise_stage.sa_sum_mql_lt_all --3,830
as select	
	v.summary_group
	,mla.mql_qtr as results_qtr
	,mla.mql_wk as results_wk
	,mla.result_product
	,mla.result_region
	,count(distinct mla.contact_id) as mql_lt_all
from mci_enterprise_stage.sa_07 v
inner join mci_enterprise_stage.sa_resp_05 mla
	on v.row_num = mla.all_mql_lt_row_num
group by	
	v.summary_group
	,mla.mql_qtr
	,mla.mql_wk
	,mla.result_product
	,mla.result_region
;
select * from (
select sum(mql_ft_all) from  mci_enterprise_stage.sa_sum_mql_ft_all
union all 
select sum(mql_lt_all) from  mci_enterprise_stage.sa_sum_mql_lt_all
union all
select sum(mql_at_all) from  mci_enterprise_stage.sa_sum_mql_infl) z
--********************************************************************************************************************************	
----------------------------------------------------------------------------------------------------------------------------------
--RESULTS- Opptys
----------------------------------------------------------------------------------------------------------------------------------	
--********************************************************************************************************************************	
drop table mci_enterprise_stage.sa_opp_01;
create table mci_enterprise_stage.sa_opp_01 --3,245
as 
select
		o.opp_created_qtr
		,o.opp_created_wk
		,o.opp_id
		,o.sub_std_name_key
		,o.opp_name
		--,o.opp_adjusted_commitment
		,o.opp_created_date
		,initcap(coalesce(o.opp_opg,'Unknown')) as result_product
		,o.opp_gross_asv
		,case when opp_adjusted_commitment ='Won' then 'Won' else o.opp_highest_stage_number end as opp_highest_stage_number
		,CASE 
		--Americas
				when rep_global_region = 'AMERICAS' and sfdc_account_country in ('United States','North America') then 'UNITED STATES'
				when rep_global_region = 'AMERICAS' and sfdc_account_country like '%US-%' then 'UNITED STATES'
				when rep_global_region = 'AMERICAS' and sfdc_account_country like '%CA-%' then 'CANADA'
				when rep_global_region = 'AMERICAS' and sfdc_account_country = 'Canada' then 'CANADA'
				when rep_global_region = 'AMERICAS' and sfdc_account_country = 'Brazil' then 'BRAZIL'
				when rep_global_region = 'AMERICAS' and sfdc_account_country like '%Mexico%' then 'MEXICO'
				when rep_global_region = 'AMERICAS' and sfdc_account_country in ('Chile','LATAM: excl Brazil') then 'STRAT. LATIN AMERICA'
				when rep_global_region = 'AMERICAS' and sfdc_account_country like '%South America%' then 'STRAT. LATIN AMERICA'
		--EMEA
				when rep_global_region = 'EMEA' and sfdc_account_country in ('Belgium','Belux','Netherlands') then 'BENELUX'
				when rep_global_region = 'EMEA' and sfdc_account_country like '%UK%' then 'UNITED KINGDOM'  ----Changed here: UK -> UNITED KINGDOM 
				when rep_global_region = 'EMEA' and sfdc_account_country in ('Ireland','Great Britain') then 'UNITED KINGDOM'  ----Changed here: UK -> UNITED KINGDOM 
				when rep_global_region = 'EMEA' and sfdc_account_country like '%France%' then 'FRANCE'
				when rep_global_region = 'EMEA' and sfdc_account_country like '%Germany%' then 'GERMANY'
				when rep_global_region = 'EMEA' and sfdc_account_country like '%Italy%' then 'ITALY'
				when rep_global_region = 'EMEA' and sfdc_account_country = 'Iberica' then 'IBERICA'
				when rep_global_region = 'EMEA' and sfdc_account_country like '%Sweden%' then 'NORDIC'
				when rep_global_region = 'EMEA' and sfdc_account_country like '%Denmark%' then 'NORDIC'
				when rep_global_region = 'EMEA' and sfdc_account_country like '%Finland%' then 'NORDIC'
				when rep_global_region = 'EMEA' and sfdc_account_country like '%Norway%' then 'NORDIC'
				when rep_global_region = 'EMEA' and sfdc_account_country like '%Nordics%' then 'NORDIC'
				when rep_global_region = 'EMEA' and sfdc_account_country = 'Israel' then 'SSA & ISRAEL'
				when rep_global_region = 'EMEA' and sfdc_account_country like '%Russia%' then 'RUSSIA & CIS'
				when rep_global_region = 'EMEA' and sfdc_account_country like '%RCIS%' then 'RUSSIA & CIS'
				when rep_global_region = 'EMEA' and sfdc_account_country like '%Switzerland%' then 'SWITZERLAND'
				when rep_global_region = 'EMEA' and sfdc_account_country = 'Central Europe' then 'SWITZERLAND'
				when rep_global_region = 'EMEA' and sfdc_account_country = 'Eastern Europe' then 'EASTERN EUROPE'
		--JAPAC   
				when rep_global_region = 'APAC' and sfdc_account_country in ('ANZ','Australia','New South Wales + Northern Territory + Queensland') then 'ANZ'
				when rep_global_region = 'APAC' and sfdc_account_country like '%AU-%' then 'ANZ'
				when rep_global_region = 'APAC' and sfdc_account_country like '%China%' then 'CHINA'
				when rep_global_region = 'APAC' and sfdc_account_country like '%India%' then 'INDIA'
				when rep_global_region = 'APAC' and sfdc_account_country like '%Korea%' then 'KOREA'
				when rep_global_region = 'APAC' and sfdc_account_country like '%Hong Kong%' then 'HONG KONG & TAIWAN'
				when rep_global_region = 'APAC' and sfdc_account_country in ('Pacific','SEA','Singapore') then 'SEA'
				when rep_global_region = 'JAPAN' then 'JAPAN'
			else 'OTHER' end market_area
		,case when rep_global_region = 'AGS AMERICAS' then 'Americas'
				when rep_global_region = 'AMERICAS' then 'Americas'
				when rep_global_region = 'AMERICAS MARKETO' then 'Americas'
				when rep_global_region = 'APAC' then 'APAC'
				when rep_global_region = 'APAC MARKETO' then 'APAC'
				when rep_global_region = 'C&B  LATAM' then 'Americas'
				when rep_global_region = 'C&B AMERICAS' then 'Americas'
				when rep_global_region = 'C&B APAC' then 'APAC'
				when rep_global_region = 'C&B EMEA' then 'EMEA'
				when rep_global_region = 'CHANNEL EMEA' then 'EMEA'
				when rep_global_region = 'CHANNEL JAPAN' then 'Japan'
				when rep_global_region = 'EMEA' then 'EMEA'
				when rep_global_region = 'JAPAN' then 'Japan'
				when rep_global_region = 'JAPAN MARKETO' then 'Japan'
				when rep_global_region = 'WORLDWIDE' then 'Worldwide'
				when rep_global_region = 'WW' then 'Worldwide'
				when rep_global_region = 'WW SALES OPS TA PAT' then 'Worldwide' else 'Unknown' end as result_region
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
where opp_opg = 'SIGN'
	and opp_stage_3_reached = 'Y'
	and opp_adjusted_commitment in ('Forecast','Upside','Won')
	and o.opp_created_date >= '2019-03-01'
;


select count(distinct sub_std_name_key) from mci_enterprise.abm_account_oppty_all_p2s 
where opp_created_qtr = '2020-Q1'

--calc touches for oppty
drop table mci_enterprise_stage.sa_opp_02; 
create table mci_enterprise_stage.sa_opp_02 --2,616
as select
	o.opp_created_qtr
	,o.opp_created_wk
	,o.opp_id
	,o.sub_std_name_key
	,o.oppty_lookback
	,o.sub_name
	,o.industry
	,o.employee_count
	,o.opp_created_date 
	,o.result_region
	,o.result_product
	,max(case when v.table_tag_type = 'SFDC' then 1 else null end) as SFDC
	,max(case when v.table_tag_type is not null  then 1 else null end) as has_both
	
	,max(o.opp_gross_asv) as opp_gross_asv -- check into why these differ	
	,min(case when v.attribution_group = 'SFDC Sign' then v.row_num else null end) as oppty_ft_row_num
	,max(case when v.attribution_group = 'SFDC Sign' then v.row_num else null end) as oppty_lt_row_num
	,1/count(distinct case when v.attribution_group = 'SFDC Sign' then v.row_num else null end) as oppty_rows
	
	,min(case when v.attribution_group in ('SFDC Sign','SFDC and CGEN Sign') then v.row_num else null end) as both_oppty_ft_row_num
	,max(case when v.attribution_group in ('SFDC Sign','SFDC and CGEN Sign') then v.row_num else null end) as both_oppty_lt_row_num
	,1/count(distinct case when v.attribution_group in ('SFDC Sign','SFDC and CGEN Sign') then v.row_num else null end) as both_oppty_rows
	
	/*,min(case when v.attribution_group in ('SFDC Sign','SFDC and CGEN Sign','No CC Opt Meacham')  then v.row_num else null end) as excc_oppty_ft_row_num
	,max(case when v.attribution_group in ('SFDC Sign','SFDC and CGEN Sign','No CC Opt Meacham')  then v.row_num else null end) as excc_oppty_lt_row_num
	,1/count(distinct case when v.attribution_group in ('SFDC Sign','SFDC and CGEN Sign','No CC Opt Meacham')  then v.row_num else null end) as excc_oppty_rows
	
	,min(v.row_num) as all_oppty_ft_row_num
	,max(v.row_num) as all_oppty_lt_row_num
	,1/count(distinct v.row_num) as all_oppty_rows*/
	
from mci_enterprise_stage.sa_opp_01 o
inner join mci_enterprise_stage.sa_07 v
	on v.tap_sub_std_name_key = o.sub_std_name_key
where o.oppty_lookback <= v.click_date
	and o.opp_created_date >= v.click_date
	and o.row_num = 1
group by 
	o.opp_created_qtr
	,o.opp_created_wk
	,o.opp_id
	,o.sub_std_name_key
	,o.oppty_lookback
	,o.sub_name
	,o.industry
	,o.employee_count
	,o.opp_created_date 
	,o.result_region
	,o.result_product
;
-- for the other view (touches by channel)
drop  table mci_enterprise_stage.sa_opp_03_0;
create table mci_enterprise_stage.sa_opp_03_0 --3,566,757
as select distinct
	o.opp_id
	,o.sub_std_name_key
	,o.opp_gross_asv
	,o.opp_name
	,o.opp_created_date
	,o.opp_highest_stage_number
	,o.opp_concat_name
	,o.sub_name
	,o.industry
	,o.employee_count
	,o.market_area
	,o.result_region
	,o.opp_pipeline_creator_group
	,o.account_segmentation
	,o.result_product
	,v.channel
	,v.campaign_tag
	,v.program_campaign
	,v.group_campaign
	,v.table_tag_type
	,v.tag
	,v.click_date
	,v.row_num
	,r.latest_mql_date
	,r.createddate
	,r.resp_id 
	,g.account_gtm_segment
from mci_enterprise_stage.sa_opp_01 o
inner join mci_enterprise_stage.sa_07 v
	on v.tap_sub_std_name_key = o.sub_std_name_key
left join (select distinct r.tap_sub_std_name_key, r.latest_mql_date,r.createddate,r.resp_id, sfdc_accountid
		from mci_enterprise_stage.sa_resp_02 r) r
	on r.tap_sub_std_name_key = o.sub_std_name_key
left join select distinct(  sfdc_account_id, account_gtm_segment from mci_enterprise.abm_enterprise_account_profile_aec_sfdc) g
	on r.sfdc_accountid	= g. sfdc_account_id	
where o.oppty_lookback <= v.click_date
	and o.opp_created_date >= v.click_date
;
drop table mci_enterprise_stage.sa_opp_03;
create table mci_enterprise_stage.sa_opp_03 --3,566,757
as select * 
		,sum(case when seq_num_opp = 1 and channel = 'Affiliate' then 1 else 0 end) over (partition by opp_id) Affiliate
		,sum(case when seq_num_opp = 1 and channel = 'Display' then 1 else 0 end) over (partition by opp_id)Display
		,sum(case when seq_num_opp = 1 and channel = 'Email' then 1 else 0 end) over (partition by opp_id) Email
		,sum(case when seq_num_opp = 1 and channel = 'Other' then 1 else 0 end) over (partition by opp_id) Other
		,sum(case when seq_num_opp = 1 and channel = 'Product' then 1 else 0 end) over (partition by opp_id) Product
		,sum(case when seq_num_opp = 1 and channel = 'Search: Natural' then 1 else 0 end) over (partition by opp_id) Search_Natural
		,sum(case when seq_num_opp = 1 and channel = 'Search: Paid' then 1 else 0 end) over (partition by opp_id) Search_Paid
		,sum(case when seq_num_opp = 1 and channel = 'Social: Organic' then 1 else 0 end) over (partition by opp_id) Social_Organic
		,sum(case when seq_num_opp = 1 and channel = 'Social: Owned' then 1 else 0 end) over (partition by opp_id) Social_Owned
		,sum(case when seq_num_opp = 1 and channel = 'Social: Paid' then 1 else 0 end) over (partition by opp_id) Social_Paid
		,row_number() over (partition by opp_id, channel, seq_num_opp order by click_date) as channel_touches
from (
    select *
		,row_number() over (partition by row_num, opp_id) as seq_num_opp
		,row_number() over (partition by row_num, sub_name) as seq_num_acct
		from mci_enterprise_stage.sa_opp_03_0
		)z 
;
--------------------------------------------------------
--RESULTS - Summarize OPPTY influenced
--------------------------------------------------------
drop table mci_enterprise_stage.sa_sum_opp_infl;
create table mci_enterprise_stage.sa_sum_opp_infl -- 385,288
as select	
	v.summary_group
	,o.opp_created_qtr as results_qtr
	,o.opp_created_wk as results_wk
	,o.result_product
	,o.result_region
	/*,count(distinct case when o.opp_id is not null then row_num else null end) as oppty_infl_all
	,sum(o.opp_gross_asv) as asv_infl_all
	,sum(o.all_oppty_rows) as oppty_at_all*/
	
	,count(distinct case when v.attribution_group in ('SFDC Sign','SFDC and CGEN Sign')  then row_num else null end) as oppty_infl_both
	,sum(case when v.attribution_group in ('SFDC Sign','SFDC and CGEN Sign')  then o.opp_gross_asv else null end) as asv_infl_both
	,sum(case when v.attribution_group in ('SFDC Sign','SFDC and CGEN Sign')   then o.both_oppty_rows else 0 end) as oppty_at_both
	
	/*,count(distinct case when v.attribution_group in ('SFDC Sign','SFDC and CGEN Sign','No CC Opt Meacham')  then row_num else null end) as oppty_infl_excc
	,sum(case when v.attribution_group in ('SFDC Sign','SFDC and CGEN Sign','No CC Opt Meacham')  then o.opp_gross_asv else null end) as asv_infl_excc
	,sum(case when v.attribution_group in ('SFDC Sign','SFDC and CGEN Sign','No CC Opt Meacham')   then o.excc_oppty_rows else 0 end) as oppty_at_excc*/
	
	,count(distinct case when o.opp_id is not null and v.attribution_group = 'SFDC Sign' then row_num else null end) as oppty_infl
	,sum(case when v.attribution_group = 'SFDC Sign'  then o.opp_gross_asv else null end) as asv_infl
	,sum(case when v.attribution_group = 'SFDC Sign'  then o.oppty_rows else 0 end) as oppty_at

from mci_enterprise_stage.sa_07 v
inner join mci_enterprise_stage.sa_opp_02 o
	on v.tap_sub_std_name_key = o.sub_std_name_key
where o.oppty_lookback <= v.click_date
	and o.opp_created_date >= v.click_date
group by v.summary_group
	,o.opp_created_qtr
	,o.opp_created_wk
	,o.result_product
	,o.result_region
;
--------------------------------------------------------
--RESULTS - Summarize OPPTY sfdc ft
--qtr and week comes from the result table so i broke these into separate queries
--maybe you could use a master date table and append these on which is sort of 
--what i do later but with the results from these aggregations
--distinct count is important because of many to many so a larger build with different results might take longer
--------------------------------------------------------	
drop table mci_enterprise_stage.sa_sum_opp_ft;
create table mci_enterprise_stage.sa_sum_opp_ft --300
as select	
	v.summary_group
	,opf.opp_created_qtr as results_qtr
	,opf.opp_created_wk as results_wk
	,opf.result_product
	,opf.result_region
	,count(distinct opf.opp_id) as oppty_ft
	,sum(opf.opp_gross_asv) as asv_ft
from mci_enterprise_stage.sa_07 v
inner join mci_enterprise_stage.sa_opp_02 opf
	on v.row_num = opf.oppty_ft_row_num
group by	
	v.summary_group
	,opf.opp_created_qtr
	,opf.opp_created_wk
	,opf.result_product
	,opf.result_region
;
--------------------------------------------------------
--RESULTS - Summarize OPPTY sfdc lt
--------------------------------------------------------	
drop table mci_enterprise_stage.sa_sum_opp_lt;
create table mci_enterprise_stage.sa_sum_opp_lt --263
as select	
	v.summary_group
	,ol.opp_created_qtr as results_qtr
	,ol.opp_created_wk as results_wk
	,ol.result_product
	,ol.result_region
	,count(distinct ol.opp_id) as oppty_lt
	,sum(ol.opp_gross_asv) as asv_lt
from mci_enterprise_stage.sa_07 v
inner join  mci_enterprise_stage.sa_opp_02 ol
	on v.row_num = ol.oppty_lt_row_num
group by	
	v.summary_group
	,ol.opp_created_qtr
	,ol.opp_created_wk
	,ol.result_product
	,ol.result_region
;

select * from (
select sum(oppty_infl) from  mci_enterprise_stage.sa_sum_opp_infl
union all 
select sum(oppty_ft) from  mci_enterprise_stage.sa_sum_opp_ft
union all 
select sum(oppty_lt) from  mci_enterprise_stage.sa_sum_opp_lt
union all
select sum(oppty_at) from  mci_enterprise_stage.sa_sum_opp_infl) z

--------------------------------------------------------
--RESULTS - Summarize OPPTY both ft
--------------------------------------------------------	
drop table mci_enterprise_stage.sa_sum_opp_ft_both;
create table mci_enterprise_stage.sa_sum_opp_ft_both --2,062
as select	
	v.summary_group
	,opfb.opp_created_qtr as results_qtr
	,opfb.opp_created_wk as results_wk
	,opfb.result_product
	,opfb.result_region
	,count(distinct opfb.opp_id) as oppty_ft_both
	,sum(opfb.opp_gross_asv) as asv_ft_both
from mci_enterprise_stage.sa_07 v
inner join mci_enterprise_stage.sa_opp_02 opfb
	on v.row_num = opfb.both_oppty_ft_row_num
group by	
	v.summary_group
	,opfb.opp_created_qtr
	,opfb.opp_created_wk
	,opfb.result_product
	,opfb.result_region
;
--------------------------------------------------------
--RESULTS - Summarize OPPTY both lt
--------------------------------------------------------	
drop table mci_enterprise_stage.sa_sum_opp_lt_both;
create table mci_enterprise_stage.sa_sum_opp_lt_both --2,098
as select	
	v.summary_group
	,olb.opp_created_qtr as results_qtr
	,olb.opp_created_wk as results_wk
	,olb.result_product
	,olb.result_region
	,count(distinct olb.opp_id) as oppty_lt_both
	,sum(olb.opp_gross_asv) as asv_lt_both
from mci_enterprise_stage.sa_07 v
inner join mci_enterprise_stage.sa_opp_02 olb
	on v.row_num = olb.both_oppty_lt_row_num
group by	
	v.summary_group
	,olb.opp_created_qtr
	,olb.opp_created_wk
	,olb.result_product
	,olb.result_region
;

select * from (
select sum(oppty_infl_both) from  mci_enterprise_stage.sa_sum_opp_infl_both
union all 
select sum(oppty_ft_both) from  mci_enterprise_stage.sa_sum_opp_ft_both
union all 
select sum(oppty_lt_both) from  mci_enterprise_stage.sa_sum_opp_lt_both
union all
select sum(oppty_at_both) from  mci_enterprise_stage.sa_sum_opp_infl) z
--------------------------------------------------------
--RESULTS - Summarize OPPTY excc ft
--------------------------------------------------------	
drop table mci_enterprise_stage.sa_sum_opp_ft_excc;
create table mci_enterprise_stage.sa_sum_opp_ft_excc --2,062
as select	
	v.summary_group
	,opfe.opp_created_qtr as results_qtr
	,opfe.opp_created_wk as results_wk
	,opfe.result_product
	,opfe.result_region
	,count(distinct opfe.opp_id) as oppty_ft_excc
	,sum(opfe.opp_gross_asv) as asv_ft_excc
from mci_enterprise_stage.sa_07 v
inner join mci_enterprise_stage.sa_opp_02 opfe
	on v.row_num = opfe.excc_oppty_ft_row_num
group by	
	v.summary_group
	,opfe.opp_created_qtr
	,opfe.opp_created_wk
	,opfe.result_product
	,opfe.result_region
;
--------------------------------------------------------
--RESULTS - Summarize OPPTY excc lt
--------------------------------------------------------	
drop table mci_enterprise_stage.sa_sum_opp_lt_excc;
create table mci_enterprise_stage.sa_sum_opp_lt_excc --2,098
as select	
	v.summary_group
	,ole.opp_created_qtr as results_qtr
	,ole.opp_created_wk as results_wk
	,count(distinct ole.opp_id) as oppty_lt_excc
	,sum(ole.opp_gross_asv) as asv_lt_excc
from mci_enterprise_stage.sa_07 v
inner join mci_enterprise_stage.sa_opp_02 ole
	on v.row_num = ole.excc_oppty_lt_row_num
group by	
	v.summary_group
	,ole.opp_created_qtr
	,ole.opp_created_wk
;
select * from (
select sum(oppty_ft_excc) from  mci_enterprise_stage.sa_sum_opp_ft_excc
union all 
select sum(oppty_lt_excc) from  mci_enterprise_stage.sa_sum_opp_lt_excc
union all
select sum(oppty_at_excc) from  mci_enterprise_stage.sa_sum_opp_infl) z
--------------------------------------------------------
--RESULTS - Summarize OPPTY all ft
--------------------------------------------------------	
drop table mci_enterprise_stage.sa_sum_opp_ft_all;
create table mci_enterprise_stage.sa_sum_opp_ft_all --1,209
as select	
	v.summary_group
	,opfa.opp_created_qtr as results_qtr
	,opfa.opp_created_wk as results_wk
	,opfa.result_product
	,opfa.result_region
	,count(distinct opfa.opp_id) as oppty_ft_all
	,sum(opfa.opp_gross_asv) as asv_ft_all
from mci_enterprise_stage.sa_07 v
inner join mci_enterprise_stage.sa_opp_02 opfa
	on v.row_num = opfa.all_oppty_ft_row_num
group by	
	v.summary_group
	,opfa.opp_created_qtr
	,opfa.opp_created_wk
	,opfa.result_product
	,opfa.result_region
;
--------------------------------------------------------
--RESULTS - Summarize OPPTY all lt
--------------------------------------------------------	
drop table mci_enterprise_stage.sa_sum_opp_lt_all;
create table mci_enterprise_stage.sa_sum_opp_lt_all --1,532
as select	
	v.summary_group
	,ola.opp_created_qtr as results_qtr
	,ola.opp_created_wk as results_wk
	,ola.result_product
	,ola.result_region
	,count(distinct ola.opp_id) as oppty_lt_all
	,sum(ola.opp_gross_asv) as asv_lt_all
from mci_enterprise_stage.sa_07 v
inner join mci_enterprise_stage.sa_opp_02 ola
	on v.row_num = ola.all_oppty_lt_row_num
group by	
	v.summary_group
	,ola.opp_created_qtr
	,ola.opp_created_wk
	,ola.result_product
	,ola.result_region
	
select * from (
select sum(oppty_ft_all) from  mci_enterprise_stage.sa_sum_opp_ft_all
union all 
select sum(oppty_lt_all) from  mci_enterprise_stage.sa_sum_opp_lt_all
union all
select sum(oppty_at_all) from  mci_enterprise_stage.sa_sum_opp_infl) z
--********************************************************************************************************************************	
--------------------------------------------------------
--VISITS summarize
--------------------------------------------------------
--********************************************************************************************************************************	
drop table mci_enterprise_stage.sa_sum_00;
create table mci_enterprise_stage.sa_sum_00 --139,631
as select	
		--filters
	concat(substr(v.qtr,1,5),'Q',substr(v.qtr,7,1)) as qtr
	,concat(substr(v.qtr,1,5),lpad(v.week,2,'0')) as week
	,v.summary_group
	,count(distinct row_num) as clicks
from mci_enterprise_stage.sa_07 v
group by 
	--filters
	concat(substr(v.qtr,1,5),'Q',substr(v.qtr,7,1))
	,concat(substr(v.qtr,1,5),lpad(v.week,2,'0'))
	,v.summary_group

--------------------------------------------------------
--VISITS details
--------------------------------------------------------
drop table mci_enterprise_stage.sa_sum_01;
create table mci_enterprise_stage.sa_sum_01 --13,390
as select	distinct
	v.channel 
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
from mci_enterprise_stage.sa_07 v
--------------------------------------------------------
--All dates and campaigns
--------------------------------------------------------
drop table mci_enterprise_stage.sa_sum_02;
create table mci_enterprise_stage.sa_sum_02 as --3,561,044
select distinct * from (
	select results_qtr as qtr, results_wk as week, result_product, result_region, summary_group from
	mci_enterprise_stage.sa_sum_opp_infl oi
union all
	select results_qtr as qtr, results_wk as week, result_product, result_region, summary_group from		
	mci_enterprise_stage.sa_sum_resp_infl ri
union all
	select results_qtr as qtr, results_wk as week, result_product, result_region, summary_group from		
	mci_enterprise_stage.sa_sum_mql_infl mi
	) z

-------------------------------------------------------
--VISITS join
--------------------------------------------------------
drop table mci_enterprise_stage.sa_sum_03;
create table mci_enterprise_stage.sa_sum_03 --4,355
as select
v2.qtr
,v2.week
,v2.result_product
,v2.result_region
,v.*
--,coalesce(v1.clicks,0) as clicks
,coalesce(oi.oppty_infl,0) as oppty_infl
,coalesce(oi.oppty_infl_both,0) as oppty_infl_both
,0 as oppty_infl_excc
,0 as oppty_infl_all
,coalesce(oi.oppty_at,0) as oppty_at
,coalesce(oi.oppty_at_both,0) as oppty_at_both
,0 as oppty_at_excc
,0 as oppty_at_all
,coalesce(opf.oppty_ft,0) as oppty_ft
,coalesce(opfb.oppty_ft_both,0) as oppty_ft_both
,0 as oppty_ft_excc
,0 as oppty_ft_all
,coalesce(ol.oppty_lt,0) as oppty_lt
,coalesce(olb.oppty_lt_both,0) as oppty_lt_both
,0 as oppty_lt_excc
,0 as oppty_lt_all

,coalesce(oi.asv_infl,0) as asv_infl
,coalesce(oi.asv_infl_both,0) as asv_infl_both
,0 as asv_infl_excc
,0 as asv_infl_all
,coalesce(opf.asv_ft,0) as asv_ft
,coalesce(opfb.asv_ft_both,0) as asv_ft_both
,0 as asv_ft_excc
,0 as asv_ft_all
,coalesce(ol.asv_lt,0) as asv_lt
,coalesce(olb.asv_lt_both,0) as asv_lt_both
,0 as asv_lt_excc
,0 as asv_lt_all

,coalesce(ri.resp_infl,0) as resp_infl
,coalesce(ri.resp_infl_both,0) as resp_infl_both
,0 as resp_infl_excc
,0 as resp_infl_all
,coalesce(ri.resp_at,0) as resp_at
,coalesce(ri.resp_at_both,0) as resp_at_both
,0 as resp_at_excc
,0 as resp_at_all
,coalesce(rf.resp_ft,0) as resp_ft
,coalesce(rfb.resp_ft_both,0) as resp_ft_both
,0 as resp_ft_excc
,0 as resp_ft_all
,coalesce(rl.resp_lt,0) as resp_lt
,coalesce(rlb.resp_lt_both,0) as resp_lt_both
,0 as resp_lt_excc
,0 as resp_lt_all

,coalesce(mi.mql_infl,0) as mql_infl
,coalesce(mi.mql_infl_both,0) as mql_infl_both
,0 as mql_infl_excc
,0 as mql_infl_all
,coalesce(mi.mql_at,0) as mql_at
,coalesce(mi.mql_at_both,0) as mql_at_both
,0 as mql_at_excc
,0 as mql_at_all
,coalesce(mf.mql_ft,0) as mql_ft
,coalesce(mfb.mql_ft_both,0) as mql_ft_both
,0 as mql_ft_excc
,0 as mql_ft_all
,coalesce(ml.mql_lt,0) as mql_lt
,coalesce(mfb.mql_ft_both,0) as mql_lt_both
,0 as mql_lt_excc
,0 as mql_lt_all
,row_number() over () as row_num

,coalesce(oi.oppty_infl,0) as oppty_infl
,coalesce(oi.oppty_infl_both,0) as oppty_infl_both
/*,coalesce(oi.oppty_infl_excc,0) as oppty_infl_excc
,coalesce(oi.oppty_infl_all,0) as oppty_infl_all*/
,coalesce(oi.oppty_at,0) as oppty_at
,coalesce(oi.oppty_at_both,0) as oppty_at_both
/*,coalesce(oi.oppty_at_excc,0) as oppty_at_excc
,coalesce(oi.oppty_at_all,0) as oppty_at_all*/
,coalesce(opf.oppty_ft,0) as oppty_ft
,coalesce(opfb.oppty_ft_both,0) as oppty_ft_both
/*,coalesce(opfe.oppty_ft_excc,0) as oppty_ft_excc
,coalesce(opfa.oppty_ft_all,0) as oppty_ft_all*/
,coalesce(ol.oppty_lt,0) as oppty_lt
,coalesce(olb.oppty_lt_both,0) as oppty_lt_both
/*coalesce(ole.oppty_lt_excc,0) as oppty_lt_excc
,coalesce(ola.oppty_lt_all,0) as oppty_lt_all*/

,coalesce(oi.asv_infl,0) as asv_infl
,coalesce(oi.asv_infl_both,0) as asv_infl_both
/*,coalesce(oi.asv_infl_excc,0) as asv_infl_excc
,coalesce(oi.asv_infl_all,0) as asv_infl_all*/
,coalesce(opf.asv_ft,0) as asv_ft
,coalesce(opfb.asv_ft_both,0) as asv_ft_both
/*,coalesce(opfe.asv_ft_excc,0) as asv_ft_excc
,coalesce(opfa.asv_ft_all,0) as asv_ft_all*/
,coalesce(ol.asv_lt,0) as asv_lt
,coalesce(olb.asv_lt_both,0) as asv_lt_both
/*,coalesce(ole.asv_lt_excc,0) as asv_lt_excc
,coalesce(ola.asv_lt_all,0) as asv_lt_all*/

,coalesce(ri.resp_infl,0) as resp_infl
,coalesce(ri.resp_infl_both,0) as resp_infl_both
/*,coalesce(ri.resp_infl_excc,0) as resp_infl_excc
,coalesce(ri.resp_infl_all,0) as resp_infl_all*/
,coalesce(ri.resp_at,0) as resp_at
,coalesce(ri.resp_at_both,0) as resp_at_both
/*,coalesce(ri.resp_at_excc,0) as resp_at_excc
,coalesce(ri.resp_at_all,0) as resp_at_all*/
,coalesce(rf.resp_ft,0) as resp_ft
,coalesce(rfb.resp_ft_both,0) as resp_ft_both
/*,coalesce(rfe.resp_ft_excc,0) as resp_ft_excc
,coalesce(rfa.resp_ft_all,0) as resp_ft_all*/
,coalesce(rl.resp_lt,0) as resp_lt
,coalesce(rlb.resp_lt_both,0) as resp_lt_both
/*,coalesce(rle.resp_lt_excc,0) as resp_lt_excc
,coalesce(rla.resp_lt_all,0) as resp_lt_all*/

,coalesce(mi.mql_infl,0) as mql_infl
,coalesce(mi.mql_infl_both,0) as mql_infl_both
/*,coalesce(mi.mql_infl_excc,0) as mql_infl_excc
,coalesce(mi.mql_infl_all,0) as mql_infl_all*/
,coalesce(mi.mql_at,0) as mql_at
,coalesce(mi.mql_at_both,0) as mql_at_both
/*,coalesce(mi.mql_at_excc,0) as mql_at_excc
,coalesce(mi.mql_at_all,0) as mql_at_all*/
,coalesce(mf.mql_ft,0) as mql_ft
,coalesce(mfb.mql_ft_both,0) as mql_ft_both
/*,coalesce(mfe.mql_ft_excc,0) as mql_ft_excc
,coalesce(mfa.mql_ft_all,0) as mql_ft_all*/
,coalesce(ml.mql_lt,0) as mql_lt
,coalesce(mfb.mql_ft_both,0) as mql_lt_both
/*,coalesce(mfe.mql_ft_excc,0) as mql_lt_excc
,coalesce(mfa.mql_ft_all,0) as mql_lt_all*/
,row_number() over () as row_num

from mci_enterprise_stage.sa_sum_02 v2
/*left join mci_enterprise_stage.sa_sum_00 v1
	on v2.summary_group = v1.summary_group
	and v2.qtr = v1.qtr 
	and v2.week = v1.week*/
left join mci_enterprise_stage.sa_sum_01 v
	on v2.summary_group =  v.summary_group
left join mci_enterprise_stage.sa_sum_opp_infl oi
	on v2.summary_group = oi.summary_group
	and v2.qtr = oi.results_qtr
	and v2.week = oi.results_wk
	and v2.result_product = oi.result_product 
	and v2.result_region = oi.result_region 
left join mci_enterprise_stage.sa_sum_opp_ft opf
	on v2.summary_group = opf.summary_group
	and v2.qtr = opf.results_qtr
	and v2.week = opf.results_wk
	and v2.result_product = opf.result_product 
	and v2.result_region = opf.result_region 
left join mci_enterprise_stage.sa_sum_opp_ft_both opfb
	on v2.summary_group = opfb.summary_group
	and v2.qtr = opfb.results_qtr
	and v2.week = opfb.results_wk
	and v2.result_product = opfb.result_product 
	and v2.result_region = opfb.result_region 
/*left join mci_enterprise_stage.sa_sum_opp_ft_excc opfe
	on v2.summary_group = opfe.summary_group
	and v2.qtr = opfe.results_qtr
	and v2.week = opfe.results_wk
	and v2.result_product = opfe.result_product 
	and v2.result_region = opfe.result_region 
left join mci_enterprise_stage.sa_sum_opp_ft_all opfa
	on v2.summary_group = opfa.summary_group
	and v2.qtr = opfa.results_qtr
	and v2.week = opfa.results_wk
	and v2.result_product = opfa.result_product 
	and v2.result_region = opfa.result_region  */
	
left join mci_enterprise_stage.sa_sum_opp_lt ol
	on v2.summary_group = ol.summary_group
	and v2.qtr = ol.results_qtr
	and v2.week = ol.results_wk
	and v2.result_product = ol.result_product 
	and v2.result_region = ol.result_region 
left join mci_enterprise_stage.sa_sum_opp_lt_both olb
	on v2.summary_group = olb.summary_group
	and v2.qtr = olb.results_qtr
	and v2.week = olb.results_wk
	and v2.result_product = olb.result_product 
	and v2.result_region = olb.result_region 
/*left join mci_enterprise_stage.sa_sum_opp_lt_excc ole
	on v2.summary_group = ole.summary_group
	and v2.qtr = ole.results_qtr
	and v2.week = ole.results_wk
	and v2.result_product = ole.result_product 
	and v2.result_region = ole.result_region 
left join mci_enterprise_stage.sa_sum_opp_lt_all ola
	on v2.summary_group = ola.summary_group
	and v2.qtr = ola.results_qtr
	and v2.week = ola.results_wk
	and v2.result_product = ola.result_product 
	and v2.result_region = ola.result_region  */
	
left join mci_enterprise_stage.sa_sum_resp_infl ri
	on v2.summary_group = ri.summary_group
	and v2.qtr = ri.results_qtr
	and v2.week = ri.results_wk
	and v2.result_product = ri.result_product 
	and v2.result_region = ri.result_region 
left join mci_enterprise_stage.sa_sum_resp_ft rf
	on v2.summary_group = rf.summary_group
	and v2.qtr = rf.results_qtr
	and v2.week = rf.results_wk
	and v2.result_product = rf.result_product 
	and v2.result_region = rf.result_region 
left join mci_enterprise_stage.sa_sum_resp_ft_both rfb
	on v2.summary_group = rfb.summary_group
	and v2.qtr = rfb.results_qtr
	and v2.week = rfb.results_wk
	and v2.result_product = rfb.result_product 
	and v2.result_region = rfb.result_region 
/*left join mci_enterprise_stage.sa_sum_resp_ft_excc rfe
	on v2.summary_group = rfe.summary_group
	and v2.qtr = rfe.results_qtr
	and v2.week = rfe.results_wk
	and v2.result_product = rfe.result_product 
	and v2.result_region = rfe.result_region 
left join mci_enterprise_stage.sa_sum_resp_ft_all rfa
	on v2.summary_group = rfa.summary_group
	and v2.qtr = rfa.results_qtr
	and v2.week = rfa.results_wk
	and v2.result_product = rfa.result_product 
	and v2.result_region = rfa.result_region  */
	
left join mci_enterprise_stage.sa_sum_resp_lt rl
	on v2.summary_group = rl.summary_group
	and v2.qtr = rl.results_qtr
	and v2.week = rl.results_wk
	and v2.result_product = rl.result_product 
	and v2.result_region = rl.result_region 
left join mci_enterprise_stage.sa_sum_resp_lt_both rlb
	on v2.summary_group = rlb.summary_group
	and v2.qtr = rlb.results_qtr
	and v2.week = rlb.results_wk
	and v2.result_product = rlb.result_product 
	and v2.result_region = rlb.result_region 
/*left join mci_enterprise_stage.sa_sum_resp_lt_excc rle
	on v2.summary_group = rle.summary_group
	and v2.qtr = rle.results_qtr
	and v2.week = rle.results_wk
	and v2.result_product = rle.result_product 
	and v2.result_region = rle.result_region 
left join mci_enterprise_stage.sa_sum_resp_lt_all rla
	on v2.summary_group = rla.summary_group
	and v2.qtr = rla.results_qtr
	and v2.week = rla.results_wk
	and v2.result_product = rla.result_product 
	and v2.result_region = rla.result_region  */
	
left join mci_enterprise_stage.sa_sum_mql_infl mi
	on v2.summary_group = mi.summary_group
	and v2.qtr = mi.results_qtr
	and v2.week = mi.results_wk
	and v2.result_product = mi.result_product 
	and v2.result_region = mi.result_region 
left join mci_enterprise_stage.sa_sum_mql_ft mf
	on v2.summary_group = mf.summary_group
	and v2.qtr = mf.results_qtr
	and v2.week = mf.results_wk
	and v2.result_product = mf.result_product 
	and v2.result_region = mf.result_region 
left join mci_enterprise_stage.sa_sum_mql_ft_both mfb
	on v2.summary_group = mfb.summary_group
	and v2.qtr = mfb.results_qtr
	and v2.week = mfb.results_wk
	and v2.result_product = mfb.result_product 
	and v2.result_region = mfb.result_region 
/*left join mci_enterprise_stage.sa_sum_mql_ft_excc mfe
	on v2.summary_group = mfe.summary_group
	and v2.qtr = mfe.results_qtr
	and v2.week = mfe.results_wk
	and v2.result_product = mfe.result_product 
	and v2.result_region = mfe.result_region 
left join mci_enterprise_stage.sa_sum_mql_ft_all mfa
	on v2.summary_group = mfa.summary_group
	and v2.qtr = mfa.results_qtr
	and v2.week = mfa.results_wk
	and v2.result_product = mfa.result_product 
	and v2.result_region = mfa.result_region */
	
left join mci_enterprise_stage.sa_sum_mql_lt ml
	on v2.summary_group = ml.summary_group
	and v2.qtr = ml.results_qtr
	and v2.week = ml.results_wk
	and v2.result_product = ml.result_product 
	and v2.result_region = ml.result_region 
left join mci_enterprise_stage.sa_sum_mql_lt_both mlb
	on v2.summary_group = mlb.summary_group
	and v2.qtr = mlb.results_qtr
	and v2.week = mlb.results_wk
	and v2.result_product = mlb.result_product 
	and v2.result_region = mlb.result_region 
/*left join mci_enterprise_stage.sa_sum_mql_lt_excc mle
	on v2.summary_group = mle.summary_group
	and v2.qtr = mle.results_qtr
	and v2.week = mle.results_wk
	and v2.result_product = mle.result_product 
	and v2.result_region = mle.result_region 
left join mci_enterprise_stage.sa_sum_mql_lt_all mla
	on v2.summary_group = mla.summary_group
	and v2.qtr = mla.results_qtr
	and v2.week = mla.results_wk
	and v2.result_product = mla.result_product 
	and v2.result_region = mla.result_region */
where mql_infl_all > 0 or resp_infl_all >0 or oppty_infl_all >0
--------------------------------------------------------
-- Check Counts
--------------------------------------------------------
select
sum(clicks) as clicks
,sum(resp_infl) as resp_infl
,sum(resp_ft) as resp_ft
,sum(resp_lt) as resp_lt
,sum(resp_at) as resp_at

,sum(mql_infl) as mql_infl
,sum(mql_ft) as mql_ft
,sum(mql_lt) as mql_lt
,sum(mql_at) as mql_at

,sum(oppty_infl) as oppty_infl
,sum(oppty_ft) as oppty_ft
,sum(oppty_lt) as oppty_lt
,sum(oppty_at) as oppty_at

,sum(asv_infl) as asv_infl
,sum(asv_ft) as asv_ft
,sum(asv_lt) as asv_lt

,sum(resp_infl_both) as resp_infl_both
,sum(resp_ft_both) as resp_ft_both
,sum(resp_lt_both) as resp_lt_both
,sum(resp_at_both) as resp_at_both
,sum(mql_infl_both) as mql_infl_both

,sum(mql_ft_both) as mql_ft_both
,sum(mql_lt_both) as mql_lt_both
,sum(mql_at_both) as mql_at_both

,sum(oppty_infl_both) as oppty_infl_both
,sum(oppty_ft_both) as oppty_ft_both
,sum(oppty_lt_both) as oppty_lt_both
,sum(oppty_at_both) as oppty_at_both
,sum(asv_infl_both) as asv_infl_both

,sum(asv_ft_both) as asv_ft_both
,sum(asv_lt_both) as asv_lt_both
,sum(asv_infl_both) as asv_infl_both
/*
,sum(resp_infl_excc) as resp_infl_excc
,sum(resp_ft_excc) as resp_ft_excc
,sum(resp_lt_excc) as resp_lt_excc
,sum(resp_at_excc) as resp_at_excc
,sum(mql_infl_excc) as mql_infl_excc

,sum(mql_ft_excc) as mql_ft_excc
,sum(mql_lt_excc) as mql_lt_excc
,sum(mql_at_excc) as mql_at_excc

,sum(oppty_infl_excc) as oppty_infl_excc
,sum(oppty_ft_excc) as oppty_ft_excc
,sum(oppty_lt_excc) as oppty_lt_excc
,sum(oppty_at_excc) as oppty_at_excc
,sum(asv_infl_excc) as asv_infl_excc

,sum(asv_ft_excc) as asv_ft_excc
,sum(asv_lt_excc) as asv_lt_excc
,sum(asv_infl_excc) as asv_infl_excc

,sum(resp_infl_all) as resp_infl_all
,sum(resp_ft_all) as resp_ft_all
,sum(resp_lt_all) as resp_lt_all
,sum(resp_at_all) as resp_at_all

,sum(mql_infl_all) as mql_infl_all
,sum(mql_ft_all) as mql_ft_all
,sum(mql_lt_all) as mql_lt_all
,sum(mql_at_all) as mql_at_all

,sum(oppty_infl_all) as oppty_infl_all
,sum(oppty_ft_all) as oppty_ft_all
,sum(oppty_lt_all) as oppty_lt_all
,sum(oppty_at_all) as oppty_at_all

,sum(asv_infl_all) as asv_infl_all
,sum(asv_ft_all) as asv_ft_all
,sum(asv_lt_all) as asv_lt_all*/
from mci_enterprise_stage.sa_sum_03

/*
select * from mci_enterprise_stage.sa_sum_03 where row_num >=1 and row_num < 100000 ;
select * from mci_enterprise_stage.sa_sum_03 where row_num >=100000 and row_num < 199999 ;
select * from mci_enterprise_stage.sa_sum_03 where row_num >=199999 and row_num < 299998 ;
select * from mci_enterprise_stage.sa_sum_03 where row_num >=299998 and row_num < 399997 ;
select * from mci_enterprise_stage.sa_sum_03 where row_num >=399997 and row_num < 499996 ;
select * from mci_enterprise_stage.sa_sum_03 where row_num >=499996 and row_num < 599995 ;
select * from mci_enterprise_stage.sa_sum_03 where row_num >=599995 and row_num < 699994 ;
select * from mci_enterprise_stage.sa_sum_03 where row_num >=699994 and row_num < 799993 ;
select * from mci_enterprise_stage.sa_sum_03 where row_num >=799993 and row_num < 899992 ;
select * from mci_enterprise_stage.sa_sum_03 where row_num >=899992 and row_num < 999991 ;
select * from mci_enterprise_stage.sa_sum_03 where row_num >=999991 and row_num < 1099990 ;
select * from mci_enterprise_stage.sa_sum_03 where row_num >=1099990 and row_num < 1199989 ;
select * from mci_enterprise_stage.sa_sum_03 where row_num >=1199989 and row_num < 1299988 ;
select * from mci_enterprise_stage.sa_sum_03 where row_num >=1299988 and row_num < 1399987 ;
select * from mci_enterprise_stage.sa_sum_03 where row_num >=1399987 and row_num < 1499986 ;
select * from mci_enterprise_stage.sa_sum_03 where row_num >=1499986 and row_num < 1599985 ;
select * from mci_enterprise_stage.sa_sum_03 where row_num >=1599985 and row_num < 1699984 ;
select * from mci_enterprise_stage.sa_sum_03 where row_num >=1699984 and row_num < 1799983 ;
*/

/*
drop table mci_enterprise_stage.sa_00;
drop table mci_enterprise_stage.sa_01;

drop table mci_enterprise_stage.sa_camp_00s; 
drop table mci_enterprise_stage.sa_camp_00c;
drop table mci_enterprise_stage.sa_camp_01;
drop table mci_enterprise_stage.sa_camp_02;
drop table mci_enterprise_stage.sa_camp_03;
drop table mci_enterprise_stage.sa_camp_04;

drop table mci_enterprise_stage.sa_02;
drop table mci_enterprise_stage.sa_03; 
drop table mci_enterprise_stage.sa_04; 
drop table mci_enterprise_stage.sa_05;

drop table mci_enterprise_stage.sa_t;
drop table mci_enterprise_stage.sa_f;
drop table mci_enterprise_stage.sa_e;
drop table mci_enterprise_stage.sa_s;

drop table mci_enterprise_stage.sa_06;
drop table mci_enterprise_stage.sa_07;

drop table mci_enterprise_stage.sa_opp_01;
drop table mci_enterprise_stage.sa_opp_02;
drop table mci_enterprise_stage.sa_opp_03_0;
drop table mci_enterprise_stage.sa_opp_03;
drop table mci_enterprise_stage.sa_sum_opp_infl;
drop table mci_enterprise_stage.sa_sum_opp_ft;
drop table mci_enterprise_stage.sa_sum_opp_lt;
drop table mci_enterprise_stage.sa_sum_opp_ft_both;
drop table mci_enterprise_stage.sa_sum_opp_lt_both;
drop table mci_enterprise_stage.sa_sum_opp_ft_all;
drop table mci_enterprise_stage.sa_sum_opp_lt_all;

drop table mci_enterprise_stage.sa_resp_01;
drop table mci_enterprise_stage.sa_resp_02;
drop table mci_enterprise_stage.sa_resp_03;
drop table mci_enterprise_stage.sa_sum_resp_infl;
drop table mci_enterprise_stage.sa_sum_resp_ft;
drop table mci_enterprise_stage.sa_sum_resp_lt;
drop table mci_enterprise_stage.sa_sum_resp_ft_both;
drop table mci_enterprise_stage.sa_sum_resp_lt_both;
drop table mci_enterprise_stage.sa_sum_resp_ft_all;
drop table mci_enterprise_stage.sa_sum_resp_lt_all;

drop table mci_enterprise_stage.sa_resp_04;
drop table mci_enterprise_stage.sa_resp_05;
drop table mci_enterprise_stage.sa_sum_mql_infl;
drop table mci_enterprise_stage.sa_sum_mql_ft;
drop table mci_enterprise_stage.sa_sum_mql_lt;
drop table mci_enterprise_stage.sa_sum_mql_ft_both;
drop table mci_enterprise_stage.sa_sum_mql_lt_both;
drop table mci_enterprise_stage.sa_sum_mql_ft_all;
drop table mci_enterprise_stage.sa_sum_mql_lt_all;

drop table mci_enterprise_stage.sa_sum_00;
drop table mci_enterprise_stage.sa_sum_01;
drop table mci_enterprise_stage.sa_sum_02;
drop table mci_enterprise_stage.sa_sum_03;


create table mci_enterprise_stage.sa_counts as 
select * from (
select 'sa_00' as table ,count(*) as cnt from mci_enterprise_stage.sa_00 group by 'sa_00' union all
select 'sa_01' as table ,count(*) as cnt from mci_enterprise_stage.sa_01 group by 'sa_01' union all

select 'sa_camp_00s ' as table ,count(*) as cnt from mci_enterprise_stage.sa_camp_00s  group by 'sa_camp_00s ' union all
select 'sa_camp_00c' as table ,count(*) as cnt from mci_enterprise_stage.sa_camp_00c group by 'sa_camp_00c' union all
select 'sa_camp_01' as table ,count(*) as cnt from mci_enterprise_stage.sa_camp_01 group by 'sa_camp_01' union all
select 'sa_camp_02' as table ,count(*) as cnt from mci_enterprise_stage.sa_camp_02 group by 'sa_camp_02' union all
select 'sa_camp_03' as table ,count(*) as cnt from mci_enterprise_stage.sa_camp_03 group by 'sa_camp_03' union all
select 'sa_camp_04' as table ,count(*) as cnt from mci_enterprise_stage.sa_camp_04 group by 'sa_camp_04' union all

select 'sa_02' as table ,count(*) as cnt from mci_enterprise_stage.sa_02 group by 'sa_02' union all
select 'sa_03 ' as table ,count(*) as cnt from mci_enterprise_stage.sa_03  group by 'sa_03 ' union all
select 'sa_04 ' as table ,count(*) as cnt from mci_enterprise_stage.sa_04  group by 'sa_04 ' union all
select 'sa_05' as table ,count(*) as cnt from mci_enterprise_stage.sa_05 group by 'sa_05' union all

select 'sa_t' as table ,count(*) as cnt from mci_enterprise_stage.sa_t group by 'sa_t' union all
select 'sa_f' as table ,count(*) as cnt from mci_enterprise_stage.sa_f group by 'sa_f' union all
select 'sa_e' as table ,count(*) as cnt from mci_enterprise_stage.sa_e group by 'sa_e' union all
select 'sa_s' as table ,count(*) as cnt from mci_enterprise_stage.sa_s group by 'sa_s' union all

select 'sa_06' as table ,count(*) as cnt from mci_enterprise_stage.sa_06 group by 'sa_06' union all
select 'sa_07' as table ,count(*) as cnt from mci_enterprise_stage.sa_07 group by 'sa_07' union all

select 'sa_opp_01' as table ,count(*) as cnt from mci_enterprise_stage.sa_opp_01 group by 'sa_opp_01' union all
select 'sa_opp_02' as table ,count(*) as cnt from mci_enterprise_stage.sa_opp_02 group by 'sa_opp_02' union all
select 'sa_opp_03_0' as table ,count(*) as cnt from mci_enterprise_stage.sa_opp_03_0 group by 'sa_opp_03_0' union all
select 'sa_opp_03' as table ,count(*) as cnt from mci_enterprise_stage.sa_opp_03 group by 'sa_opp_03' union all
select 'sa_sum_opp_infl' as table ,count(*) as cnt from mci_enterprise_stage.sa_sum_opp_infl group by 'sa_sum_opp_infl' union all
select 'sa_sum_opp_ft' as table ,count(*) as cnt from mci_enterprise_stage.sa_sum_opp_ft group by 'sa_sum_opp_ft' union all
select 'sa_sum_opp_lt' as table ,count(*) as cnt from mci_enterprise_stage.sa_sum_opp_lt group by 'sa_sum_opp_lt' union all
select 'sa_sum_opp_ft_both' as table ,count(*) as cnt from mci_enterprise_stage.sa_sum_opp_ft_both group by 'sa_sum_opp_ft_both' union all
select 'sa_sum_opp_lt_both' as table ,count(*) as cnt from mci_enterprise_stage.sa_sum_opp_lt_both group by 'sa_sum_opp_lt_both' union all
select 'sa_sum_opp_ft_all' as table ,count(*) as cnt from mci_enterprise_stage.sa_sum_opp_ft_all group by 'sa_sum_opp_ft_all' union all
select 'sa_sum_opp_lt_all' as table ,count(*) as cnt from mci_enterprise_stage.sa_sum_opp_lt_all group by 'sa_sum_opp_lt_all' union all

select 'sa_resp_01' as table ,count(*) as cnt from mci_enterprise_stage.sa_resp_01 group by 'sa_resp_01' union all
select 'sa_resp_02' as table ,count(*) as cnt from mci_enterprise_stage.sa_resp_02 group by 'sa_resp_02' union all
select 'sa_resp_03' as table ,count(*) as cnt from mci_enterprise_stage.sa_resp_03 group by 'sa_resp_03' union all
select 'sa_sum_resp_infl' as table ,count(*) as cnt from mci_enterprise_stage.sa_sum_resp_infl group by 'sa_sum_resp_infl' union all
select 'sa_sum_resp_ft' as table ,count(*) as cnt from mci_enterprise_stage.sa_sum_resp_ft group by 'sa_sum_resp_ft' union all
select 'sa_sum_resp_lt' as table ,count(*) as cnt from mci_enterprise_stage.sa_sum_resp_lt group by 'sa_sum_resp_lt' union all
select 'sa_sum_resp_ft_both' as table ,count(*) as cnt from mci_enterprise_stage.sa_sum_resp_ft_both group by 'sa_sum_resp_ft_both' union all
select 'sa_sum_resp_lt_both' as table ,count(*) as cnt from mci_enterprise_stage.sa_sum_resp_lt_both group by 'sa_sum_resp_lt_both' union all
select 'sa_sum_resp_ft_all' as table ,count(*) as cnt from mci_enterprise_stage.sa_sum_resp_ft_all group by 'sa_sum_resp_ft_all' union all
select 'sa_sum_resp_lt_all' as table ,count(*) as cnt from mci_enterprise_stage.sa_sum_resp_lt_all group by 'sa_sum_resp_lt_all' union all

select 'sa_resp_04' as table ,count(*) as cnt from mci_enterprise_stage.sa_resp_04 group by 'sa_resp_04' union all
select 'sa_resp_05' as table ,count(*) as cnt from mci_enterprise_stage.sa_resp_05 group by 'sa_resp_05' union all
select 'sa_sum_mql_infl' as table ,count(*) as cnt from mci_enterprise_stage.sa_sum_mql_infl group by 'sa_sum_mql_infl' union all
select 'sa_sum_mql_ft' as table ,count(*) as cnt from mci_enterprise_stage.sa_sum_mql_ft group by 'sa_sum_mql_ft' union all
select 'sa_sum_mql_lt' as table ,count(*) as cnt from mci_enterprise_stage.sa_sum_mql_lt group by 'sa_sum_mql_lt' union all
select 'sa_sum_mql_ft_both' as table ,count(*) as cnt from mci_enterprise_stage.sa_sum_mql_ft_both group by 'sa_sum_mql_ft_both' union all
select 'sa_sum_mql_lt_both' as table ,count(*) as cnt from mci_enterprise_stage.sa_sum_mql_lt_both group by 'sa_sum_mql_lt_both' union all
select 'sa_sum_mql_ft_all' as table ,count(*) as cnt from mci_enterprise_stage.sa_sum_mql_ft_all group by 'sa_sum_mql_ft_all' union all
select 'sa_sum_mql_lt_all' as table ,count(*) as cnt from mci_enterprise_stage.sa_sum_mql_lt_all group by 'sa_sum_mql_lt_all' union all

select 'sa_sum_00' as table ,count(*) as cnt from mci_enterprise_stage.sa_sum_00 group by 'sa_sum_00' union all
select 'sa_sum_01' as table ,count(*) as cnt from mci_enterprise_stage.sa_sum_01 group by 'sa_sum_01' union all
select 'sa_sum_02' as table ,count(*) as cnt from mci_enterprise_stage.sa_sum_02 group by 'sa_sum_02' union all
select 'sa_sum_03' as table ,count(*) as cnt from mci_enterprise_stage.sa_sum_03 group by 'sa_sum_03'
) z;



