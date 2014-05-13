# A sample Guardfile
# More info at https://github.com/guard/guard#readme

group :resque_ring, halt_on_fail: true do
  guard :rubocop, all_on_start: true, keep_failed: true,
    cli: ['--format', 'progress'] do
    watch(/^.rubocop.yml/)        { '.'   }
    watch(%r{^lib/(.+)\.rb})      { |m| m }
    watch(%r{^bin/resque_ring})   { |m| m }
    watch(%r{^bin/rr_tester})     { |m| m }
  end

  guard :minitest, all_after_pass: true do
    # with Minitest::Spec
    watch(%r{^spec/(.*)_spec\.rb})
    watch(%r{^lib/(.+)\.rb})         { |m| "spec/#{m[1]}_base_spec.rb" }
    watch(%r{^spec/spec_helper\.rb}) { 'spec' }
  end
end
