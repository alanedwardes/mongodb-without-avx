param (
    [Parameter(Mandatory=$true)][string]$version
)

$ErrorActionPreference = "Stop"

cmd /c 'aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws'

docker build --build-arg MONGO_VERSION=$version --tag public.ecr.aws/alanedwardes/mongodb-without-avx:$version .

docker push public.ecr.aws/alanedwardes/mongodb-without-avx:$version
