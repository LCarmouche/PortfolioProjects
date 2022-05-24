/*

Cleaning Data in SQL queries

/*

Select *
From PortfolioProject.dbo.NashvilleHousing
-------------------------------------------------------------------------------------------------------------------
---Standardise Data Format

Select SaleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing 
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing 
SET SaleDateConverted = CONVERT(Date,SaleDate)

------------------------------------------------------------------------------------------------------------------------
---Populate Property Address data

Select *
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is NULL
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
    on a.parcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
	Where a.PropertyAddress is NULL

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
    on a.parcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is NULL

-----------------------------------------------------------------------------------------------------------------------
---Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is NULL
order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)  , LEN(PropertyAddress)) as Address

From PortfolioProject.dbo.NashvilleHousing 

ALTER TABLE NashvilleHousing
Add PropertySplitAddress NVARCHAR(255);

Update NashvilleHousing 
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)


ALTER TABLE NashvilleHousing
Add PropertySplitCity NVARCHAR(255);

Update NashvilleHousing 
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)  , LEN(PropertyAddress))


SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing 

SELECT
PARSENAME(REPLACE(OwnerAddress,',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress,',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress,',', '.') , 1)
FROM PortfolioProject.dbo.NashvilleHousing 

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress NVARCHAR(255);

Update NashvilleHousing 
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity NVARCHAR(255);

Update NashvilleHousing 
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',', '.') , 2)


ALTER TABLE NashvilleHousing
Add PropertySplitState NVARCHAR(255);

Update NashvilleHousing 
SET PropertySplitState = PARSENAME(REPLACE(OwnerAddress,',', '.') , 1)
-------------------------------------------------------------------------------------------------------------------------

---Change Y and N to Yes in "Sold as Vacant" field

Select Distinct(soldasvacant), Count(soldasvacant)
FROM PortfolioProject.dbo.NashvilleHousing 
Group by soldasvacant
order by 2


Select soldasvacant
, CASE when soldasvacant = 'Y' THEN 'Yes'
   when soldasvacant = 'N' THEN 'No'
   ELSE Soldasvacant
   END
FROM PortfolioProject.dbo.NashvilleHousing 

Update NashvilleHousing
SET soldasvacant = CASE when soldasvacant = 'Y' THEN 'Yes'
   when soldasvacant = 'N' THEN 'No'
   ELSE Soldasvacant
   END

--------------------------------------------------------------------------------------------------------------------

---Remove Duplicates

WITH RowNumCTE AS (
Select *,
  ROW_NUMBER() OVER (
  PARTITION BY ParcelID,
  PropertyAddress,
  SalePrice,
  SaleDate,
  LegalReference
  ORDER BY
     UniqueID
	 ) row_num


FROM PortfolioProject.dbo.NashvilleHousing 
--order by parcelID
)

DELETE
FROM RowNumCTE
where row_num > 1
---Order by PropertyAddress

----------------------------------------------------------------------------------------------------------------------
---Delete Unused Columns



SELECT *
FROM PortfolioProject.dbo.NashvilleHousing 

ALTER TABLE PortfolioProject.dbo.NashvilleHousing 
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousing 
DROP COLUMN SaleDate