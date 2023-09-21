CREATE TABLE azure_ip_data AS (
  SELECT DISTINCT
    prefixes AS cidr_block,
    STR_SPLIT(prefixes, '/')[1] AS ip_address,
    CAST(STR_SPLIT(prefixes, '/')[2] AS INTEGER) AS ip_address_mask,
    CAST(pow(2, 32-CAST(STR_SPLIT(prefixes, '/')[2] AS INTEGER)) AS INTEGER) AS ip_address_cnt,
    CASE
      WHEN region = '' THEN 'No region'
      ELSE region
    END AS region
  FROM (
    SELECT DISTINCT
      prop.region AS region,
      UNNEST(prop.addressPrefixes) AS prefixes
    FROM (
      SELECT 
        values.properties AS prop
      FROM (
        SELECT 
          unnest(values) AS values
        FROM
          read_json_auto('###AZURE_URL###', maximum_object_size=20000000)
      )
    )
  )
  WHERE
    prefixes NOT LIKE '%::%'
);
