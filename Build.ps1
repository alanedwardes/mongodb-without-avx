 param (
    [Parameter(Mandatory=$true)][string]$version
 )

docker build --build-arg MONGO_VERSION=$version --tag public.ecr.aws/alanedwardes/mongodb-without-avx:$version .

docker push public.ecr.aws/alanedwardes/mongodb-without-avx:$version
