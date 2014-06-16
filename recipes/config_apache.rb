cookbook_file '/var/www/index.html' do
  source 'index.html'
  mode '0644'
end
