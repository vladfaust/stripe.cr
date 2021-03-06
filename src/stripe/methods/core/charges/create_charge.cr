class Stripe
  def create_charge(
    amount : Int32,
    currency : String,
    application_fee : Int32? = nil,
    capture : Bool? = nil,
    customer : String | Customer? = nil,
    description : String? = nil,
    destination : T? = nil,
    metadata : Hash(String, String)? = nil,
    on_behalf_of : String? = nil,
    receipt_email : String? = nil,
    shipping : U? = nil,
    source : String | Token | PaymentMethods::Card | PaymentMethods::BankAccount? = nil,
    statement_descriptor : String? = nil,
    transfer_group : String? = nil
  ) : Charge forall T, U
    customer = customer.as(Customer).id if customer.is_a?(Customer)

    validate destination, {{T}} do
      type account : String
      type amount : Int32? = nil
    end

    validate shipping, {{U}} do
      type address do
        type line1 : String
        type city : String? = nil
        type country : String? = nil
        type line2 : String? = nil
        type postal_code : String? = nil
        type state : String? = nil
      end

      type name : String
      type carrier : String? = nil
      type phone : String? = nil
      type tracking_number : String? = nil
    end

    case source
    when Token, PaymentMethods::Card, PaymentMethods::BankAccount
      source = source.not_nil!.id
    end

    io = IO::Memory.new
    builder = ParamsBuilder.new(io)

    {% for x in %w(amount currency application_fee capture customer description destination metadata on_behalf_of receipt_email shipping source statement_descriptor transfer_group) %}
      builder.add({{x}}, {{x.id}}) unless {{x.id}}.nil?
    {% end %}

    response = @client.post("/v1/charges", form: io.to_s)

    if response.status_code == 200
      return Charge.from_json(response.body)
    else
      raise Error.from_json(response.body, "error")
    end
  end
end
