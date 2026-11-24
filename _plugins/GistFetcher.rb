require 'net/http'
require 'uri'
require 'digest'
require 'fileutils'

module GistFetcher
  # Les raw_url des gists contiennent le hash de révision : leur contenu est
  # immuable, on peut donc le mettre en cache sur disque indexé par URL.
  CACHE_SUBDIR = File.join('.jekyll-cache', 'gists')

  # Hook Jekyll qui s'exécute après la lecture du site
  Jekyll::Hooks.register :site, :post_read do |site|
    process_gists(site) if site.data['gist']
  end

  private

  # Traite tous les gists du site
  def self.process_gists(site)
    @cache_dir = File.join(site.source, CACHE_SUBDIR)
    FileUtils.mkdir_p(@cache_dir)
    @hits = 0
    @downloads = 0

    site.data['gist'].each do |post|
      next unless post['files'].is_a?(Hash)

      process_single_gist(post)
    end

    Jekyll.logger.info "GistFetcher:", "#{@hits} gist(s) depuis le cache, #{@downloads} téléchargé(s)"
  end

  # Traite un gist individuel
  def self.process_single_gist(post)
    filename = post['files'].keys.first
    file_data = post['files'][filename]

    # Extraction des métadonnées
    extract_metadata(post, filename, file_data)
    
    # Récupération du contenu
    fetch_and_process_content(post, filename)
  end

  # Extrait les métadonnées du gist
  def self.extract_metadata(post, filename, file_data)
    post['filename'] = filename
    post['title'] = File.basename(filename, ".*")
    post['excerpt'] = post['description']
    post['raw_url'] = file_data['raw_url']
  end

  # Récupère et traite le contenu du fichier
  def self.fetch_and_process_content(post, filename)
    begin
      content = fetch_raw_content(post['raw_url'])
      return unless content

      # Formatage du contenu selon le type de fichier
      formatted_content = format_content(content, filename, post['excerpt'])
      post['raw_content'] = formatted_content

    rescue => e
      Jekyll.logger.error "GistFetcher:", "Erreur lors de la récupération de #{post['raw_url']}: #{e.message}"
    end
  end

  # Récupère le contenu brut depuis l'URL
  def self.fetch_raw_content(raw_url)
    cache_file = File.join(@cache_dir, "#{Digest::SHA256.hexdigest(raw_url)}.txt")

    if File.exist?(cache_file)
      @hits += 1
      return File.read(cache_file, encoding: 'UTF-8')
    end

    uri = URI.parse(raw_url)
    response = Net::HTTP.get_response(uri)

    unless response.is_a?(Net::HTTPSuccess)
      Jekyll.logger.warn "GistFetcher:", "Impossible de récupérer #{raw_url} (#{response.code})"
      return nil
    end

    # Nettoyage de l'encodage UTF-8
    content = clean_encoding(response.body)

    # Écriture atomique pour éviter un cache corrompu en cas d'interruption
    tmp_file = "#{cache_file}.tmp"
    File.write(tmp_file, content, encoding: 'UTF-8')
    File.rename(tmp_file, cache_file)
    @downloads += 1

    content
  end

  # Nettoie l'encodage du contenu
  def self.clean_encoding(content)
    content.force_encoding("UTF-8")
    
    unless content.valid_encoding?
      content = content.encode("UTF-8", invalid: :replace, undef: :replace, replace: "?")
    end
    
    content
  end

  # Formate le contenu selon le type de fichier
  def self.format_content(content, filename, excerpt)
    extension = File.extname(filename).delete(".")

    # Corrige la detection des tableaux
    if extension != "md"
      content = content.gsub(/([^\|])\n\|/, "\\1\n\n|")
                      .gsub(/(?<=\|)\n([^\|])/, "\n\n\\1")
    end
    content = content.strip
    case
    when extension != "md"
      # Fichier non-markdown : ajout de wrapper avec syntaxe highlight
      "# #{filename}\n#{excerpt}\n```#{extension}\n#{content}\n```"
    when !content.start_with?("# ")
      # Fichier markdown sans titre : ajout du nom de fichier comme titre
      "# #{filename}  \n#{content}"
    else
      # Fichier markdown avec titre existant : contenu inchangé
      content
    end
  end
end