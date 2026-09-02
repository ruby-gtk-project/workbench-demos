require 'gtk4'
require 'adwaita'

class BoxDemo
  ALIGNMENTS = %i[fill start center end].freeze

  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        Gtk::StyleContext.add_provider_for_display(
          Gdk::Display.default, css_provider, Gtk::StyleProvider::PRIORITY_APPLICATION
        )

        window.tap do |win|
          win.child = clamp

          clamp.tap do |c|
            c.child = content_box

            content_box.tap do |b|
              b.append(title_label)
              b.append(subtitle_label)
              b.append(links_box)
              b.append(controls_box)

              links_box.tap do |links|
                links.append(tutorial_link)
                links.append(reference_link)
              end

              controls_box.tap do |controls|
                controls.append(buttons_box)
                controls.append(options_box)
                controls.append(grid)

                buttons_box.tap do |box|
                  box.append(button_append)
                  box.append(button_prepend)
                  box.append(button_remove)

                  button_append.tap { |btn| btn.signal_connect('clicked') { append_item } }
                  button_prepend.tap { |btn| btn.signal_connect('clicked') { prepend_item } }
                  button_remove.tap { |btn| btn.signal_connect('clicked') { remove_item } }
                end

                options_box.tap do |box|
                  box.append(orientation_box)
                  box.append(highlight)

                  orientation_box.tap do |ob|
                    ob.append(orientation_label)
                    ob.append(orientation_toggles)

                    orientation_toggles.tap do |toggles|
                      toggles.append(toggle_orientation_horizontal)
                      toggles.append(toggle_orientation_vertical)

                      toggle_orientation_horizontal.tap do |btn|
                        btn.signal_connect('toggled') { interactive_box.orientation = :horizontal if btn.active? }
                      end

                      toggle_orientation_vertical.tap do |btn|
                        btn.signal_connect('toggled') { interactive_box.orientation = :vertical if btn.active? }
                      end
                    end
                  end

                  highlight.tap do |check|
                    check.signal_connect('toggled') do
                      if check.active?
                        interactive_box.add_css_class('border')
                      else
                        interactive_box.remove_css_class('border')
                      end
                    end
                  end
                end

                grid.tap do |g|
                  g.attach(halign_box, 1, 0, 1, 1)
                  g.attach(valign_box, 0, 1, 1, 1)
                  g.attach(scrolled_window, 1, 1, 1, 1)

                  halign_box.tap do |box|
                    box.append(halign_label)
                    box.append(halign_toggles)

                    halign_toggles.tap do |toggles|
                      halign_buttons.each do |align, btn|
                        toggles.append(btn)
                        btn.signal_connect('toggled') { interactive_box.halign = align if btn.active? }
                      end
                    end
                  end

                  valign_box.tap do |box|
                    box.append(valign_label)
                    box.append(valign_toggles)

                    valign_toggles.tap do |toggles|
                      valign_buttons.each do |align, btn|
                        toggles.append(btn)
                        btn.signal_connect('toggled') { interactive_box.valign = align if btn.active? }
                      end
                    end
                  end

                  scrolled_window.tap { |sw| sw.child = interactive_box }
                end
              end
            end
          end
        end

        append_item

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.box', :default_flags)
  def clamp = @clamp ||= Adwaita::Clamp.new.tap { |c| c.maximum_size = 1024 }
  def content_box = @content_box ||= Gtk::Box.new(:vertical, 0)
  def controls_box = @controls_box ||= Gtk::Box.new(:vertical, 0)
  def interactive_box = @interactive_box ||= Gtk::Box.new(:horizontal, 0)
  def orientation_label = @orientation_label ||= Gtk::Label.new('orientation')
  def count = @count ||= 0

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Box'
      win.set_default_size(960, 800)
    end
  end

  def css_provider
    @css_provider ||= Gtk::CssProvider.new.tap { |provider| provider.load_from_path(File.join(__dir__, 'main.css')) }
  end

  def title_label
    @title_label ||= Gtk::Label.new('Box').tap do |label|
      label.margin_top = 12
      label.margin_bottom = 12
      label.add_css_class('title-1')
    end
  end

  def subtitle_label
    @subtitle_label ||= Gtk::Label.new('A widget that arranges its child widgets into a single row or column')
  end

  def links_box
    @links_box ||= Gtk::Box.new(:horizontal, 0).tap do |box|
      box.halign = :center
      box.valign = :end
      box.margin_bottom = 12
    end
  end

  def tutorial_link
    @tutorial_link ||= Gtk::LinkButton.new(
      'https://developer.gnome.org/documentation/tutorials/beginners/components/box.html'
    ).tap { |btn| btn.label = 'Tutorial' }
  end

  def reference_link
    @reference_link ||= Gtk::LinkButton.new('https://docs.gtk.org/gtk4/class.Box.html').tap do |btn|
      btn.label = 'API Reference'
    end
  end

  def buttons_box
    @buttons_box ||= Gtk::Box.new(:horizontal, 18).tap do |box|
      box.halign = :center
      box.margin_bottom = 24
    end
  end

  def button_append = @button_append ||= pill_button('Append Item')
  def button_prepend = @button_prepend ||= pill_button('Prepend Item')
  def button_remove = @button_remove ||= pill_button('Remove Item')

  def options_box = @options_box ||= Gtk::Box.new(:horizontal, 18).tap { |box| box.halign = :center }
  def orientation_box = @orientation_box ||= Gtk::Box.new(:horizontal, 18)

  def orientation_toggles
    @orientation_toggles ||= Gtk::Box.new(:horizontal, 0).tap do |box|
      box.margin_start = 6
      box.homogeneous = true
      box.halign = :center
      box.add_css_class('linked')
    end
  end

  def toggle_orientation_horizontal
    @toggle_orientation_horizontal ||= Gtk::ToggleButton.new.tap do |btn|
      btn.label = 'horizontal'
      btn.active = true
    end
  end

  def toggle_orientation_vertical
    @toggle_orientation_vertical ||= Gtk::ToggleButton.new.tap do |btn|
      btn.label = 'vertical'
      btn.group = toggle_orientation_horizontal
    end
  end

  def highlight = @highlight ||= Gtk::CheckButton.new.tap { |check| check.label = 'Highlight Box' }

  def grid
    @grid ||= Gtk::Grid.new.tap do |g|
      g.margin_top = 12
      g.margin_bottom = 12
      g.margin_start = 12
      g.margin_end = 114
      g.row_spacing = 18
    end
  end

  def halign_box
    @halign_box ||= Gtk::Box.new(:vertical, 0).tap do |box|
      box.tooltip_text = 'Horizontal Alignment'
    end
  end

  def halign_label
    @halign_label ||= Gtk::Label.new('halign').tap do |label|
      label.margin_top = 12
      label.margin_bottom = 12
    end
  end

  def halign_toggles
    @halign_toggles ||= Gtk::Box.new(:horizontal, 36).tap do |box|
      box.homogeneous = true
      box.halign = :center
    end
  end

  def halign_buttons = @halign_buttons ||= toggle_group

  def valign_box
    @valign_box ||= Gtk::Box.new(:horizontal, 0).tap { |box| box.tooltip_text = 'Vertical Alignment' }
  end

  def valign_label = @valign_label ||= Gtk::Label.new('valign').tap { |label| label.add_css_class('rotate') }

  def valign_toggles
    @valign_toggles ||= Gtk::Box.new(:vertical, 60).tap { |box| box.valign = :center }
  end

  def valign_buttons
    @valign_buttons ||= toggle_group.tap { |group| group.each_value { |btn| btn.add_css_class('rotate') } }
  end

  def scrolled_window
    @scrolled_window ||= Gtk::ScrolledWindow.new.tap do |sw|
      sw.hexpand = true
      sw.vexpand = true
      sw.has_frame = true
    end
  end

  private

  def pill_button(label)
    Gtk::Button.new.tap do |btn|
      btn.label = label
      btn.add_css_class('pill')
    end
  end

  def toggle_group
    first = nil

    ALIGNMENTS.to_h do |align|
      [align, Gtk::ToggleButton.new.tap do |btn|
        btn.label = align.to_s
        btn.active = first.nil?
        btn.group = first if first
        first ||= btn
      end]
    end
  end

  def card_label
    Gtk::Label.new("Item #{count + 1}").tap do |label|
      label.name = 'card'
      label.add_css_class('card')
    end
  end

  def append_item
    interactive_box.append(card_label)
    @count = count + 1
  end

  def prepend_item
    interactive_box.prepend(card_label)
    @count = count + 1
  end

  def remove_item
    if count.zero?
      puts 'The box has no child widget to remove'
    else
      interactive_box.remove(interactive_box.last_child)
      @count = count - 1
    end
  end
end

BoxDemo.new.build.run
