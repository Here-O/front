# HereO

![image](https://github.com/Here-O/back/assets/71596178/c288437c-9d96-4127-9171-4773ac430014)

## 프로젝트 소개

Flutter와 Node.js, MongoDB를 사용한 사용자 위치 기반 활동 인증 투두리스트

## 개발환경

- Flutter
- Node.js
- MongoDB

## APK 파일
https://drive.google.com/file/d/1Dbu4iUicaLQWGJ8yc1EqdDd-jljKbYSS/view?usp=sharing

## 팀원

양준원 - 카이스트 산업공학과 22학번

한채연 - 숙명여대 IT공학과 20학번

## 주요기능

## 회원가입&로그인

<img src="https://github.com/Here-O/back/assets/71596178/9dd2fe1a-2ac8-4c41-908c-eca81c149d9a" width="30%" height="30%"/>
<img src="https://github.com/Here-O/back/assets/71596178/e4409efa-1f8b-4fa1-83ee-be60be1488be" width="30%" height="30%"/>

- 회원가입시 이름, 이메일, 비밀번호 입력
- 사용자를 userEmail로 확인하여, 이전에 가입한 적 있는 이메일이라면 가입 불가
- 로그인시 이메일과 비밀번호를 입력받아 db에 암호화된 값과 동일한지 판단하고, 동일하다면 jwt 토큰 반환
- 회원가입과 로그인을 제외한 모든 요청에서, 헤더에 ``Bearer 토큰`‘의  형태로 토큰을 함께 전송

## Map

<img src="https://github.com/Here-O/back/assets/71596178/2aff05de-bb6c-4eb7-b62e-8639c090a218" width="30%" height="30%"/>
<img src="https://github.com/Here-O/back/assets/71596178/10b01c99-68eb-47ff-a97f-3a370e35548f" width="30%" height="30%"/>

- 네이버 지도 api 벡터 맵
    - 네이버 지도 api 벡터 맵 띄우기
    - 내 위치 파란색 동그라미로 띄우기
    - 초록색 마커로 지정 위치 띄우기

- 위치 정보 검색하기
    - naver openapi 검색 기능을 활용해 검색어 query 넘겨주면 위치 정보 응답 얻음
    - 위치 정보 응답을 각각 검색 결과 창에 띄우기
    

## Todolist

<img src="https://github.com/Here-O/back/assets/71596178/bd28cfbb-22e5-4eb9-a45d-3d6a7be2d9ff" width="30%" height="30%"/>
<img src="https://github.com/Here-O/back/assets/71596178/4145c82a-8533-4d7b-8d17-8c04d5b275bc" width="30%" height="30%"/>
<img src="https://github.com/Here-O/back/assets/71596178/55e0722a-33c9-406a-aeb2-533312e04e7e" width="30%" height="30%"/>
<img src="https://github.com/Here-O/back/assets/71596178/e0315c21-e33c-4340-b9a4-a1f0bb907c83" width="30%" height="30%"/>


- 이전 날짜는 노랑, 오늘 날짜는 초록, 내일 이후부터는 회색으로 구분하여 표시
- Todo 작성시 지도에서 검색한 위치와 내용, 루틴 여부를 함께 작성
- Todo 내용 수정 기능
- Todo 인증 기능
    - 투두 뷰 탭에서 횡 스크롤 액션 취할 시 애니메이션과 함께 맵 탭으로 넘어가며 인증 버튼 띄우기
    - 현재 사용자 위치와 태그된 위치를 확인한 뒤 300m이내일 경우 `눌러서 인증 완료하기` 버튼 활성화
    - 벗어난 경우 `더 가깝게 가주세요!`

## My points

<img src="https://github.com/Here-O/back/assets/71596178/25542ab4-a700-4e52-a471-f8f120fd2029" width="30%" height="30%"/>
<img src="https://github.com/Here-O/back/assets/71596178/395ec36d-192f-4593-aacb-48a897898157" width="30%" height="30%"/>

- 내 이미지 클릭시 갤러리로 이동하여 프로필 사진 변경 가능
- AWS의 S3를 사용하여 사용자의 이미지 저장
- 나의 포인트 적립 내역, 총 포인트, 이미지 조회
- 포인트 상위 5명 유저의 이름, 이미지, 총 포인트, 적립 내역 조회 가능
