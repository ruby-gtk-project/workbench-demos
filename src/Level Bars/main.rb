require 'gtk4'
require 'adwaita'

class LevelBarsDemo
  # This is not a secure way to estimate password strength; use a proper
  # solution such as zxcvbn instead.
  STRENGTHS = {
    1 => ['Very Weak', 'very-weak-label'],
    2 => ['Weak', 'weak-label'],
    3 => ['Moderate', 'moderate-label'],
    4 => ['Moderate', 'moderate-label'],
    5 => ['Strong', 'strong-label'],
    6 => ['Strong', 'strong-label']
  }.freeze

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
              b.append(bars_box)
              b.append(links_box)

              bars_box.tap do |box|
                box.append(continuous_label)
                box.append(battery_card)
                box.append(discrete_label)
                box.append(entry)
                box.append(bar_discrete)
                box.append(label_strength)

                battery_card.tap do |card|
                  card.append(battery_label)
                  card.append(bar_continuous)
                end

                entry.tap do |e|
                  e.signal_connect('notify::text') { estimate_password_strength }
                end
              end

              links_box.tap do |box|
                box.append(tutorial_link)
                box.append(reference_link)
              end
            end
          end
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.levelbars', :default_flags)
  def continuous_label = @continuous_label ||= Gtk::Label.new('Continuous')
  def discrete_label = @discrete_label ||= Gtk::Label.new('Discrete')
  def label_strength = @label_strength ||= Gtk::Label.new

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Level Bars'
      win.set_default_size(640, 800)
    end
  end

  def css_provider
    @css_provider ||= Gtk::CssProvider.new.tap { |provider| provider.load_from_path(File.join(__dir__, 'main.css')) }
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Level Bars'
      page.description = 'A bar widget used as a level indicator'
    end
  end

  def content_box
    @content_box ||= Gtk::Box.new(:vertical, 0).tap do |box|
      box.margin_top = 24
      box.halign = :center
    end
  end

  def bars_box
    @bars_box ||= Gtk::Box.new(:vertical, 18).tap do |box|
      box.margin_start = 18
      box.margin_end = 18
    end
  end

  def battery_card
    @battery_card ||= Gtk::Box.new(:vertical, 12).tap do |box|
      box.add_css_class('card')
      box.margin_bottom = 24
    end
  end

  def battery_label
    @battery_label ||= Gtk::Label.new('Battery').tap do |label|
      label.halign = :start
      label.margin_start = 12
      label.margin_top = 12
    end
  end

  def bar_continuous
    @bar_continuous ||= Gtk::LevelBar.new.tap do |bar|
      bar.mode = :continuous
      bar.margin_start = 12
      bar.margin_end = 12
      bar.margin_bottom = 24
      bar.min_value = 0
      bar.max_value = 100
      bar.value = 50
      bar.add_offset_value('full', 100)
      bar.add_offset_value('half', 50)
      bar.add_offset_value('low', 25)
    end
  end

  def entry
    @entry ||= Gtk::PasswordEntry.new.tap do |e|
      e.placeholder_text = 'Password'
      e.show_peek_icon = true
    end
  end

  def bar_discrete
    @bar_discrete ||= Gtk::LevelBar.new.tap do |bar|
      bar.mode = :discrete
      bar.min_value = 0
      bar.max_value = 6
      bar.add_offset_value('very-weak', 1)
      bar.add_offset_value('weak', 2)
      bar.add_offset_value('moderate', 4)
      bar.add_offset_value('strong', 6)
    end
  end

  def links_box
    @links_box ||= Gtk::Box.new(:vertical, 0).tap { |box| box.margin_bottom = 24 }
  end

  def tutorial_link
    @tutorial_link ||= Gtk::LinkButton.new(
      'https://developer.gnome.org/documentation/tutorials/beginners/components/level_bar.html'
    ).tap { |btn| btn.label = 'Tutorial' }
  end

  def reference_link
    @reference_link ||= Gtk::LinkButton.new('https://docs.gtk.org/gtk4/class.LevelBar.html').tap do |btn|
      btn.label = 'API Reference'
    end
  end

  private

  def estimate_password_strength
    [(entry.text.length / 2.0).ceil, 6].min.then do |level|
      label_strength.css_classes = []
      STRENGTHS[level].then do |strength|
        label_strength.label = strength ? strength.first : ''
        label_strength.css_classes = strength ? [strength.last] : []
      end
      bar_discrete.value = level
    end
  end
end

LevelBarsDemo.new.build.run
