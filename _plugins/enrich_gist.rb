Jekyll::Hooks.register :site, :post_read do |site|
  if site.data['gist']
    site.data['gist'].each do |post|
      if post['files'].is_a?(Hash)
        filename = post['files'].keys.first
        post['title'] = File.basename(filename, ".*")
        post['excerpt'] = post['description']
      end
    end
  end
end