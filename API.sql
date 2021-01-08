-- Historic Data
drop TABLE mci_enterprise_stage.sa_api_02;
CREATE TABLE mci_enterprise_stage.sa_api_02
    (token string
	,lead_person_id string
    ,email string
    ,sfdc_contact_id string
    ,sfdc_contact_account_id string)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',';

LOAD DATA INPATH '/data/warehouse/mci_enterprise_stage/File1_0_130000000.csv' --878,546
OVERWRITE INTO TABLE mci_enterprise_stage.sa_api_02;
select count(*) from  mci_enterprise_stage.sa_api_02;
 
LOAD DATA INPATH '/data/warehouse/mci_enterprise_stage/File2_130000001_132500000.csv' --1,820,799
INTO TABLE mci_enterprise_stage.sa_api_02;
 
LOAD DATA INPATH '/data/warehouse/mci_enterprise_stage/File3_132500001_133500000.csv' --2,782,162
INTO TABLE mci_enterprise_stage.sa_api_02;
 
LOAD DATA INPATH '/data/warehouse/mci_enterprise_stage/File4_133500001_134500000.csv' --3,745,674
INTO TABLE mci_enterprise_stage.sa_api_02;
 
LOAD DATA INPATH '/data/warehouse/mci_enterprise_stage/File5_134500001_135500000.csv' --4,704,524
INTO TABLE mci_enterprise_stage.sa_api_02;
 
LOAD DATA INPATH '/data/warehouse/mci_enterprise_stage/File6_135500001_max.csv' --5,006,023
INTO TABLE mci_enterprise_stage.sa_api_02;

LOAD DATA INPATH '/data/warehouse/mci_enterprise_stage/load.csv' --5,007,492
INTO TABLE mci_enterprise_stage.sa_api_02;

-- Pull cookies send to API
drop table mci_enterprise_stage.sa_api_01;
create table mci_enterprise_stage.sa_api_01 as
SELECT distinct 
v.mch_cookie as id
FROM mci_enterprise_stage.sa_00 v
left join (select distinct token from  mci_enterprise_stage.sa_api_02 where email is not null) t
    on t.token = v.mch_cookie
WHERE v.faas_submission_id like 'token:_mch-adobe.com%'
and t.token is null

select count(*) from mci_enterprise_stage.sa_api_01 --34,732


