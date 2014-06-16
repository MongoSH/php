name              'php'
maintainer        'Nash Patel'
maintainer_email  'interlity@gmail.com'
description       'Installs additional components on the web server'
version           '1.0.0'


%w{ debian ubuntu centos redhat fedora scientific amazon windows oracle }.each do |os|
  supports os
end
