/* 

CLEANING DATA IN SQL QUERIES


*/

USE Portfolio_Project;
--
SELECT
	*
FROM nashvillehousing



-----------------------------------------------------------------------------------------------------------------

-- STANDARDIZE DATE FORMAT

SELECT
	saledate,
	CONVERT(Date,saledate)
FROM nashvillehousing

UPDATE dbo.NashvilleHousing
SET saledate = CONVERT(Date,saledate)


-- IF THE UPDATE CODE DOES NOT WORK TRY ALTER TABLE

-- BY ADDING NEW COLUMN TO THE DATA SET
ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

-- THEN UPDATE THE NEW COLUMN TO CONVERT DATE
UPDATE dbo.NashvilleHousing
SET saledateconverted = CONVERT(Date,saledate)

SELECT 
	*
FROM NashvilleHousing


-----------------------------------------------------------------------------------------------------------------

-- POPULATE PROPERTY ADDRESS DATA THAT IS NULL

-- Here we found out that there is multiple ParcelID with 99.9% the same address, we can use the same Property Address
	-- and copy the Property Address that is not NULL to the same ParcelID
SELECT 
	*
FROM NashvilleHousing
--WHERE propertyaddress IS NULL
ORDER BY parcelID

-- USING SELF JOIN to determine the parcelID with multiple address
SELECT 
	a.parcelid,
	a.propertyaddress,
	b.parcelid,
	b.propertyaddress,
	ISNULL(a.propertyaddress,b.propertyaddress)
FROM NashvilleHousing a
JOIN Nashvillehousing b 
	ON a.parcelid = b.parcelid
	AND a.[uniqueID ] <> b.[uniqueID ]
WHERE a.propertyaddress IS NULL

-- we will transfer the new column (no column name from ISNULL command) to a.propertyaddress

UPDATE a
SET propertyaddress = ISNULL(a.propertyaddress,b.propertyaddress)
FROM NashvilleHousing a
JOIN Nashvillehousing b 
	ON a.parcelid = b.parcelid
	AND a.[uniqueID ] <> b.[uniqueID ]
WHERE a.propertyaddress IS NULL


-----------------------------------------------------------------------------------------------------------------

-- BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (Address, City, State)

-- SPLIITING 'PropertyAddess' COLUMN USING SUBSTRING COMMAND

SELECT 
	propertyaddress
FROM NashvilleHousing
--WHERE propertyaddress IS NULL
ORDER BY parcelID

SELECT
	SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress) -1) AS address
	, SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress) +1, LEN (propertyaddress)) AS address
FROM NashvilleHousing

-- updating/adding new column our data set for ADDRESS

ALTER TABLE NashvilleHousing
ADD propertysplitaddress NVARCHAR(255);

UPDATE dbo.NashvilleHousing
SET propertysplitaddress = SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress) -1)


-- updating/adding new column our data set for CITY

ALTER TABLE NashvilleHousing
ADD propertysplitcity NVARCHAR(255);

UPDATE dbo.NashvilleHousing
SET propertysplitcity = SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress) +1, LEN (propertyaddress))



-- SPLIITING 'OwnerAddress' COLUMN USING PARSENAME command

SELECT 
	*
FROM NashvilleHousing
ORDER BY parcelid


SELECT 
	PARSENAME(REPLACE(owneraddress, ',','.') ,3)
	,PARSENAME(REPLACE(owneraddress, ',','.') ,2)
	,PARSENAME(REPLACE(owneraddress, ',','.') ,1)
FROM NashvilleHousing

-- updating/adding  ADDRESS

ALTER TABLE NashvilleHousing
ADD ownersplitaddress NVARCHAR(255);

UPDATE dbo.NashvilleHousing
SET ownersplitaddress = PARSENAME(REPLACE(owneraddress, ',','.') ,3)


-- updating/adding new column our data set for CITY

ALTER TABLE NashvilleHousing
ADD ownersplitcity NVARCHAR(255);

UPDATE dbo.NashvilleHousing
SET ownersplitcity = PARSENAME(REPLACE(owneraddress, ',','.') ,2)

-- updating/adding new column our data set for STATE

ALTER TABLE NashvilleHousing
ADD ownersplitstate NVARCHAR(255);

UPDATE dbo.NashvilleHousing
SET ownersplitstate = PARSENAME(REPLACE(owneraddress, ',','.') ,1)



-----------------------------------------------------------------------------------------------------------------

-- CHANGE Y AND N TO Yes and No in "Sold as Vacant" field

SELECT 
	DISTINCT(soldasvacant),COUNT(soldasVACANT)
FROM NashvilleHousing
GROUP BY soldasvacant
ORDER BY 2


SELECT 
	soldasvacant
	, CASE WHEN soldasvacant = 'Y' THEN 'Yes'
		   WHEN soldasvacant = 'N' THEN 'No'
		   ELSE soldasvacant
		   END
FROM NashvilleHousing

-- UPDATING DATASET

UPDATE nashvillehousing
SET soldasvacant = CASE WHEN soldasvacant = 'Y' THEN 'Yes'
		   WHEN soldasvacant = 'N' THEN 'No'
		   ELSE soldasvacant
		   END



-----------------------------------------------------------------------------------------------------------------
-- REMOVE DUPLICATES

WITH rownumCTE AS  (
SELECT 
	*
	, ROW_NUMBER () OVER (
	PARTITION BY parcelid,
				 propertyaddress,
				 saleprice,
				 saledate,
				 legalreference
				 ORDER BY 
					uniqueid
					) row_num
FROM nashvillehousing
)

DELETE
FROM rownumCTE
WHERE row_num > 1 

-- CHECK IF THERE IS STILL DUPLICATES

WITH rownumCTE AS  (
SELECT 
	*
	, ROW_NUMBER () OVER (
	PARTITION BY parcelid,
				 propertyaddress,
				 saleprice,
				 saledate,
				 legalreference
				 ORDER BY 
					uniqueid
					) row_num
FROM nashvillehousing
)

SELECT *
FROM rownumCTE
WHERE row_num > 1 



-----------------------------------------------------------------------------------------------------------------
-- DELETE UNUSED COLUMNS

SELECT *
FROM nashvillehousing

ALTER TABLE nashvillehousing
DROP COLUMN owneraddress,taxdistrict,propertyaddress

ALTER TABLE nashvillehousing
DROP COLUMN saledate