require 'gtk4'
require 'adwaita'

class DialogDemo
  PRESENTATION_MODES = ['Auto', 'Floating', 'Bottom Sheet'].freeze

  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = status_page

          status_page.tap do |page|
            page.child = content_box

            content_box.tap do |b|
              b.append(list_box)
              b.append(button)
              b.append(links_box)

              list_box.tap { |list| list.append(combo_row) }

              combo_row.tap do |row|
                row.signal_connect('notify::selected') { dialog.presentation_mode = row.selected }
              end

              button.tap do |btn|
                btn.signal_connect('clicked') { dialog.present(window) }
              end

              links_box.tap do |links|
                links.append(reference_link)
                links.append(hig_link)
              end
            end
          end
        end

        dialog.tap do |d|
          d.child = toolbar_view

          toolbar_view.tap do |view|
            view.add_top_bar(header_bar)
            view.content = image
          end

          d.signal_connect('close-attempt') do
            puts 'Close Attempt'
            d.force_close
          end

          d.signal_connect('closed') { puts 'Closed' }
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.dialog', :default_flags)
  def toolbar_view = @toolbar_view ||= Adwaita::ToolbarView.new
  def header_bar = @header_bar ||= Adwaita::HeaderBar.new
  def links_box = @links_box ||= Gtk::Box.new(:vertical, 0)
  def dialog = @dialog ||= Adwaita::Dialog.new.tap { |d| d.can_close = false }

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Dialog'
      win.set_default_size(640, 620)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Dialog'
      page.description = 'An adaptive dialog container'
    end
  end

  def content_box
    @content_box ||= Gtk::Box.new(:vertical, 28).tap { |box| box.halign = :center }
  end

  def list_box
    @list_box ||= Gtk::ListBox.new.tap do |list|
      list.width_request = 320
      list.selection_mode = :none
      list.add_css_class('boxed-list')
    end
  end

  def combo_row
    @combo_row ||= Adwaita::ComboRow.new.tap do |row|
      row.title = 'Presentation Mode'
      row.model = Gtk::StringList.new(PRESENTATION_MODES)
    end
  end

  def button
    @button ||= Gtk::Button.new.tap do |btn|
      btn.label = 'Open Dialog'
      btn.halign = :center
      btn.add_css_class('suggested-action')
      btn.add_css_class('pill')
    end
  end

  def image
    @image ||= Gtk::Image.new.tap do |img|
      img.pixel_size = 320
      img.file = File.join(__dir__, 'image.svg')
    end
  end

  def reference_link
    @reference_link ||= Gtk::LinkButton.new(
      'https://gnome.pages.gitlab.gnome.org/libadwaita/doc/1.6/class.Dialog.html'
    ).tap { |btn| btn.label = 'API Reference' }
  end

  def hig_link
    @hig_link ||= Gtk::LinkButton.new('https://developer.gnome.org/hig/patterns/feedback/dialogs.html').tap do |btn|
      btn.label = 'Human Interface Guidelines'
    end
  end
end

DialogDemo.new.build.run
