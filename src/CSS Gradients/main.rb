require 'gtk4'
require 'adwaita'
require 'gtksourceview5'

class CssGradientsDemo
  GRADIENT_TYPES = ['Linear', 'Radial', 'Conic'].freeze

  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        Gtk::StyleContext.add_provider_for_display(
          Gdk::Display.default, static_css_provider, Gtk::StyleProvider::PRIORITY_APPLICATION
        )

        window.tap do |win|
          win.child = status_page

          status_page.tap do |page|
            page.child = content_box

            content_box.tap do |b|
              b.append(preview_bin)
              b.append(list_box)
              b.append(using_link)
              b.append(spec_link)

              preview_bin.tap do |bin|
                bin.child = grid

                grid.tap do |g|
                  gradient_frames.each_with_index do |frame, index|
                    g.attach(frame, index % 3, index / 3, 1, 1)
                  end
                end
              end

              list_box.tap do |list|
                list.append(preview_row)
                list.append(combo_row_gradient_type)
                list.append(spin_row_angle)
                list.append(first_color_row)
                list.append(second_color_row)
                list.append(third_color_row)
                list.append(css_expander)

                preview_row.tap { |row| row.add_suffix(background_frame) }

                first_color_row.tap do |row|
                  row.add_suffix(button_color_1)
                  row.activatable_widget = button_color_1
                end

                second_color_row.tap do |row|
                  row.add_suffix(button_color_2)
                  row.activatable_widget = button_color_2
                end

                third_color_row.tap do |row|
                  row.add_suffix(button_color_3)
                  row.activatable_widget = button_color_3
                end

                css_expander.tap do |row|
                  row.add_row(source_row)

                  source_row.tap do |source|
                    source.child = overlay

                    overlay.tap do |o|
                      o.child = source_view
                      o.add_overlay(button_copy_css)

                      button_copy_css.tap do |btn|
                        btn.signal_connect('clicked') { clipboard.set(gtksource_buffer.text) }
                      end
                    end
                  end
                end

                [combo_row_gradient_type, spin_row_angle].each do |row|
                  row.signal_connect('notify::selected') { update }
                  row.signal_connect('notify::value') { update }
                end

                [button_color_1, button_color_2, button_color_3].each do |btn|
                  btn.signal_connect('notify::rgba') { update }
                end
              end
            end
          end
        end

        style_manager.tap do |manager|
          manager.signal_connect('notify::dark') { update_color_scheme }
        end

        gtksource_buffer.language = GtkSource::LanguageManager.default.get_language('css')

        update_color_scheme
        update

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.cssgradients', :default_flags)
  def content_box = @content_box ||= Gtk::Box.new(:vertical, 0).tap { |box| box.halign = :center }
  def overlay = @overlay ||= Gtk::Overlay.new
  def color_dialog = @color_dialog ||= Gtk::ColorDialog.new
  def clipboard = @clipboard ||= Gdk::Display.default.clipboard
  def style_manager = @style_manager ||= Adwaita::StyleManager.default
  def gtksource_buffer = @gtksource_buffer ||= GtkSource::Buffer.new.tap { |buf| buf.highlight_syntax = true }

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'CSS Gradients'
      win.set_default_size(720, 900)
    end
  end

  def static_css_provider
    @static_css_provider ||= Gtk::CssProvider.new.tap do |provider|
      provider.load_from_path(File.join(__dir__, 'main.css'))
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'CSS Gradients'
      page.description = 'Generate an image that smoothly fades from one color to another'
    end
  end

  def preview_bin
    @preview_bin ||= Adwaita::Bin.new.tap do |bin|
      bin.halign = :center
      bin.margin_bottom = 18
      bin.add_css_class('card')
    end
  end

  def grid
    @grid ||= Gtk::Grid.new.tap do |g|
      g.row_spacing = 18
      g.column_spacing = 18
      g.margin_top = 18
      g.margin_bottom = 18
      g.margin_start = 18
      g.margin_end = 18
    end
  end

  def gradient_frames
    @gradient_frames ||= [
      %w[linear circular], ['radial'], ['conic'],
      %w[repeating-linear circular], ['repeating-radial']
    ].map do |styles|
      Gtk::Frame.new.tap do |frame|
        styles.each { |style| frame.add_css_class(style) }
        frame.add_css_class('gradient-card')
      end
    end
  end

  def list_box
    @list_box ||= Gtk::ListBox.new.tap do |list|
      list.selection_mode = :none
      list.margin_bottom = 12
      list.add_css_class('boxed-list')
    end
  end

  def preview_row = @preview_row ||= Adwaita::ActionRow.new

  def background_frame
    @background_frame ||= Gtk::Frame.new.tap do |frame|
      frame.valign = :center
      frame.set_size_request(312, 140)
      frame.margin_top = 18
      frame.margin_bottom = 18
      frame.margin_end = 6
      frame.add_css_class('background-gradient')
    end
  end

  def combo_row_gradient_type
    @combo_row_gradient_type ||= Adwaita::ComboRow.new.tap do |row|
      row.title = 'Gradient type'
      row.model = Gtk::StringList.new(GRADIENT_TYPES)
    end
  end

  def spin_row_angle
    @spin_row_angle ||= Adwaita::SpinRow.new(Gtk::Adjustment.new(90, 0, 360, 10, 0, 0), 0.2, 0).tap do |row|
      row.title = 'Angle'
    end
  end

  def first_color_row = @first_color_row ||= Adwaita::ActionRow.new.tap { |r| r.title = 'First Color Stop' }
  def second_color_row = @second_color_row ||= Adwaita::ActionRow.new.tap { |r| r.title = 'Second Color Stop' }
  def third_color_row = @third_color_row ||= Adwaita::ActionRow.new.tap { |r| r.title = 'Third Color Stop' }

  def button_color_1 = @button_color_1 ||= color_button('#e01b24')
  def button_color_2 = @button_color_2 ||= color_button('#3584e4')
  def button_color_3 = @button_color_3 ||= color_button('#f6d32d')

  def css_expander
    @css_expander ||= Adwaita::ExpanderRow.new.tap { |row| row.title = 'Generated CSS' }
  end

  def source_row = @source_row ||= Adwaita::PreferencesRow.new.tap { |row| row.activatable = false }

  def source_view
    @source_view ||= GtkSource::View.new(gtksource_buffer).tap do |view|
      view.top_margin = 6
      view.bottom_margin = 6
      view.left_margin = 6
      view.right_margin = 6
      view.editable = false
      view.monospace = true
    end
  end

  def button_copy_css
    @button_copy_css ||= Gtk::Button.new.tap do |btn|
      btn.margin_bottom = 6
      btn.margin_end = 6
      btn.valign = :end
      btn.halign = :end
      btn.tooltip_text = 'Copy'
      btn.icon_name = 'edit-copy-symbolic'
      btn.add_css_class('flat')
    end
  end

  def using_link
    @using_link ||= Gtk::LinkButton.new(
      'https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_images/Using_CSS_gradients'
    ).tap { |btn| btn.label = 'Using CSS Gradients' }
  end

  def spec_link
    @spec_link ||= Gtk::LinkButton.new('https://www.w3.org/TR/css-images-3/#gradients').tap do |btn|
      btn.label = 'Specifications'
    end
  end

  private

  def color_button(hex)
    Gtk::ColorDialogButton.new(color_dialog).tap do |btn|
      btn.valign = :center
      btn.rgba = Gdk::RGBA.parse(hex)
    end
  end

  def update
    spin_row_angle.sensitive = combo_row_gradient_type.selected != 1
    generate_css.then do |css|
      gtksource_buffer.text = css
      update_css_provider(css)
    end
  end

  def generate_css
    angle = spin_row_angle.value.to_i
    stops = [button_color_1, button_color_2, button_color_3].map { |btn| btn.rgba.to_s }.join(",\n    ")

    case combo_row_gradient_type.selected
    when 0 then gradient_rule("linear-gradient(\n    #{angle}deg,\n    #{stops}\n  )")
    when 1 then gradient_rule("radial-gradient(\n    #{stops}\n  )")
    else gradient_rule("conic-gradient(\n    from #{angle}deg,\n    #{stops}\n  )")
    end
  end

  def gradient_rule(image)
    ".background-gradient {\n  background-image: #{image};\n}\n"
  end

  def update_css_provider(css)
    Gdk::Display.default.then do |display|
      Gtk::StyleContext.remove_provider_for_display(display, gradient_provider) if @gradient_provider

      @gradient_provider = Gtk::CssProvider.new.tap { |provider| provider.load_from_string(css) }
      Gtk::StyleContext.add_provider_for_display(display, @gradient_provider,
                                                 Gtk::StyleProvider::PRIORITY_APPLICATION)
    end
  end

  def gradient_provider = @gradient_provider

  def update_color_scheme
    gtksource_buffer.style_scheme = GtkSource::StyleSchemeManager.default.get_scheme(
      style_manager.dark? ? 'Adwaita-dark' : 'Adwaita'
    )
  end
end

CssGradientsDemo.new.build.run
