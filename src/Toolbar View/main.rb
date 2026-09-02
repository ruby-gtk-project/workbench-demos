require 'gtk4'
require 'adwaita'

class ToolbarViewDemo
  STYLES = ['Flat', 'Raised', 'Raised-Border'].freeze

  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = toolbar_view

          toolbar_view.tap do |view|
            view.add_top_bar(header_bar)
            view.add_bottom_bar(action_bar)
            view.content = status_page

            header_bar.tap { |bar| bar.title_widget = window_title }

            action_bar.tap do |bar|
              bar.pack_start(start_widget)
              bar.pack_end(end_widget)
              bar.center_widget = action_bar_label
            end

            status_page.tap do |page|
              page.child = content_box

              content_box.tap do |b|
                b.append(title_label)
                b.append(description_label)
                b.append(reference_button)
                b.append(list_box)

                list_box.tap do |list|
                  list.append(barstyle_select)
                  list.append(reveal_topbar)
                  list.append(reveal_bottombar)
                  list.append(extend_top)
                  list.append(extend_bottom)

                  barstyle_select.tap do |row|
                    row.signal_connect('notify::selected') do
                      view.top_bar_style = row.selected
                      view.bottom_bar_style = row.selected
                    end
                  end

                  reveal_topbar.tap do |row|
                    row.bind_property('active', view, 'reveal-top-bars', GLib::BindingFlags::SYNC_CREATE)
                  end

                  reveal_bottombar.tap do |row|
                    row.bind_property('active', view, 'reveal-bottom-bars', GLib::BindingFlags::SYNC_CREATE)
                  end

                  extend_top.tap do |row|
                    row.bind_property('active', view, 'extend-content-to-top-edge',
                                      GLib::BindingFlags::SYNC_CREATE)
                  end

                  extend_bottom.tap do |row|
                    row.bind_property('active', view, 'extend-content-to-bottom-edge',
                                      GLib::BindingFlags::SYNC_CREATE)
                  end
                end
              end
            end
          end
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.toolbarview', :default_flags)
  def toolbar_view = @toolbar_view ||= Adwaita::ToolbarView.new
  def header_bar = @header_bar ||= Adwaita::HeaderBar.new
  def window_title = @window_title ||= Adwaita::WindowTitle.new('Header Bar', '')
  def status_page = @status_page ||= Adwaita::StatusPage.new
  def action_bar_label = @action_bar_label ||= Gtk::Label.new('Action Bar')

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Toolbar View'
      win.set_size_request(360, 640)
      win.set_default_size(640, 640)
    end
  end

  def action_bar
    @action_bar ||= Gtk::ActionBar.new.tap do |bar|
      bar.revealed = true
      bar.valign = :end
    end
  end

  def start_widget = @start_widget ||= Gtk::Button.new.tap { |btn| btn.icon_name = 'call-start-symbolic' }
  def end_widget = @end_widget ||= Gtk::Button.new.tap { |btn| btn.icon_name = 'view-more-symbolic' }

  def content_box
    @content_box ||= Gtk::Box.new(:vertical, 18).tap { |box| box.halign = :center }
  end

  def title_label
    @title_label ||= Gtk::Label.new('Toolbar View').tap { |label| label.add_css_class('title-1') }
  end

  def description_label
    @description_label ||= Gtk::Label.new(
      'A widget containing a page, as well as top and/or bottom bars'
    ).tap { |label| label.wrap = true }
  end

  def reference_button
    @reference_button ||= Gtk::LinkButton.new(
      'https://gnome.pages.gitlab.gnome.org/libadwaita/doc/1.6/class.ToolbarView.html'
    ).tap { |btn| btn.label = 'API Reference' }
  end

  def list_box
    @list_box ||= Gtk::ListBox.new.tap do |list|
      list.selection_mode = :none
      list.add_css_class('boxed-list')
    end
  end

  def barstyle_select
    @barstyle_select ||= Adwaita::ComboRow.new.tap do |row|
      row.title = 'Style'
      row.model = Gtk::StringList.new(STYLES)
    end
  end

  def reveal_topbar = @reveal_topbar ||= switch_row('Reveal Top Bar', true)
  def reveal_bottombar = @reveal_bottombar ||= switch_row('Reveal Bottom Bar', true)
  def extend_top = @extend_top ||= switch_row('Extend Content Behind Top Bar', false)
  def extend_bottom = @extend_bottom ||= switch_row('Extend Content Behind Bottom Bar', false)

  private

  def switch_row(title, active)
    Adwaita::SwitchRow.new.tap do |row|
      row.title = title
      row.active = active
    end
  end
end

ToolbarViewDemo.new.build.run
