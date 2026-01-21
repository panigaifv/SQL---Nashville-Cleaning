-- Limpando dados em Queries de SQL

SELECT *
	FROM PortfolioCleaning..NashvilleHousing

------------------------------------------------------------------

-- Formatando a data

SELECT SaleDate, CONVERT (Date, SaleDate) AS SaleDateConverted
	FROM PortfolioCleaning..NashvilleHousing

	--UPDATE NashvilleHousing
	--SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE PortfolioCleaning..NashvilleHousing
	ADD SaleDateConverted Date;

	UPDATE PortfolioCleaning..NashvilleHousing
	SET SaleDateConverted = CONVERT(Date , SaleDate)

SELECT SaleDateConverted
	FROM PortfolioCleaning..NashvilleHousing

--------------------------------------------------------------------

-- Endereço da Propriedade (Populate Property Address data)

SELECT PropertyAddress
	FROM PortfolioCleaning..NashvilleHousing
	WHERE PropertyAddress is NULL

SELECT a.ParcelID , a.PropertyAddress, b.ParcelID, b.PropertyAddress
	FROM PortfolioCleaning..NashvilleHousing a
	JOIN PortfolioCleaning..NashvilleHousing b
		ON a.ParcelID = b.ParcelID
		AND a.[UniqueID ] <> b.[UniqueID ]
	WHERE a.PropertyAddress is NULL

--Realizamos um Join da tabela com ela mesmo e dizemos onde 
-- A ParcelID é igual, mas que não se encontra na mesma linha
-- Então se existirem linhas onde a ParcelID são iguais, 
-- As UniqueIDs serão diferentes (pois são únicas) e são estes
--resgistros que irão popular nosso resultado do Query.
-- Com a última linha que foi adicionada posteriormente,
-- conseguimos identificar diferenças entre as 2 colunas
-- Onde um endereço existe, porém, na a.propertyaddress não

-- O próximo Query com a função ISNULL indica a nova coluna
-- que irá popular a coluna com os valores NULLs.

SELECT a.ParcelID ,
a.PropertyAddress ,
b.ParcelID ,
b.PropertyAddress ,
ISNULL (a.PropertyAddress , b.PropertyAddress)
	FROM PortfolioCleaning..NashvilleHousing a
	JOIN PortfolioCleaning..NashvilleHousing b
		ON a.ParcelID = b.ParcelID
		AND a.[UniqueID ] <> b.[UniqueID ]
	WHERE a.PropertyAddress is NULL

-- Agora iremos atualizar a tabela, populando onde, encontram-se
-- valores nulos, no caso, a segunda coluna (primeira PropertyAddress)

UPDATE a
SET PropertyAddress = ISNULL (a.PropertyAddress , b.PropertyAddress)
	FROM PortfolioCleaning..NashvilleHousing a
		JOIN PortfolioCleaning..NashvilleHousing b
		ON a.ParcelID = b.ParcelID
		AND a.[UniqueID ] <> b.[UniqueID ]
	WHERE a.PropertyAddress is NULL

-- Como resultado deste Query, agora não obtemos mais nenhum
-- valor nulo (NULL), na primeira coluna de PropertyAddress
-- Com isso, ao executarmos os Query anterior, só obtemos 
-- uma tabela vazia, sem conteúdo.

-- A função ISNULL no caso seleciona a primeira coluna (o primeiro
-- argumento) e preenche com o conteúdo da segunda (segundo argumento)
-- Pode-se também preencher com uma string. Exemplo:
-- ISNULL (a.PropertyAddress, 'No Address')

------------------------------------------------------------------
-- "Quebrando" endereços em colunas individuais (Endereço, Cidade, Estado)

SELECT PropertyAddress
	FROM PortfolioCleaning..NashvilleHousing

-- Percebemos que a coluna carece de um separador, com os dados
-- misturados, como números, endereço e cidade

SELECT 
	SUBSTRING (PropertyAddress, 1, CHARINDEX(',' , PropertyAddress)) AS Address
	FROM PortfolioCleaning..NashvilleHousing

-- Na linha substring temos o primeiro argumento sendo a coluna 
-- que queremos, o segundo argumento é a posição(1), e o terceiro
-- argumento, no caso, o CHARINDEX é o que vai buscar um valor
-- específico na coluna (pode ser um símbolo ou um nome como 'tom').
-- Ao abrirmos o parenteses, entre aspas temos o que estamos buscando
-- e após a vírgula onde estamos buscando.

-- Com esse Query, ainda obtemos uma vírgula ao final do endereço
-- Se selecionarmos apenas o CHARINDEX, temos uma coluna nova
-- com um número, este número indica a posição onde a vírgula 
-- se encontra na coluna selecionada

SELECT 
	SUBSTRING (PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) -1) AS Address
	FROM PortfolioCleaning..NashvilleHousing

-- Ao adicinoarmos o -1 após o parênteses do CHARINDEX, dizemos
-- para eliminar a última posição, e com isso, a vírgula é eliminada

-- Porém, ainda temos o problema com o separador/delimitador, onde
-- temos os Estados misturados com o endereço (rua?), para isso, 
-- temos que realizar mais uma operação com o separador, onde 
-- acrescentamos um, ao final do PropertyAddress

SELECT
	SUBSTRING (PropertyAddress, 1, CHARINDEX (',' , PropertyAddress) -1) As PropertySplitAddress,
	SUBSTRING (PropertyAddress, CHARINDEX(',' , PropertyAddress) +1 , LEN(PropertyAddress)) As PropertySplitCity
	FROM PortfolioCleaning..NashvilleHousing

-- Ao retirarmos o +1, a vírgula inicia os valores da segunda
-- coluna address, onde se encontram os Estados.
-- Com isso não podemos separar 2 valores de uma coluna, sem criar
-- uma outra coluna, com isso, vamos criar 2 colunas novas e adicionar
-- os valores nelas. 

	ALTER TABLE PortfolioCleaning..NashvilleHousing
	Add PropertySplitAddress nvarchar(255);

	UPDATE PortfolioCleaning..NashvilleHousing
	SET	PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX (',' , PropertyAddress) -1)

	ALTER TABLE PortfolioCleaning..NashvilleHousing
	ADD PropertySplitCity nvarchar(255);

	UPDATE PortfolioCleaning..NashvilleHousing
	SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',' , PropertyAddress) +1 , LEN(PropertyAddress))

SELECT *
	FROM PortfolioCleaning..NashvilleHousing

-- Os dados das novas colunas são alocados nas últimas colunas da
-- planilha. Só mover o cursor para visualizá-los.
-- Ao fazer o UPDATE, necessitamos especificar que tipo de dados
-- serão os dados das novas colunas no caso, a substring inteira realizada.

-------------------------------------------------------------

-- Agora vamos trabalhar com os OwnerAddress

SELECT OwnerAddress
	FROM PortfolioCleaning..NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
	FROM PortfolioCleaning..NashvilleHousing

-- A função PARSENAME funciona apenas com pontos, por isso, vamos[
-- reaalizar a substituição (replace) das vírgulas para ponto.

-- O PARSENAME realiza as modificações em ordem contrária ao esperado
-- Por isso, ao executarmos o Query apenas da forma que se encontra
-- obtemos apenas o Estado que no caso visualizamos TN - Tennesse.

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
	FROM PortfolioCleaning..NashvilleHousing

-- Com este procedimento, fica mais fácil do que estipular substrings
-- para a organização dos dados.

	ALTER TABLE PortfolioCleaning..NashvilleHousing
	Add OwnerSplitAddress nvarchar(255);

	UPDATE PortfolioCleaning..NashvilleHousing
	SET	OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

	ALTER TABLE PortfolioCleaning..NashvilleHousing
	ADD OwnerSplitCity nvarchar(255);

	UPDATE PortfolioCleaning..NashvilleHousing
	SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

	ALTER TABLE PortfolioCleaning..NashvilleHousing
	Add OwnerSplitState nvarchar(255);

	UPDATE PortfolioCleaning..NashvilleHousing
	SET	OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--------------------------------------------------------------------

-- Agora trabalharemos a coluna SoldAsVacant, alterando valores
-- de Y e N para Yes e No.

SELECT Distinct(SoldAsVacant), COUNT (SoldAsVacant)
	FROM PortfolioCleaning..NashvilleHousing
	GROUP BY SoldAsVacant
	ORDER BY 2

-- Aqui vemos os valores diferentes da coluna em questão


SELECT SoldAsVacant,
	CASE
		When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
	FROM PortfolioCleaning..NashvilleHousing

UPDATE PortfolioCleaning..NashvilleHousing
	SET SoldAsVacant = 	CASE
							When SoldAsVacant = 'Y' THEN 'Yes'
							When SoldAsVacant = 'N' THEN 'No'
							ELSE SoldAsVacant
						END

-- Para verificarmos se tudo realmente foi atualizado, basta
-- executar o Query Select com o argumento Distinct novamente
-- E percebemos que funcionou.


------------------------------------------------------------------

-- Removendo Duplicatas

-- Apesar não ser o ideal é possível fazer a remoção de colunas
-- utilizando SQL.
-- Utilizaremos um CTE

-- Neste caso, temos que usar o Partition by com alguma coluna
-- que apresente apenas valores únicos sem repetições.

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
		PARTITION BY ParcelID, 
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
		ORDER BY UniqueID
			) row_num
	FROM PortfolioCleaning..NashvilleHousing
		--ORDER BY ParcelID
)	

DELETE
	FROM RowNumCTE
	Where row_num > 1
	
-- Com isso, as duplicatas foram removidas a partir da criação de
-- um CTE.

-----------------------------------------------------------------

-- Deletando colunas não utilizadas

ALTER TABLE PortfolioCleaning..NashvilleHousing
	DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate