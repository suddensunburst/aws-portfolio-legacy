from flask import Flask, request, jsonify
import uuid
from datetime import datetime, timezone
import boto3
import os

# appを初期化
app = Flask(__name__)

# DynamoDBクライアントを初期化
dynamodb = boto3.resource("dynamodb", region_name=os.environ["AWS_DEFAULT_REGION"])
table = dynamodb.Table("portfolio-messages")

# GET /
@app.route("/")
def index():
    return "<h1>portfolio</h1>"

# GET|POST /messages
# GETの場合:
#   limitパラメータを取得
#   limitがあれば件数を絞って返す
#   なければ全件返す
# POSTの場合:
#   リクエストボディを取得
#   id, content, created_atを持つmsgを作る
#   itemに追加
#   201で返す
@app.route("/messages", methods = ["GET", "POST"])
def handle_messages():
    if request.method == "GET":
        limit = request.args.get("limit")
        result = table.scan()
        items = result["Items"]
        if limit is not None:
            items = items[:int(limit)]
        return jsonify(items)

    data = request.get_json()
    msg = {
        "id": str(uuid.uuid4()),
        "content": data["content"],
        "created_at": datetime.now(timezone.utc).isoformat()
    }
    table.put_item(Item=msg)
    return jsonify(msg), 201

# DELETE /messages/<id>
#   idでアイテムを消す
#   204で返す
@app.route("/messages/<id>", methods = ["DELETE"])
def delete_message(id):
    table.delete_item(Key={"id": id})
    return "", 204

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)