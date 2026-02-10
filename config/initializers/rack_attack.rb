class Rack::Attack
  # 1. 安全なIPリスト（自分自身など）
  # 開発環境（localhost）からのアクセスは制限しない設定
  safelist("allow-localhost") do |req|
    "127.0.0.1" == req.ip || "::1" == req.ip
  end

  # 2. 全体的なリクエスト制限（負荷対策）
  # 同じIPから 5分間に300回 まで
  throttle("req/ip", limit: 300, period: 5.minutes) do |req|
    req.ip
  end

  # 3. 投稿の連打対策（荒らし対策）
  # POST /posts へのアクセスを 1分間に10回 まで
  throttle("posts/ip", limit: 10, period: 1.minute) do |req|
    if req.path == "/posts" && req.post?
      req.ip
    end
  end

  # 4. ログインの総当たり攻撃対策
  # POST /users/sign_in へのアクセスを 1分間に20回 まで
  self.throttled_responder = lambda do |request|
    match_data = request.env["rack.attack.match_data"]
    now = match_data[:epoch_time]

    retry_after = (match_data[:period] - (now % match_data[:period])).to_i

    [
      429,
      {
        "Content-Type" => "text/plain; charset=utf-8",
        "Retry-After" => retry_after.to_s
      },
      [ "リクエストが多すぎます。\nあと #{retry_after} 秒待ってから再試行してください。" ]
    ]
  end
end
