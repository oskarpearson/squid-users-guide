#!/usr/bin/env ruby

require "erb"
require "fileutils"

chapters = {
  'index' => {
    # Open Directory Project currently misspells my name, which means google also misspells it.
    # I'm hoping this change, plus <meta name="robots" content="NOODP"> in the content
    # fixes it.
    # I'm also removing the apostrophe as apparently Google cuts off titles at the apostrophe,
    # which would make  this the "Oskar Pearson - Squid User" :)
    :title => 'Squid User Guide - Home - Oskar Pearson',
    :next_chapter => 'terminology-and-technologies',
    :suppress_page_footer => true,
    :suppress_page_header => true
  },
  'terminology-and-technologies' => {
    :title => 'Terminology and Technologies',
    :next_chapter => 'installing-squid'
  },
  'installing-squid' => {
    :title => 'Installing Squid',
    :next_chapter => 'squid-configuration-basics'
  },
  'squid-configuration-basics' => {
    :title => 'Squid Configuration Basics',
    :next_chapter => 'starting-squid'
  },
  'starting-squid' => {
    :title => 'Starting Squid',
    :next_chapter => 'browser-configuration'
  },
  'browser-configuration' => {
    :title => 'Browser Configuration',
    :next_chapter => 'squid-access-control-and-access-control-operators'
  },
  'squid-access-control-and-access-control-operators' => {
    :title => 'Access Control and Access Control Operators',
    :next_chapter => 'cache-hierarchies'
  },
  'cache-hierarchies' => {
    :title => 'Cache Hierarchies',
    :next_chapter => 'accelerator-mode'
  },
  'accelerator-mode' => {
    :title => 'Accelerator Mode',
    :next_chapter => 'transparent-caching-proxy'
  },
  'transparent-caching-proxy' => {
    :title => 'Transparent Caching Proxy',
    :next_chapter => 'history-and-credits'
  },
  'history-and-credits' => {
    :title => 'History and Credits',
    :next_chapter => 'wishlist'
  },
  'wishlist' => {
    :title => 'Changes Wishlist',
    :next_chapter => 'copyright'
  },
  'copyright' => {
    :title => 'Copyright',
    :next_chapter => 'index'
  }
}


class Page
  def initialize(page, title, link_title, next_chapter, next_chapter_title, suppress_page_header, suppress_page_footer, fn)
    @page = page
    @title = title
    @link_title = link_title || title
    @next_chapter = next_chapter
    @next_chapter_title = next_chapter_title
    @suppress_page_header = suppress_page_header
    @suppress_page_footer = suppress_page_footer
    @fn = fn
  end
  def render_with_layout(layout = 'source/layout/site.rhtml')
    # p "layout is #{layout}"
    render(layout) { render(@page) }
  end
  def render(filename)
    # p "Rendering #{filename}"
    content = File.read(File.expand_path(filename))
    t = ERB.new(content)
    t.result(binding)
  end
end

['css', 'js'].each do |n|
  Dir.entries("source/#{n}/").each do |fn|
    if fn != '.' && fn != '..'
      FileUtils.cp "source/#{n}/#{fn}", "website/#{n}"
    end
  end
end

Dir.entries("source/content/").each do |fn|
  if fn =~ /\.rhtml$/
    fn.sub!(/\.rhtml$/, '')
    
    print "Rendering #{fn}.rhtml ... "
    
    title = chapters[fn][:title]
    title = chapters[fn][:title] + " - Squid User Guide" unless fn == 'index'
    link_title = chapters[fn][:title]
    
    pg = Page.new(
      "source/content/#{fn}.rhtml",
      title,
      link_title,
      chapters[fn][:next_chapter],
      chapters[ chapters[fn][:next_chapter] ][:title],
      chapters[fn][:suppress_page_header] ? true : false,      
      chapters[fn][:suppress_page_footer] ? true : false,
      fn
    )
    res = pg.render_with_layout
    File.open("website/#{fn}.html", 'w') { |f| f.write(res) }
    print "done\n"
  end
end
FileUtils.cp "source/robots.txt", "website/robots.txt"
