-- Data cleaning

Select *
From PortfolioProjects..Housing

-- Date format convert

Select SaleDateConvert, CONVERT(Date, SaleDate)
From PortfolioProjects..Housing

Alter Table Housing
Add SaleDateConvert Date;

Update Housing
Set SaleDateConvert = CONVERT(Date,SaleDate)


-- Populate Property Addresses

Select PropertyAddress
From PortfolioProjects..Housing
Where PropertyAddress is null

Select *
From PortfolioProjects..Housing
--Where PropertyAddress is null
order by ParcelID

-- Fill empty address cells.
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProjects..Housing a
Join PortfolioProjects..Housing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProjects..Housing a
Join PortfolioProjects..Housing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- Separate Address, City and State

Select PropertyAddress
From PortfolioProjects..Housing

Select
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address,
SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
From PortfolioProjects..Housing

Alter Table Housing
Add PropertySplitAdress Nvarchar(255);

Update Housing
Set PropertySplitAdress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

Alter Table Housing
Add PropertySplitCity Nvarchar(255);

Update Housing
Set PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select *
From PortfolioProjects..Housing

-- OwnerAddressSplit

Select OwnerAddress
From PortfolioProjects..Housing

Select
PARSENAME (REPLACE(OwnerAddress, ',', '.') ,3),
PARSENAME (REPLACE(OwnerAddress, ',', '.') ,2),
PARSENAME (REPLACE(OwnerAddress, ',', '.') ,1)
From PortfolioProjects..Housing

Alter Table Housing
Add OwnerSplitAddress Nvarchar(255);

Update Housing
Set OwnerSplitAddress = PARSENAME (REPLACE(OwnerAddress, ',', '.') ,3)

Alter Table Housing
Add OwnerSplitCity Nvarchar(255);

Update Housing
Set OwnerSplitCity = PARSENAME (REPLACE(OwnerAddress, ',', '.') ,2)

Alter Table Housing
Add OwnerSplitState Nvarchar(255);

Update Housing
Set OwnerSplitState = PARSENAME (REPLACE(OwnerAddress, ',', '.') ,1)

Select *
From PortfolioProjects..Housing

-- Changing Y and N to Yes and No if its sold or not

Select Distinct (SoldAsVacant), Count(SoldAsVacant) as CountS
From PortfolioProjects..Housing
Group by SoldAsVacant
Order by CountS

Select SoldAsVacant,
CASE When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 END
From PortfolioProjects..Housing

Update Housing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 END



-- Duplicates

Select *
From PortfolioProjects..Housing

WITH RowNumCTE AS (
Select *,
	ROW_NUMBER() Over (
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by
					UniqueID) row_num
From PortfolioProjects..Housing
)
Select *
From RowNumCTE
Where row_num > 1
order by PropertyAddress

-- Deleting Duplicates

WITH RowNumCTE AS (
Select *,
	ROW_NUMBER() Over (
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by
					UniqueID) row_num
From PortfolioProjects..Housing
)
DELETE
From RowNumCTE
Where row_num > 1


-- Delete unused columns

Select *
From PortfolioProjects..Housing

ALTER TABLE PortfolioProjects..Housing
DROP COLUMN OwnerAddress, PropertyAddress, SaleDate