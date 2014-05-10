# A sample Guardfile
# More info at https://github.com/guard/guard#readme

group :red_green_refactor, halt_on_fail: true do
  guard :minitest, all_after_pass: true do
    # with Minitest::Spec
    watch(%r{^spec/(.*)_spec\.rb})
    watch(%r{^lib/(.+)\.rb})         { |m| "spec/#{m[1]}_spec.rb" }
    watch(%r{^spec/spec_helper\.rb}) { 'spec' }
  end

  guard :rubocop, all_on_start: true, keep_failed: true,
    cli: ['--format', 'progress'] do
    watch(%r{^lib/(.+)\.rb})
  end
end
