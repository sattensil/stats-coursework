--------------------------------------------------------SIGN ANALYSIS-----------------------------------------------------------------------
--Q2 Data

--CREATE TABLE mci_enterprise_stage.mn_web_visitor_base_Q22020
DROP TABLE mci_enterprise_stage.cd_web_visitor_base_Q22020
CREATE TABLE mci_enterprise_stage.cd_web_visitor_base_Q22020
STORED AS ORC tblproperties( "orc.compress" = "SNAPPY", "serialization.null.format" = "") AS
SELECT a.click_date
   ,coalesce(pagename,post_pagename,custom_link_page_name) pagename
   ,visit_key
   ,tap_sub_std_name_key sub_std_name_key
   ,b.fiscal_yr_and_wk_desc
   ,visitor_detection_mode
   ,visitor_detection_method
FROM mcietl.web_visitor_base_v2 a
INNER JOIN sourcedata.dim_date b on a.click_date = b.date_date
WHERE click_date >= '2020-02-29'
   and click_date <= '2020-05-29'
--   and coalesce(tap_sub_std_name_key,0) > 0
   and market_area_Code ='US'
;


--Q3 Data
--CREATE TABLE mci_enterprise_stage.mn_web_visitor_base_Q32020
DROP TABLE mci_enterprise_stage.cd_web_visitor_base_Q32020;
CREATE TABLE mci_enterprise_stage.cd_web_visitor_base_Q32020
STORED AS ORC tblproperties( "orc.compress" = "SNAPPY", "serialization.null.format" = "") AS
SELECT a.click_date
   ,coalesce(pagename,post_pagename,custom_link_page_name) pagename
   ,visit_key
   ,tap_sub_std_name_key sub_std_name_key
   ,b.fiscal_yr_and_wk_desc
   ,visitor_detection_mode
   ,visitor_detection_method
FROM mcietl.web_visitor_base_v2 a
INNER JOIN sourcedata.dim_date b on a.click_date = b.date_date
WHERE click_date >= '2020-05-30'
   and click_date <= '2020-08-14' -- 14th Aug
--   and coalesce(tap_sub_std_name_key,0) > 0
   and market_area_Code ='US'
;



-----------------------ADDING IN THE TAXONOMY
--mci_enterprise_stage.ab_big_sign_campaign_taxonomy

--CREATE TABLE mci_enterprise_stage.mn_sign_visits_Q2Q3
DROP TABLE mci_enterprise_stage.cd_sign_visits_Q2Q3;
CREATE TABLE mci_enterprise_stage.cd_sign_visits_Q2Q3
STORED AS ORC tblproperties( "orc.compress" = "SNAPPY", "serialization.null.format" = "") AS
SELECT visits.*
  --,case
  --	when products in  ('Adobe Sign: Sign','DC: Adobe Sign') then 'Sign' else 'Others'
  --end as products
FROM
  (
  select * from mci_enterprise_stage.cd_web_visitor_base_Q22020 --mci_enterprise_stage.mn_web_visitor_base_Q22020
  union all
  select * from mci_enterprise_stage.cd_web_visitor_base_Q32020 --mci_enterprise_stage.mn_web_visitor_base_Q32020
  ) visits
  --join mci_enterprise_stage.ab_big_sign_campaign_taxonomy tax on lower(visits.pagename) = lower(tax.pagename)

--Sign pages defined by the web team (8/21/2020)
WHERE (pagename like '%acrobat.adobe.com:sign%'
   or pagename like 'acrobat.adobe.com:documents:%'
   or pagename like 'landing.adobe.com:products:echosign%'
   or pagename like 'echosign.acrobat.com%'
   or pagename like 'echosign.adobe.com%'
   or pagename like 'adobesigndemo%'
   or pagename like 'acrobat.adobe.com:sign:use-cases%'
   or pagename = 'acrobat.adobe.com:business:integrations:dropbox:pricing'
   or pagename like '%adobe.com%landing:sign:%')
   and not(pagename like 'adobesigndemoaccount%'
        or pagename = 'acrobat.adobe.com:sign:free-trial-global-form-a'
        or pagename = 'acrobat.adobe.com:sign:free-trial-global-form-b'
       )
;


--EXTRACT QUERY
select count (distinct visit_key),fiscal_yr_and_wk_desc as visits
from mci_enterprise_stage.cd_sign_visits_Q2Q3
--where products ='Sign'
group by fiscal_yr_and_wk_desc

select count (distinct visit_key),fiscal_yr_and_wk_desc as visits
from mci_enterprise_stage.cd_sign_visits_Q2Q3_aa
--where products ='Sign'
group by fiscal_yr_and_wk_desc


----------------------ADDING THE ACCOUNT SEGMENT
-- Ref Tables
--mci_enterprise_stage.mn_dme_named_accounts_mod - Named List
--mci_enterprise_stage.mn_dme_not_named_ecp  - MM List

CREATE TABLE mci_enterprise_stage.cd_sign_visits_segment_wise_Q2Q3
--CREATE TABLE mci_enterprise_stage.mn_sign_visits_segment_wise_Q2Q3
STORED AS ORC tblproperties( "orc.compress" = "SNAPPY", "serialization.null.format" = "") AS
select A.*
,case when B.sub_std_name_key is not null then 'Named'
      when B.sub_std_name_key is null and C.sub_std_name_key is not null then 'MM'
	  else  'CSMB'
	  end as account_segment
from
(select visit_key,sub_std_name_key,fiscal_yr_and_wk_desc from mci_enterprise_stage.cd_sign_visits_Q2Q3 --mci_enterprise_stage.mn_sign_visits_Q2Q3 where lower(products) ='sign'
	group by visit_key,sub_std_name_key,fiscal_yr_and_wk_desc)A
left join
(select sub_std_name_key
	from  mci_enterprise_stage.mn_dme_named_accounts_mod
	where new_product_group ='sign'
	and lower(market_area) ='united states'
	group by sub_std_name_key
)B
 on A.sub_std_name_key = B.sub_std_name_key
left join
(select sub_std_name_key
	from  mci_enterprise_stage.mn_dme_not_named_ecp
	where new_product_group ='sign'
	and lower(market_area_description)  = 'united states'
	group by sub_std_name_key
)C
 on A.sub_std_name_key = C.sub_std_name_key


--EXTRACT QUERY
select fiscal_yr_and_wk_desc , account_segment ,count (distinct visit_key) as visits
from mci_enterprise_stage.mn_sign_visits_segment_wise_Q2Q3
group by fiscal_yr_and_wk_desc , account_segment


--check with AA dash
select fiscal_yr_and_wk_desc, count(distinct visit_key) as visits, count(distinct surro_key) as surro_cnt, count(*) pvs
from mci_enterprise_stage.mn_sign_visits_segment_wise_Q2Q3_aa
group by fiscal_yr_and_wk_desc

describe mci_enterprise_stage.mn_sign_visits_segment_wise_Q2Q3;

 --- FOR TRIAL Visits

CREATE TABLE mci_enterprise_stage.mn_sign_trial_visits_segment_wise_Q2Q3
STORED AS ORC tblproperties( "orc.compress" = "SNAPPY", "serialization.null.format" = "") AS
select A.*
,case when B.sub_std_name_key is not null then 'Named'
      when B.sub_std_name_key is null and C.sub_std_name_key is not null then 'MM'
	  else 'CSMB'
	  end as account_segment
from
(select visit_key,sub_std_name_key,fiscal_yr_and_wk_desc from mci_enterprise_stage.mn_sign_visits_Q2Q3 where lower(products) ='sign'
	and lower(pagename) like '%acrobat.adobe.com:sign:free-trial-global%'
	group by visit_key,sub_std_name_key,fiscal_yr_and_wk_desc
	)A
left join
(select sub_std_name_key
	from  mci_enterprise_stage.mn_dme_named_accounts_mod
	where new_product_group ='sign'
	and lower(market_area) ='united states'
	group by sub_std_name_key
)B
 on A.sub_std_name_key = B.sub_std_name_key
left join
(select sub_std_name_key
	from  mci_enterprise_stage.mn_dme_not_named_ecp
	where new_product_group ='sign'
	and lower(market_area_description)  = 'united states'
	group by sub_std_name_key
)C
 on A.sub_std_name_key = C.sub_std_name_key


 --EXTRACT QUERY
select fiscal_yr_and_wk_desc , account_segment ,count (distinct visit_key) as visits
from mci_enterprise_stage.mn_sign_trial_visits_segment_wise_Q2Q3
 group by fiscal_yr_and_wk_desc , account_segment
