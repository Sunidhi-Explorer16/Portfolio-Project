--Cleaning Data in sql queries
Select * from PortfolioProject..[NashvilleHousing]


--Standardize Date Format

Select SaleDate,convert(date,SaleDate) as saledateconverted
from PortfolioProject..[NashvilleHousing] 

Update PortfolioProject..[NashvilleHousing] 
Set saledate = convert(date,SaleDate)

ALTER TABLE PortfolioProject..[NashvilleHousing] 
DROP COLUMN saledateconverted 

--Populate Property Address data

Select a.parcelid,a.propertyaddress,b.parcelid,b.propertyaddress,ISNULL(a.propertyaddress,b.propertyaddress)
as NullPropertyAddress from PortfolioProject..[NashvilleHousing] as a
join PortfolioProject..[NashvilleHousing] as b on a.parcelid = b.parcelid
and a.uniqueid<>b.uniqueid where a.propertyaddress is null


Update a
Set propertyaddress = ISNULL(a.propertyaddress,b.propertyaddress)
from PortfolioProject..[NashvilleHousing] as a
join PortfolioProject..[NashvilleHousing] as b on a.parcelid = b.parcelid
and a.uniqueid<>b.uniqueid where a.propertyaddress is null



--Breaking out address into individual columns (address,city,state)

Select propertyaddress 
from PortfolioProject..[NashvilleHousing] 

Select SUBSTRING(propertyaddress,1,charindex(',',propertyaddress)-1) as Address,
SUBSTRING(propertyaddress,charindex(',',propertyaddress)+1,len(propertyaddress)) as City
from PortfolioProject..[NashvilleHousing] 

ALTER TABLE PortfolioProject..[NashvilleHousing] 
Add propertysplitaddress Nvarchar(255)

Update PortfolioProject..[NashvilleHousing]  
Set propertysplitaddress = SUBSTRING(propertyaddress,1,charindex(',',propertyaddress)-1)

ALTER TABLE PortfolioProject..[NashvilleHousing] 
Add propertysplitcity Nvarchar(255)

Update PortfolioProject..[NashvilleHousing] 
Set propertysplitcity = SUBSTRING(propertyaddress,charindex(',',propertyaddress)+1,len(propertyaddress)) 

Select * from PortfolioProject..[NashvilleHousing]

Select 
PARSENAME(REPLACE(owneraddress,',','.'),3) as address
PARSENAME(REPLACE(owneraddress,',','.'),2) as city
PARSENAME(REPLACE(owneraddress,',','.'),1) as state
from PortfolioProject..[NashvilleHousing]

Alter table  PortfolioProject..[NashvilleHousing] 
Add ownersplitaddress Nvarchar(255)

Update PortfolioProject..[NashvilleHousing]  
Set ownersplitaddress = PARSENAME(REPLACE(owneraddress,',','.'),3)

ALTER TABLE PortfolioProject..[NashvilleHousing] 
Add ownersplitcity Nvarchar(255)

Update PortfolioProject..[NashvilleHousing] 
Set ownersplitcity =  PARSENAME(REPLACE(owneraddress,',','.'),2) 

ALTER TABLE PortfolioProject..[NashvilleHousing] 
Add ownersplitstate Nvarchar(255)

Update PortfolioProject..[NashvilleHousing] 
Set ownersplitstate =  PARSENAME(REPLACE(owneraddress,',','.'),1) 

Select * from PortfolioProject..[NashvilleHousing]


--Change Y and N into yes and no in "sold as vacant" field

Select distinct(soldasvacant) from PortfolioProject..[NashvilleHousing]
Update PortfolioProject..[NashvilleHousing] 
Set SoldAsVacant = 'No'  where SoldAsVacant = 'N' 
Update PortfolioProject..[NashvilleHousing] 
Set SoldAsVacant = 'Yes'  where SoldAsVacant = 'Y' 
Select distinct(soldasvacant), count(soldasvacant) from PortfolioProject..[NashvilleHousing]
group by SoldAsVacant


--Another way


Select soldasvacant ,
 CASE when soldasvacant = 'Y' then 'Yes'
      when soldasvacant = 'N' then 'No'
	  ELSE soldasvacant
	  END
from PortfolioProject..[NashvilleHousing]

Update PortfolioProject..[NashvilleHousing] 
SET SoldAsVacant = CASE when soldasvacant = 'Y' then 'Yes'
      when soldasvacant = 'N' then 'No'
	  ELSE soldasvacant
	  END


--Remove duplicates

WITH RowNumCTE AS(
Select * ,
ROW_NUMBER() OVER(
PARTITION BY ParcelId,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY 
			 UniqueID
			 )row_num
from PortfolioProject..[NashvilleHousing]
--ORDER BY ParcelID
)
Select * from RowNumCTE
where row_num > 1
ORDER BY PropertyAddress


--Delete unused columns

Select * from PortfolioProject..[NashvilleHousing]

 ALTER TABLE PortfolioProject..[NashvilleHousing]
 DROP COLUMN propertyaddress,owneraddress

 ALTER TABLE PortfolioProject..[NashvilleHousing]
 DROP COLUMN landuse,taxdistrict,saledate





