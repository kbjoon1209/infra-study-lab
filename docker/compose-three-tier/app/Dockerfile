FROM python:3.12-slim

# Container 내부 작업 디렉터리.
WORKDIR /app

# Library 목록을 먼저 복사.
COPY requirements.txt .

# 필요한 Python Package 설치.
RUN pip install --no-cache-dir -r requirements.txt

# App Code 복사.
COPY app.py .

# App이 Container 내부 5000번 Port를 사용한다는 정보.
# EXPOSE만으로 Host에 Port가 공개되지는 않는다.
EXPOSE 5000

# Container 시작 시 Python App 실행.
CMD ["python", "app.py"]