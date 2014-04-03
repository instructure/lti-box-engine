task "assets:precompile" do
  #Copy assets to a non-fingerprinted version
  fingerprint = /\-[0-9a-f]{32}\./
  for file in Dir["public/assets/lti_box_engine/**/*"]
    next unless file =~ fingerprint && !file.end_with?('.css', '.css.gz', '.js', '.js.gz')
    nondigest = file.sub fingerprint, '.'
    FileUtils.cp file, nondigest, verbose: true
  end
end
