/***** 

Cleaning Housing Data in SQL

*****/

Select *
From HousingDataProject1.dbo.NashvilleHousing

---------------------------

--Standardize Date Format 

Select SaleDate, CONVERT(Date,SaleDate)
From HousingDataProject1.dbo.NashvilleHousing

Update NashvilleHousing 
Set SaleDate = CONVERT(Date,SaleDate)

---- *Alternative Method / Created a new colum in db with modified Date 
Alter table NashvilleHousing
Add SaleDateConverted Date

Update NashvilleHousing 
Set SaleDateConverted = CONVERT(Date,SaleDate)

Select SaleDateConverted, CONVERT(Date,SaleDate)
From HousingDataProject1.dbo.NashvilleHousing


-------------------------------------------------------

-- Populate Property Address data

Select PropertyAddress
From HousingDataProject1.dbo.NashvilleHousing
Where PropertyAddress is null

Select *
From HousingDataProject1.dbo.NashvilleHousing
Where PropertyAddress is null

Select * -- Researching if ParcelID is simalar to PropertyAddress
From HousingDataProject1.dbo.NashvilleHousing
Where PropertyAddress is null
order by ParcelID

Select *
From HousingDataProject1.dbo.NashvilleHousing
Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, ISNULL(a.PropertyAddress, b.PropertyAddress)
From HousingDataProject1.dbo.NashvilleHousing a
Join HousingDataProject1.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ] 
Where a.PropertyAddress is Null

Update a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From HousingDataProject1.dbo.NashvilleHousing a
Join HousingDataProject1.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is Null -- Run above Select query and there should be no more Null Values in PropertyAddress

------------------------------------------------------

--Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From HousingDataProject1.dbo.NashvilleHousing

----- Splitting up Property Address Colum (Harder Method
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From HousingDataProject1.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) 


ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) 


Select *
From HousingDataProject1.dbo.NashvilleHousing


--- Splitting Up Owners Address - Using PARSENAME (Easier Method)

Select OwnerAddress
From HousingDataProject1.dbo.NashvilleHousing

Select 
PARSENAME(Replace(OwnerAddress,',', '.'),3) as Address -- Used REPLACE Statement to change the comma with a period because PARSENAME only works with periods
,PARSENAME(Replace(OwnerAddress,',', '.'),2) as City
,PARSENAME(Replace(OwnerAddress,',', '.'),1) as State
From HousingDataProject1.dbo.NashvilleHousing -- In Reverse order to rearange in correct order 

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',', '.'),3)


ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',', '.'),2) 

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(Replace(OwnerAddress,',', '.'),1) 


Select *
From HousingDataProject1.dbo.NashvilleHousing



--------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select DISTINCT(SoldAsVacant), Count(SoldAsVacant)
From HousingDataProject1.dbo.NashvilleHousing
Group by SoldAsVacant
ORDER by 2



Select SoldAsVacant
, CASE when SoldAsVacant = 'Y' Then 'Yes'
			 When SoldAsVacant = 'N' THEN 'No'
			 ELSE SoldAsVacant 
			 END
From HousingDataProject1.dbo.NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' Then 'Yes'
			 When SoldAsVacant = 'N' THEN 'No'
			 ELSE SoldAsVacant 
			 END

Select DISTINCT(SoldAsVacant), Count(SoldAsVacant)
From HousingDataProject1.dbo.NashvilleHousing
Group by SoldAsVacant
ORDER by 2

.------------------------------------------------------

-- Remove Duplicates - Use PArtition By to find unique key

WITH RowNumCTE AS(
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

From HousingDataProject1.dbo.NashvilleHousing
--ORDER BY ParcelID
)
Select *
--Delete - Use 1st to delete duplicates then run select * to see if deletion was sucessful
From RowNumCTE
Where row_num > 1
Order By PropertyAddress


--------------------------------------------------------

-- Delete Unused Columns - Deleting Columns that aren't useful in this Data set

Select *
From HousingDataProject1.dbo.NashvilleHousing -- Run After Altering Table

ALTER TABLE HousingDataProject1.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate 

-----------------------------------------------------------

-- Completed DataSet after Cleaning Data

Select *
From HousingDataProject1.dbo.NashvilleHousing
