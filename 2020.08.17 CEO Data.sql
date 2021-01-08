
create table mci_enterprise_stage.sa_ceo_00
as select v.*
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
		inner join mci_enterprise_stage.ab_big_sign_campaign_taxonomy a
			on v.post_pagename = a.pagename
		where v.report_suite='adbadobenonacdcprod' 
			and mcvisid <> '00000000000000000000000000000000000000'
			and v.click_date >= '2020-02-01'
			and v.session_id is not null
	)v 
	left join mcietl.web_visitor_base_v2  v2
		on v2.mcvisid = v.mcvisid
		and v2.visit_key = v.session_id
		and v2.visid = v.visid
		and v2.click_date = v.click_date
		and v2.click_date >= '2020-02-01'
		and v2.post_pagename = v.post_pagename

drop table mci_enterprise_stage.sa_ceo_01;
create table mci_enterprise_stage.sa_ceo_01 as
	select distinct
    v.click_date 	
	,v.visid
	,v.mcvisid	
	,v.session_id
	,v.tap_sub_std_name_key
	,v.mch_cookie
	,v.faas_submission_id
	,v.email	
	,v.sfdc_id
	,v.qtr	
	,v.week
	,v.page_url
	,v.post_pagename
	,v.cgen_tag	
	,v.sfdc_tag
	,v.leadsource
	,v.leadsource2
	,coalesce(se.exposure,ce.exposure,l.exposure,l2.exposure) as exposure
	,coalesce(v.marketing_channel,sfdc_channel) as marketing_channel
	,coalesce(v.productname,c.product_promoted) as product
	,coalesce(v.sfdc_tag,v.leadsource,v.cgen_tag,v.leadsource2) as tag
	,coalesce(s.sfdc_region,c.cgen_region) as region
	,concat(coalesce(s.sfdc_program,v.leadsource,c.cgen_campaign_name),coalesce(case when s.id is null then concat(' (',v.sfdc_tag,')') else '' end,'')) as program_campaign
	,concat(coalesce(s.bu_group__c,v.leadsource,c.cgen_campaign_name),coalesce(case when s.id is null then concat(' (',v.sfdc_tag,')') else '' end,'')) as group_campaign
	,concat(coalesce(s.sfdc_campaign_name,v.leadsource2,c.tag_name),coalesce(case when s.id is null then concat(' (',v.sfdc_tag,')') else '' end,'')) as campaign_tag
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
	from  mci_enterprise_stage.sa_ceo_00 v	
	left join mci_enterprise_stage.sa_camp_00c c
		on c.tag_id = v.cgen_tag
	left join mci_enterprise_stage.sa_camp_00s s
		on s.id  = v.sfdc_tag
	left join mci_enterprise_stage.sa_exposed_sf se
			on UPPER(v.sfdc_tag) = UPPER(se.sfdc_tag)
	left join mci_enterprise_stage.sa_exposed_leadsource l
		on UPPER(v.leadsource) = UPPER(l.leadsource)
	left join mci_enterprise_stage.sa_exposed_leadsource l2
		on UPPER(v.leadsource2) = UPPER(l2.leadsource)
	left join mci_enterprise_stage.sa_exposed_cgen2 ce
		on v.cgen_tag = ce.cgen_tag
;
select count(*), count(tap_sub_std_name_key), count(distinct tap_sub_std_name_key) from mci_enterprise_stage.sa_ceo_01;
--140,370,854	139,805,003	388,996

create table mci_enterprise_stage.sa_ceo_tap as
select distinct
	 f.sf_account_id 
	,coalesce(v.tap_sub_std_name_key, f.sub_std_name_key, d.tap_sub_std_name_key) as tap_sub_std_name_key
from mci_enterprise_stage.sa_ceo_01 v
inner join mci_enterprise.wv_ecp_id_domain_data d
                on UPPER(split(v.email,'[\@]')[1]) = UPPER(d.domain)
inner join (select x.sf_account_id, sub_std_name_key, sub_name
			from mdpd_target.ent_sf_account_site_key_xref x 
             inner join mdpd_target.enterprise_contact_composite y
                 on  x.site_key = y.site_key) f
on f.sf_account_id = d.sfdc_act_id 


/* these don't seem to add any additional tap_sub_std_name_key*/

--append tap_sub_std_name_key from other sources
drop table mci_enterprise_stage.sa_ceo_02;
create table mci_enterprise_stage.sa_ceo_02 as
select distinct
 v.click_date 	
	,v.visid
	,v.mcvisid	
	,v.session_id
	,coalesce(v.tap_sub_std_name_key,f.tap_sub_std_name_key, c1.tap_sub_std_name_key, c2.tap_sub_std_name_key) as tap_sub_std_name_key
	,v.mch_cookie
	,v.faas_submission_id
	,v.email	
	,v.sfdc_id
	,v.qtr	
	,v.week
	,v.page_url
	,v.post_pagename
	,v.cgen_tag	
	,v.sfdc_tag
	,v.leadsource
	,v.leadsource2
	,v.exposure
	,v.marketing_channel
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
	,v.bu_campaign__c
	,v.subtype__c 
from mci_enterprise_stage.sa_ceo_01 v
left join mci_enterprise.wv_ecp_id_domain_data d
	on UPPER(split(v.email,'[\@]')[1]) = UPPER(d.domain)
left join (select distinct email, tap_sub_std_name_key from mci_enterprise.abm_sfdc_contacts_mapped where email is not null and tap_sub_std_name_key is not null) c1
    on UPPER(v.email) = UPPER(c1.email)
left join (select distinct contactid, tap_sub_std_name_key from mci_enterprise.abm_sfdc_contacts_mapped where contactid is not null and tap_sub_std_name_key is not null) c2
    on UPPER(v.sfdc_id) = UPPER(c2.contactid)
left join mci_enterprise_stage.sa_ceo_tap f
	on f.sf_account_id = d.sfdc_act_id 

select count(*), count(tap_sub_std_name_key), count(distinct tap_sub_std_name_key) from mci_enterprise_stage.sa_ceo_02;
--140,370,854	13,9805,003	388,996

--backfill
drop table mci_enterprise_stage.sa_ceo_t;
create table mci_enterprise_stage.sa_ceo_t --
as select *, row_number() over (partition by visid order by cnt desc) as rnk from (
select 
v.tap_sub_std_name_key
,v.visid
,count(*) as cnt
from mci_enterprise_stage.sa_ceo_02 v
where v.tap_sub_std_name_key is not null
group by
v.tap_sub_std_name_key
,v.visid )z;

drop table mci_enterprise_stage.sa_ceo_03;
create table mci_enterprise_stage.sa_ceo_03 as
select distinct
 v.click_date 	
	,v.visid
	,v.mcvisid	
	,v.session_id
	,coalesce(v.tap_sub_std_name_key, t.tap_sub_std_name_key) as tap_sub_std_name_key
	,v.mch_cookie
	,v.faas_submission_id
	,v.email	
	,v.sfdc_id
	,v.qtr	
	,v.week
	,min(v.click_date) over (partition by v.week) as week_start 
    ,max(v.click_date) over (partition by v.week) as week_end  
	,v.page_url
	,v.post_pagename
	,v.cgen_tag	
	,v.sfdc_tag
	,v.leadsource
	,v.leadsource2
	,v.exposure
	,v.marketing_channel
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
	,v.bu_campaign__c
	,v.subtype__c 
from mci_enterprise_stage.sa_ceo_02 v
left join mci_enterprise_stage.sa_ceo_t t
     on t.visid = v.visid
     and t.rnk = 1;

select count(*), count(tap_sub_std_name_key), count(distinct tap_sub_std_name_key) from mci_enterprise_stage.sa_ceo_03;


--summary
drop table mci_enterprise_stage.sa_ceo_summary;
create table mci_enterprise_stage.sa_ceo_summary as
	select
v.week
,v.week_start
,v.week_end
,l.funnel_type
,count(*) cnt
,count(distinct v.mcvisid) distinct_visid
,count(distinct v.email) distinct_email
,count(distinct v.tap_sub_std_name_key) distinct_tap_sub_std_name_key
from mci_enterprise_stage.sa_ceo_03 v
left join mci_enterprise_stage.ab_final_response_subid_wk1437 l
    on v.tap_sub_std_name_key = l.sub_std_name_key
group by 
v.week
,v.week_start
,v.week_end
,l.funnel_type
;

drop table mci_enterprise_stage.sa_ceo_account_flag;
create table mci_enterprise_stage.sa_ceo_account_flag as
select distinct * from (
select sub_std_name_key,'Non Named' as account_flag from mci_enterprise_stage.mn_dme_not_named_ecp  
union all 
select sub_std_name_key,'Named' as account_flag from mci_enterprise_stage.mn_dme_named_accounts_mod
union all 
select b.tap_sub_std_name_key as sub_std_name_key,'Non ECP' as account_flag from mci_enterprise_stage.ab_dme_acrobatsign_base_wk27_32 b 
	left join mci_enterprise_stage.mn_dme_named_accounts_mod m
		on b.tap_sub_std_name_key = m.sub_std_name_key
	left join mci_enterprise_stage.mn_dme_not_named_ecp e
		on b.tap_sub_std_name_key = e.sub_std_name_key
	where m.sub_std_name_key is null and e.sub_std_name_key is null
union all 
select b.sub_std_name_key,'Non ECP' as account_flag from mci_enterprise_stage.ab_final_response_subid_wk1437 b
	left join mci_enterprise_stage.mn_dme_named_accounts_mod m
		on b.sub_std_name_key = m.sub_std_name_key
	left join mci_enterprise_stage.mn_dme_not_named_ecp e
		on b.sub_std_name_key = e.sub_std_name_key
	where m.sub_std_name_key is null and e.sub_std_name_key is null
)z;

drop table mci_enterprise_stage.sa_ceo_summary_2;
create table mci_enterprise_stage.sa_ceo_summary_2 as
	select
v.week
,v.week_start
,v.week_end
,l.account_flag 
,count(*) cnt
,count(distinct v.mcvisid) distinct_visid
,count(distinct v.email) distinct_email
,count(distinct v.tap_sub_std_name_key) distinct_tap_sub_std_name_key
from mci_enterprise_stage.sa_ceo_03 v
left join mci_enterprise_stage.sa_ceo_account_flag l
    on v.tap_sub_std_name_key = l.sub_std_name_key
group by 
v.week
,v.week_start
,v.week_end
,l.account_flag 
;