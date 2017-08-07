RSpec.shared_context 'time freeze in view', type: :view do
  before { Timecop.freeze(Time.current) }
  after { Timecop.return }
end

RSpec.shared_context 'time freeze', timecop: true do
  before { Timecop.freeze(Time.current) }
  after { Timecop.return }
end
