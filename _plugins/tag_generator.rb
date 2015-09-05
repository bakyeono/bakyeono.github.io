module Jekyll
  class TagIndex < Page
    def initialize(site, base, dir, tag)
      @site = site
      @base = base
      @dir = dir
      @name = tag + '.html'
      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'tag.html')
      self.data['tag'] = tag
      self.data['title'] = tag
    end
  end
  class TagGenerator < Generator
    safe true
    def generate(site)
      if site.layouts.key? 'tag'
        dir = site.config['tag_dir'] || 'tag'
        site.tags.keys.each do |tag|
          write_tag_page(site, File.join(dir), tag)
        end
      end
    end
    def write_tag_page(site, dir, tag)
      page = TagIndex.new(site, site.source, dir, tag)
      page.render(site.layouts, site.site_payload)
      page.write(site.dest)
      site.pages << page
    end
  end
end
