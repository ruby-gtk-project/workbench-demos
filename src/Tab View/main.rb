require 'gtk4'
require 'adwaita'

class TabViewDemo
  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = overview

          overview.tap do |o|
            o.enable_new_tab = true
            o.view = tab_view
            o.child = content_box
            o.signal_connect('create-tab') { add_page }

            content_box.tap do |box|
              box.append(header_bar)
              box.append(tab_bar)
              box.append(tab_view)

              header_bar.tap do |bar|
                bar.pack_start(button_new_tab)
                bar.pack_start(button_overview)

                button_new_tab.tap { |btn| btn.signal_connect('clicked') { add_page } }
                button_overview.tap { |btn| btn.signal_connect('clicked') { o.open = true } }
              end

              tab_bar.tap { |bar| bar.view = tab_view }

              tab_view.tap do |view|
                view.append(main_page).tap { |page| page.title = 'Main Page' }
              end
            end
          end
        end

        main_page.tap do |page|
          page.child = links_box

          links_box.tap do |box|
            box.append(references_label)
            box.append(references_row)
            box.append(hig_link)

            references_row.tap do |row|
              row.append(tab_view_link)
              row.append(tab_bar_link)
              row.append(tab_overview_link)
            end
          end
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.tabview', :default_flags)
  def overview = @overview ||= Adwaita::TabOverview.new
  def content_box = @content_box ||= Gtk::Box.new(:vertical, 0)
  def header_bar = @header_bar ||= Adwaita::HeaderBar.new
  def tab_bar = @tab_bar ||= Adwaita::TabBar.new
  def tab_view = @tab_view ||= Adwaita::TabView.new
  def tab_count = @tab_count ||= 1
  def references_label = @references_label ||= Gtk::Label.new('API References')
  def links_box = @links_box ||= Gtk::Box.new(:vertical, 6)
  def references_row = @references_row ||= Gtk::Box.new(:horizontal, 0).tap { |box| box.halign = :center }

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Tab View Demo'
      win.set_default_size(800, 600)
    end
  end

  def button_new_tab = @button_new_tab ||= icon_button('tab-new-symbolic')
  def button_overview = @button_overview ||= icon_button('view-grid-symbolic')

  def main_page
    @main_page ||= Adwaita::StatusPage.new.tap do |page|
      page.hexpand = true
      page.vexpand = true
      page.title = 'Tab View'
      page.description = 'A dynamic tabbed container'
    end
  end

  def tab_view_link = @tab_view_link ||= link('Tab View', 'TabView')
  def tab_bar_link = @tab_bar_link ||= link('Tab Bar', 'TabBar')
  def tab_overview_link = @tab_overview_link ||= link('Tab Overview', 'TabOverview')

  def hig_link
    @hig_link ||= Gtk::LinkButton.new('https://developer.gnome.org/hig/patterns/nav/tabs.html').tap do |btn|
      btn.label = 'Human Interface Guidelines'
    end
  end

  private

  def icon_button(icon_name)
    Gtk::Button.new.tap { |btn| btn.icon_name = icon_name }
  end

  def link(label, class_name)
    Gtk::LinkButton.new(
      "https://gnome.pages.gitlab.gnome.org/libadwaita/doc/1.6/class.#{class_name}.html"
    ).tap { |btn| btn.label = label }
  end

  def add_page
    "Tab #{tab_count}".then do |title|
      @tab_count = tab_count + 1

      tab_view.append(Adwaita::StatusPage.new.tap do |page|
        page.title = title
        page.vexpand = true
      end).tap do |tab_page|
        tab_page.title = title
        tab_page.live_thumbnail = true
      end
    end
  end
end

TabViewDemo.new.build.run
