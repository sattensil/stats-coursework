











drop table gedi_dev.sign_account_bridge;
create table gedi_dev.sign_account_bridge as 
select 
a.sign_sfdc_account_id,
a.sign_sfdc_account_name,
a.sign_sfdc_account_name_cleaned,
a.corporate_sfdc_account_id,
a.geo,
coalesce(a.sub_std_name_key,b.sub_std_name_key,c.sub_std_name_key,d.sub_std_name_key) as sub_std_name_key,
coalesce(a.prnt_std_name_key,b.prnt_std_name_key) as prnt_std_name_key

from gedi_dev.sign_midmarket_opportunities_std a

left join mci_enterprise.global_brdg_ecp_acctid b
on a.corporate_sfdc_account_id = b.sfdc_account_id

left join ecp.hana_tap_rv_td_brdg_org_ecc c
on a.ecc_id = c.ecc_id 

left join mci_enterprise.sops_rv_td_sub_std d
on a.naics_id = d.naics_code

left join mci_enterprise_stage.vk_ecp_sub_domain_all_comb_vf e 
on lower(trim(a.domain)) = lower(trim(e.website_domain))




group by 
a.id,
a.AccountID18Digit__c,
a.sign_sfdc_account_name,
a.corp_sfdc_account_id,
a.geo,
a.sub_name,
coalesce(a.sub_key,b.sub_std_name_key,c.sub_std_name_key,d.sub_std_name_key),
a.prnt_name,
coalesce(a.prnt_key,b.prnt_std_name_key) 

--select count(distinct id) from gedi_dev.sign_account_bridge
-- 1982

--select count(distinct id) from gedi_dev.sign_account_bridge
--where sub_std_name_key !='NULL'
-- 246

describe mci_enterprise.sops_rv_td_sub_std;


