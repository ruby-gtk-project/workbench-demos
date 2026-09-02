require 'gtk4'
require 'adwaita'

class RevealerDemo
  ITEMS = ['Item 1', 'Item 2', 'Item 3', 'Item 4'].freeze

  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = status_page

          status_page.tap do |page|
            page.child = content_box

            content_box.tap do |b|
              b.append(demos_box)
              b.append(reference_button)

              demos_box.tap do |demos|
                demos.append(slide_section)
                demos.append(crossfade_section)

                slide_section.tap do |section|
                  section.append(button_slide)
                  section.append(clamp)

                  clamp.tap do |c|
                    c.child = revealer_slide

                    revealer_slide.tap do |revealer|
                      revealer.child = list_box

                      list_box.tap { |list| rows.each { |row| list.append(row) } }
                    end
                  end

                  button_slide.tap do |btn|
                    btn.signal_connect('toggled') { revealer_slide.reveal_child = btn.active? }
                  end
                end

                crossfade_section.tap do |section|
                  section.append(button_crossfade)
                  section.append(overlay)

                  overlay.tap do |o|
                    o.child = image1
                    o.add_overlay(revealer_crossfade)

                    revealer_crossfade.tap { |revealer| revealer.child = image2 }
                  end

                  button_crossfade.tap do |btn|
                    btn.signal_connect('toggled') { revealer_crossfade.reveal_child = btn.active? }
                  end
                end
              end
            end
          end
        end

        revealer_slide.tap do |revealer|
          revealer.signal_connect('notify::child-revealed') do
            puts revealer.child_revealed? ? 'Slide Revealer Shown' : 'Slide Revealer Hidden'
          end
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.revealer', :default_flags)
  def content_box = @content_box ||= Gtk::Box.new(:vertical, 24)
  def clamp = @clamp ||= Adwaita::Clamp.new
  def overlay = @overlay ||= Gtk::Overlay.new
  def image1 = @image1 ||= Gtk::Picture.new(Gio::File.new_for_path(File.join(__dir__, 'image1.png')))
  def image2 = @image2 ||= Gtk::Picture.new(Gio::File.new_for_path(File.join(__dir__, 'image2.png')))

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Revealer'
      win.set_default_size(720, 840)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Revealer'
      page.description = 'Animates the transition of its child from invisible to visible'
    end
  end

  def demos_box
    @demos_box ||= Gtk::Box.new(:vertical, 0).tap { |box| box.homogeneous = true }
  end

  def slide_section = @slide_section ||= section_box
  def crossfade_section = @crossfade_section ||= section_box

  def button_slide = @button_slide ||= pill_toggle('Slide')
  def button_crossfade = @button_crossfade ||= pill_toggle('Crossfade')

  # https://docs.gtk.org/gtk4/enum.RevealerTransitionType.html
  def revealer_slide
    @revealer_slide ||= Gtk::Revealer.new.tap do |revealer|
      revealer.transition_duration = 300
      revealer.transition_type = :slide_up
    end
  end

  def revealer_crossfade
    @revealer_crossfade ||= Gtk::Revealer.new.tap do |revealer|
      revealer.transition_duration = 800
      revealer.transition_type = :crossfade
    end
  end

  def list_box
    @list_box ||= Gtk::ListBox.new.tap do |list|
      list.selection_mode = :none
      list.add_css_class('boxed-list')
    end
  end

  def rows
    @rows ||= ITEMS.map { |title| Adwaita::ActionRow.new.tap { |row| row.title = title } }
  end

  def reference_button
    @reference_button ||= Gtk::LinkButton.new('https://docs.gtk.org/gtk4/class.Revealer.html').tap do |btn|
      btn.label = 'API Reference'
    end
  end

  private

  def section_box
    Gtk::Box.new(:vertical, 12).tap do |box|
      box.margin_start = 24
      box.margin_end = 24
    end
  end

  def pill_toggle(label)
    Gtk::ToggleButton.new.tap do |btn|
      btn.halign = :center
      btn.label = label
      btn.add_css_class('pill')
    end
  end
end

RevealerDemo.new.build.run
