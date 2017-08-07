module Concerns::ActsAsServiceObject
  SuccessfulResult = Struct.new :payload do
    def self.create(payload: nil)
      fail 'payload must have to respond_to method "as_json".' unless payload.respond_to? :as_json
      new(payload)
    end

    def success?
      true
    end

    def as_json(*)
      {
        success: true,
        payload: payload.as_json
      }
    end

    def error
      nil
    end
  end

  FailedResult = Struct.new :error do
    def self.create(error: ServiceObjectError.new)
      new(error)
    end

    def success?
      false
    end

    def as_json(*)
      {
        success: false,
        error: error.as_json
      }
    end

    def payload
      nil
    end
  end

  def execute(args = {})
    SuccessfulResult.create payload: process(args)
  rescue ServiceObjectError => e
    FailedResult.create error: e
  end

  private

  def process(_args = {})
    fail 'my son will take care of you'
  end
end
