class Order < ApplicationRecord
  belongs_to :product
  validates :quantity, presence: true, numericality: { only_integer: true }
  after_create :body

  include AASM

  aasm column: :state do
    state :pending, initial: true
    state :confirmed

    event :check do
      transitions from: :pending, to: :confirmed
    end
  end


  def total_amount
    self.amount = self.quantity * self.product.price
  end

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

  def require_signature
    @nonce = SecureRandom.uuid
    self.requset_body
    secrect = ENV["lines_pay_ChannelSecret"]
    post_uri = "/v3/payments/request"
    message = "#{secrect}#{post_uri}#{@body.to_json}#{@nonce}"
    hash = OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), secrect, message)
    @signature = Base64.strict_encode64(hash)
  end

  def require_header
    require_signature()
    @header = {"Content-Type": "application/json",
          "X-LINE-ChannelId": ENV["line_pay_ChannelID"],
          "X-LINE-Authorization-Nonce": @nonce,
          "X-LINE-Authorization": @signature }
  end

  def get_response
    require_header()
    uri = URI.parse("https://sandbox-api-pay.line.me/v3/payments/request")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(uri.request_uri, @header)
    request.body = @body.to_json
    response = http.request(request)
  end

  def confirm(transactionId)
    nonce = SecureRandom.uuid
    confirm_body = { amount: self.amount,
                     currency: self.currency
    }
    secrect = ENV["lines_pay_ChannelSecret"]
    post_uri = "/v3/payments/" + "#{transactionId}" + "/confirm"

    message = "#{secrect}#{post_uri}#{confirm_body.to_json}#{nonce}"
    hash = OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), secrect, message)
    signature = Base64.strict_encode64(hash)

    confirm_header = {"Content-Type": "application/json",
          "X-LINE-ChannelId": ENV["line_pay_ChannelID"],
          "X-LINE-Authorization-Nonce": nonce,
          "X-LINE-Authorization": signature }

    uri = URI.parse("https://sandbox-api-pay.line.me" + "#{post_uri}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(uri.request_uri, confirm_header)
    request.body = confirm_body.to_json
    response = http.request(request)
  end

  private
  def body
    self.total_amount()
    self.order_id = "order#{SecureRandom.uuid}"
    self.packages_id = "pack#{SecureRandom.uuid}"
    self.name = self.product.name
    self.price = self.product.price
  end
end
