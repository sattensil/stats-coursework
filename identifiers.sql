--------------------------------------------------------
-- Identifiers
--------------------------------------------------------
create temporary function LKP_REAL as 'com.mci.hive.udfs.LKP_ORIGINAL';

--recent mcvisids
drop table mci_enterprise_stage.sa_mcvisid;
create table mci_enterprise_stage.sa_mcvisid as
select distinct * from 
(select g.mcvisid from mcietl.web_visits_detailed  g 
				where g.report_suite='adbadobenonacdcprod' 
				and g.mcvisid <> '00000000000000000000000000000000000000'
				and g.click_date >= '2020-07-01'
union all
select g.mcvisid from mcietl.web_visitor_base_v2 g where g.click_date >= '2020-07-01'
)z;

--guids from detailed last year

create table mci_enterprise_stage.sa_mcvisid_guid_01_a as
	select distinct g.mcvisid, LKP_REAL(v.member_guid_in_session,'guid') guid 
	from mci_enterprise_stage.sa_mcvisid g
		inner join mcietl.web_visits_detailed  v 
			on g.mcvisid = v.mcvisid
		where v.report_suite='adbadobenonacdcprod' 
			and v.click_date >= '2019-01-01'
			and v.member_guid_in_session is not null
			and v.member_guid_in_session <> 'Unknown'
;	

create table mci_enterprise_stage.sa_mcvisid_guid_01_b as
	select distinct g.mcvisid, LKP_REAL(v.subscription_guid,'guid') guid 
	from mci_enterprise_stage.sa_mcvisid g
		inner join mcietl.web_visits_detailed  v 
			on g.mcvisid = v.mcvisid
		where v.report_suite='adbadobenonacdcprod' 
			and v.click_date >= '2019-01-01'
			and v.subscription_guid is not null
			and v.subscription_guid <> 'Unknown'
;		

create table mci_enterprise_stage.sa_mcvisid_guid_01_c as
	select distinct g.mcvisid, LKP_REAL(v.member_guid,'guid') guid  
	from mci_enterprise_stage.sa_mcvisid  g 
		inner join mcietl.web_visits_detailed  v 
			on g.mcvisid = v.mcvisid
		where v.report_suite='adbadobenonacdcprod' 
			and v.click_date >= '2019-01-01'
			and v.member_guid is not null
			and v.member_guid <> 'Unknown' 
			and v.subscription_guid <> v.member_guid
			and v.member_guid <> v.member_guid_in_session
;
create table mci_enterprise_stage.sa_mcvisid_guid_01_d as
	select distinct g.mcvisid, LKP_REAL(v.user_guid,'guid') guid  
	from mci_enterprise_stage.sa_mcvisid  g 
		inner join mcietl.web_visitor_base_v2 v 
			on g.mcvisid = v.mcvisid
		where v.click_date >= '2019-01-01'
			and v.user_guid is not null
			and v.user_guid<> 'Unknown' 
;

drop table mci_enterprise_stage.sa_mcvisid_guid_01;
create table mci_enterprise_stage.sa_mcvisid_guid_01 as --
select distinct * from (
select * from mci_enterprise_stage.sa_mcvisid_guid_01_a
union all 
select * from mci_enterprise_stage.sa_mcvisid_guid_01_b
union all 
select * from mci_enterprise_stage.sa_mcvisid_guid_01_c
union all 
select * from mci_enterprise_stage.sa_mcvisid_guid_01_d
)z;

--guids emails and cookies
create table mci_enterprise_stage.sa_mcvisid_guid_02 as
select m.mcvisid
	,UPPER(g.guid) guid
	,v.mch_cookie 
	,v.email
	,v.sfdc_id as contact_id
from mci_enterprise_stage.sa_mcvisid m
left join mci_enterprise_stage.sa_mcvisid_guid_01  g 
	on g.mcvisid = m.mcvisid
left join (select mcvisid,substr(v.faas_submission_id,22,34) as mch_cookie, v.email, v,sfdc_id from mcietl.web_visitor_base_v2  v where v.click_date >= '2019-01-01' and  v.faas_submission_id is not null) v
	on m.mcvisid = v.mcvisid
where g.guid is not null or v.mch_cookie is not null or v.email is not null
;

--guid to email - Jason extract
drop TABLE mci_enterprise_stage.sa_jason_email_guid;
CREATE TABLE mci_enterprise_stage.sa_jason_email_guid
    (visid string
	,post_evar12 string
	,pers_email string)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',';

LOAD DATA INPATH '/data/warehouse/mci_enterprise_stage/emails.csv'
OVERWRITE INTO TABLE mci_enterprise_stage.sa_jason_email_guid;


--add in all email sources
create table mci_enterprise_stage.sa_email_guid_03 as
select distinct * from (
	select 
	v.mcvisid
	,v.guid
	,v.mch_cookie 
	,v.email
	from  mci_enterprise_stage.sa_mcvisid_guid_02 v
union all select 
	v.mcvisid
	,v.guid
	,v.mch_cookie 
	,a.email
	from  mci_enterprise_stage.sa_mcvisid_guid_02 v
	inner join (select distinct email,token from mci_enterprise_stage.sa_api_02 where email is not null) a
		on v.mch_cookie = a.token
union all select 
	v.mcvisid
	,v.guid
	,v.mch_cookie 
	,c.email
	from  mci_enterprise_stage.sa_mcvisid_guid_02 v
	inner join (select distinct email,token,sfdc_contact_id from mci_enterprise_stage.sa_api_02 where email is not null) a
		on v.mch_cookie = a.token
	inner join mci_enterprise_stage.abm_sfdc_contacts_mapped c
		on upper(coalesce(v.contact_id,a.sfdc_contact_id)) = upper(c.contactid)
		and c.email is not null
union all select 
	v.mcvisid
	,v.guid
	,v.mch_cookie 
	,cc.email
	from  mci_enterprise_stage.sa_mcvisid_guid_02 v
	inner join mci_enterprise.abm_enterprise_contact cc
		on upper(cc.sf_contact_id) = upper(v.contact_id)
		and cc.email is not null
union all select 
	v.mcvisid
	,v.guid
	,v.mch_cookie 
	,cg.email
	from  mci_enterprise_stage.sa_mcvisid_guid_02 v
	inner join mci_enterprise.abm_enterprise_contact cg
		on upper(cg.user_guid) = upper(guid)
		and cg.email is not null
union all select 
	v.mcvisid
	,v.guid
	,v.mch_cookie 
	,p.pers_email as email
	from  mci_enterprise_stage.sa_mcvisid_guid_02 v
	inner join mci_enterprise_stage.okui_lvt_profile_sample p --warehouse.dim_user_lvt_profile 
		on upper(p.event_guid) =  upper(v.guid)
		and p.pers_email is not null
)z;	
		
		
drop mci_enterprise_stage.sa_email_guid_04; --
create table mci_enterprise_stage.sa_email_guid_04 as
select distinct 
mcvisid
,case when guid = 'Unknown' then null else upper(guid) end guid
,email
,mch_cookie from mci_enterprise_stage.sa_email_guid_03 
;

--most frequent email by mcvisid
drop mci_enterprise_stage.sa_email_guid_05; --
create table mci_enterprise_stage.sa_email_guid_05 as
select mcvisid, email as freq_email_by_mcvisid
from (select mcvisid, email, row_number() over (partition by mcvisid order by cnt desc) as seqnum
      from (select mcvisid, email, count(*) as cnt from mci_enterprise_stage.sa_email_guid_04 where email is not null
      group by mcvisid, email) z )z
where seqnum = 1;

--most frequent mcvisid by guid
drop mci_enterprise_stage.sa_email_guid_06; --
select guid, mcvisid as freq_mcvisid_by_guid
from (select guid, mcvisid, row_number() over (partition by guid order by cnt desc) as seqnum
      from (select guid, mcvisid, count(*) as cnt from mci_enterprise_stage.sa_email_guid_04 where mcvisid is not null
      group by guid, mcvisid) z )z
where seqnum = 1;  

drop mci_enterprise_stage.sa_email_guid_final; --
create table mci_enterprise_stage.sa_email_guid_final as
select distinct 
g.mcvisid
,g.guid
,g.email
,g.contact_id
,g.mch_cookie 
,e.freq_email_by_mcvisid
,b.freq_mcvisid_by_guid
from mci_enterprise_stage.sa_email_guid_04 g
left join mci_enterprise_stage.sa_email_guid_05 e
	on g.mcvisid = e.mcvisid
left join mci_enterprise_stage.sa_email_guid_06 b
	on g.guid = b.guid
;

