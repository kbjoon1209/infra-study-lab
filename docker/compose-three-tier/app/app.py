import os

import pymysql
from flask import Flask, jsonify

app = Flask(__name__)


@app.get("/health")
def health():
    """
    App 자체가 HTTP 요청에 응답 가능한지 확인한다.
    DB 연결 여부는 검사하지 않는다.
    """
    return jsonify(status="ok", service="app"), 200


@app.get("/db-check")
def db_check():
    """
    환경변수에서 DB 접속 정보를 읽고,
    MySQL에 실제로 연결한 뒤 SELECT 1을 수행한다.
    """
    connection = None

    try:
        connection = pymysql.connect(
            host=os.getenv("DB_HOST", "db"),
            port=int(os.getenv("DB_PORT", "3306")),
            user=os.getenv("DB_USER", "labuser"),
            password=os.getenv("DB_PASSWORD", "labpass"),
            database=os.getenv("DB_NAME", "labdb"),
            connect_timeout=3,
        )

        with connection.cursor() as cursor:
            cursor.execute("SELECT 1")
            result = cursor.fetchone()

        return jsonify(
            status="ok",
            database="reachable",
            result=result[0],
        ), 200

    except Exception as exc:
        # 상세 장애 내용은 App Log에 남긴다.
        app.logger.exception("Database check failed")

        # Client에는 예외 전체 내용을 그대로 노출하지 않는다.
        return jsonify(
            status="error",
            database="unreachable",
            error_type=type(exc).__name__,
        ), 503

    finally:
        if connection is not None:
            connection.close()


if __name__ == "__main__":
    # 0.0.0.0:
    # Container 외부의 다른 Container에서도 접근 가능하게 Listen.
    #
    # 5000:
    # App Container 내부 TCP Port.
    app.run(host="0.0.0.0", port=5000)