# frozen_string_literal: true

SimpleCov.load_profile "rails"

# Lets concurrent test runs keep separate reports, e.g. COVERAGE_DIR=tmp/coverage_a
SimpleCov.coverage_dir ENV.fetch("COVERAGE_DIR", "coverage")

SimpleCov.coverage :line do
  minimum 100
  minimum 100, per: :file
end

SimpleCov.coverage :branch do
  ignore :eval_generated
  minimum 100
  minimum 100, per: :file
end
