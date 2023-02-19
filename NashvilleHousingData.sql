--Populating property_adress columns

SELECT a.parcel_id, a.property_address, b.parcel_id, b.property_address,
		COALESCE(a.property_address, b.property_address)
FROM "nashville_housing_data" as a
INNER JOIN "nashville_housing_data" as b
	ON a.parcel_id=b.parcel_id
	AND a.unique_id<>b.unique_id
WHERE a.property_address is null;

UPDATE "nashville_housing_data"
SET property_address=COALESCE(a.property_address, b.property_address)
FROM "nashville_housing_data" as a
INNER JOIN "nashville_housing_data" as b
	ON a.parcel_id=b.parcel_id
	AND a.unique_id<>b.unique_id
WHERE a.property_adress is null;

--Breaking adress into three different columns: adress, city, state

ALTER TABLE IF EXISTS "nashville_housing_data"
ADD property_split_address VARCHAR;

UPDATE "nashville_housing_data"
SET property_split_address=SPLIT_PART(property_address, ',', 1);

ALTER TABLE IF EXISTS "nashville_housing_data"
ADD property_split_city VARCHAR;

UPDATE "nashville_housing_data"
SET property_split_city=SPLIT_PART(property_address, ',', 2);

ALTER TABLE IF EXISTS "nashville_housing_data"
ADD owner_split_address VARCHAR;

UPDATE "nashville_housing_data"
SET owner_split_address=SPLIT_PART(owner_address, ',', 1);

ALTER TABLE IF EXISTS "nashville_housing_data"
ADD owner_split_city VARCHAR;

UPDATE "nashville_housing_data"
SET owner_split_city=SPLIT_PART(owner_address, ',', 2);

ALTER TABLE IF EXISTS "nashville_housing_data"
ADD owner_split_state VARCHAR;

UPDATE "nashville_housing_data"
SET owner_split_state=SPLIT_PART(owner_address, ',', 3);

-- Removing duplicates

WITH duplicates AS (
	SELECT *,
			ROW_NUMBER()OVER(PARTITION BY parcel_id,
						   				property_address,
										sale_date,
										sale_price,
						   				legal_reference) as row_number
	FROM public.nashville_housing_data
)

DELETE FROM public.nashville_housing_data USING duplicates
WHERE duplicates.row_number>1;

-- Deleting unused columns

ALTER TABLE IF EXISTS public.nashville_housing_data 
DROP COLUMN IF EXISTS property_address;

ALTER TABLE IF EXISTS public.nashville_housing_data 
DROP COLUMN IF EXISTS owner_address;
