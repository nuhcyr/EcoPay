# EcoPay
🌿 EcoPay: AI Tabanlı Yeşil Finans Yönetimi
EcoPay, harcamalarınızı yapay zeka ile analiz ederek çevre dostu tüketimi teşvik eden ve "Yeşil Puan" sistemiyle oyunlaştıran yeni nesil bir dijital cüzdan uygulamasıdır.

🚀 Proje Vizyonu
Kullanıcıların günlük harcama alışkanlıklarını (market, ulaşım, yemek vb.) analiz ederek, karbon ayak izini azaltan işletmeleri tercih etmelerini sağlamak ve kurumsal/bireysel bazda "Yeşil Lig" sıralamaları oluşturmak.

🛠️ Teknoloji Yığını (Tech Stack)
Backend: Java 21, Spring Boot 3.x
Persistence: Spring Data JPA, Hibernate (Code-First Approach)
Database: Supabase (PostgreSQL + Auth + Realtime)
Security: Spring Security & JWT (JSON Web Token)
Caching: Redis (Merchant Score Caching)

## Backend Quickstart

### 1) Ortam Degiskenleri
`.env.example` dosyasini kopyalayip kendi degerlerinizi girin.

Gerekli degiskenler:
- `DB_URL`
- `DB_USERNAME`
- `DB_PASSWORD`
- `JWT_SECRET`
- `REDIS_HOST`
- `REDIS_PORT`

### 2) Uygulamayi Calistirma
```bash
mvn spring-boot:run
```

Swagger:
- `http://localhost:8080/swagger-ui`

### 3) API Akisi (Onerilen Sira)
1. `POST /api/v1/auth/register`
2. `POST /api/v1/auth/login` -> `accessToken` al
3. `GET /api/v1/users/me`
4. `POST /api/v1/activities`
5. `GET /api/v1/activities/me`
6. `GET /api/v1/rewards`
7. `POST /api/v1/rewards/{rewardId}/claim`
8. `PATCH /api/v1/rewards/me/{userRewardId}/use`
9. `GET /api/v1/reports/me/summary`

Tum korumali endpointler icin header:
- `Authorization: Bearer <accessToken>`

### 4) Postman
Hazir koleksiyon:
- `postman/EcoPay.postman_collection.json`
