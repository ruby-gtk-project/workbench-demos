require 'gtk4'
require 'adwaita'

class SearchDemo
  FRUITS = ['Apple 🍎️', 'Orange 🍊️', 'Pear 🍐️', 'Watermelon 🍉️', 'Melon 🍈️', 'Pineapple 🍍️',
            'Grape 🍇️', 'Kiwi 🥝️', 'Banana 🍌️', 'Peach 🍑️', 'Cherry 🍒️', 'Strawberry 🍓️',
            'Blueberry 🫐️', 'Mango 🥭️', 'Bell Pepper 🫑️'].freeze

  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.titlebar = header_bar
          win.child = container

          header_bar.tap { |bar| bar.pack_start(button_search) }

          container.tap do |box|
            box.append(searchbar)
            box.append(stack)

            searchbar.tap do |bar|
              bar.key_capture_widget = box
              bar.child = searchentry

              bar.signal_connect('notify::search-mode-enabled') do
                stack.visible_child = bar.search_mode_enabled? ? search_page : main_page
              end
            end

            stack.tap do |s|
              s.add_child(main_page)
              s.add_child(search_page)
              s.add_child(status_page)

              main_page.tap do |page|
                page.child = links_box

                links_box.tap do |links|
                  links.append(references_label)
                  links.append(references_row)
                  links.append(hig_link)

                  references_row.tap do |row|
                    row.append(search_entry_reference)
                    row.append(search_bar_reference)
                  end
                end
              end

              search_page.tap do |page|
                page.child = clamp

                clamp.tap do |c|
                  c.child = listbox

                  listbox.tap do |list|
                    rows.each { |row| list.append(row) }
                    list.set_filter_func { |row| matches?(row) }
                  end
                end
              end
            end
          end
        end

        button_search.tap do |btn|
          btn.signal_connect('clicked') { searchbar.search_mode_enabled = !searchbar.search_mode_enabled? }
        end

        searchentry.tap do |entry|
          entry.signal_connect('search-changed') { refilter }
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.search', :default_flags)
  def header_bar = @header_bar ||= Gtk::HeaderBar.new
  def container = @container ||= Gtk::Box.new(:vertical, 0)
  def searchbar = @searchbar ||= Gtk::SearchBar.new
  def stack = @stack ||= Gtk::Stack.new.tap { |s| s.transition_type = :crossfade }
  def button_search = @button_search ||= Gtk::ToggleButton.new.tap { |btn| btn.icon_name = 'edit-find-symbolic' }
  def references_label = @references_label ||= Gtk::Label.new('API References')
  def results_count = @results_count ||= 0

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Search'
      win.set_default_size(800, 600)
    end
  end

  def searchentry
    @searchentry ||= Gtk::SearchEntry.new.tap do |entry|
      entry.search_delay = 100
      entry.placeholder_text = 'Search fruits'
      entry.width_request = 400
    end
  end

  def main_page
    @main_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Search'
      page.description = 'Allow items to be located by filtering'
      page.vexpand = true
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'No Results Founds'
      page.description = 'Try a different search'
      page.icon_name = 'edit-find-symbolic'
      page.vexpand = true
    end
  end

  def search_page = @search_page ||= Gtk::ScrolledWindow.new

  def clamp
    @clamp ||= Adwaita::Clamp.new.tap do |c|
      c.margin_top = 24
      c.margin_bottom = 24
    end
  end

  def listbox
    @listbox ||= Gtk::ListBox.new.tap do |list|
      list.valign = :start
      list.hexpand = true
      list.selection_mode = :none
      list.add_css_class('boxed-list')
    end
  end

  def rows
    @rows ||= FRUITS.map { |name| Adwaita::ActionRow.new.tap { |row| row.title = name } }
  end

  def links_box = @links_box ||= Gtk::Box.new(:vertical, 6)
  def references_row = @references_row ||= Gtk::Box.new(:horizontal, 0).tap { |box| box.halign = :center }

  def search_entry_reference
    @search_entry_reference ||= Gtk::LinkButton.new('https://docs.gtk.org/gtk4/class.SearchEntry.html').tap do |btn|
      btn.label = 'Search Entry API Reference'
    end
  end

  def search_bar_reference
    @search_bar_reference ||= Gtk::LinkButton.new('https://docs.gtk.org/gtk4/class.SearchBar').tap do |btn|
      btn.label = 'Search Bar API Reference'
    end
  end

  def hig_link
    @hig_link ||= Gtk::LinkButton.new('https://developer.gnome.org/hig/patterns/nav/search.html').tap do |btn|
      btn.label = 'Human Interface Guidelines'
      btn.margin_top = 6
    end
  end

  private

  def matches?(row)
    Regexp.new(Regexp.escape(searchentry.text), Regexp::IGNORECASE).match?(row.title).tap do |match|
      @results_count = results_count + 1 if match
    end
  end

  def refilter
    @results_count = 0
    listbox.invalidate_filter

    stack.visible_child =
      if results_count.zero?
        status_page
      elsif searchbar.search_mode_enabled?
        search_page
      else
        main_page
      end
  end
end

SearchDemo.new.build.run
