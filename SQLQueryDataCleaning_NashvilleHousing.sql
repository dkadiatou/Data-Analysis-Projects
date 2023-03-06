/*

Cleaning Data in SQL Queries

*/

SELECT *
FROM portofolioProjects.dbo.NashvilleHousing


------------------------------------------------------------------------------------------------------

--Standardize Date Format

-- first try not working (sometimes it works but not every time)
SELECT SaleDate, CONVERT(Date, SaleDate)
FROM portofolioProjects.dbo.NashvilleHousing

UPDATE portofolioProjects.dbo.NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)


-- second try is working
ALTER TABLE portofolioProjects.dbo.NashvilleHousing
ADD SaleDateConverted Date

UPDATE portofolioProjects.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

SELECT SaleDate, SaleDateConverted
FROM portofolioProjects.dbo.NashvilleHousing



------------------------------------------------------------------------------------------------------

--Populate properly Adress data


SELECT *
FROM portofolioProjects.dbo.NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID


-- We have to join the table to it self and replace the NULL Propertyaddress by the propertyAddress of the same ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress, b.PropertyAddress)
FROM portofolioProjects.dbo.NashvilleHousing a
JOIN portofolioProjects.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


-- Update

UPDATE a
SET PropertyAddress = ISNULL (a.PropertyAddress, b.PropertyAddress)
FROM portofolioProjects.dbo.NashvilleHousing a
JOIN portofolioProjects.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null



------------------------------------------------------------------------------------------------------

-- Breaking out Property Adress into individual colums (Adress, City, State)

SELECT PropertyAddress
FROM portofolioProjects.dbo.NashvilleHousing
--WHERE PropertyAddress is null
--ORDER BY ParcelID


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Adress
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS AdressCity
FROM portofolioProjects.dbo.NashvilleHousing




ALTER TABLE portofolioProjects.dbo.NashvilleHousing
ADD PropertySplitAdress Nvarchar(255)

UPDATE portofolioProjects.dbo.NashvilleHousing
SET PropertySplitAdress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)



ALTER TABLE portofolioProjects.dbo.NashvilleHousing
ADD PropertySplitCity Nvarchar(255)

UPDATE portofolioProjects.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


SELECT PropertySplitAdress, PropertySplitCity
FROM portofolioProjects.dbo.NashvilleHousing




---- Breaking out Owner Adress into individual colums (Adress, City, State) in a other way
--PARSENAME (USE ONLY PERIODE (.) SO WE NEED TO CHANDE THE COMMA (,) BY PERIODE (.)

SELECT OwnerAddress
FROM portofolioProjects.dbo.NashvilleHousing


Select
PARSENAME (REPLACE(OwnerAddress, ',' , '.') , 3)
,PARSENAME (REPLACE(OwnerAddress, ',' , '.') , 2)
,PARSENAME (REPLACE(OwnerAddress, ',' , '.') , 1)
FROM portofolioProjects.dbo.NashvilleHousing



ALTER TABLE portofolioProjects.dbo.NashvilleHousing
ADD OwnerSplitAdress Nvarchar(255)

UPDATE portofolioProjects.dbo.NashvilleHousing
SET OwnerSplitAdress = PARSENAME (REPLACE(OwnerAddress, ',' , '.') , 3)



ALTER TABLE portofolioProjects.dbo.NashvilleHousing
ADD OwnerSplitCity Nvarchar(255)

UPDATE portofolioProjects.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME (REPLACE(OwnerAddress, ',' , '.') , 2)



ALTER TABLE portofolioProjects.dbo.NashvilleHousing
ADD OwnerSplitState Nvarchar(255)

UPDATE portofolioProjects.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME (REPLACE(OwnerAddress, ',' , '.') , 1)

SELECT *
FROM portofolioProjects.dbo.NashvilleHousing


------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No om "SoldasVacant"

SELECT DISTINCT (Soldasvacant), count(SoldAsVacant)
FROM portofolioProjects.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2



SELECT	SoldAsVacant
		,CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
			  WHEN SoldAsVacant ='N' THEN 'No'
			  ELSE SoldAsVacant
			  END
FROM portofolioProjects.dbo.NashvilleHousing




------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE
AS (

	SELECT *
			,Row_number() OVER (
							PARTITION BY ParcelID
										,PropertyAddress
										,SalePrice
										,SaleDate
										,LegalReference
										ORDER BY uniqueID
								) row_num

	FROM portofolioProjects.dbo.NashvilleHousing
	--ORDER BY ParcelID
   )

   -- Montre tous les duplicates (Rouler avec le CTE)

SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


 -- Effacer les duplicates (rouler avec le CTE)

DELETE
FROM RowNumCTE
WHERE row_num > 1



------------------------------------------------------------------------------------------------------

-- Delete Unsed Columns

SELECT *
FROM portofolioProjects.dbo.NashvilleHousing

ALTER TABLE portofolioProjects.dbo.NashvilleHousing
DROP COLUMN OwnerAddress
			,TaxDistrict
			,PropertyAddress


ALTER TABLE portofolioProjects.dbo.NashvilleHousing
DROP COLUMN SaleDate