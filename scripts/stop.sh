#!/bin/bash

set -e

APP_JAR=/home/ubuntu/myapp/mysite.jar
echo "[중지] 실행 중인 Spring Boot 애플리케이션 종료 시도"

set +e  # pgrep 실패해도 스크립트 중단 안 함
PID=$(pgrep -f "java -jar $APP_JAR")
set -e  # 다시 엄격 모드
echo "[중지] PID: $PID"

if [ -n "$PID" ]; then
  echo "[중지] 실행 중인 프로세스 발견 (PID: $PID), 종료합니다"
  kill "$PID"
  sleep 5
  if ps -p "$PID" > /dev/null; then
    echo "[강제 종료] 프로세스가 여전히 실행 중입니다. 강제 종료 시도"
    kill -9 "$PID"
  fi
  echo "[중지 완료] 애플리케이션 정상 종료"
else
  echo "[중지] 실행 중인 애플리케이션이 없습니다"
fi
