# 메뉴 최적화를 위한 홍차 전문 카페 데이터 분석

## 주제 선정

2021년부터 부모님께서 운영하시는 홍차 전문 카페에는 메뉴와 관련하여 두 가지 문제가 존재했다.
1. 메뉴에 제품을 추가하거나 제거하는 것부터 새로운 제품을 개발하는 것까지 메뉴와 관련된 의사 결정이 감으로 이루어졌음.
2. 메뉴가 많고 다양해서 직원들이 모든 제품의 레시피를 완전히 파악하고 일관된 품질로 제조하는 데 어려움을 겪고 있었음.

이러한 문제들을 해결하기 위해 POS 시스템에서 수집된 1년 치 매출 데이터를 분석하여 **모든 제품의 인기도를 확인**하고 **메뉴를 최적화**하는 프로젝트를 진행했다.

## 분석 목적

- 상대적으로 판매량이 부진한 **비인기 제품을 식별하고 제거**하여 메뉴 구성 조정
- 고객의 선호도를 파악하여 **새로운 제품을 개발할 때 참고** 자료로 활용
- 판매가 중단됐지만 상대적으로 인기가 있었던 제품은 **재출시**하여 메뉴 구성 조정

## 분석 결과 예상 (가설)

1. 홍차 전문 카페이기 때문에 홍차가 들어가지 않는 제품은 인기가 없을 것이다.
2. 여름에는 차가운 음료가 인기 있고, 겨울에는 따뜻한 음료가 인기 있을 것이다.
3. 메뉴판 상단에 위치한 제품들은 접근이 쉬워서 판매량이 많을 것이다.
4. 구매를 유도하는 추천 문구가 달린 제품들은 판매량이 많을 것이다.
5. 판매가 중단되어 메뉴에서 제거된 제품들은 실제로 인기가 없었을 것이다.

## 데이터 전처리
[MySQL 활용 데이터 전처리](https://github.com/yejinannachoi/cafe_menu_optimization/blob/main/menu%20optimization%20(kor)/preprocessing.sql)

## 탐색적 데이터 분석 (EDA)
[MySQL 활용 EDA](https://github.com/yejinannachoi/cafe_menu_optimization/blob/main/menu%20optimization%20(kor)/EDA.sql)

## 데이터 시각화
[Python 활용 데이터 시각화](https://github.com/yejinannachoi/cafe_menu_optimization/blob/main/menu%20optimization%20(kor)/EDA_visualization.ipynb)

## 최종 프로젝트 자료
데이터 설명, 분석 결과, 액션 아이템, 회고 등 주요 내용이 포함되어 있습니다.  
[노션 활용 프로젝트 자료](https://github.com/yejinannachoi/cafe_menu_optimization/blob/main/menu%20optimization%20(kor)/final_deliverable.pdf)
