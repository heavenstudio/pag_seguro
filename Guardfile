guard 'rspec', :version => 2 do
  watch(%r{^spec/.+_spec\.rb})
  watch(%r{^lib/(.+)\.rb})     { |m| "spec/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb') { "spec" }
  watch('lib/pag_seguro.rb') { "spec" }
  watch('lib/checkout.xml.haml') { "spec/pag_seguro/checkout_xml_spec.rb" }
end
