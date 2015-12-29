Pod::Spec.new do |s|
  s.name         = 'ScrollBarTagView'
  s.version      = '0.0.1'
  s.summary      = 'Add a custom TagView on ScrollViewBar, with ScrollViewBar scroll. Can displayed something info on the TagView.'
  s.homepage     = 'https://github.com/dse12345z/ScrollBarTagView'

  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'Daisuke' => 'dse12345z@gmail.com' }
  s.source       = {
    :git => 'https://github.com/dse12345z/ScrollBarTagView.git',
    :tag => "#{s.version}"
  }

  s.platform     = :ios, '7.0'
  s.source_files = 'ScrollBarTagView/ScrollBarTagView/*.{h,m}'
  s.requires_arc = true
end
