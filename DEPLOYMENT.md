# 운영 서버 배포 가이드

## 현재 상황
- ✅ 로컬에서 Vue 개발 서버 실행 중 (http://localhost:5173)
- ✅ Rails 서버 실행 중 (http://localhost:3000)
- ✅ Vue 앱 빌드 완료 (`client/dist/`)

## 배포 방법

### 옵션 1: 자동 배포 스크립트 사용 (권장)

**1. 로컬에서 실행:**
```bash
./deploy_to_production.sh
```

이 스크립트는:
- Vue 앱 빌드
- Git에 커밋 및 푸시
- 운영 서버에서 실행할 명령어 안내

**2. 운영 서버에서 실행:**
```bash
ssh your-server
cd /var/www/ssl_reseller_rails
bash deploy_vue.sh
```

---

### 옵션 2: 수동 배포

**1. 로컬에서 코드 푸시:**
```bash
# Vue 앱 빌드
cd client
npm run build

# Git 푸시
cd ..
git add .
git commit -m "Update ticket system"
git push
```

**2. 운영 서버 접속:**
```bash
ssh your-server
cd /var/www/ssl_reseller_rails
```

**3. 운영 서버에서 배포:**
```bash
# 최신 코드 가져오기
git pull

# Vue 앱 빌드
cd client
npm install
npm run build

# public 디렉토리로 복사
cd ..
mkdir -p public/tickets
cp -r client/dist/* public/tickets/

# Caddy 리로드
sudo systemctl reload caddy
```

---

### 옵션 3: SCP로 직접 전송 (빠른 테스트용)

```bash
# 로컬에서 빌드된 파일만 전송
scp -r client/dist/* your-server:/var/www/ssl_reseller_rails/public/tickets/

# 운영 서버에서 Caddy 리로드
ssh your-server "sudo systemctl reload caddy"
```

---

## 운영 서버 Caddyfile 수정

`/etc/caddy/Caddyfile`에 다음 내용 추가:

```caddy
certgate.duckdns.org {
        root * /var/www/ssl_reseller_rails/public

        # 정적 파일 직접 서빙
        @static {
                path /assets/*
                path /tickets/*      # ← 이 줄 추가
                path /favicon.ico
                path /robots.txt
        }
        file_server @static

        reverse_proxy localhost:3000 {
             header_up Host {host}
             header_up X-Forwarded-Host {host}
             header_up X-Forwarded-Port {server_port}
             header_up X-Forwarded-Proto https
             header_up X-Forwarded-Ssl on
             header_up X-Forwarded-For {remote}
             header_up X-Real-IP {remote}
             header_up Cookie {http.request.header.Cookie}
       }

        log {
                output file /var/log/caddy/ssl_reseller.log
                format json
        }
}
```

수정 후:
```bash
sudo systemctl reload caddy
```

---

## 환경 변수 설정

**운영 서버** `/var/www/ssl_reseller_rails/.env`:
```bash
# Vue dev server는 사용하지 않음
# VUE_DEV_SERVER=false
```

**로컬** `.env`:
```bash
# Vue dev server 사용
VUE_DEV_SERVER=true
```

---

## 확인 사항

배포 후 확인:
1. ✅ https://certgate.duckdns.org/tickets/new 접속
2. ✅ 티켓 생성 폼이 보이는지 확인
3. ✅ 브라우저 개발자 도구에서 에러가 없는지 확인
4. ✅ API 호출이 잘 되는지 확인 (`/api/v1/tickets`)

---

## 향후 배포 흐름

### 개발 환경 (로컬)
```
코드 수정 → Vue dev server에서 확인 → Git 커밋
```

### 운영 환경
```
Git 푸시 → 운영 서버 접속 → git pull → npm run build → 복사 → Caddy 리로드
```

또는 CI/CD 도구 사용 (GitHub Actions, GitLab CI 등)

---

## 문제 해결

**Vue 앱이 안 보일 때:**
```bash
# 운영 서버에서
ls -la /var/www/ssl_reseller_rails/public/tickets/
# index.html 파일이 있는지 확인

# Caddy 로그 확인
sudo tail -f /var/log/caddy/ssl_reseller.log
```

**API 호출 실패:**
- Rails 서버가 실행 중인지 확인
- CORS 설정 확인
- 브라우저 개발자 도구 Network 탭 확인
