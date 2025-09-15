require 'net/http'
require 'uri'

Jekyll::Hooks.register :site, :post_read do |site|
  if site.data['gist']
    site.data['gist'].each do |post|
      if post['files'].is_a?(Hash)
        filename = post['files'].keys.first
        file_data = post['files'][filename]

        post['filename'] = filename
        post['title'] = File.basename(filename, ".*")
        post['excerpt'] = post['description']
        post['raw_url'] = file_data['raw_url']

        begin
          uri = URI.parse(post['raw_url'])
          response = Net::HTTP.get_response(uri)
          if response.is_a?(Net::HTTPSuccess)
            # Forcer l’encodage en UTF-8 proprement
            body = response.body
            body.force_encoding("UTF-8")
            unless body.valid_encoding?
              body = body.encode("UTF-8", invalid: :replace, undef: :replace, replace: "?")
            end
            post['raw_content'] = body
            ext = File.extname(filename).delete(".")
            if ext != "md" || !body.start_with?("# ")
              if ext != "md"
                body = "# #{filename}\n#{post['excerpt']}\n```#{ext}\n#{body}\n```"
              else
                body = "# #{filename}  \n#{body}"
              end
            end

            post['raw_content'] = body
          else
            Jekyll.logger.warn "GistFetcher:", "Impossible de récupérer #{post['raw_url']} (#{response.code})"
          end
        rescue => e
          Jekyll.logger.error "GistFetcher:", "Erreur lors de la récupération de #{post['raw_url']}: #{e.message}"
        end
      end
    end
  end
end
