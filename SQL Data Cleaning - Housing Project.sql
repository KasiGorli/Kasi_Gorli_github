select * from Portfolio_Project.[dbo].[Nashville_Hotel_data]

-- Standardizing Date Format

select saledate,
	convert(date,saledate)
from Portfolio_Project.[dbo].[Nashville_Hotel_data]


alter table Portfolio_Project.[dbo].[Nashville_Hotel_data]
add saledateconverted date;

Update Portfolio_Project.[dbo].[Nashville_Hotel_data]
set saledateconverted = convert(date,saledate)

select saledateconverted from Portfolio_Project.[dbo].[Nashville_Hotel_data]


-----Populate Property Address data

select *
from Portfolio_Project.[dbo].[Nashville_Hotel_data]
where Propertyaddress is null
order by parcelid

Select a.parcelid, 
	b.parcelid, 
	a.propertyaddress, 
	b.propertyaddress, 
	isnull(a.propertyaddress, b.propertyaddress)
from Portfolio_Project.[dbo].[Nashville_Hotel_data] a
	join Portfolio_Project.[dbo].[Nashville_Hotel_data] b
	on a.parcelid = b.parcelid
	and a.uniqueid <> b.uniqueid
where a.propertyaddress is null

update a
set propertyaddress = isnull(a.propertyaddress, b.propertyaddress)
from Portfolio_Project.[dbo].[Nashville_Hotel_data] a
	join Portfolio_Project.[dbo].[Nashville_Hotel_data] b
	on a.parcelid = b.parcelid
	and a.uniqueid <> b.uniqueid
where a.propertyaddress is null

---- Breaking out address into individual columns( Address, City, State) 

select Propertyaddress
	from Portfolio_Project.[dbo].[Nashville_Hotel_data]

Select substring(Propertyaddress,1,charindex(',',Propertyaddress)-1) as address,
	ltrim(substring(propertyaddress,charindex(',',Propertyaddress)+1, LEN(Propertyaddress))) as Address
	from Portfolio_Project.[dbo].[Nashville_Hotel_data]

Alter table Portfolio_Project.[dbo].[Nashville_Hotel_data]
add Property_SPlit_Address nvarchar(255)

update Portfolio_Project.[dbo].[Nashville_Hotel_data]
set Property_SPlit_Address = substring(Propertyaddress,1,charindex(',',Propertyaddress)-1)

alter table Portfolio_Project.[dbo].[Nashville_Hotel_data]
add Property_split_city nvarchar(255)

update Portfolio_Project.[dbo].[Nashville_Hotel_data]
set Property_split_city = ltrim(substring(propertyaddress,charindex(',',Propertyaddress)+1, LEN(Propertyaddress)))

select *--Property_SPlit_Address,Property_split_city
	 from Portfolio_Project.[dbo].[Nashville_Hotel_data]

-- SPliting the owwner address

select owneraddress
	from Portfolio_Project.[dbo].[Nashville_Hotel_data]

select 
 PARSENAME(replace(owneraddress,',','.'),3) as owner_st,
 PARSENAME(replace(owneraddress,',','.'),2) as owner_city,
 PARSENAME(replace(owneraddress,',','.'),1) as owner_state
 from Portfolio_Project.[dbo].[Nashville_Hotel_data]

Alter table Portfolio_Project.[dbo].[Nashville_Hotel_data]
add Owner_street nvarchar(200)

update Portfolio_Project.[dbo].[Nashville_Hotel_data]
set Owner_street =  PARSENAME(replace(owneraddress,',','.'),3)

Alter table Portfolio_Project.[dbo].[Nashville_Hotel_data]
add Owner_city nvarchar(200)

update Portfolio_Project.[dbo].[Nashville_Hotel_data]
set Owner_city =  PARSENAME(replace(owneraddress,',','.'),2)

Alter table Portfolio_Project.[dbo].[Nashville_Hotel_data]
add Owner_state nvarchar(200)

update Portfolio_Project.[dbo].[Nashville_Hotel_data]
set Owner_state =  PARSENAME(replace(owneraddress,',','.'),1)

select * from Portfolio_Project.[dbo].[Nashville_Hotel_data]


--change Y and N to Yes and No in "Solid as Vacant"

select distinct(soldasvacant), count(soldasvacant)
from Portfolio_Project.[dbo].[Nashville_Hotel_data]
group by soldasvacant
order by 2

select soldasvacant,
	case when soldasvacant = 'Y' then 'Yes' 
	when soldasvacant = 'N' then 'NO' 
	else soldasvacant
	end
	from portfolio_Project.[dbo].[Nashville_Hotel_data]

update portfolio_Project.[dbo].[Nashville_Hotel_data]
set soldasvacant = case when soldasvacant = 'Y' then 'Yes' 
	when soldasvacant = 'N' then 'NO' 
	else soldasvacant
	end


--Remove Duplicates

with RowNumberCTE as
(
	select *,
	row_number() over(partition by parcelid, 
						propertyaddress,
						saleprice,
						saledate,
						legalreference
						order by uniqueid) as RN					
 from portfolio_Project.[dbo].[Nashville_Hotel_data]
--order by parcelid
)

Delete * from RowNumberCTE
where RN >1
--order by propertyaddress

--Delete unused columns

select * 
from portfolio_Project.[dbo].[Nashville_Hotel_data]

alter table portfolio_Project.[dbo].[Nashville_Hotel_data]
drop column Propertyaddress,owneraddress, Taxdistrict

alter table portfolio_Project.[dbo].[Nashville_Hotel_data]
drop column saledate
