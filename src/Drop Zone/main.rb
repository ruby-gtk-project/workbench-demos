require 'gtk4'
require 'adwaita'

class DropZoneDemo
  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        Gtk::StyleContext.add_provider_for_display(
          Gdk::Display.default, css_provider, Gtk::StyleProvider::PRIORITY_APPLICATION
        )

        window.tap do |win|
          win.child = status_page

          status_page.tap do |page|
            page.child = content_box

            content_box.tap do |b|
              b.append(clamp)
              b.append(links_box)

              clamp.tap do |c|
                c.child = card_box

                card_box.tap do |card|
                  card.append(bin)

                  bin.tap do |area|
                    area.child = prompt_label
                    area.add_controller(string_drop_target)
                    area.add_controller(file_drop_target)
                  end
                end
              end

              links_box.tap do |links|
                links.append(dnd_link)
                links.append(drop_target_link)
              end
            end
          end
        end

        string_drop_target.tap do |target|
          target.signal_connect('drop') { |_, value, _x, _y| show(text_preview(value)) }
          highlight_while_hovering(target)
        end

        file_drop_target.tap do |target|
          target.signal_connect('drop') { |_, value, _x, _y| show(file_preview(value)) }
          highlight_while_hovering(target)
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.dropzone', :default_flags)
  def clamp = @clamp ||= Adwaita::Clamp.new.tap { |c| c.maximum_size = 500 }
  def content_box = @content_box ||= Gtk::Box.new(:vertical, 0)
  def card_box = @card_box ||= Gtk::Box.new(:vertical, 0).tap { |box| box.add_css_class('card') }
  def bin = @bin ||= Adwaita::Bin.new.tap { |b| b.height_request = 150 }
  def prompt_label = @prompt_label ||= Gtk::Label.new('Drop Files or Text Here')
  def string_drop_target = @string_drop_target ||= Gtk::DropTarget.new(GLib::Type::STRING, Gdk::DragAction::COPY)
  def file_drop_target = @file_drop_target ||= Gtk::DropTarget.new(Gio::File.gtype, Gdk::DragAction::COPY)

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Drop Zone'
      win.set_default_size(640, 620)
    end
  end

  def css_provider
    @css_provider ||= Gtk::CssProvider.new.tap { |provider| provider.load_from_path(File.join(__dir__, 'main.css')) }
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Drop Zone'
      page.description = 'A versatile drop area for external content'
    end
  end

  def links_box
    @links_box ||= Gtk::Box.new(:vertical, 0).tap { |box| box.margin_top = 24 }
  end

  def dnd_link
    @dnd_link ||= Gtk::LinkButton.new('https://docs.gtk.org/gtk4/drag-and-drop.html#drop-targets').tap do |btn|
      btn.label = 'Drag-and-Drop in GTK'
    end
  end

  def drop_target_link
    @drop_target_link ||= Gtk::LinkButton.new('https://docs.gtk.org/gtk4/class.DropTarget.html').tap do |btn|
      btn.label = 'Drop Target API Reference'
    end
  end

  private

  def highlight_while_hovering(target)
    target.signal_connect('enter') { bin.add_css_class('overlay-drag-area') }
    target.signal_connect('leave') { bin.remove_css_class('overlay-drag-area') }
  end

  def show(preview)
    bin.child = preview
    bin.remove_css_class('overlay-drag-area')
    true
  end

  def preview_box
    Gtk::Box.new(:vertical, 6).tap do |box|
      box.halign = :center
      box.valign = :center
      box.margin_top = 12
      box.margin_bottom = 12
      box.margin_start = 12
      box.margin_end = 12
    end
  end

  def text_preview(text)
    preview_box.tap { |box| box.append(Gtk::Label.new(text).tap { |label| label.wrap = true }) }
  end

  def file_preview(file)
    file.query_info('standard::content-type', :none).content_type.then do |content_type|
      case content_type
      when /\Aimage\// then image_preview(file)
      when /\Avideo\// then video_preview(file)
      else generic_file_preview(file)
      end
    end
  end

  def image_preview(file)
    preview_box.tap do |box|
      box.append(Gtk::Picture.new(file).tap do |picture|
        picture.can_shrink = true
        picture.content_fit = :scale_down
      end)
    end
  end

  def video_preview(file)
    preview_box.tap { |box| box.append(Gtk::Video.new.tap { |video| video.file = file }) }
  end

  def generic_file_preview(file)
    preview_box.tap do |box|
      box.append(Gtk::Image.new.tap do |image|
        image.gicon = file.query_info('standard::icon', :none).icon
        image.icon_size = :large
      end)
      box.append(Gtk::Label.new(file.basename))
    end
  end
end

DropZoneDemo.new.build.run
