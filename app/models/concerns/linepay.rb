module Linepay
  extend ActiveSupport::Concern

  def request_response
    self.requset_body()
    self.prepare_require_signature()
    self.require_header()
    @uri = URI.parse("https://sandbox-api-pay.line.me/v3/payments/request")
    self.get_response()
  end

  def confirm_response(transactionId)
    self.confirm_body()
    self.prepare_confirm_signature(transactionId)
    self.require_header()
    @uri = URI.parse("https://sandbox-api-pay.line.me" + "#{@post_uri}")
    self.get_response()
  end

  def refund_response
    self.refund_body()
    self.prepare_refund_signature()
    self.require_header()
    @uri = URI.parse("https://sandbox-api-pay.line.me" + "#{@post_uri}")
    self.get_response()
  end

  private
  def requset_body
    @body = { amount: self.amount,
              currency: self.currency,
              orderId: self.order_id,
              packages: [ { id: self.packages_id,
                            amount: self.amount,
                            products: [ {
                            name: self.name,
                            quantity: self.quantity,
                            price: self.price } ] } ],
              redirectUrls: { confirmUrl: "http://127.0.0.1:3000/confirm",
                              cancelUrl: "http://127.0.0.1:3000/cancel" } }
  end

  def confirm_body
    @body = { amount: self.amount,
              currency: self.currency
    }
  end

  def refund_body
    @bady = {refundAmount: self.amount}
  end

  def get_nonce_and_secrect
    @nonce = SecureRandom.uuid
    @secrect = ENV["lines_pay_ChannelSecret"]
  end

  def prepare_require_signature
    get_nonce_and_secrect()
    @post_uri = "/v3/payments/request"
  end

  def prepare_confirm_signature(transactionId)
    get_nonce_and_secrect()
    @post_uri = "/v3/payments/" + "#{transactionId}" + "/confirm"
  end

  def prepare_refund_signature
    get_nonce_and_secrect()
    @post_uri = "/v3/payments/" + "#{self.transactionid}" + "/refund"
  end

  def get_signature
    message = "#{@secrect}#{@post_uri}#{@body.to_json}#{@nonce}"
    hash = OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), @secrect, message)
    @signature = Base64.strict_encode64(hash)
  end

  def require_header
    get_signature()
    @header = {"Content-Type": "application/json",
          "X-LINE-ChannelId": ENV["line_pay_ChannelID"],
          "X-LINE-Authorization-Nonce": @nonce,
          "X-LINE-Authorization": @signature }
  end

  def get_response
    http = Net::HTTP.new(@uri.host, @uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(@uri.request_uri, @header)
    request.body = @body.to_json
    @response = http.request(request)
  end
end