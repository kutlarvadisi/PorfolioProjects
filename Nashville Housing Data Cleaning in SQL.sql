
-- Standardize Date Format
select SaleDate2, convert(date,saledate) from [NashvilleHousing ]

update [NashvilleHousing ] set SaleDate= convert(date,saledate)

ALter Table [NashvilleHousing ]
Add SaleDate2 date;

update [NashvilleHousing ] set SaleDate2= convert(date,saledate)

-- Populate Property Address data
select* from [NashvilleHousing ]
order by ParcelID

select a.ParcelID, a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from [NashvilleHousing ] a
join [NashvilleHousing ] b
on a.ParcelID=b.ParcelID and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from [NashvilleHousing ] a
join [NashvilleHousing ] b
on a.ParcelID=b.ParcelID and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

-- Breaking out Address into Individual Columns (Address, City, State)
select substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address, 
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as City 
from [NashvilleHousing ]

Alter Table [NashvilleHousing ]
Add PropretySplitAddress nvarchar(250)

Update [NashvilleHousing ]
set PropretySplitAddress=substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

Alter Table [NashvilleHousing ]
Add PropertySplitCity nvarchar(250)

Update [NashvilleHousing ]
Set PropertySplitCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

Select* From [NashvilleHousing ]

Select OwnerAddress from [NashvilleHousing ]

Select PARSENAME(replace(OwnerAddress,',','.'),3),
PARSENAME(replace(OwnerAddress,',','.'),2),
PARSENAME(replace(OwnerAddress,',','.'),1)
from [NashvilleHousing ]

Alter Table [NashvilleHousing ]
Add OwnerSpiltAddres nvarchar(250)

Update [NashvilleHousing ]
set OwnerSpiltAddres=PARSENAME(replace(OwnerAddress,',','.'),3)

Alter Table [NashvilleHousing ]
Add OwnerSpiltCity nvarchar(250)

Update [NashvilleHousing ]
set OwnerSpiltCity=PARSENAME(replace(OwnerAddress,',','.'),2)

Alter Table [NashvilleHousing ]
Add OwnerSpiltState nvarchar(250)

Update [NashvilleHousing ]
set OwnerSpiltState=PARSENAME(replace(OwnerAddress,',','.'),1)

Select * from [NashvilleHousing ]

-- Change Y and N to Yes and No in "Sold as Vacant" field
Select distinct(SoldAsVacant), count(SoldAsVacant) as CountSoldAsVacant
from [NashvilleHousing ]
group by SoldAsVacant
order by 2

select SoldAsVacant,
case
when SoldAsVacant='Y' then 'Yes'
when SoldAsVacant='N' then 'No'
Else SoldAsVacant
End
from [NashvilleHousing ]

Update [NashvilleHousing ]
Set SoldAsVacant=case
when SoldAsVacant='Y' then 'Yes'
when SoldAsVacant='N' then 'No'
Else SoldAsVacant
End

-- Remove Duplicates
With DuplicateRCTE As (
Select ParcelID, PropertyAddress, SalePrice, SaleDate,LegalReference, COUNT(*) as DuplicateCount
From [NashvilleHousing ]
Group by  ParcelID, PropertyAddress, SalePrice, SaleDate,LegalReference
having count(*)>1
)

Delete nh
From [NashvilleHousing ] nh
Inner Join DuplicateRCTE d
On nh.ParcelID=d.ParcelID 
And nh.PropertyAddress=d.PropertyAddress
And nh.SalePrice=d.SalePrice
And nh.SaleDate=d.SaleDate
And nh.LegalReference=d.LegalReference

Alter Table [NashvilleHousing ]
Drop Column OwnerAddress, PropertyAddress, TaxDistrict 

Alter Table [NashvilleHousing ]
Drop Column SaleDate

Select * 
From [NashvilleHousing ]