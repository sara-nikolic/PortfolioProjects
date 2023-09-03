select *
from NashvilleHousing

-- Standardizing Date Format
select SaleDate
from NashvilleHousing

alter table NashvilleHousing
add SaleDateCorrect Date;

UPDATE NashvilleHousing
SET SaleDateCorrect = CONVERT(Date, SaleDate)

-- Populating Property Adress
select *
from NashvilleHousing
where PropertyAddress is null

select *
from NashvilleHousing
order by ParcelID				/* homes with same parcell id have the same address */

select nh1.ParcelID, nh1.PropertyAddress, nh2.ParcelID, nh2.PropertyAddress, isnull(nh1.PropertyAddress, nh2.PropertyAddress)
from NashvilleHousing nh1
join NashvilleHousing nh2
on nh1.UniqueID <> nh2.UniqueID and nh1.ParcelID = nh2.ParcelID
where nh1.PropertyAddress is null

update nh1
set PropertyAddress = isnull(nh1.PropertyAddress, nh2.PropertyAddress)
from NashvilleHousing nh1
join NashvilleHousing nh2
on nh1.UniqueID <> nh2.UniqueID and nh1.ParcelID = nh2.ParcelID
where nh1.PropertyAddress is null


-- Spliting PropertyAddress and OwnerAddress into separate Address, City, State columns
select PropertyAddress
from NashvilleHousing

select PropertyAddress, 
	   substring(PropertyAddress, 1, charindex(',', PropertyAddress) - 1) as AddressSplit,
	   substring(PropertyAddress, charindex(',', PropertyAddress) + 1, len(PropertyAddress)) as CitySplit
from NashvilleHousing

alter table NashvilleHousing
add PropertyAddressSplit nvarchar(255)

update NashvilleHousing
set PropertyAddressSplit = substring(PropertyAddress, 1, charindex(',', PropertyAddress) - 1)

alter table NashvilleHousing
add PropertyCitySplit nvarchar(255)

update NashvilleHousing
set PropertyCitySplit = substring(PropertyAddress, charindex(',', PropertyAddress) + 1, len(PropertyAddress))

select OwnerAddress 
from NashvilleHousing

select OwnerAddress, parsename(replace(OwnerAddress, ',', '.'), 1) as State,
	   parsename(replace(OwnerAddress, ',', '.'), 2) as City,
	   parsename(replace(OwnerAddress, ',', '.'), 3) as Address
from NashvilleHousing

alter table NashvilleHousing
add OwnerAddressSplit nvarchar(255)

update NashvilleHousing
set OwnerAddressSplit = parsename(replace(OwnerAddress, ',', '.'), 3)

alter table NashvilleHousing
add OwnerCitySplit nvarchar(255)

update NashvilleHousing
set OwnerCitySplit = parsename(replace(OwnerAddress, ',', '.'), 2)

alter table NashvilleHousing
add OwnerStateSplit nvarchar(255)

update NashvilleHousing
set OwnerStateSplit = parsename(replace(OwnerAddress, ',', '.'), 1)


-- Y and N to Yes and No in SoldAsVacant
select distinct SoldAsVacant
from NashvilleHousing

select SoldAsVacant, count(UniqueID)
from NashvilleHousing
group by SoldAsVacant
order by count(UniqueID)

select SoldAsVacant, 
	case when SoldAsVacant = 'N' then 'No'
		 when SoldAsVacant = 'Y' then 'Yes'
		 else SoldAsVacant
		 end
from NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'N' then 'No'
		 when SoldAsVacant = 'Y' then 'Yes'
		 else SoldAsVacant
		 end


-- Delete unused columns
alter table NashvilleHousing
drop column SaleDate, PropertyAddress, OwnerAddress

select * 
from NashvilleHousing

select distinct LandUse from NashvilleHousing