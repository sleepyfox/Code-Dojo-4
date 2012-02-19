# This automatically runs the vows tests
watch('.*\.coffee') {|match| system "vows --spec test*"}
