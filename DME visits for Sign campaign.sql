-----------------------------------------------------------------------------------------------------------------------------------------------------------
--Extracting DemandBase Dimensions for Industry, Employee Size and Revenue
-----------------------------------------------------------------------------------------------------------------------------------------------------------
--change week, create new table for every week

drop table mci_enterprise_stage.dme_demandbase_dimensions_weekly;
create table mci_enterprise_stage.dme_demandbase_dimensions_weekly stored as ORC as
Select
    session_id,
    demandbase_51,
    split(demandbase_51,'\\:')[0] as sid,
    split(demandbase_51,'\\:')[1] as company_name,
    split(demandbase_51,'\\:')[2] as industry,
    split(demandbase_51,'\\:')[3] as subindustry,
    split(demandbase_51,'\\:')[4] as emp_range,
    split(demandbase_51,'\\:')[5] as rev_range,
    split(demandbase_51,'\\:')[6] as audience,
    split(demandbase_51,'\\:')[7] as audience_seg
from mcietl.web_visits_detailed
where demandbase_51 is not null
and click_date between '2020-07-25' and '2020-07-31'; --change dates here


--mci_enterprise_stage.dme_demandbase_dimension - historic table
insert into table mci_enterprise_stage.dme_demandbase_dimension
select distinct * from mci_enterprise_stage.dme_demandbase_dimensions_weekly;





-----------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------
--STEP 1 : Creating base table for account detection, visits and pageviews
-----------------------------------------------------------------------------------------------------------------------------------------------------------
--create new table for every week
drop table mci_enterprise_stage.ab_dme_acrobatsign_base_wk27_32;
create table mci_enterprise_stage.ab_dme_acrobatsign_base_wk27_32 stored as ORC
as
select
	visit_key, mcvisid, visid,  surro_key, tap_sub_std_name_key, subname, pagename, email, visit_geo, geo_country, click_date,
	products,
	market_area_description, fiscal_yr_and_wk_desc, persona, dx_persona_group,
	--sfdc variables
	sfdc_campaign_id, f.name as sfdc_campaign_name, f.type as campaign_type, f.subtype__c as campaign_subtype,  f.bu_campaign__c as campaign_bu, 
	g.opp_gross_asv,
	external_campaign, post_event_list
from
	(
	select 
	a.visit_key,mcvisid, a.surro_key, a.tap_sub_std_name_key,
	coalesce(a.tap_sub_name, a.demandbase_company_name) as subname,
	coalesce(a.pagename, a.post_pagename, a.custom_link_page_name) as pagename,
	a.email, a.sfdc_id, a.sfdc_campaign_code, a.external_campaign, a.post_event_list,
	a.visit_geo, a.geo_country, a.click_date,	
	case when products in ('DC: Acrobat','DC: Document Cloud') then 'Acrobat'
		 when products = 'Adobe Sign: Sign' then 'Sign'
	end as products,
		c.market_area_description,
		d.fiscal_yr_and_wk_desc,
		coalesce(
			case when length(split(a.sfdc_campaign_code,'\\|')[4]) < 1 then null else split(a.sfdc_campaign_code,'\\|')[4] END,
			case when length(split(a.sfdc_campaign_code,'\\|')[3]) < 1 then null else split(a.sfdc_campaign_code,'\\|')[3] END,
			case when length(split(a.sfdc_campaign_code,'\\|')[2]) < 1 then null else split(a.sfdc_campaign_code,'\\|')[2] END,
			case when length(split(a.sfdc_campaign_code,'\\|')[1]) < 1 then null else split(a.sfdc_campaign_code,'\\|')[1] END,
			case when length(split(a.sfdc_campaign_code,'\\|')[0]) < 1 then null else split(a.sfdc_campaign_code,'\\|')[0] END
			) as sfdc_campaign_id,
		e.persona, e.dx_persona_group

		from 
			mcietl.web_visitor_base_v2 a
		join mci_enterprise_stage.ab_big_sign_campaign_taxonomy b
			on a.pagename = b.pagename
		-- to append market area description	
		left join warehouse.country c
			on lower(a.geo_country) = lower(c.country_code_iso3)
		-- to append to get fiscal week number	
		left join warehouse.hana_ccmusage_dim_date d			
			on a.click_date = d.date_date
		-- to get persona and persona group	
		left join
			(
			select cc.email, cc.persona, dd.dx_persona_group
			from mdpd_target.enterprise_contact_composite cc
			left join mci_enterprise.dx_persona_group_xref dd
			on lower(trim(cc.persona))=lower(trim(dd.dx_persona))
			) e
			on lower(trim(a.email)) = lower(trim(e.email))
		-----------------------	
		---CHANGE DATES HERE---
		-----------------------
		where a.click_date between '2020-05-30' and '2020-07-10'
		--where a.click_date between date_sub(to_date(current_date),9) and date_sub(to_date(current_date),2)
		-----------------------
			and lower(c.market_area_description) in ('united states','united kingdom','germany','japan','anz')   ---addind ANZ from wk25 onwards
			and lower(b.products) in ('dc: acrobat','adobe sign: sign','dc: document cloud')
			and a.tap_sub_std_name_key >1
	) subquery
	
-- to get SFDC campaign name	
left join sourcedata.sfdc_campaign f
	on lower(subquery.sfdc_campaign_id) = lower(f.id)

--to get ASV for Account-Market-Product
left join mci_enterprise.abm_account_oppty_all_p2s g
	on subquery.tap_sub_std_name_key = g.sub_std_name_key
	and trim(lower(subquery.products)) = trim(lower(g.opp_opg))
	and trim(lower(subquery.market_area_description)) = trim(lower(g.sfdc_account_market_area))
	--and trim(lower(subquery.geo_country)) = trim(lower(g.sfdc_account_geo))
	
group by 
	visit_key,mcvisid, visid, surro_key, tap_sub_std_name_key, subname, pagename, email, visit_geo, geo_country, click_date,
	products, market_area_description, fiscal_yr_and_wk_desc, persona, dx_persona_group,
	sfdc_campaign_id, f.name, f.type, f.subtype__c, f.bu_campaign__c, 
	g.opp_gross_asv,
	external_campaign, post_event_list;



/*

--------------------------------------------------------------------------------------------------------------------------------------------------------------
--NAMED LIST FOR SIGN AND ACROBAT
--Assuming that if the Product_group is NULL we can consider it in both Sign and Acrobat for now
-- Create named account list at  Sub_key x Market_area x  (Sign or Acrobat) level 
--------------------------------------------------------------------------------------------------------------------------------------------------------------
drop table mci_enterprise_stage.mn_dme_named_accounts_mod;
create table mci_enterprise_stage.mn_dme_named_accounts_mod as
select 
'sign' as new_product_group,
sub_std_name_key,
sub_name,
market_area,
concat(lower(market_area),'_sign') as join_key
from mci_enterprise_stage.ab_dme_named_accounts_market
union all 
select 
'acrobat' as new_product_group,
sub_std_name_key,
sub_name,
market_area,
concat(lower(market_area),'_acrobat') as join_key
from mci_enterprise_stage.ab_dme_named_accounts_market
where product_group in ('Acrobat + DCE + SIGN','Digital Media incl: PPBU')



--------------------------------------------------------------------------------------------------------------------------------------------------------------
--IN ECP NOT NAMED FOR SIGN AND ACROBAT 
--We may have to attach the Employee and revenue size to this
-------------------------------------------------------------------------------------------------------------------------------------------------------------
create table mci_enterprise_stage.mn_dme_not_named_ecp as
select 
'sign' as new_product_group,
sub_std_name_key,
sub_name,
market_area_description,
concat(lower(market_area_description),'_sign') as join_key
from 
( 	select 
	y.sub_std_name_key,
	y.sub_name,
	y.market_area_description,
	a.sub_std_name_key as named_sub_key 
	from ecp.hana_tap_an_rv_td_sub y
	left join 
		(
		select * 
		from  mci_enterprise_stage.mn_dme_named_accounts_mod 
		where new_product_group ='sign'
		) a
	on a.sub_std_name_key = y.sub_std_name_key
	and lower(a.market_area) = lower(y.market_area_description)
)a 
where named_sub_key is null 
union all 
select 
'acrobat' as new_product_group,
sub_std_name_key,
sub_name,
market_area_description,
concat(lower(market_area_description),'_acrobat') as join_key
from 
( 	select 
	y.sub_std_name_key,
	y.sub_name,
	y.market_area_description,
	a.sub_std_name_key as named_sub_key 
	from ecp.hana_tap_an_rv_td_sub y
	left join
	(
	select * 
	from  mci_enterprise_stage.mn_dme_named_accounts_mod 
	where new_product_group ='acrobat'
	) a
on a.sub_std_name_key = y.sub_std_name_key
and lower(a.market_area) = lower(y.market_area_description)
)a where named_sub_key is null 

*/





-------------CREATING INDIVIDUAL BASE TABLES for NAMED, NON NAMED AND NON ECP------------------

---===NAMED===---
-----------------------------------------------------------------------------------------------------------------------------------------------------------
--STEP 2 : Creating base table for DME named accouts; Adding industry, revenue range and employee size to dme_named_accounts
-----------------------------------------------------------------------------------------------------------------------------------------------------------
--drop table mci_enterprise_stage.ab_dme_named_accounts_base_wk34;
create table mci_enterprise_stage.ab_dme_named_accounts_base_wk27_32 stored as ORC
as
select 
visit_key, mcvisid,visid,surro_key, tap_sub_std_name_key, subname, pagename, email, visit_geo, geo_country, click_date, products, 
	a.market_area_description, fiscal_yr_and_wk_desc, persona, dx_persona_group,
	opp_gross_asv,
	
	coalesce(c.industry, d.tap_industry) as industry,
	coalesce(d.db_emp_range, e.emp_range, c.employee_range) as employee_range,
	--coalesce(cast(d.db_annual_sales_usd as string), e.rev_range, c.revenue_range) as revenue_range,
	coalesce(cast((case when cast(d.db_annual_sales_usd as BIGINT)<50000000 then "Less than 50M USD"
					when cast(d.db_annual_sales_usd as BIGINT)<250000000 and cast(d.db_annual_sales_usd as BIGINT)>=50000000 then "50M USD to 250M USD"
					when cast(d.db_annual_sales_usd as BIGINT)<500000000 and cast(d.db_annual_sales_usd as BIGINT)>=250000000 then "250M+ USD to 500M USD"
					when cast(d.db_annual_sales_usd as BIGINT)<1000000000 and cast(d.db_annual_sales_usd as BIGINT)>=500000000 then "500M+ USD to 1B USD"
					when cast(d.db_annual_sales_usd as BIGINT)>=1000000000 then "Over 1B USD"
					else 'Unknown' end) as string), e.rev_range, c.revenue_range) as revenue_range,
	"Named" as account_flag
from 
	--REPLACE WITH TABLE STEP 1
	mci_enterprise_stage.ab_dme_acrobatsign_base_wk27_32 a   ---add base table

--accounts IN dme_named
join mci_enterprise_stage.mn_dme_named_accounts_mod b
	on a.tap_sub_std_name_key = b.sub_std_name_key
	and lower(a.market_area_description) = lower(b.market_area)
	and lower(a.products) = lower(b.new_product_group) -- Sign /Acrobat
	
--join mci_enterprise_stage.ab_dme_named_accounts_market b
	--on a.tap_sub_std_name_key = b.sub_std_name_key
	--and lower(a.market_area_description) = lower(b.market_area)
	
--OPG table to append industry, revenue range and employee size	
left join mci_enterprise.dme_account_profile_opg c
	on a.tap_sub_std_name_key = c.sub_std_name_key
	and lower(a.market_area_description) = lower(c.market_area)
--ECP table to append industry, revenue range and employee size
left join ecp.hana_tap_an_rv_td_sub d
	on a.tap_sub_std_name_key = d.sub_std_name_key
	and lower(a.market_area_description) = lower(d.market_area_description)
--demandbase dimensions to append revenue range and employee size
left join mci_enterprise_stage.dme_demandbase_dimension e
	on a.visit_key = e.session_id

group by 
	visit_key,mcvisid,visid, surro_key, tap_sub_std_name_key, subname, pagename, email, visit_geo, geo_country, click_date,
	products, a.market_area_description, fiscal_yr_and_wk_desc, persona, dx_persona_group,
	opp_gross_asv,

	coalesce(c.industry, d.tap_industry),
	coalesce(d.db_emp_range, e.emp_range, c.employee_range),
	--coalesce(cast(d.db_annual_sales_usd), e.rev_range, c.revenue_range),
	coalesce(cast((case when cast(d.db_annual_sales_usd as BIGINT)<50000000 then "Less than 50M USD"
					when cast(d.db_annual_sales_usd as BIGINT)<250000000 and cast(d.db_annual_sales_usd as BIGINT)>=50000000 then "50M USD to 250M USD"
					when cast(d.db_annual_sales_usd as BIGINT)<500000000 and cast(d.db_annual_sales_usd as BIGINT)>=250000000 then "250M+ USD to 500M USD"
					when cast(d.db_annual_sales_usd as BIGINT)<1000000000 and cast(d.db_annual_sales_usd as BIGINT)>=500000000 then "500M+ USD to 1B USD"
					when cast(d.db_annual_sales_usd as BIGINT)>=1000000000 then "Over 1B USD"
					else 'Unknown' end) as string), e.rev_range, c.revenue_range);




---===NON NAMED===---

-----------------------------------------------------------------------------------------------------------------------------------------------------------
--STEP 3 : Creating base table for DME non-named accounts and present in ecp; Adding industry, revenue range and employee size to non-named accounts
-----------------------------------------------------------------------------------------------------------------------------------------------------------
--drop table mci_enterprise_stage.ab_dme_non_named_accounts_base_wk34;
create table mci_enterprise_stage.ab_dme_non_named_accounts_base_wk27_32 stored as ORC
as
select visit_key,mcvisid,visid, surro_key, tap_sub_std_name_key, subname, pagename, email, visit_geo, geo_country, click_date,
	products, a.market_area_description, fiscal_yr_and_wk_desc, persona, dx_persona_group,
	opp_gross_asv,

	coalesce(c.industry, y.tap_industry) as industry,
	coalesce(y.db_emp_range, d.emp_range, c.employee_range) as employee_range,
	--coalesce(y.db_annual_sales_usd, d.rev_range, c.revenue_range) as revenue_range,
	coalesce(cast((case when cast(y.db_annual_sales_usd as BIGINT)<50000000 then "Less than 50M USD"
					when cast(y.db_annual_sales_usd as BIGINT)<250000000 and cast(y.db_annual_sales_usd as BIGINT)>=50000000 then "50M USD to 250M USD"
					when cast(y.db_annual_sales_usd as BIGINT)<500000000 and cast(y.db_annual_sales_usd as BIGINT)>=250000000 then "250M+ USD to 500M USD"
					when cast(y.db_annual_sales_usd as BIGINT)<1000000000 and cast(y.db_annual_sales_usd as BIGINT)>=500000000 then "500M+ USD to 1B USD"
					when cast(y.db_annual_sales_usd as BIGINT)>=1000000000 then "Over 1B USD"
					else 'Unknown' end) as string), d.rev_range, c.revenue_range) as revenue_range,
	"Non Named" as account_flag
from 
	--REPLACE WITH TABLE STEP 1
	mci_enterprise_stage.ab_dme_acrobatsign_base_wk27_32 a
join mci_enterprise_stage.mn_dme_not_named_ecp b
	on a.tap_sub_std_name_key = b.sub_std_name_key
	and lower(a.market_area_description) = lower(b.market_area_description)
	and lower(a.products) = lower(b.new_product_group)	
	
--accounts NOT IN dme_named but present IN ECP
--left join mci_enterprise_stage.ab_dme_named_accounts_market x 
	--on a.tap_sub_std_name_key = x.sub_std_name_key
	--and lower(a.market_area_description) = lower(x.market_area)

left join ecp.hana_tap_an_rv_td_sub y
	on a.tap_sub_std_name_key = y.sub_std_name_key
	and lower(a.market_area_description) = lower(y.market_area_description)
--OPG table to append industry, revenue range and employee size
left join mci_enterprise.dme_account_profile_opg c
	on a.tap_sub_std_name_key = c.sub_std_name_key
	and lower(a.market_area_description) = lower(c.market_area)
--demandbase dimensions to append revenue range and employee size
left join mci_enterprise_stage.dme_demandbase_dimension d
	on a.visit_key = d.session_id

--where x.sub_std_name_key is null and y.sub_std_name_key is not null

group by 
	visit_key,mcvisid,visid, surro_key, tap_sub_std_name_key, subname, pagename, email, visit_geo, geo_country, click_date,
	products, a.market_area_description, fiscal_yr_and_wk_desc, persona, dx_persona_group,
	opp_gross_asv,

	coalesce(c.industry, y.tap_industry),
	coalesce(y.db_emp_range, d.emp_range, c.employee_range),
	--coalesce(y.db_annual_sales_usd, d.rev_range, c.revenue_range)
	coalesce(cast((case when cast(y.db_annual_sales_usd as BIGINT)<50000000 then "Less than 50M USD"
					when cast(y.db_annual_sales_usd as BIGINT)<250000000 and cast(y.db_annual_sales_usd as BIGINT)>=50000000 then "50M USD to 250M USD"
					when cast(y.db_annual_sales_usd as BIGINT)<500000000 and cast(y.db_annual_sales_usd as BIGINT)>=250000000 then "250M+ USD to 500M USD"
					when cast(y.db_annual_sales_usd as BIGINT)<1000000000 and cast(y.db_annual_sales_usd as BIGINT)>=500000000 then "500M+ USD to 1B USD"
					when cast(y.db_annual_sales_usd as BIGINT)>=1000000000 then "Over 1B USD"
					else 'Unknown' end) as string), d.rev_range, c.revenue_range);
					



---===NON ECP===---
-----------------------------------------------------------------------------------------------------------------------------------------------------------
--STEP 4 : Creating base table for DME accounts not present in ecp; Adding industry, revenue range and employee size to non-ecp accounts
-----------------------------------------------------------------------------------------------------------------------------------------------------------
--drop table mci_enterprise_stage.ab_dme_non_ecp_accounts_base_wk34 ;
create table mci_enterprise_stage.ab_dme_non_ecp_accounts_base_wk27_32  stored as ORC
as
select visit_key,mcvisid,visid, surro_key, tap_sub_std_name_key, subname, pagename, email, visit_geo, geo_country, click_date, products, 
a.market_area_description, fiscal_yr_and_wk_desc, persona, dx_persona_group, opp_gross_asv,

	coalesce(c.industry, d.industry) as industry,
	coalesce(c.emp_range, d.employee_range) as employee_range,
	coalesce(c.rev_range, d.revenue_range) as revenue_range,
	"Non ECP" as account_flag
from 
	--REPLACE WITH TABLE STEP 1
	mci_enterprise_stage.ab_dme_acrobatsign_base_wk27_32 a 
--accounts NOT IN ECP
left join ecp.hana_tap_an_rv_td_sub b
	on a.tap_sub_std_name_key = b.sub_std_name_key
	and lower(a.market_area_description) = lower(b.market_area_description)
--using demandbase to fetch industry, emp size, rev range
left join mci_enterprise_stage.dme_demandbase_dimension c 
	on trim(a.visit_key) = trim(c.session_id)
--OPG table to append industry, revenue range and employee size
left join mci_enterprise.dme_account_profile_opg d
	on a.tap_sub_std_name_key = d.sub_std_name_key
	and lower(a.market_area_description) = lower(d.market_area)
	
where b.sub_std_name_key is null

group by 
	visit_key,mcvisid,visid, surro_key, tap_sub_std_name_key, subname, pagename, email, visit_geo, geo_country, click_date,
	products, a.market_area_description, fiscal_yr_and_wk_desc, persona, dx_persona_group,
	opp_gross_asv,

	coalesce(c.industry, d.industry),
	coalesce(c.emp_range, d.employee_range),
	coalesce(c.rev_range, d.revenue_range);





-----------------------------------------------------------------------------------------------------------------------------------------------------------
--STEP 5 : Combining Named, Non Named and Non ECP into a single table
-----------------------------------------------------------------------------------------------------------------------------------------------------------
--WEEK 26
--drop table  mci_enterprise_stage.ab_dmedashboard_summary_prefinal_wk34;
create table mci_enterprise_stage.ab_dmedashboard_summary_prefinal_wk27_32 stored as ORC 
as
select a.*
from mci_enterprise_stage.ab_dme_named_accounts_base_wk27_32 a  --TABLE FROM STEP 2
union all
select b.*
from mci_enterprise_stage.ab_dme_non_named_accounts_base_wk27_32 b   --TABLE FROM STEP 3
union all
select c.*
from mci_enterprise_stage.ab_dme_non_ecp_accounts_base_wk27_32 c   --TABLE FROM STEP 4




-----------------------------------------------------------------------------------------------------------------------------------------------------------
----AGGREGATION FOR PBI
-----------------------------------------------------------------------------------------------------------------------------------------------------------
--WEEK 26
--from table: step2 + step3 + step4 = mci_enterprise_stage.ab_dmedashboard_summary_prefinal_0106
--creating table to push into historic = mci_enterprise_stage.ab_dmedashboard_summary_0106
drop table mci_enterprise_stage.ab_dmedashboard_summary_wk34;
create table mci_enterprise_stage.ab_dmedashboard_summary_wk35 stored as ORC
as
select
count(distinct visit_key) as total_visits,
count(pagename) as total_pageviews,
count(email) as total_contacts,
count(distinct (case when a.email is not null then a.email end)) as valid_contacts,
count(case when a.email is not null then a.pagename end) as valid_pageviews,
a.tap_sub_std_name_key,
a.subname,
case when a.products='Sign' then 'Sign Only' else 'Acrobat' end as product,
a.visit_geo,
a.geo_country,
a.market_area_description,
a.fiscal_yr_and_wk_desc,
a.persona,
a.dx_persona_group,
a.industry,
a.employee_range,
a.revenue_range,
a.account_flag
from
	--RELPACE TABLE FROM STEP 5--
    mci_enterprise_stage.ab_dmedashboard_summary_prefinal_wk35 a
group by 
a.tap_sub_std_name_key,
a.subname,
case when a.products='Sign' then 'Sign Only' else 'Acrobat' end,
a.visit_geo,
a.geo_country,
a.market_area_description,
a.fiscal_yr_and_wk_desc,
a.persona,
a.dx_persona_group,
a.industry,
a.employee_range,
a.revenue_range,
a.account_flag;




-----------------------------------------------------------------------------------------------------------------------------------------------------------
--INSERT combined(named + nonnamed + nonecp) into summary (final) table
-----------------------------------------------------------------------------------------------------------------------------------------------------------
set hive.exec.dynamic.partition.mode=nonstrict;
--overwrite with following week
insert overwrite table mci_enterprise_stage.ab_dmedashboard_summary
PARTITION (fiscal_yr_and_wk_desc)
select
    total_visits,
	total_pageviews,
	total_contacts,
	valid_contacts,
	valid_pageviews,
	tap_sub_std_name_key,
	subname,
	product,
	visit_geo,
	geo_country,
	market_area_description,
	--partition column always goes last
	persona,
	dx_persona_group,
	industry,
	employee_range,
	revenue_range,
	account_flag,
	fiscal_yr_and_wk_desc   --mention partition column in ALWAYS LAST in the select list
--REPLACE TABLE AFTER AGGREGATING FOR PBI
from mci_enterprise_stage.ab_dmedashboard_summary_wk35  --has all data until week25, replace with tables from following weeks

where fiscal_yr_and_wk_desc = '2020-35'
--where fiscal_yr_and_wk_desc is not null



