class Order < ApplicationRecord
  belongs_to :product

  validates :quantity, presence: true, numericality: { only_integer: true }

  after_create :set_order

  #state
  include AASM

  aasm column: :state do
    state :pending, initial: true
    state :confirmed

    event :check do
      transitions from: :pending, to: :confirmed
    end
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

  def confirm_body
    @body = { amount: self.amount,
              currency: self.currency
    }
  end

  def get_nonce_and_secrect
    @nonce = SecureRandom.uuid
    @secrect = ENV["lines_pay_ChannelSecret"]
  end

  def paper_require_signature
    get_nonce_and_secrect()
    @post_uri = "/v3/payments/request"
  end

  def paper_confirm_signature(transactionId)
    get_nonce_and_secrect()
    @post_uri = "/v3/payments/" + "#{transactionId}" + "/confirm"
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

  def request_response
    self.requset_body()
    paper_require_signature()
    require_header()
    @uri = URI.parse("https://sandbox-api-pay.line.me/v3/payments/request")
    get_response()
  end

  def confirm_response(transactionId)
    self.confirm_body()
    paper_confirm_signature(transactionId)
    require_header()
    @uri = URI.parse("https://sandbox-api-pay.line.me" + "#{@post_uri}")
    get_response()
  end

  private
  def set_order
    order_id = "order#{SecureRandom.uuid}"
    packages_id = "pack#{SecureRandom.uuid}"
    self.amount = self.quantity * self.product.price
    self.order_id = order_id
    self.packages_id = packages_id
    self.name = self.product.name
    self.price = self.product.price
  end
end
