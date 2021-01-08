--Code enhancements:
--1) Fixed bug introduced due to warehouse.country join (bug triplicates the data)
--2) Fixed taxonomy to align with GTM DMe Team (Jorge's team)
--3) Fixed: pull in Demandbase industry and revenue range (added Demandbase profile attributes)
--4) New: added Sign install base
--5) Fixed: named segment to only pull in Americas

--------------------------------------------------------------------------------------------------
--Mental model/code flow to build Sign web data set
--1) Create "web visitor base v2 subset" - filtered with Sign pages and analysis time frame
--2) Standardize "web visitor base v2 subset" - fiscal_yr_and_wk_desc and market_area_description
--3) Append profile attributes to "web visitor base v2 subset" with:
--      1) DME Sign List
--      2) ECP Profile (Industry, Employee Size Range)
--      3) Demandbase Profile (Industry, Employee Size Range, Revenue Range)
--      4) ABX Profile (Industry, Employee Size, Revenue Range)
--4) Apply segmentation rules and other profile attributes for analysis
--      1) GTM Segment: Enterprise, Mid-Market, CSMB/Unidentified, Gov
--      2) Industry Group: GOV, EDU, COM
--      3) Account Type: New vs Existing
--            a) Build Sign install base
--      4) License Type: ETLA, VIP, etc. (future enhancement)
--      5) Competitive Installs: future enhancement
--      6) CGEN codes from parsed URL (Scarlett's table); to add still
--            a) table: mci_enterprise_stage.sa_00
--            b) column: cgen_campaign
--      7) Sign trial page flag Y/N
--------------------------------------------------------------------------------------------------


--1) Create "web visitor base v2 subset" - filtered with Sign pages and analysis time frame
CREATE TABLE mci_enterprise.cd_web_visitor_base_sign_subset
STORED AS ORC tblproperties( "orc.compress" = "SNAPPY", "serialization.null.format" = "") AS
SELECT *
FROM mcietl.web_visitor_base_v2
--Sign pages defined by the web team (8/21/2020)
WHERE click_date >= '2020-02-29'
   and click_date <= '2020-08-14'
   and market_area_Code ='US'
   and
   --Sign pages defined by the web team (8/21/2020)
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
;

--2) Standardize "web visitor base v2 subset"
drop table mci_enterprise.cd_web_visitor_base_sign_subset_std
CREATE TABLE mci_enterprise.cd_web_visitor_base_sign_subset_std
STORED AS ORC tblproperties( "orc.compress" = "SNAPPY", "serialization.null.format" = "") AS
SELECT a.click_date
   ,coalesce(pagename,post_pagename,custom_link_page_name) pagename
   ,surro_key
   ,visit_key
   ,mcvisid
   ,tap_sub_std_name_key sub_std_name_key

   --IDs for profile appends
   ,faas_submission_id
   --,email                     -- removed for privacy; can add back if really needed
   ,user_guid                   -- used to hook into C-Stack
   --,sfdc_id
   ,dun_bradstreet_tracking_1   --for future enhancement
   ,dun_bradstreet_tracking_2   --for future enhancement
   ,demandbase_sid
   --,demandbase_company_name
   --,demandbase_domain
   ,audience_manager_uuid       --for future enhancement

   --referral attributes
   ,custom_marketing_channel
   ,cgen_marketing_vehicle
   ,external_campaign
   ,post_social_id

   ,b.fiscal_yr_and_wk_desc
   ,c.market_area_description
FROM mci_enterprise.cd_web_visitor_base_sign_subset a
   INNER JOIN sourcedata.dim_date b on a.click_date = b.date_date
   INNER JOIN warehouse.country c on lower(a.market_area_code) = lower(c.market_area_code)
      and c.country_code_iso2 = 'US'
;


--3) Append profile attributes to "web visitor base v2 subset" with:
--      1) DME Sign List
--      2) ECP Profile
--      3) Demandbase Profile
--      4) ABX Profile
DROP TABLE mci_enterprise.cd_web_visitor_base_sign_ext;
CREATE TABLE mci_enterprise.cd_web_visitor_base_sign_ext
STORED AS ORC tblproperties( "orc.compress" = "SNAPPY", "serialization.null.format" = "") AS
SELECT a.*
   ,CASE WHEN b.sub_std_name_key is not null THEN 1 ELSE 0 END dme_sign_named
   ,c.tap_industry as ecp_industry
   ,c.db_emp_range as ecp_db_emp_range
   ,d.demandbase_industry_std
   ,d.demandbase_employee_range_std
   ,d.demandbase_revenue_range_std
   ,e.industry abx_industry
   ,e.employee_range abx_employee_range
   ,e.revenue_range abx_revenue_range
FROM mci_enterprise.cd_web_visitor_base_sign_subset_std a
   LEFT OUTER JOIN
   (
     SELECT sub_std_name_key
     FROM mci_enterprise.dme_named_accounts
     WHERE product_group in ('Digital Media incl: PPBU','SIGN')
        and rep_global_region = 'AMERICAS'
     GROUP BY sub_std_name_key
   ) b on a.sub_std_name_key = b.sub_std_name_key
   LEFT OUTER JOIN ecp.hana_tap_an_rv_td_sub c on a.sub_std_name_key = c.sub_std_name_key
      and lower(a.market_area_description) = lower(c.market_area_description)
   LEFT OUTER JOIN mci_enterprise.cd_demandbase_profile d on a.demandbase_sid = d.demandbase_sid
   LEFT OUTER JOIN
   (
     SELECT sub_std_name_key
        ,industry
        ,employee_range
        ,revenue_range
     FROM mci_enterprise.abm_enterprise_account_profile_dme
     WHERE geo = 'AMERICAS'
     GROUP BY sub_std_name_key
        ,industry
        ,employee_range
        ,revenue_range
   ) e on a.sub_std_name_key = e.sub_std_name_key
;


CREATE TABLE mci_enterprise.dme_account_status_sign
STORED AS ORC tblproperties ("orc.compress"="SNAPPY") as
SELECT a.geo
   ,a.market_area
   ,a.sub_std_name_key
   ,sum(opg_arr) dme_arr_total
   --,case when sum(opg_arr) <> 0 then 'Install Base' else 'New Logo' end dme_account_status
   ,case when sum(opg_arr) <> 0 then 'Y' else 'N' end sign_active
FROM  mci_enterprise.dme_account_sops_profile_sub a
WHERE major_opg1 = 'SIGN'
GROUP BY a.geo
   ,a.market_area
   ,a.sub_std_name_key
;


--4) Apply segmentation rules and other profile attributes for analysis
--      1) GTM Segment: Gov (ECP=Gov or Demandbase Industry=Gov), Enterprise (named only), Mid-Market (100+ employees), CSMB/Unidentified
--      2) Industry Group: GOV, EDU, COM
--      3) Account Type: New vs Existing
--            a) Build Sign install base
--      4) License Type: ETLA, VIP, etc. (future enhancement)
--      5) Competitive Installs: future enhancement
--      6) CGEN codes from parsed URL (Scarlett's table);
--            a) table: mci_enterprise_stage.sa_00
--            b) column: cgen_campaign
--      7) Sign trial page flag Y/N
DROP TABLE mci_enterprise.cd_sign_web_data_raw;
CREATE TABLE mci_enterprise.cd_sign_web_data_raw
STORED AS ORC tblproperties( "orc.compress" = "SNAPPY", "serialization.null.format" = "") AS
SELECT a.*
   --GTM Segment: Gov, Enterprise, Mid-Market, CSMB/Unidentified
   ,CASE WHEN COALESCE(abx_industry, ecp_industry, demandbase_industry_std) IN ('Government - Federal','Government - Local','Government - Military','Government - State','Government') THEN 'GOV'
         WHEN COALESCE(dme_sign_named,0) = 1 THEN 'Enterprise'
         WHEN COALESCE(abx_employee_range, ecp_db_emp_range, demandbase_employee_range_std) IN ('100-499','500-999','1000-4999','5000+','> 1K','> 3K','> 5K','> 5k','> 10K','>10K','>10k') THEN 'Mid-Market' --100+
         ELSE 'CSMB/Unidentified' END gtm_segment
   --Industry Group: GOV, EDU, COM
   ,CASE WHEN COALESCE(abx_industry, ecp_industry, demandbase_industry_std) IN ('Government - Federal','Government - Local','Government - Military','Government - State','Government') THEN 'GOV'
         WHEN COALESCE(abx_industry, ecp_industry, demandbase_industry_std) IN ('Education - Higher Ed','Education - K12','Education') THEN 'EDU'
         WHEN COALESCE(abx_industry, ecp_industry, demandbase_industry_std) IS NOT NULL THEN 'COM'
         ELSE 'UNKNOWN' END industry_group
   ,coalesce(sign_active,'N') sign_active
   ,coalesce(dme_arr_total,0) sign_arr
   --,cgen_campaign
   ,CASE WHEN lower(pagename) like '%acrobat.adobe.com:sign:free-trial-global%' THEN 1 ELSE 0 END sign_trial_page
FROM mci_enterprise.cd_web_visitor_base_sign_ext a
   LEFT OUTER JOIN mci_enterprise.dme_account_status_sign c on a.sub_std_name_key = c.sub_std_name_key
      and c.market_area = 'UNITED STATES'
   --LEFT OUTER JOIN mci_enterprise_stage.sa_00
;

--QA check
--11,142,776
select count(*) from mci_enterprise.cd_web_visitor_base_sign_subset

--11,142,776
select count(*) from mci_enterprise.cd_web_visitor_base_sign_subset_std

--11,142,776
select count(*) from mci_enterprise.cd_web_visitor_base_sign_ext

--11,142,776
select count(*) from mci_enterprise.cd_sign_web_data_raw

select ecp_industry, abx_industry, demandbase_industry_std, count(*) from mci_enterprise.cd_sign_web_data_raw group by ecp_industry, abx_industry, demandbase_industry_std

select ecp_db_emp_range, abx_employee_range, demandbase_employee_range_std, count(*) from mci_enterprise.cd_sign_web_data_raw group by ecp_db_emp_range, abx_employee_range, demandbase_employee_range_std

select abx_revenue_range, demandbase_revenue_range_std, count(*) from mci_enterprise.cd_sign_web_data_raw group by abx_revenue_range, demandbase_revenue_range_std




select fiscal_yr_and_wk_desc, GTM_segment, count(*) from mci_enterprise.cd_sign_web_data_raw group by fiscal_yr_and_wk_desc, GTM_segment

select fiscal_yr_and_wk_desc, GTM_segment, count(*) from mci_enterprise.cd_sign_web_data_raw where sign_trial_page = 1 group by fiscal_yr_and_wk_desc, GTM_segment
