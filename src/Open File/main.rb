require 'gtk4'
require 'adwaita'

class OpenFileDemo
  IMAGE_MIME_TYPES = ['image/svg+xml', 'image/png', 'image/jpeg', 'image/webp', 'image/gif'].freeze

  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = status_page

          status_page.tap do |page|
            page.child = content_box

            content_box.tap do |b|
              b.append(button_single)
              b.append(button_image)
              b.append(button_multiple)
              b.append(reference_button)

              button_single.tap do |btn|
                btn.signal_connect('clicked') { open_file(Gtk::FileDialog.new, 'Selected File') }
              end

              button_image.tap do |btn|
                btn.signal_connect('clicked') { open_file(image_dialog, 'Selected Image') }
              end

              button_multiple.tap do |btn|
                btn.signal_connect('clicked') { open_multiple_files }
              end
            end
          end
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.openfile', :default_flags)
  def content_box = @content_box ||= Gtk::Box.new(:vertical, 24)

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Open File'
      win.set_default_size(560, 560)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Open File'
      page.description = 'Open a file using a file dialog'
    end
  end

  def button_single = @button_single ||= pill_button('Open File…')
  def button_image = @button_image ||= pill_button('Open Image…')
  def button_multiple = @button_multiple ||= pill_button('Open Multiple Files…')

  def file_filter_image
    @file_filter_image ||= Gtk::FileFilter.new.tap do |filter|
      IMAGE_MIME_TYPES.each { |mime_type| filter.add_mime_type(mime_type) }
    end
  end

  def image_dialog
    @image_dialog ||= Gtk::FileDialog.new.tap { |dialog| dialog.default_filter = file_filter_image }
  end

  def reference_button
    @reference_button ||= Gtk::LinkButton.new('https://docs.gtk.org/gtk4/class.FileDialog.html').tap do |btn|
      btn.label = 'API Reference'
    end
  end

  private

  def pill_button(label)
    Gtk::Button.new.tap do |btn|
      btn.label = label
      btn.halign = :center
      btn.add_css_class('pill')
    end
  end

  def file_name(file)
    file.query_info('standard::name', :none).name
  end

  def open_file(dialog, description)
    dialog.open(window, nil) do |source, result|
      puts "#{description}: #{file_name(source.open_finish(result))}"
    end
  end

  def open_multiple_files
    Gtk::FileDialog.new.open_multiple(window, nil) do |source, result|
      source.open_multiple_finish(result).then do |files|
        puts "Selected Files (#{files.n_items}):"
        files.each { |file| puts "   #{file_name(file)}" }
      end
    end
  end
end

OpenFileDemo.new.build.run
