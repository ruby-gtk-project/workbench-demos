require 'gtk4'
require 'adwaita'

class WelcomeDemo
  TIPS = [
    ['update-symbolic', 'Edit Style or UI to update the Preview'],
    ['floppy-symbolic', 'Changes are automatically saved and restored'],
    ['library-symbolic', 'Browse the Library for demos and examples'],
    ['bookmark-outline-symbolic', 'Checkout the Bookmarks menu to learn and get help']
  ].freeze

  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        Gtk::StyleContext.add_provider_for_display(
          Gdk::Display.default, css_provider, Gtk::StyleProvider::PRIORITY_APPLICATION
        )

        window.tap do |win|
          win.child = welcome

          welcome.tap do |box|
            box.append(logo)
            box.append(title_label)
            box.append(subtitle)
            box.append(tips_box)

            subtitle.tap do |sub|
              sub.append(subtitle_label)
              sub.append(button)

              button.tap do |btn|
                btn.signal_connect('clicked') { greet }
              end
            end

            tips_box.tap do |tips|
              tips.append(run_tip)
              TIPS.each { |icon_name, text| tips.append(tip_row(icon_name, text)) }
            end
          end
        end

        puts 'Welcome to Workbench!'

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.welcome', :default_flags)

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Welcome'
      win.set_default_size(720, 800)
    end
  end

  def css_provider
    @css_provider ||= Gtk::CssProvider.new.tap { |provider| provider.load_from_path(File.join(__dir__, 'main.css')) }
  end

  def welcome
    @welcome ||= Gtk::Box.new(:vertical, 0).tap do |box|
      box.valign = :center
      box.halign = :center
    end
  end

  def logo
    @logo ||= Gtk::Image.new.tap do |image|
      image.name = 'logo'
      image.icon_name = 're.sonny.Workbench'
      image.pixel_size = 196
      image.margin_bottom = 30
      image.add_css_class('icon-dropshadow')
    end
  end

  def title_label
    @title_label ||= Gtk::Label.new('Welcome to Workbench').tap do |label|
      label.margin_bottom = 30
      label.add_css_class('title-1')
    end
  end

  def subtitle
    @subtitle ||= Gtk::Box.new(:vertical, 0).tap do |box|
      box.halign = :center
      box.margin_bottom = 30
    end
  end

  def subtitle_label
    @subtitle_label ||= Gtk::Label.new("Learn and prototype with\nGNOME technologies").tap do |label|
      label.justify = :center
    end
  end

  def button
    @button ||= Gtk::Button.new.tap do |btn|
      btn.label = 'Press me'
      btn.margin_top = 6
      btn.add_css_class('suggested-action')
    end
  end

  def tips_box
    @tips_box ||= Gtk::Box.new(:vertical, 0).tap do |box|
      box.homogeneous = true
      box.halign = :center
    end
  end

  def run_tip
    @run_tip ||= tip_box.tap do |box|
      box.append(tip_icon('play-large-symbolic'))
      box.append(Gtk::Label.new('Hit'))
      box.append(Gtk::ShortcutLabel.new('<Control>Return').tap { |shortcut| shortcut.margin_start = 12 })
      box.append(Gtk::Label.new('to format and run Code'))
    end
  end

  def greeting_dialog
    @greeting_dialog ||= Adwaita::AlertDialog.new(nil, 'Hello World!').tap do |dialog|
      dialog.add_response('ok', 'OK')
    end
  end

  private

  def tip_box
    Gtk::Box.new(:horizontal, 0).tap { |box| box.margin_bottom = 6 }
  end

  def tip_icon(icon_name)
    Gtk::Image.new.tap do |image|
      image.icon_name = icon_name
      image.margin_end = 12
      image.icon_size = :normal
    end
  end

  def tip_row(icon_name, text)
    tip_box.tap do |box|
      box.append(tip_icon(icon_name))
      box.append(Gtk::Label.new(text))
    end
  end

  def greet
    greeting_dialog.choose(window, nil) do |source, result|
      puts source.choose_finish(result)
    end
  end
end

WelcomeDemo.new.build.run
