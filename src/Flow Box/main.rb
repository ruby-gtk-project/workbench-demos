require 'gtk4'
require 'adwaita'

class FlowBoxDemo
  EMOJI_RANGE = (128_513..128_591).freeze

  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        Gtk::StyleContext.add_provider_for_display(
          Gdk::Display.default, css_provider, Gtk::StyleProvider::PRIORITY_APPLICATION
        )

        window.tap do |win|
          win.titlebar = header_bar
          win.child = status_page

          status_page.tap do |page|
            page.child = content_box

            content_box.tap do |b|
              b.append(scrolled_window)
              b.append(reference_button)

              scrolled_window.tap { |sw| sw.child = flowbox }

              flowbox.tap do |box|
                EMOJI_RANGE.each { |code| box.append(emoji_card(code.chr(Encoding::UTF_8))) }

                box.signal_connect('child-activated') do |_, item|
                  # FlowBoxChild -> Adwaita::Bin -> Label
                  puts "Unicode: #{item.child.child.label.codepoints.first.to_s(16)}"
                end
              end
            end
          end
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.flowbox', :default_flags)
  def header_bar = @header_bar ||= Adwaita::HeaderBar.new
  def content_box = @content_box ||= Gtk::Box.new(:vertical, 12)

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Flow Box Demo'
      win.set_default_size(800, 800)
    end
  end

  def css_provider
    @css_provider ||= Gtk::CssProvider.new.tap { |provider| provider.load_from_path(File.join(__dir__, 'main.css')) }
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Flow Box'
      page.description = 'Puts child widgets in a reflowing grid'
    end
  end

  def scrolled_window
    @scrolled_window ||= Gtk::ScrolledWindow.new.tap do |sw|
      sw.propagate_natural_height = true
      sw.has_frame = true
    end
  end

  def flowbox
    @flowbox ||= Gtk::FlowBox.new.tap do |box|
      box.orientation = :horizontal
      box.row_spacing = 6
      box.column_spacing = 6
      box.homogeneous = true
      box.max_children_per_line = 6
      box.min_children_per_line = 3
    end
  end

  def reference_button
    @reference_button ||= Gtk::LinkButton.new('https://docs.gtk.org/gtk4/class.FlowBox.html').tap do |btn|
      btn.label = 'API Reference'
    end
  end

  private

  def emoji_card(unicode)
    Adwaita::Bin.new.tap do |bin|
      bin.set_size_request(100, 100)
      bin.add_css_class('card')
      bin.child = Gtk::Label.new(unicode).tap do |label|
        label.vexpand = true
        label.hexpand = true
        label.add_css_class('emoji')
      end
    end
  end
end

FlowBoxDemo.new.build.run
