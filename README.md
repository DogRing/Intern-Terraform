# Terraform을 이용한 AWS ECS 구축 및 모니터링
2022.10 ~ 2022.11  
인턴 개인 과제
  
![ECS](https://github.com/DogRing/Intern-Terraform/assets/33221641/e051de0a-7de0-4f16-b052-9f14a26f5fcc)

# Terraform
하나의 큰 서비스 전체를 관리  
Pinpoint APM, DB, S3 등을 한번에 생성  
> 중점: MicroService별 추가와 삭제, 연동이 간편하게 설계  

# Gitlab Runner
이미지 빌드와 저장 자동화
## Image Build
gitlab runner를 이용한 소스코드 빌드  
Java Source -> image with jar -> AWS ECR  
> ECR 트리거로 CodePipeline 실행
## APM agent
Dockerfile을 이용해 Pinpoint-agent 설치  
## DB Connect
DataBase의 IP, ID, PW는 Terraform에서 관리
> 개발자가 DB에 대한 신경을 쓰지 않기 위함  
## Log 관리
APP에서 S3로 직접 저장하는 방식
> 보안에도 좋지 않고, 성능에도 영향을 끼침  
> 신뢰성 면에서도 좋지 않음  
> 개선방향: EFS나 공유폴더 등으로 관리 후 S3에 저장