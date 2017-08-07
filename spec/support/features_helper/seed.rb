shared_context 'seed', seed: true do
  before do
    SeedFu.quiet = true
    SeedFu.seed
  end
end
