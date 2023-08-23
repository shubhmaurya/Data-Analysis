/*

Cleaning Data in SQL Queries

*/

Select * from ProjectPortfolioOne..NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------
-- Standardize Date Format
ALTER TABLE ProjectPortfolioOne..NashvilleHousing
Add SalesDate Date;

Update ProjectPortfolioOne..NashvilleHousing
SET SalesDate = CONVERT(Date,SaleDate)

--------------------------------------------------------------------------------------------------------------------------
-- Populate Property Address Data
Select * 
from ProjectPortfolioOne..NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select x.ParcelID,x.PropertyAddress,y.ParcelID,y.PropertyAddress,ISNULL(x.PropertyAddress,y.PropertyAddress)
from ProjectPortfolioOne..NashvilleHousing as x
	join ProjectPortfolioOne..NashvilleHousing as y
	on x.ParcelID = y.ParcelID
	and x.[UniqueID ] <> y.[UniqueID ]
where x.PropertyAddress is null

Update x
Set PropertyAddress = ISNULL(x.PropertyAddress,y.PropertyAddress)
from ProjectPortfolioOne..NashvilleHousing as x
	join ProjectPortfolioOne..NashvilleHousing as y
	on x.ParcelID = y.ParcelID
	and x.[UniqueID ] <> y.[UniqueID ]
where x.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------
-- Breaking out Address into Individual Columns like: Address, City, State

-- Property Address Column
Select PropertyAddress
from ProjectPortfolioOne..NashvilleHousing

Select 
SUBSTRING( PropertyAddress,1,CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING( PropertyAddress,CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
from ProjectPortfolioOne..NashvilleHousing

ALTER TABLE ProjectPortfolioOne..NashvilleHousing
Add AddressOfOwner Nvarchar(255);

Update ProjectPortfolioOne..NashvilleHousing
SET Address = SUBSTRING( PropertyAddress,1,CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE ProjectPortfolioOne..NashvilleHousing
Add City Nvarchar(255);

Update ProjectPortfolioOne..NashvilleHousing
SET City = SUBSTRING( PropertyAddress,CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

-- Owner Address Column
Select OwnerAddress
from ProjectPortfolioOne..NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',','.'),3),
PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
from ProjectPortfolioOne..NashvilleHousing

ALTER TABLE ProjectPortfolioOne..NashvilleHousing
Add AddressOfOwner Nvarchar(255);

Update ProjectPortfolioOne..NashvilleHousing
SET AddressOfOwner = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

ALTER TABLE ProjectPortfolioOne..NashvilleHousing
Add CityOfOwner Nvarchar(255);

Update ProjectPortfolioOne..NashvilleHousing
SET CityOfOwner = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

ALTER TABLE ProjectPortfolioOne..NashvilleHousing
Add StateOfOwner Nvarchar(255);

Update ProjectPortfolioOne..NashvilleHousing
SET StateOfOwner = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)

Select * from ProjectPortfolioOne..NashvilleHousing;

--------------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in 'Sold as Vacant' column

-- to check
select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from ProjectPortfolioOne..NashvilleHousing
group by SoldAsVacant
order by 2;

-- to treat, we're using case statement
select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end
from ProjectPortfolioOne..NashvilleHousing

Update ProjectPortfolioOne..NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
						when SoldAsVacant = 'N' then 'No'
						else SoldAsVacant
						end

--------------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates

With RowNumCTE as (
select *,
		ROW_NUMBER() over (Partition by ParcelID,
										PropertyAddress,
										SalePrice,
										SaleDate,
										LegalReference
										Order By 
											UniqueID
											) row_num
from ProjectPortfolioOne..NashvilleHousing
)
Select *
from RowNumCTE
where row_num > 1

--------------------------------------------------------------------------------------------------------------------------
-- Delete Unused Columns

Select * 
from ProjectPortfolioOne..NashvilleHousing;

Alter table ProjectPortfolioOne..NashvilleHousing
Drop column PropertyAddress,OwnerAddress,TaxDistrict,SaleDate