-- QUERY TO FIRST LOOK AT THE COMPLETE DATA

SELECT * FROM NashvilleHousing

-- LET'S STANDARDIZE THE SALEDATE FORMAT

SELECT SaleDate, CONVERT(Date,SaleDate)
from NashvilleHousing

UPDATE NashvilleHousing 
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)



--POPULATING PROPERTY ADDRESS DATA

SELECT PropertyAddress
FROM NashvilleHousing
WHERE PropertyAddress is null

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress) --(iF A null, it puts B into it)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


SELECT * 
FROM NashvilleHousing
WHERE PropertyAddress is null   --THIS SHOULD NOT RETURN ANY VALUES NOW


--NOW, BREAKING OUT ADDRESS INTO SPLIT COLUMNS TO MAKE IT MORE USABLE


SELECT PropertyAddress
FROM NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) AS Address --using SUBSTRING 
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) AS Address
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))



--NOW, THE SAME THING FOR THE OWNER ADDRESS COLUMN BUT IN A DIFFERENT WAY

SELECT owneraddress
FROM NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)  --we are using PARSENAME here
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM PortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


SELECT * FROM NashvilleHousing


--CHANGING Y AND N TO YES AND NO RESPECTIVELY IN SOLD AS COLUMN

SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END


--REMOVING DUPLICATES (USING CTE'S)

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM NashvilleHousing 
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


SELECT * FROM NashvilleHousing


--DELETING UNUSED COLUMNS

SELECT *
FROM NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate