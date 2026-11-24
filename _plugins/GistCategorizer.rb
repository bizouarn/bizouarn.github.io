require 'yaml'

# Pré-génère des catégories par mots-clés pour chaque gist (après GistFetcher)
# et prépare le texte de recherche utilisé par la page d'accueil.
#
# Ajoute à chaque gist :
#   post['categories']   => [{ 'id' => 'git', 'label' => 'Git & CI' }, ...]
#   post['category_ids'] => "git dotnet"          (pour data-attributes HTML)
#   post['search_text']  => texte normalisé       (titre + description + catégories)
# Expose :
#   site.data['gist_category_list'] => [{ 'id', 'label', 'count' }, ...] (triées par count)
module GistCategorizer
  TITLE_WEIGHT   = 3
  CONTENT_WEIGHT = 1
  DEFAULT_MIN    = 3
  UNCATEGORIZED  = { 'id' => 'autres', 'label' => 'autres' }.freeze

  # priority: :low => s'exécute après le hook de GistFetcher (contenu disponible)
  Jekyll::Hooks.register :site, :post_read, priority: :low do |site|
    categorize(site) if site.data['gist'].is_a?(Array)
  end

  # Normalise : minuscules, sans accents, ponctuation conservée utile (+ # .)
  def self.normalize(text)
    text.to_s.unicode_normalize(:nfd).gsub(/\p{Mn}/, '').downcase
  end

  def self.load_rules(site)
    rules = site.data['gist_categories']
    unless rules.is_a?(Array)
      Jekyll.logger.warn "GistCategorizer:", "_data/gist_categories.yml absent ou invalide"
      return []
    end
    rules.map do |r|
      {
        'id' => r['id'],
        'label' => r['label'] || r['id'],
        'min_score' => r['min_score'] || DEFAULT_MIN,
        'regexes' => Array(r['keywords']).map { |k| keyword_regex(normalize(k)) }
      }
    end
  end

  # Mot entier : pas de lettre/chiffre collé avant ni après
  def self.keyword_regex(keyword)
    /(?<![a-z0-9])#{Regexp.escape(keyword)}(?![a-z0-9])/
  end

  def self.score(rule, head, body)
    rule['regexes'].sum do |re|
      (head.match?(re) ? TITLE_WEIGHT : 0) + (body.match?(re) ? CONTENT_WEIGHT : 0)
    end
  end

  def self.categorize(site)
    rules = load_rules(site)
    counts = Hash.new(0)
    labels = {}

    site.data['gist'].each do |post|
      next unless post.is_a?(Hash)

      filename = post['filename'] || (post['files'].is_a?(Hash) ? post['files'].keys.first : '')
      head = normalize("#{filename} #{post['description']}")
      body = normalize(post['raw_content'])

      cats = rules.select { |r| score(r, head, body) >= r['min_score'] }
                  .map { |r| { 'id' => r['id'], 'label' => r['label'] } }
      cats << UNCATEGORIZED.dup if cats.empty?

      post['categories']   = cats
      post['category_ids'] = cats.map { |c| c['id'] }.join(' ')
      post['search_text']  = normalize("#{filename} #{post['description']} #{cats.map { |c| c['label'] }.join(' ')}")

      cats.each { |c| counts[c['id']] += 1; labels[c['id']] = c['label'] }
    end

    site.data['gist_category_list'] = counts.map { |id, n| { 'id' => id, 'label' => labels[id], 'count' => n } }
                                            .sort_by { |c| [c['id'] == 'autres' ? 1 : 0, -c['count'], c['label']] }
    Jekyll.logger.info "GistCategorizer:", "#{site.data['gist'].size} gists, #{counts.size} catégories"
  end
end
