require 'gtk4'
require 'adwaita'

class ProgressBarDemo
  PULSE_PERIOD = 500
  DURATION = 10_000

  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = status_page

          status_page.tap do |page|
            page.child = content_box

            content_box.tap do |b|
              b.append(first)
              b.append(second)
              b.append(progress_tracker)
              b.append(play)
              b.append(reference_link)
              b.append(hig_link)

              play.tap do |btn|
                btn.signal_connect('clicked') do
                  animation.play
                  update_tracker
                  pulse_progress
                end
              end
            end
          end
        end

        animation.tap do |a|
          a.signal_connect('done') { a.reset }
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.progressbar', :default_flags)
  def content_box = @content_box ||= Gtk::Box.new(:vertical, 0).tap { |box| box.halign = :center }

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Progress Bar'
      win.set_default_size(640, 660)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Progress Bar'
      page.description = 'Display the progress of a long running operation'
    end
  end

  def first
    @first ||= Gtk::ProgressBar.new.tap do |bar|
      bar.fraction = 0.2
      bar.show_text = true
      bar.margin_bottom = 24
    end
  end

  def second
    @second ||= Gtk::ProgressBar.new.tap do |bar|
      bar.inverted = true
      bar.pulse_step = 0.25
      bar.show_text = true
      bar.text = ''
      bar.margin_bottom = 24
    end
  end

  def progress_tracker
    @progress_tracker ||= Gtk::Label.new('').tap { |label| label.margin_bottom = 12 }
  end

  def play
    @play ||= Gtk::Button.new.tap do |btn|
      btn.halign = :center
      btn.margin_bottom = 24
      btn.icon_name = 'media-playback-start-symbolic'
    end
  end

  def target = @target ||= Adwaita::PropertyAnimationTarget.new(first, 'fraction')

  def animation
    @animation ||= Adwaita::TimedAnimation.new(first, 0.2, 1, 11_000, target).tap do |a|
      a.easing = Adwaita::Easing::LINEAR
    end
  end

  def reference_link
    @reference_link ||= Gtk::LinkButton.new('https://docs.gtk.org/gtk4/class.ProgressBar.html').tap do |btn|
      btn.label = 'API Reference'
    end
  end

  def hig_link
    @hig_link ||= Gtk::LinkButton.new(
      'https://developer.gnome.org/hig/patterns/feedback/progress-bars.html'
    ).tap { |btn| btn.label = 'Human Interface Guidelines' }
  end

  private

  def pulse_progress
    counter = 0.0
    increment = PULSE_PERIOD.to_f / DURATION

    GLib::Timeout.add(PULSE_PERIOD) do
      if counter >= 1.0
        second.fraction = 0
        false
      else
        second.pulse
        counter += increment
        true
      end
    end
  end

  def update_tracker
    time = 10

    GLib::Timeout.add(1000) do
      if time.zero?
        progress_tracker.label = ''
        puts 'Operation complete!'
        false
      else
        progress_tracker.label = "#{time} seconds remaining…"
        time -= 1
        true
      end
    end
  end
end

ProgressBarDemo.new.build.run
