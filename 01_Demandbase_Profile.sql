----
--Builds a Demandbase Profile table: profile attributes by Demandbase ID and domain
----

--Presto query
--CREATE TABLE IF NOT EXISTS mci_enterprise.cd_demandbase_raw COMMENT 'demandbase raw data' WITH
--(
--   format = 'ORC'
   --,partitioned_by = click_date
--)
--AS
--(
--select demandbase_51
--   ,demandbase_52
--   ,cast(split(demandbase_51, '[\:]')[0] as bigint)  as demandbase_sid
--   ,split(demandbase_51, '[\:]')[1]  as demandbase_company_name
--   ,split(demandbase_51, '[\:]')[2]  as demandbase_industry
--   ,split(demandbase_52, '[\:]')[0]  as demandbase_domain
--from mcietl.web_visits_detailed
--where cast(click_date as date) >= date'2020-02-29'
--   and cast(click_date as date) <= date'2020-08-14'
--   and report_suite = 'adbadobenonacdcprod'
--   and demandbase_51 is not null
--) WITH DATA

--Hive Demandbase raw table
--runs ~13-15 minutes each table
CREATE TABLE mci_enterprise.cd_demandbase_raw_hive1
STORED AS ORC tblproperties( "orc.compress" = "SNAPPY", "serialization.null.format" = "") AS
SELECT demandbase_51
  ,demandbase_52
  ,cast(split(demandbase_51, '[\:]')[0] as bigint)  as demandbase_sid
  ,split(demandbase_51, '[\:]')[1]  as demandbase_company_name
  ,split(demandbase_51, '[\:]')[2]  as demandbase_industry
  ,split(demandbase_52, '[\:]')[0]  as demandbase_domain
FROM mcietl.web_visits_detailed
WHERE cast(click_date as date) >= date'2020-02-29'
  and cast(click_date as date) < date'2020-03-28'
  and report_suite = 'adbadobenonacdcprod'
  and demandbase_51 is not null
;

CREATE TABLE mci_enterprise.cd_demandbase_raw_hive2
STORED AS ORC tblproperties( "orc.compress" = "SNAPPY", "serialization.null.format" = "") AS
SELECT demandbase_51
   ,demandbase_52
   ,cast(split(demandbase_51, '[\:]')[0] as bigint)  as demandbase_sid
   ,split(demandbase_51, '[\:]')[1]  as demandbase_company_name
   ,split(demandbase_51, '[\:]')[2]  as demandbase_industry
   ,split(demandbase_52, '[\:]')[0]  as demandbase_domain
FROM mcietl.web_visits_detailed
WHERE cast(click_date as date) >= date'2020-03-28'
   and cast(click_date as date) < date'2020-04-25'
   and report_suite = 'adbadobenonacdcprod'
   and demandbase_51 is not null
;

CREATE TABLE mci_enterprise.cd_demandbase_raw_hive3
STORED AS ORC tblproperties( "orc.compress" = "SNAPPY", "serialization.null.format" = "") AS
SELECT demandbase_51
  ,demandbase_52
  ,cast(split(demandbase_51, '[\:]')[0] as bigint)  as demandbase_sid
  ,split(demandbase_51, '[\:]')[1]  as demandbase_company_name
  ,split(demandbase_51, '[\:]')[2]  as demandbase_industry
  ,split(demandbase_52, '[\:]')[0]  as demandbase_domain
FROM mcietl.web_visits_detailed
WHERE cast(click_date as date) >= date'2020-04-25'
  and cast(click_date as date) < date'2020-05-30'
  and report_suite = 'adbadobenonacdcprod'
  and demandbase_51 is not null
;

CREATE TABLE mci_enterprise.cd_demandbase_raw_hive4
STORED AS ORC tblproperties( "orc.compress" = "SNAPPY", "serialization.null.format" = "") AS
SELECT demandbase_51
   ,demandbase_52
   ,cast(split(demandbase_51, '[\:]')[0] as bigint)  as demandbase_sid
   ,split(demandbase_51, '[\:]')[1]  as demandbase_company_name
   ,split(demandbase_51, '[\:]')[2]  as demandbase_industry
   ,split(demandbase_52, '[\:]')[0]  as demandbase_domain
   --,click_date
FROM mcietl.web_visits_detailed
WHERE cast(click_date as date) >= date'2020-05-30'
   and cast(click_date as date) < date'2020-06-27'
   and report_suite = 'adbadobenonacdcprod'
   and demandbase_51 is not null
;

CREATE TABLE mci_enterprise.cd_demandbase_raw_hive5
STORED AS ORC tblproperties( "orc.compress" = "SNAPPY", "serialization.null.format" = "") AS
SELECT demandbase_51
  ,demandbase_52
  ,cast(split(demandbase_51, '[\:]')[0] as bigint)  as demandbase_sid
  ,split(demandbase_51, '[\:]')[1]  as demandbase_company_name
  ,split(demandbase_51, '[\:]')[2]  as demandbase_industry
  ,split(demandbase_52, '[\:]')[0]  as demandbase_domain
  --,click_date
FROM mcietl.web_visits_detailed
WHERE cast(click_date as date) >= date'2020-06-27'
  and cast(click_date as date) < date'2020-07-25'
  and report_suite = 'adbadobenonacdcprod'
  and demandbase_51 is not null
;

CREATE TABLE mci_enterprise.cd_demandbase_raw_hive6
STORED AS ORC tblproperties( "orc.compress" = "SNAPPY", "serialization.null.format" = "") AS
SELECT demandbase_51
  ,demandbase_52
  ,cast(split(demandbase_51, '[\:]')[0] as bigint)  as demandbase_sid
  ,split(demandbase_51, '[\:]')[1]  as demandbase_company_name
  ,split(demandbase_51, '[\:]')[2]  as demandbase_industry
  ,split(demandbase_52, '[\:]')[0]  as demandbase_domain
  --,click_date
FROM mcietl.web_visits_detailed
WHERE cast(click_date as date) >= date'2020-07-25'
  and cast(click_date as date) < date'2020-08-15'
  and report_suite = 'adbadobenonacdcprod'
  and demandbase_51 is not null
;

--runs for ~6minutes each table
CREATE TABLE mci_enterprise.cd_demandbase_raw_hive1_unq
STORED AS ORC tblproperties( "orc.compress" = "SNAPPY", "serialization.null.format" = "") AS
SELECT demandbase_sid
   ,demandbase_company_name
   ,demandbase_industry
   ,split(demandbase_51, '[\:]')[3]  as demandbase_sub_industry1
   ,split(demandbase_51, '[\:]')[4]  as demandbase_employee_range
   ,split(demandbase_51, '[\:]')[5]  as demandbase_revenue_range
   ,split(demandbase_51, '[\:]')[6]  as demandbase_business_type
   ,split(demandbase_51, '[\:]')[7]  as demandbase_sub_industry2
   ,demandbase_domain
FROM mci_enterprise.cd_demandbase_raw_hive1
WHERE demandbase_sid is not null
GROUP BY demandbase_sid
   ,demandbase_company_name
   ,demandbase_industry
   ,split(demandbase_51, '[\:]')[3]
   ,split(demandbase_51, '[\:]')[4]
   ,split(demandbase_51, '[\:]')[5]
   ,split(demandbase_51, '[\:]')[6]
   ,split(demandbase_51, '[\:]')[7]
   ,demandbase_domain
;

CREATE TABLE mci_enterprise.cd_demandbase_raw_hive2_unq
STORED AS ORC tblproperties( "orc.compress" = "SNAPPY", "serialization.null.format" = "") AS
SELECT demandbase_sid
   ,demandbase_company_name
   ,demandbase_industry
   ,split(demandbase_51, '[\:]')[3]  as demandbase_sub_industry1
   ,split(demandbase_51, '[\:]')[4]  as demandbase_employee_range
   ,split(demandbase_51, '[\:]')[5]  as demandbase_revenue_range
   ,split(demandbase_51, '[\:]')[6]  as demandbase_business_type
   ,split(demandbase_51, '[\:]')[7]  as demandbase_sub_industry2
   ,demandbase_domain
FROM mci_enterprise.cd_demandbase_raw_hive2
WHERE demandbase_sid is not null
GROUP BY demandbase_sid
   ,demandbase_company_name
   ,demandbase_industry
   ,split(demandbase_51, '[\:]')[3]
   ,split(demandbase_51, '[\:]')[4]
   ,split(demandbase_51, '[\:]')[5]
   ,split(demandbase_51, '[\:]')[6]
   ,split(demandbase_51, '[\:]')[7]
   ,demandbase_domain
;

CREATE TABLE mci_enterprise.cd_demandbase_raw_hive3_unq
STORED AS ORC tblproperties( "orc.compress" = "SNAPPY", "serialization.null.format" = "") AS
SELECT demandbase_sid
   ,demandbase_company_name
   ,demandbase_industry
   ,split(demandbase_51, '[\:]')[3]  as demandbase_sub_industry1
   ,split(demandbase_51, '[\:]')[4]  as demandbase_employee_range
   ,split(demandbase_51, '[\:]')[5]  as demandbase_revenue_range
   ,split(demandbase_51, '[\:]')[6]  as demandbase_business_type
   ,split(demandbase_51, '[\:]')[7]  as demandbase_sub_industry2
   ,demandbase_domain
FROM mci_enterprise.cd_demandbase_raw_hive3
WHERE demandbase_sid is not null
GROUP BY demandbase_sid
   ,demandbase_company_name
   ,demandbase_industry
   ,split(demandbase_51, '[\:]')[3]
   ,split(demandbase_51, '[\:]')[4]
   ,split(demandbase_51, '[\:]')[5]
   ,split(demandbase_51, '[\:]')[6]
   ,split(demandbase_51, '[\:]')[7]
   ,demandbase_domain
;

CREATE TABLE mci_enterprise.cd_demandbase_raw_hive4_unq
STORED AS ORC tblproperties( "orc.compress" = "SNAPPY", "serialization.null.format" = "") AS
SELECT demandbase_sid
   ,demandbase_company_name
   ,demandbase_industry
   ,split(demandbase_51, '[\:]')[3]  as demandbase_sub_industry1
   ,split(demandbase_51, '[\:]')[4]  as demandbase_employee_range
   ,split(demandbase_51, '[\:]')[5]  as demandbase_revenue_range
   ,split(demandbase_51, '[\:]')[6]  as demandbase_business_type
   ,split(demandbase_51, '[\:]')[7]  as demandbase_sub_industry2
   ,demandbase_domain
FROM mci_enterprise.cd_demandbase_raw_hive4
WHERE demandbase_sid is not null
GROUP BY demandbase_sid
   ,demandbase_company_name
   ,demandbase_industry
   ,split(demandbase_51, '[\:]')[3]
   ,split(demandbase_51, '[\:]')[4]
   ,split(demandbase_51, '[\:]')[5]
   ,split(demandbase_51, '[\:]')[6]
   ,split(demandbase_51, '[\:]')[7]
   ,demandbase_domain
;

CREATE TABLE mci_enterprise.cd_demandbase_raw_hive5_unq
STORED AS ORC tblproperties( "orc.compress" = "SNAPPY", "serialization.null.format" = "") AS
SELECT demandbase_sid
   ,demandbase_company_name
   ,demandbase_industry
   ,split(demandbase_51, '[\:]')[3]  as demandbase_sub_industry1
   ,split(demandbase_51, '[\:]')[4]  as demandbase_employee_range
   ,split(demandbase_51, '[\:]')[5]  as demandbase_revenue_range
   ,split(demandbase_51, '[\:]')[6]  as demandbase_business_type
   ,split(demandbase_51, '[\:]')[7]  as demandbase_sub_industry2
   ,demandbase_domain
FROM mci_enterprise.cd_demandbase_raw_hive5
WHERE demandbase_sid is not null
GROUP BY demandbase_sid
   ,demandbase_company_name
   ,demandbase_industry
   ,split(demandbase_51, '[\:]')[3]
   ,split(demandbase_51, '[\:]')[4]
   ,split(demandbase_51, '[\:]')[5]
   ,split(demandbase_51, '[\:]')[6]
   ,split(demandbase_51, '[\:]')[7]
   ,demandbase_domain
;

CREATE TABLE mci_enterprise.cd_demandbase_raw_hive6_unq
STORED AS ORC tblproperties( "orc.compress" = "SNAPPY", "serialization.null.format" = "") AS
SELECT demandbase_sid
   ,demandbase_company_name
   ,demandbase_industry
   ,split(demandbase_51, '[\:]')[3]  as demandbase_sub_industry1
   ,split(demandbase_51, '[\:]')[4]  as demandbase_employee_range
   ,split(demandbase_51, '[\:]')[5]  as demandbase_revenue_range
   ,split(demandbase_51, '[\:]')[6]  as demandbase_business_type
   ,split(demandbase_51, '[\:]')[7]  as demandbase_sub_industry2
   ,demandbase_domain
FROM mci_enterprise.cd_demandbase_raw_hive6
WHERE demandbase_sid is not null
GROUP BY demandbase_sid
   ,demandbase_company_name
   ,demandbase_industry
   ,split(demandbase_51, '[\:]')[3]
   ,split(demandbase_51, '[\:]')[4]
   ,split(demandbase_51, '[\:]')[5]
   ,split(demandbase_51, '[\:]')[6]
   ,split(demandbase_51, '[\:]')[7]
   ,demandbase_domain
;

--combine all tables and build standardized values for industry, employee range and revenue range
DROP TABLE mci_enterprise.cd_demandbase_raw;
CREATE TABLE mci_enterprise.cd_demandbase_raw
STORED AS ORC tblproperties( "orc.compress" = "SNAPPY", "serialization.null.format" = "") AS
SELECT demandbase_sid
   ,demandbase_domain
   ,demandbase_company_name
   ,demandbase_industry
   ,demandbase_sub_industry1
   ,demandbase_employee_range
   ,demandbase_revenue_range
   ,demandbase_business_type
   ,demandbase_sub_industry2

   --STANDARDIZED FIELDS
   ,CASE WHEN demandbase_industry IN ('Consumer Goods & Ser', 'Consumer Goods & Services') THEN 'Consumer Goods & Services'
          WHEN demandbase_industry IN ('Media & Entertainmen', 'Media & Entertainment') THEN 'Media & Entertainment'
          WHEN demandbase_industry IN ('Printing & Publishin', 'Printing & Publishing') THEN 'Printing & Publishing'
          WHEN demandbase_industry IN ('Retail & Distributio', 'Retail & Distribution') THEN 'Retail & Distribution'
          WHEN demandbase_industry IN ('Software & Technolog', 'Software & Technology', 'Software', 'software & technolog') THEN 'Software & Technology'
          WHEN demandbase_industry IN ('Transportation & Log', 'Transportation & Logistics', 'Transportation') THEN 'Transportation & Logistics'
          WHEN demandbase_industry IN ('Healthcare & Medical', 'Healthcare') THEN 'Healthcare & Medical'
          WHEN demandbase_industry IN ('Education', 'education') THEN 'Education'
          WHEN demandbase_industry IN ('Aerospace & Defense'
             ,'Agriculture'
             ,'Apparel'
             ,'Associations'
             ,'Automotive'
             ,'Biotech'
             ,'Business Services'
             ,'Construction'
             ,'Energy & Utilities'
             ,'Financial Services'
             ,'Food & Beverage'
             ,'Furniture'
             ,'Government'
             ,'Hardware'
             ,'Holding Company'
             ,'Home & Garden'
             ,'Hospitality & Travel'
             ,'Manufacturing'
             ,'Mining'
             ,'Pharmaceuticals'
             ,'Real Estate'
             ,'Recreation'
             ,'Services'
             ,'Telecommunications'
             ,'Textiles'
             ,'Wholesale Trade') THEN demandbase_industry ELSE NULL END demandbase_industry_std
  ,CASE WHEN demandbase_employee_range in ('1-9', '10-99', '100-499', '500-999', '1000-4999') THEN demandbase_employee_range
        WHEN demandbase_employee_range in ('5000', '5000 ','5000+') THEN '5000+'
        ELSE null END demandbase_employee_range_std
  ,CASE WHEN UPPER(demandbase_revenue_range) in ('$1 - $1','$1 - $1M') THEN '$1 - $1M'
        WHEN UPPER(demandbase_revenue_range) in ('$1M - $5','$1M - $5M') THEN '$1M - $5M'
        WHEN UPPER(demandbase_revenue_range) in ('$5M - $10','$5M - $10M') THEN '$5M - $10M'
        WHEN UPPER(demandbase_revenue_range) in ('$10M - $25','$10M - $25M') THEN '$10M - $25M'
        WHEN UPPER(demandbase_revenue_range) in ('$25M - $50','$25M - $50M') THEN '$25M - $50M'
        WHEN UPPER(demandbase_revenue_range) in ('$50M - $10','$50M - $100','$50M - $100M') THEN '$50M - $100M'
        WHEN UPPER(demandbase_revenue_range) in ('$100M - $2','$100M - $250','$100M - $250M') THEN '$100M - $250M'
        WHEN UPPER(demandbase_revenue_range) in ('$250M - $5','$250M - $500','$250M - $500M') THEN '$250M - $500M'
        WHEN UPPER(demandbase_revenue_range) in ('$500M - $1','$500M - $1B') THEN '$500M - $1B'
        WHEN UPPER(demandbase_revenue_range) in ('$1B - $2.5','$1B - $2.5B') THEN '$1B - $2.5B'
        WHEN UPPER(demandbase_revenue_range) in ('$2.5B - $5','$2.5B - $5B') THEN '$2.5B - $5B'
        WHEN UPPER(demandbase_revenue_range) = 'OVER $5B' THEN 'Over $5B'
        ELSE null END demandbase_revenue_range_std
FROM
  (
  SELECT * FROM mci_enterprise.cd_demandbase_raw_hive1_unq
  UNION ALL SELECT * FROM mci_enterprise.cd_demandbase_raw_hive2_unq
  UNION ALL SELECT * FROM mci_enterprise.cd_demandbase_raw_hive3_unq
  UNION ALL SELECT * FROM mci_enterprise.cd_demandbase_raw_hive4_unq
  UNION ALL SELECT * FROM mci_enterprise.cd_demandbase_raw_hive5_unq
  UNION ALL SELECT * FROM mci_enterprise.cd_demandbase_raw_hive6_unq
  ) Q1
GROUP BY demandbase_sid
   ,demandbase_company_name
   ,demandbase_industry
   ,demandbase_sub_industry1
   ,demandbase_employee_range
   ,demandbase_revenue_range
   ,demandbase_business_type
   ,demandbase_sub_industry2
   ,demandbase_domain
   ,CASE WHEN demandbase_industry IN ('Consumer Goods & Ser', 'Consumer Goods & Services') THEN 'Consumer Goods & Services'
         WHEN demandbase_industry IN ('Media & Entertainmen', 'Media & Entertainment') THEN 'Media & Entertainment'
         WHEN demandbase_industry IN ('Printing & Publishin', 'Printing & Publishing') THEN 'Printing & Publishing'
         WHEN demandbase_industry IN ('Retail & Distributio', 'Retail & Distribution') THEN 'Retail & Distribution'
         WHEN demandbase_industry IN ('Software & Technolog', 'Software & Technology', 'Software', 'software & technolog') THEN 'Software & Technology'
         WHEN demandbase_industry IN ('Transportation & Log', 'Transportation & Logistics', 'Transportation') THEN 'Transportation & Logistics'
         WHEN demandbase_industry IN ('Healthcare & Medical', 'Healthcare') THEN 'Healthcare & Medical'
         WHEN demandbase_industry IN ('Education', 'education') THEN 'Education'
         WHEN demandbase_industry IN ('Aerospace & Defense'
            ,'Agriculture'
            ,'Apparel'
            ,'Associations'
            ,'Automotive'
            ,'Biotech'
            ,'Business Services'
            ,'Construction'
            ,'Energy & Utilities'
            ,'Financial Services'
            ,'Food & Beverage'
            ,'Furniture'
            ,'Government'
            ,'Hardware'
            ,'Holding Company'
            ,'Home & Garden'
            ,'Hospitality & Travel'
            ,'Manufacturing'
            ,'Mining'
            ,'Pharmaceuticals'
            ,'Real Estate'
            ,'Recreation'
            ,'Services'
            ,'Telecommunications'
            ,'Textiles'
            ,'Wholesale Trade') THEN demandbase_industry ELSE NULL END
   ,CASE WHEN demandbase_employee_range in ('1-9', '10-99', '100-499', '500-999', '1000-4999') THEN demandbase_employee_range
         WHEN demandbase_employee_range in ('5000', '5000 ','5000+') THEN '5000+'
         ELSE null END
   ,CASE WHEN UPPER(demandbase_revenue_range) in ('$1 - $1','$1 - $1M') THEN '$1 - $1M'
         WHEN UPPER(demandbase_revenue_range) in ('$1M - $5','$1M - $5M') THEN '$1M - $5M'
         WHEN UPPER(demandbase_revenue_range) in ('$5M - $10','$5M - $10M') THEN '$5M - $10M'
         WHEN UPPER(demandbase_revenue_range) in ('$10M - $25','$10M - $25M') THEN '$10M - $25M'
         WHEN UPPER(demandbase_revenue_range) in ('$25M - $50','$25M - $50M') THEN '$25M - $50M'
         WHEN UPPER(demandbase_revenue_range) in ('$50M - $10','$50M - $100','$50M - $100M') THEN '$50M - $100M'
         WHEN UPPER(demandbase_revenue_range) in ('$100M - $2','$100M - $250','$100M - $250M') THEN '$100M - $250M'
         WHEN UPPER(demandbase_revenue_range) in ('$250M - $5','$250M - $500','$250M - $500M') THEN '$250M - $500M'
         WHEN UPPER(demandbase_revenue_range) in ('$500M - $1','$500M - $1B') THEN '$500M - $1B'
         WHEN UPPER(demandbase_revenue_range) in ('$1B - $2.5','$1B - $2.5B') THEN '$1B - $2.5B'
         WHEN UPPER(demandbase_revenue_range) in ('$2.5B - $5','$2.5B - $5B') THEN '$2.5B - $5B'
         WHEN UPPER(demandbase_revenue_range) = 'OVER $5B' THEN 'Over $5B'
         ELSE null END
;

--check
SELECT demandbase_industry, demandbase_industry_std, count(*) cnt
FROM mci_enterprise.cd_demandbase_raw
GROUP BY demandbase_industry, demandbase_industry_std
;

SELECT demandbase_employee_range, demandbase_employee_range_std, count(*) cnt
FROM mci_enterprise.cd_demandbase_raw
GROUP BY demandbase_employee_range, demandbase_employee_range_std
;

SELECT demandbase_revenue_range, demandbase_revenue_range_std, count(*) cnt
FROM mci_enterprise.cd_demandbase_raw
GROUP BY demandbase_revenue_range, demandbase_revenue_range_std
;

--only 325 duplicate Demandbase SIDs
select count(*), count(distinct demandbase_sid)
from
(
select demandbase_sid
   ,demandbase_industry_std
   ,demandbase_employee_range_std
   ,demandbase_revenue_range_std
from mci_enterprise.cd_demandbase_raw
where demandbase_sid > 1
)
;

--Build Demandbase profile table at Demandbase SID level
--Pick one record for each Demandbase SID based on fill score of standardized fields and domain name
--future enhancement is to understand if we also need it at domain level, and if we get a different value
DROP TABLE mci_enterprise.cd_demandbase_profile;
CREATE TABLE mci_enterprise.cd_demandbase_profile
STORED AS ORC tblproperties( "orc.compress" = "SNAPPY", "serialization.null.format" = "") AS
SELECT demandbase_sid
   ,demandbase_industry_std
   ,demandbase_employee_range_std
   ,demandbase_revenue_range_std
   ,attribute_fill_score
FROM
(
SELECT demandbase_sid
   --,demandbase_domain
   ,demandbase_industry_std
   ,demandbase_employee_range_std
   ,demandbase_revenue_range_std
   ,case when demandbase_industry_std is not null then 1.0 else 0 end
     + case when demandbase_employee_range_std is not null then 1.0 else 0 end
     + case when demandbase_revenue_range_std is not null then 0.25 else 0 end
     + case when demandbase_domain is not null then 0.50 else 0 end attribute_fill_score
   ,row_number() over (partition by demandbase_sid
     order by case when demandbase_industry_std is not null then 1.0 else 0 end
              + case when demandbase_employee_range_std is not null then 1.0 else 0 end
              + case when demandbase_revenue_range_std is not null then 0.25 else 0 end
              + case when demandbase_domain is not null then 0.50 else 0 end desc
            , demandbase_domain) rno
FROM mci_enterprise.cd_demandbase_raw
) Q1
WHERE rno = 1
;
