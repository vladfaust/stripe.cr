# https://stripe.com/docs/api/balance/balance_object
struct Stripe::Balance
  include JSON::Serializable

  struct Funds
    include JSON::Serializable

    getter currency : String
    getter amount : Int32
    getter source_types : Hash(String, Int32)?
  end

  getter available : Array(Funds)
  getter connect_reserved : Array(Funds)?
  getter livemode : Bool
  getter pending : Array(Funds)
end
